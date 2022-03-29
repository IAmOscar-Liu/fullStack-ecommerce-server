import DataLoader from "dataloader";
import mysql from "mysql2/promise";
import { OrderProductDetail } from "../types/Order";

export const createOrderProductLoader = (pool: mysql.Pool) =>
  new DataLoader<number, OrderProductDetail[]>(async (order_ids) => {
    // const poolPromise = pool.promise();
    const [rows] = await pool.query(
      `
        SELECT 
            op.*, 
            p.name AS product_name, 
            p.price AS product_price, 
            p.img_url AS product_img_url
        FROM OrderProduct AS op
            JOIN Product AS p ON op.product_id = p.id
        WHERE 
            op.order_id IN (${order_ids.join(",")})
      `
    );

    const allOrderProducts = rows as OrderProductDetail[];

    return order_ids.map((order_id) =>
      allOrderProducts.filter((op) => op.order_id === order_id)
    );
  });
