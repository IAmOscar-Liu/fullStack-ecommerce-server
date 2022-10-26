import { ResultSetHeader } from "mysql2";
import {
  Arg,
  Ctx,
  Field,
  Int,
  Mutation,
  ObjectType,
  Query,
  Resolver,
  UnauthorizedError,
  UseMiddleware,
} from "type-graphql";
import { isAuth } from "../middleware/isAuth";
import { MyContext } from "../types";
import { FavoriteDetail } from "../types/Favorite";
import { getAccessTokenFromAuth } from "../utils/getAccessTokenFromAuth";

@ObjectType()
class FavoriteData {
  @Field(() => [FavoriteDetail], { nullable: true })
  favorites: FavoriteDetail[];
}

@Resolver()
export class FavoriteResolver {
  @Query(() => FavoriteData, { nullable: true })
  async getFavoriteByAccountID(
    @Ctx() { req, pool }: MyContext,
    @Arg("account_id") account_id: number
  ): Promise<FavoriteData> {
    const authorization = req.headers["authorization"];

    if (!authorization) throw new UnauthorizedError();

    try {
      const { account_id: accountIDFromAccessToken } =
        getAccessTokenFromAuth(authorization);

      if (accountIDFromAccessToken + "" !== account_id + "")
        return { favorites: [] };

      const [rows] = await pool.execute(
        `
            SELECT
                f.*,
                p.name AS product_name,
                p.price AS product_price,
                p.img_url AS product_img_url,
                p.isOnSale AS product_isOnSale,
                p.avg_rating AS product_avg_rating,
                p.isAvailable AS product_is_available
            FROM
                Account AS a
                LEFT JOIN Favorite AS f ON a.id = f.account_id
                INNER JOIN (

                    SELECT
                        p.*,
                        AVG(r.score) AS avg_rating
                    FROM
                        Product p
                        LEFT JOIN Rate r ON r.product_id = p.id
                    GROUP BY
                        p.id

                ) AS p ON f.product_id = p.id
            WHERE
                a.id = ?  
            ORDER BY
               f.id DESC          
        `,
        [account_id + ""]
      );

      // console.log(rows);

      return {
        favorites: rows as FavoriteDetail[],
      };
    } catch (error) {
      // console.log(error);
      return { favorites: [] };
    }
  }

  @Query(() => Int, { nullable: true })
  async getNumberOfFavoriteByAccountID(
    @Ctx() { req, pool }: MyContext,
    @Arg("account_id") account_id: number
  ): Promise<number | null> {
    const authorization = req.headers["authorization"];

    if (!authorization) return null;

    try {
      const { account_id: accountIDFromAccessToken } =
        getAccessTokenFromAuth(authorization);

      if (accountIDFromAccessToken + "" !== account_id + "") return null;

      const [favRows] = await pool.execute(
        `
        SELECT COUNT(*) AS num_of_fav FROM Favorite WHERE account_id = ?
      `,
        [account_id + ""]
      );

      const numberOfFav = (favRows as { num_of_fav: number }[])[0];

      return numberOfFav.num_of_fav;
    } catch (error) {
      // console.log(error)
      return null;
    }
  }

  @Mutation(() => Boolean)
  @UseMiddleware(isAuth)
  async createFavoriteProduct(
    @Ctx() { pool, req }: MyContext,
    @Arg("product_id") product_id: number,
    @Arg("account_id") account_id: number
  ): Promise<boolean> {
    if (account_id + "" !== req.account_id + "") throw new UnauthorizedError();

    try {
      await pool.execute(
        `
          INSERT INTO
            Favorite(product_id, account_id)
          VALUES
            (?, ?)
        `,
        [product_id + "", account_id + ""]
      );

      return true;
    } catch (error) {
      throw error;
    }
  }

  @Mutation(() => Boolean)
  @UseMiddleware(isAuth)
  async deleteFavoriteProduct(
    @Ctx() { pool, req }: MyContext,
    @Arg("product_id") product_id: number,
    @Arg("account_id") account_id: number
  ): Promise<boolean> {
    if (account_id + "" !== req.account_id + "") throw new UnauthorizedError();

    try {
      const [rows] = await pool.execute(
        `
        DELETE FROM Favorite
        WHERE product_id = ? AND account_id = ?
        `,
        [product_id + "", account_id + ""]
      );

      // console.log('delete account_id: ', account_id, ", product_id: ", product_id);

      // console.log(rows);

      if ((rows as ResultSetHeader).affectedRows !== 1) return false;

      return true;
    } catch (error) {
      throw error;
    }
  }
}
