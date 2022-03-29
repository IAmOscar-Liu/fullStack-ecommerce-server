import { ObjectType, Field, ID } from "type-graphql";

@ObjectType()
export class Comment {
  @Field(() => ID)
  id: number;

  @Field()
  content: string;

  @Field()
  createdAt: string;

  @Field(() => ID)
  post_id: number;

  @Field(() => ID)
  account_id: number;
}

@ObjectType()
export class CommentWithAccount extends Comment {
  @Field()
  account_name: string;

  @Field()
  account_img_url: string;
}

@ObjectType()
export class CommentDetail extends CommentWithAccount {
  @Field()
  commentLikeCount: number;
}
