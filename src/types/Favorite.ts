import { ObjectType, Field, ID } from "type-graphql";

@ObjectType()
export class Favorite {
  @Field(() => ID)
  id: number;

  @Field(() => ID)
  account_id: number;

  @Field(() => ID)
  product_id: number;

  @Field()
  addedAt: string;
}

@ObjectType()
export class FavoriteDetail extends Favorite {
  @Field()
  product_name: string;

  @Field()
  product_price: number;

  @Field()
  product_img_url: string;

  @Field()
  product_isOnSale: boolean;

  @Field({ nullable: true })
  product_avg_rating: number;

  @Field()
  product_is_available: boolean;
}
