import { Ctx, Query, Resolver } from "type-graphql";
import {
  Account,
  AccountWithPassword,
  removePasswordField,
} from "../types/Account";
import { MyContext } from "../types";

@Resolver()
export class HelloResolver {
  @Query(() => String)
  hello() {
    return "hello";
  }

  @Query(() => [Account], { nullable: true })
  async getAllAccount(@Ctx() { pool }: MyContext): Promise<Account[]> {
    // const poolPromise = pool.promise();

    const [rows] = await pool.query("SELECT * FROM Account");

    console.log(rows);

    return (rows as AccountWithPassword[]).map((account) =>
      removePasswordField(account)
    );
  }
}
