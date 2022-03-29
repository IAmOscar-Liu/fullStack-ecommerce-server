import { ObjectType, Field, ID } from "type-graphql";
import {BlogCommentDetail} from "./BlogComment";

@ObjectType()
export class Blog {
  @Field(() => ID)
  id: number;

  @Field()
  content: string;

  @Field()
  createdAt: string;

  @Field({nullable: true})
  img_url: string;

  @Field(() => ID)
  account_id: number;
}

@ObjectType()
export class BlogWithAccount extends Blog {
  @Field()
  account_name: string;

  @Field()
  account_img_url: string;
}

@ObjectType()
export class BlogDetail extends BlogWithAccount {
  @Field({ nullable: true })
  blogLikeCount: number;

  @Field({ nullable: true })
  blogCommentCount: number;

  @Field(() => [BlogCommentDetail])
  blogComments: BlogCommentDetail[];
}
