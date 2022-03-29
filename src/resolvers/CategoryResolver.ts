import { MyContext } from "src/types";
import { CategoryDetail } from "../types/Category";
import { Resolver, Query, Ctx, ObjectType, Field } from "type-graphql";

@ObjectType()
class CategoryData {
  @Field(() => [CategoryDetail])
  categories: CategoryDetail[];
}

@Resolver()
export class CategoryResolver {
  @Query(() => CategoryData)
  async getAllCategory(@Ctx() { pool }: MyContext): Promise<CategoryData> {
    const [rows] = await pool.query(
      `
        SELECT
          c.*,
          COUNT(c.id) AS number_of_product
        FROM
          CategoryProduct AS cp
          RIGHT JOIN Category AS c ON cp.category_id = c.id
        GROUP BY
          c.id
      `
    );

    return {
      categories: rows as CategoryDetail[],
    };
  }
}
