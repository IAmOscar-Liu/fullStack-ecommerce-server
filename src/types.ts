import { Request, Response } from "express";
import mysql from "mysql2/promise";
import Stripe from "stripe";
import { createBlogCommentLoader } from "./utils/createBlogCommentLoader";
import { createCommentLoader } from "./utils/createCommentLoader";
import { createOrderProductLoader } from "./utils/createOrderProductLoader";

export type MyContext = {
  req: Request & { account_id?: string };
  res: Response;
  pool: mysql.Pool;
  payload?: { account_id: string };
  commentLoader: ReturnType<typeof createCommentLoader>;
  blogCommentLoader: ReturnType<typeof createBlogCommentLoader>;
  orderProductLoader: ReturnType<typeof createOrderProductLoader>;
  stripe: Stripe;
};
