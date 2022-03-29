import DataLoader from "dataloader";
import mysql from "mysql2/promise";
import { CommentDetail } from "../types/Comment";

export const createCommentLoader = (pool: mysql.Pool) =>
  new DataLoader<number, CommentDetail[]>(async (post_ids) => {
    // const poolPromise = pool.promise();
    const [rows] = await pool.query(
      `
        SELECT
            c.*,
            COUNT(cl.comment_id) AS commentLikeCount,
            a.name AS account_name,
            a.img_url AS account_img_url
        FROM
            CommentLike AS cl
            RIGHT JOIN Comment AS c ON c.id = cl.comment_id
            INNER JOIN Account AS a ON c.account_id = a.id
        WHERE
            c.post_id IN (${post_ids.join(",")})
        GROUP BY
            c.id 
        ORDER BY
            c.id DESC
        `
    );

    const allComments = rows as CommentDetail[];

    return post_ids.map((post_id) =>
      allComments.filter((c) => c.post_id === post_id)
    );
  });
