import { ObjectType, Field, ID } from "type-graphql";
import { CommentDetail } from "./Comment";

@ObjectType()
export class Post {
  @Field(() => ID)
  id: number;

  @Field()
  content: string;

  @Field()
  createdAt: string;

  @Field(() => ID)
  product_id: number;

  @Field(() => ID)
  account_id: number;
}

@ObjectType()
export class PostWithAccount extends Post {
  @Field()
  account_name: string;

  @Field()
  account_img_url: string;
}

@ObjectType()
export class PostDetail extends PostWithAccount {
  @Field({ nullable: true })
  likeCount: number;

  @Field({ nullable: true })
  commentCount: number;

  @Field(() => [CommentDetail])
  comments: CommentDetail[];
}
