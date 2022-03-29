import { ObjectType, Field, ID } from "type-graphql";

@ObjectType()
export class Category {
  @Field(() => ID)
  id: number;

  @Field()
  name: string;

  @Field()
  img_url: string;
}

@ObjectType()
export class CategoryDetail extends Category {
  @Field()
  number_of_product: number;
}
