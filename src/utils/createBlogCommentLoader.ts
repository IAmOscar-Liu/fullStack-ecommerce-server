import DataLoader from "dataloader";
import mysql from "mysql2/promise";
import { BlogCommentDetail } from "../types/BlogComment";

export const createBlogCommentLoader = (pool: mysql.Pool) =>
  new DataLoader<number, BlogCommentDetail[]>(async (blog_ids) => {
    // const poolPromise = pool.promise();
    const [rows] = await pool.query(
      `
        SELECT
            bc.*,
            COUNT(bcl.blog_comment_id) AS blogCommentLikeCount,
            a.name AS account_name,
            a.img_url AS account_img_url
        FROM
            BlogCommentLike AS bcl
            RIGHT JOIN BlogComment AS bc ON bc.id = bcl.blog_comment_id
            INNER JOIN Account AS a ON bc.account_id = a.id
        WHERE
            bc.blog_id IN (${blog_ids.join(",")})
        GROUP BY
            bc.id
        ORDER BY   
            bc.id DESC
      `
    );

    const allBlogComments = rows as BlogCommentDetail[];

    return blog_ids.map((blog_id) =>
      allBlogComments.filter((c) => c.blog_id === blog_id)
    );
  });
