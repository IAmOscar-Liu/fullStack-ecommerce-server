import bcrypt from "bcryptjs";
import { getStorage, ref } from "firebase/storage";
import { FileUpload, GraphQLUpload } from "graphql-upload";
import {
  Arg,
  Ctx,
  Field,
  ID,
  InputType,
  Mutation,
  ObjectType,
  Query,
  Resolver,
  UnauthorizedError,
  UseMiddleware,
} from "type-graphql";
import { isAuth } from "../middleware/isAuth";
import { MyContext } from "../types";
import {
  AccountBrief,
  AccountDetail,
  AccountWithPassword,
  removePasswordField,
} from "../types/Account";
import { createTokens } from "../utils/createTokens";
import { firebaseUpload } from "../utils/firebaseUpload";
import { getAccessTokenFromAuth } from "../utils/getAccessTokenFromAuth";
import { sendRefreshToken } from "../utils/sendRefreshToken";
import { stream2buffer } from "../utils/stream2buffer";

@InputType()
class UserInput {
  @Field()
  name: string;

  @Field()
  password: string;
}

@InputType()
class ProviderInput {
  @Field()
  provider: string;

  @Field()
  provider_id: string;
}

@InputType()
class UserUpdateData {
  @Field({ nullable: true })
  name?: string;

  @Field({ nullable: true })
  email?: string;

  @Field({ nullable: true })
  img_url?: string;

  @Field({ nullable: true })
  description?: string;

  @Field({ nullable: true })
  phone?: string;

  @Field({ nullable: true })
  address?: string;
}

@InputType()
class UserRegisterInput extends UserInput {
  @Field()
  email: string;
}

@ObjectType()
class NumOfPostAndBlog {
  @Field()
  total_post: number;

  @Field()
  total_blog: number;
}

@ObjectType()
class AccountData {
  @Field(() => [AccountBrief])
  accounts: AccountBrief[];

  @Field()
  hasMore: boolean;
}

@Resolver()
export class AccountResolver {
  @Mutation(() => AccountDetail)
  async providerLogin(
    @Ctx() { res, pool }: MyContext,
    @Arg("providerInput") { provider, provider_id }: ProviderInput
  ): Promise<AccountDetail> {
    const [rows] = await pool.execute(
      `SELECT * FROM Account WHERE provider = ? AND provider_id = ?`,
      [provider, provider_id]
    );

    if ((rows as AccountWithPassword[]).length === 0) return {};

    const account = (rows as AccountWithPassword[])[0];

    const tokens = createTokens(account.id);

    sendRefreshToken(res, tokens.refresh_token);

    return {
      account: removePasswordField(account),
      access_token: tokens.access_token,
    };
  }

  @Mutation(() => AccountDetail)
  async login(
    @Ctx() { res, pool }: MyContext,
    @Arg("userInput", { nullable: true }) { name, password }: UserInput
  ): Promise<AccountDetail> {
    const [rows] = await pool.execute(
      `SELECT * FROM Account WHERE name = ? AND provider = ?`,
      [name, "local"]
    );

    if ((rows as AccountWithPassword[]).length === 0) return {};

    const account = (rows as AccountWithPassword[])[0];
    const valid = await bcrypt.compare(password, account.password);

    // console.log(account.password, password);
    // console.log("valid", valid);

    if (!valid) return {};

    const tokens = createTokens(account.id);

    // For testing refresh token exp
    // const { exp }: any = jwtDecode(tokens.refresh_token);
    // const current_ts = new Date();
    // const ext_ts = new Date(exp * 1000);
    // console.log(
    //   `created at: ${
    //     current_ts.getMonth() + 1
    //   }/${current_ts.getDate()}  ${current_ts.getHours()}:${current_ts.getMinutes()}`
    // );
    // console.log(
    //   `expire at: ${
    //     ext_ts.getMonth() + 1
    //   }/${ext_ts.getDate()}  ${ext_ts.getHours()}:${ext_ts.getMinutes()}`
    // );
    ////////////////////////////////

    sendRefreshToken(res, tokens.refresh_token);

    return {
      account: removePasswordField(account),
      access_token: tokens.access_token,
    };
  }

  @Mutation(() => AccountDetail)
  async register(
    @Ctx() { res, pool }: MyContext,
    @Arg("userRegister") { name, password, email }: UserRegisterInput
  ): Promise<AccountDetail> {
    const hashedPassword = await bcrypt.hash(password, 12);

    const poolTransaction = await pool.getConnection();
    await poolTransaction.beginTransaction();

    try {
      await poolTransaction.execute(
        `
          INSERT INTO
            Account(name, email, password)
          VALUES
            (?, ?, ?)
        `,
        [name, email, hashedPassword]
      );

      await poolTransaction.commit();

      const [userRows] = await pool.execute(
        `SELECT * FROM Account WHERE name = ?`,
        [name]
      );

      const account = (userRows as AccountWithPassword[])[0];

      const tokens = createTokens(account.id);
      sendRefreshToken(res, tokens.refresh_token);

      return {
        account: removePasswordField(account),
        access_token: tokens.access_token,
      };
    } catch (e) {
      await poolTransaction.rollback();
      throw e;
    }
  }

  @Mutation(() => Boolean)
  logout(@Ctx() { res }: MyContext) {
    res.clearCookie("ecommerce_refresh_token");

    return true;
  }

  @Query(() => AccountDetail)
  async me(@Ctx() { pool, req }: MyContext): Promise<AccountDetail> {
    try {
      const { account_id, access_token } = getAccessTokenFromAuth(
        req.headers["authorization"]
      );

      const [rows] = await pool.execute(
        "SELECT * FROM `Account` WHERE `id` = ?",
        [account_id + ""]
      );

      // console.log(rows);

      if ((rows as AccountWithPassword[]).length === 0) return {};

      const account = (rows as AccountWithPassword[])[0];

      return { account: removePasswordField(account), access_token };
    } catch (error) {
      // console.log(error);
      return {};
    }
  }

  @Query(() => AccountDetail)
  async otherUser(
    @Ctx() { pool, req }: MyContext,
    @Arg("account_id", () => ID) account_id: number
  ): Promise<AccountDetail> {
    try {
      getAccessTokenFromAuth(req.headers["authorization"]);

      const [rows] = await pool.execute(
        "SELECT * FROM `Account` WHERE `id` = ?",
        [account_id + ""]
      );

      if ((rows as AccountWithPassword[]).length === 0) return {};

      const account = (rows as AccountWithPassword[])[0];

      return { account: removePasswordField(account) };
    } catch (error) {
      return {};
    }
  }

  @Query(() => NumOfPostAndBlog)
  async getNumOfPostAndBlog(
    @Ctx() { pool }: MyContext,
    @Arg("account_id", () => ID) account_id: number
  ): Promise<NumOfPostAndBlog> {
    const [postTotalRows] = await pool.execute(
      `SELECT COUNT(id) AS total_post FROM Post WHERE account_id = ?`,
      [account_id + ""]
    );

    const [blogTotalRows] = await pool.execute(
      `SELECT COUNT(id) AS total_blog FROM Blog WHERE account_id = ?`,
      [account_id + ""]
    );

    return {
      total_post: (postTotalRows as { total_post: number }[])[0].total_post,
      total_blog: (blogTotalRows as { total_blog: number }[])[0].total_blog,
    };
  }

  @Query(() => AccountData)
  async getRecentAccount(
    @Ctx() { pool }: MyContext,
    @Arg("limit", { defaultValue: process.env.RECENT_ACCOUNT_LIMIT })
    _limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<AccountData> {
    const limit = parseInt(_limit as unknown as string);

    const [rows] = await pool.execute(
      `
        SELECT id, name, img_url, createdAt, updateAt 
        FROM Account
        ORDER BY id DESC
        LIMIT ?, ?
      `,
      [offset + "", limit + 1 + ""]
    );

    if ((rows as AccountBrief[]).length === limit + 1) {
      return {
        accounts: (rows as AccountBrief[]).slice(0, -1),
        hasMore: true,
      };
    }

    return {
      accounts: rows as AccountBrief[],
      hasMore: false,
    };
  }

  @Mutation(() => AccountDetail)
  @UseMiddleware(isAuth)
  async updateUser(
    @Ctx() { pool, payload }: MyContext,
    @Arg("account_id", () => ID) account_id: number,
    @Arg("userUpdateData") userUpdateData: UserUpdateData,
    @Arg("user_img", () => GraphQLUpload, { nullable: true }) file: FileUpload
  ): Promise<AccountDetail> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    const poolTransaction = await pool.getConnection();
    await poolTransaction.beginTransaction();

    try {
      // If file exists, upload file to fireStorage
      if (file) {
        const { createReadStream, filename, mimetype } = file;
        const stream = createReadStream();

        const buffer: Buffer = await stream2buffer(stream);

        const storage = getStorage();
        const storageRef = ref(storage, `user/user_${account_id}/${filename}`);

        userUpdateData.img_url = (
          await firebaseUpload({ storageRef, buffer, mimetype })
        ).img_url;
      }

      const updateStrings = Object.entries(userUpdateData)
        .filter((entry) => entry[1] !== null)
        .map((entry) => `${entry[0]} = "${entry[1]}"`);

      if (updateStrings.length === 0) return {};

      await poolTransaction.execute(
        `
          UPDATE Account
          SET 
            ${updateStrings.join(", ")}
          WHERE id = ?
        `,
        [account_id + ""]
      );

      const [userRows] = await poolTransaction.execute(
        `SELECT * FROM Account WHERE id = ?`,
        [account_id + ""]
      );

      await poolTransaction.commit();

      const account = (userRows as AccountWithPassword[])[0];
      return { account: removePasswordField(account) };
    } catch (e) {
      await poolTransaction.rollback();
      throw e;
    }
  }
}
