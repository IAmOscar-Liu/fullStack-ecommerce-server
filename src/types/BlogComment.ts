import { ObjectType, Field, ID } from "type-graphql";

@ObjectType()
export class BlogComment {
  @Field(() => ID)
  id: number;

  @Field()
  content: string;

  @Field()
  createdAt: string;

  @Field(() => ID)
  blog_id: number;

  @Field(() => ID)
  account_id: number;
}

@ObjectType()
export class BlogCommentWithAccount extends BlogComment {
  @Field()
  account_name: string;

  @Field()
  account_img_url: string;
}

@ObjectType()
export class BlogCommentDetail extends BlogCommentWithAccount {
  @Field()
  blogCommentLikeCount: number;
}
