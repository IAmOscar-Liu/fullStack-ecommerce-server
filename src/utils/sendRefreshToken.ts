import { Response } from "express";

/*
  Cookie expires in 1 month (unit: ms)
  However, refresh token will only be valid for 1 day
*/  
const MAX_AGE = 1000 * 60 * 60 * 24 * 30; 

export const sendRefreshToken = (res: Response, refresh_token: string) => {
  res.cookie("ecommerce_refresh_token", refresh_token, {
    maxAge: MAX_AGE,
    httpOnly: true,
    path: "/",
    secure: process.env.NODE_ENV === "production",
  });
};
