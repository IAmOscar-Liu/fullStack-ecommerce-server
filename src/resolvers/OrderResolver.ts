import { ResultSetHeader } from "mysql2";
import { isAuth } from "../middleware/isAuth";
import {
  Arg,
  Ctx,
  Query,
  Resolver,
  ObjectType,
  Field,
  FieldResolver,
  Root,
  Mutation,
  InputType,
  ID,
  UseMiddleware,
  UnauthorizedError,
} from "type-graphql";
import { MyContext } from "../types";
import { OrderDetail, OrderProductDetail, RecentOrder } from "../types/Order";
import { Product } from "../types/Product";
import { UserInputError, ValidationError } from "apollo-server-express";

@InputType()
class OrderProductInput {
  @Field(() => ID)
  product_id: number;

  @Field()
  quantity: number;
}

@InputType()
class OrderInput {
  @Field(() => ID)
  account_id: number;

  @Field(() => [OrderProductInput])
  products: OrderProductInput[];
}

@ObjectType()
class OrderData {
  @Field(() => [OrderDetail], { nullable: true })
  orders: OrderDetail[];

  @Field({ nullable: true })
  hasMore?: boolean;

  @Field({ nullable: true })
  total?: number;
}

@ObjectType()
class OrderResult {
  @Field(() => OrderDetail, { nullable: true })
  order?: OrderDetail;

  @Field({ nullable: true })
  session_id?: string;

  @Field({ nullable: true })
  amount_total?: number;
}

@ObjectType()
class RecentOrderData {
  @Field(() => [RecentOrder])
  recentOrder: RecentOrder[];

  @Field()
  hasMore: boolean;
}

@ObjectType()
class NumOfUserProductOrderBlog {
  @Field()
  total_user: number;

  @Field()
  total_product: number;

  @Field()
  total_order: number;

  @Field()
  total_blog: number;
}

@Resolver(OrderDetail)
export class OrderResolver {
  @FieldResolver(() => [OrderProductDetail])
  products(
    @Root() order: OrderDetail,
    @Ctx() { orderProductLoader }: MyContext
  ) {
    return orderProductLoader.load(order.id);
  }

  @Query(() => OrderData)
  async getOrdersByAccountID(
    @Ctx() { pool }: MyContext,
    @Arg("account_id") account_id: number,
    @Arg("limit", { defaultValue: process.env.PERSONAL_ORDER_LIMIT })
    _limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<OrderData> {
    const limit = parseInt(_limit as unknown as string);

    const [totalRows] = await pool.execute(
      `SELECT COUNT(id) AS total_order FROM MyOrder WHERE account_id = ?`,
      [account_id + ""]
    );

    const total = (totalRows as { total_order: number }[])[0].total_order;

    if (total === 0)
      return {
        orders: [],
        hasMore: false,
        total,
      };

    const [rows] = await pool.execute(
      `
        SELECT * FROM MyOrder 
        WHERE account_id = ? 
        ORDER BY id DESC
        LIMIT ?, ? 
      `,
      [account_id + "", offset + "", limit + 1 + ""]
    );

    if ((rows as OrderDetail[]).length === limit + 1) {
      return {
        orders: (rows as OrderDetail[]).slice(0, -1),
        hasMore: true,
        total,
      };
    }

    return {
      orders: rows as OrderDetail[],
      hasMore: false,
      total,
    };
  }

  @Query(() => RecentOrderData)
  async getRecentOrderProducts(
    @Ctx() { pool }: MyContext,
    @Arg("limit", { defaultValue: process.env.RECENT_ORDER_LIMIT })
    _limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<RecentOrderData> {
    const limit = parseInt(_limit as unknown as string);

    const [rows] = await pool.execute(
      `
          SELECT 
            op.id AS id, 
            p.id AS product_id, 
            p.name AS product_name, 
            p.price AS product_price, 
            p.img_url AS product_img_url, 
            op.payment, op.status 
          FROM OrderProduct AS op
          JOIN Product AS p
          WHERE op.product_id = p.id
          ORDER BY id DESC
          LIMIT ?, ?
        `,
      [offset + "", limit + 1 + ""]
    );

    if ((rows as RecentOrder[]).length === limit + 1) {
      return {
        recentOrder: (rows as RecentOrder[]).slice(0, -1),
        hasMore: true,
      };
    }

    return {
      recentOrder: rows as RecentOrder[],
      hasMore: false,
    };
  }

  @Query(() => NumOfUserProductOrderBlog)
  async getNumOfUserProductOrderBlog(
    @Ctx() { pool }: MyContext
  ): Promise<NumOfUserProductOrderBlog> {
    const [totalUserRows] = await pool.query(
      `SELECT COUNT(id) AS total_account FROM Account`
    );
    const [totalProductRows] = await pool.query(
      `SELECT COUNT(id) AS total_product FROM Product`
    );
    const [totalOrderProductRows] = await pool.query(
      `SELECT COUNT(id) AS total_order_product FROM OrderProduct WHERE payment = 'Succeeded'`
    );
    const [totalBlogRows] = await pool.query(
      `SELECT COUNT(id) AS total_blog FROM Blog`
    );

    return {
      total_user: (totalUserRows as { total_account: number }[])[0]
        .total_account,
      total_product: (totalProductRows as { total_product: number }[])[0]
        .total_product,
      total_order: (
        totalOrderProductRows as { total_order_product: number }[]
      )[0].total_order_product,
      total_blog: (totalBlogRows as { total_blog: number }[])[0].total_blog,
    };
  }

  @Mutation(() => OrderResult, { nullable: true })
  @UseMiddleware(isAuth)
  async createOrder(
    @Ctx() { pool, stripe, payload }: MyContext,
    @Arg("orderInput") { account_id, products }: OrderInput
  ): Promise<OrderResult | null> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    if (products.length === 0)
      throw new UserInputError("Products are not provided.");

    const [productRows] = await pool.query(
      `
        SELECT * FROM Product 
        WHERE id IN(${products.map((p) => p.product_id).join(", ")})
        AND isAvailable = true
      `
    );

    const productsInfo = productRows as Product[];

    if (productsInfo.length !== products.length)
      throw new UserInputError(
        "At least one of the products are unavailable or not existed."
      );
    const quantities = products
      .sort((a, b) => a.product_id - b.product_id)
      .map((p) => p.quantity);

    // console.log("creating session");

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      metadata: {
        account_id: account_id + "",
      },
      mode: "payment",
      success_url: `${process.env.FRONT_END_CHECKOUT_SUCCESS_URL}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${process.env.FRONT_END_CART_URL}?cancel_session_id={CHECKOUT_SESSION_ID}`,
      line_items: productsInfo.map((p, pIdx) => ({
        price_data: {
          currency: "usd",
          product_data: {
            name: p.name,
            images: [p.img_url.split("<br/>")[0]],
          },
          unit_amount: parseInt(p.price * 100 + ""),
        },
        quantity: quantities[pIdx],
      })),
    });

    // console.log("session created");
    // console.log(session);

    const poolTransaction = await pool.getConnection();
    await poolTransaction.beginTransaction();

    try {
      const [rows] = await poolTransaction.execute(
        `
          INSERT INTO
            MyOrder(account_id, session_id)
          VALUES 
            (?, ?)
        `,
        [account_id + "", session.id]
      );

      const orderID = (rows as ResultSetHeader).insertId;

      await poolTransaction.execute(
        `
          INSERT INTO
            OrderProduct(quantity, product_id, order_id)
          VALUES
            ${products
              .map(
                (product) =>
                  "(" +
                  product.quantity +
                  "," +
                  product.product_id +
                  "," +
                  orderID +
                  ")"
              )
              .join(", ")}
        `,
        [orderID + ""]
      );

      await poolTransaction.commit();

      // const [orderRows] = await pool.execute(
      //   `SELECT * FROM MyOrder WHERE id = ?`,
      //   [orderID]
      // );

      return {
        session_id: session.id,
      };
    } catch (e) {
      await poolTransaction.rollback();
      throw e;
    }
  }

  @Mutation(() => OrderResult, { nullable: true })
  @UseMiddleware(isAuth)
  async confirmOrder(
    @Ctx() { pool, stripe, payload }: MyContext,
    @Arg("account_id", () => ID) account_id: number,
    @Arg("session_id") session_id: string
  ): Promise<OrderResult | null> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    const [orderRows] = await pool.execute(
      `SELECT * FROM MyOrder WHERE session_id = ?`,
      [session_id]
    );

    const orderRowsResult = orderRows as OrderDetail[];
    if (orderRowsResult.length === 0)
      throw new ValidationError("Checkout session doesn't exist.");

    // console.log("Get session");
    const session = await stripe.checkout.sessions.retrieve(session_id);

    if (session.payment_status === "paid") {
      await pool.execute(
        `
           UPDATE OrderProduct
           SET payment = 'Succeeded', status = 'In Progress'
           WHERE order_id = ?
         `,
        [orderRowsResult[0].id + ""]
      );

      return {
        session_id: session.id,
        amount_total: session.amount_total ?? undefined,
      };
    } else {
      throw new Error("The payment wasn't successful, please call support");
    }
  }

  @Mutation(() => Boolean)
  @UseMiddleware(isAuth)
  async cancelOrder(
    @Ctx() { pool, payload }: MyContext,
    @Arg("account_id", () => ID) account_id: number,
    @Arg("session_id") session_id: string,
    @Arg("payment", { defaultValue: "Incomplete" }) payment: string
  ): Promise<boolean> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    if (payment !== "Incomplete" && payment !== "Failed")
      throw new UserInputError(
        "The value of 'payment' should be 'Cancel' or 'Failed'."
      );

    const [orderRows] = await pool.execute(
      `SELECT * FROM MyOrder WHERE session_id = ?`,
      [session_id]
    );

    const orderRowsResult = orderRows as OrderDetail[];
    if (orderRowsResult.length === 0) return false;

    await pool.execute(
      `
          UPDATE OrderProduct
          SET status = 'Cancel' ${
            payment === "Failed" ? `, payment = 'Failed'` : ""
          }
          WHERE order_id = ?
        `,
      [orderRowsResult[0].id + ""]
    );

    return true;
  }
}
