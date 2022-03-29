import { sign } from "jsonwebtoken";

export const createTokens = (account_id: number) => {
  const access_token = sign({ account_id }, process.env.ACCESS_TOKEN_SECRET, {
    expiresIn: "15m",
  });

  const refresh_token = sign({ account_id }, process.env.REFRESH_TOKEN_SECRET, {
    expiresIn: "24h",
  });

  return { access_token, refresh_token };
};
