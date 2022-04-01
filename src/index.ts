import { ApolloServer } from "apollo-server-express";
import cookieParser from "cookie-parser";
import cors from "cors";
import "dotenv-safe/config";
import express from "express";
import { FirebaseOptions, getApps, initializeApp } from "firebase/app";
import { graphqlUploadExpress } from "graphql-upload";
import { verify } from "jsonwebtoken";
import mysql from "mysql2/promise";
import passport from "passport";
import Stripe from "stripe";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import "reflect-metadata";
import { buildSchema } from "type-graphql";
import { AccountResolver } from "./resolvers/AccountResolver";
import { BlogResolver } from "./resolvers/BlogResolver";
import { CategoryResolver } from "./resolvers/CategoryResolver";
import { FavoriteResolver } from "./resolvers/FavoriteResolver";
import { OrderResolver } from "./resolvers/OrderResolver";
import { PostResolver } from "./resolvers/PostResolver";
import { ProductResolver } from "./resolvers/ProductResolver";
import { createBlogCommentLoader } from "./utils/createBlogCommentLoader";
import { createCommentLoader } from "./utils/createCommentLoader";
import { createOrderProductLoader } from "./utils/createOrderProductLoader";
import { createTokens } from "./utils/createTokens";
import { handleGoogleLogin } from "./utils/handleGoogleLogin";
import { sendRefreshToken } from "./utils/sendRefreshToken";

const firebaseConfig: FirebaseOptions = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTHDOMAIN,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.FIREBASE_APP_ID,
  measurementId: process.env.FIREBASE_MEASUREMENT_ID,
};

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {apiVersion: '2020-08-27'});

const main = async () => {
  const pool = mysql.createPool({
    host: process.env.DATABASE_HOST,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    database: process.env.DATABASE_NAME,
    port: parseInt(process.env.DATABASE_PORT),
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
  });

  // const [rows] = await pool.query('SELECT name from Account')
  // console.log(`Accounts: ${(rows as any[]).map(r => r.name)}`)

  if (!getApps.length) {
    initializeApp(firebaseConfig);
  }

  const apolloServer = new ApolloServer({
    uploads: false,
    schema: await buildSchema({
      resolvers: [
        AccountResolver,
        CategoryResolver,
        ProductResolver,
        PostResolver,
        FavoriteResolver,
        BlogResolver,
        OrderResolver,
      ],
    }),
    context: ({ req, res }: any) => ({
      req,
      res,
      pool,
      commentLoader: createCommentLoader(pool),
      blogCommentLoader: createBlogCommentLoader(pool),
      orderProductLoader: createOrderProductLoader(pool),
      stripe,
    }),
  });

  passport.use(
    new GoogleStrategy(
      {
        clientID: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        callbackURL: process.env.GOOGLE_CALLBACK_URL,
      },
      async (_accessToken, _refreshToken, profile, done) => {
        try {
          await handleGoogleLogin(pool, {
            name: profile.displayName,
            email: "YOUR_EMAIL@example.com",
            img_url: profile.photos?.[0].value || "/images/default_user.png",
            provider: "google",
            provider_id: profile.id,
          });
          console.log("fetch profile success");
          return done(null, { provider: "google", provider_id: profile.id });
        } catch (e) {
          console.log("fetch profile error - ", e);
          return done(e, undefined);
        }
      }
    )
  );

  const app = express();

  app.use(cookieParser());
  app.use(
    cors({
      origin: process.env.CORS_ORIGIN,
      credentials: true,
    })
  );

  app.use(graphqlUploadExpress({ maxFileSize: 10000000, maxFiles: 10 }));
  app.use(passport.initialize());
  // app.use(passport.session());

  app.get(
    "/auth/google/login",
    passport.authenticate("google", { scope: ["profile"] })
  );

  app.get(
    "/auth/google/callback",
    passport.authenticate("google", {
      failureRedirect: `${process.env.FRONT_END_REDIRECT}?failure=true`,
      session: false,
    }),
    async (req, res) => {
      // Successful authentication, redirect home.
      res.redirect(
        `${process.env.FRONT_END_REDIRECT}?provider=${
          (req.user as any).provider
        }&provider_id=${(req.user as any).provider_id}`
      );
    }
  );

  app.post("/refresh_token", async (req, res) => {
    // console.log("refresh_token get cookies");
    // console.log(req.cookies);

    const refresh_token = req.cookies["ecommerce_refresh_token"];

    if (!refresh_token) {
      return res.send({
        ok: false,
        errorMessage: "Refresh token doesn't exist",
      });
    }

    // // For testing refresh token exp
    // const { exp }: any = jwtDecode(refresh_token);
    // const current_ts = new Date();
    // const ext_ts = new Date(exp * 1000);
    // console.log("old refresh_token: ", refresh_token);
    // console.log(
    //   `now: ${
    //     current_ts.getMonth() + 1
    //   }/${current_ts.getDate()}  ${current_ts.getHours()}:${current_ts.getMinutes()}`
    // );
    // console.log(
    //   `expire at: ${
    //     ext_ts.getMonth() + 1
    //   }/${ext_ts.getDate()}  ${ext_ts.getHours()}:${ext_ts.getMinutes()}`
    // );
    ////////////////////////////////

    let payload_account_id: number;
    try {
      const payload: any = verify(
        refresh_token,
        process.env.REFRESH_TOKEN_SECRET
      );
      payload_account_id = parseInt(payload.account_id);
      if (!payload_account_id) throw Error("Invalid refresh token");
    } catch (error) {
      console.log("refresh token error - ", error);
      return res.send({ ok: false, errorMessage: "Invalid refresh token" });
    }

    // find user by userId stored in token
    const [userRows] = await pool.execute(
      `SELECT id FROM Account WHERE id = ?`,
      [payload_account_id]
    );
    const account_id = (userRows as { id: number }[])[0]?.id;

    if (!account_id) {
      return res.send({ ok: false, errorMessage: "Cannot find account" });
    }

    const tokens = createTokens(account_id);

    // console.log("new refresh token ", tokens.refresh_token);
    // console.log("log on ", new Date().toLocaleTimeString());

    sendRefreshToken(res, tokens.refresh_token);

    return res.send({ ok: true, access_token: tokens.access_token });
  });

  apolloServer.applyMiddleware({ app, cors: false });

  app.listen(process.env.PORT, () => {
    console.log(
      `server started on http://localhost:${process.env.PORT}/graphql`
    );
  });
};

main();
