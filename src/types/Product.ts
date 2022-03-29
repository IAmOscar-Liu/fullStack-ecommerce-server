import { ObjectType, Field, ID } from "type-graphql";
import { Category } from "./Category";

@ObjectType()
export class ProductBrief {
  @Field(() => ID)
  id: number;

  @Field()
  name: string;

  @Field()
  img_url: string;

  @Field()
  price: number;

  @Field()
  isOnSale: boolean;

  @Field({ nullable: true })
  avg_rating?: number;

  @Field({ nullable: true })
  rating_times?: number;

  @Field({ nullable: true })
  total_order_count?: number;

  @Field()
  isAvailable: boolean;
}

@ObjectType()
export class Product extends ProductBrief {
  @Field()
  description: string;

  @Field()
  addedAt: string;

  @Field()
  updateAt: string;

  @Field(() => ID)
  createdBy: number;
}

@ObjectType()
export class ProductWithAccount extends Product {
  @Field(() => ID)
  account_id: number;

  @Field()
  account_name: string;

  @Field()
  account_img_url: string;
}

@ObjectType()
export class ProductDetail extends ProductWithAccount {
  @Field(() => [Category], { nullable: true })
  categories: Category[];

  @Field(() => [ProductBrief], {nullable: true})
  simularProducts: ProductBrief[]; 
}

@ObjectType()
export class NumberOfProductAllTypes {
  @Field()
  popular: number;

  @Field()
  topRated: number;

  @Field()
  onSale: number;

  @Field()
  all: number;
}
