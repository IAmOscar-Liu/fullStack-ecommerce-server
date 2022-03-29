import { verify } from "jsonwebtoken";

export const getAccessTokenFromAuth = (authorization: string | undefined) => {
  if (!authorization) {
    return {};
  }

  const access_token = authorization.split(" ")[1];

  const account_id: number = (
    verify(access_token, process.env.ACCESS_TOKEN_SECRET) as any
  ).account_id as number;

  return {account_id, access_token};
};
