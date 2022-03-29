import { MiddlewareFn, UnauthorizedError } from "type-graphql";
import { MyContext } from "../types";
import { verify } from "jsonwebtoken";

export const isAuth: MiddlewareFn<MyContext> = async ({ context }, next) => {
  const authorization = context.req.headers["authorization"];

  if (!authorization) {
    throw new UnauthorizedError();
  }

  try {
    const token = authorization.split(" ")[1];
    const payload: any = verify(token, process.env.ACCESS_TOKEN_SECRET);
    context.payload = { account_id: payload.account_id };
  } catch (error) {
    console.log(error);
    throw new UnauthorizedError();
  }

  return next();
};
