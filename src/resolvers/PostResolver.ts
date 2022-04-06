import {
  Arg,
  Ctx,
  Query,
  Resolver,
  ObjectType,
  Field,
  FieldResolver,
  Root,
  Mutation,
  ID,
  InputType,
  Int,
  UseMiddleware,
  UnauthorizedError,
} from "type-graphql";
import { PostDetail, PostWithAccount } from "../types/Post";
import { MyContext } from "../types";
import { CommentDetail, CommentWithAccount } from "../types/Comment";
import { ResultSetHeader } from "mysql2";
import { isAuth } from "../middleware/isAuth";

@InputType()
class PostInput {
  @Field()
  content: string;

  @Field(() => ID)
  product_id: number;

  @Field(() => ID)
  account_id: number;
}

@InputType()
class PostLikeInput {
  @Field(() => ID)
  post_id: number;

  @Field(() => ID)
  account_id: number;
}

@InputType()
class CommentLikeInput {
  @Field(() => ID)
  comment_id: number;

  @Field(() => ID)
  account_id: number;
}

@InputType()
class CommentInput extends PostLikeInput {
  @Field()
  content: string;
}

@ObjectType()
class PostData {
  @Field(() => [PostDetail], { nullable: true })
  posts: PostDetail[];

  @Field({ nullable: true })
  hasMore?: boolean;
}

@ObjectType()
class NewPostData {
  @Field(() => PostDetail)
  post: PostDetail;
}

@ObjectType()
class NewCommentData {
  @Field(() => CommentDetail)
  comment: CommentDetail;
}

@ObjectType()
class NewPostLikeData {
  @Field()
  postLike: number;
}

@ObjectType()
class NewCommentLikeData {
  @Field()
  commentLike: number;
}

@Resolver(PostDetail)
export class PostResolver {
  @FieldResolver(() => [CommentDetail])
  comments(@Root() post: PostDetail, @Ctx() { commentLoader }: MyContext) {
    return commentLoader.load(post.id);
  }

  @Query(() => Int)
  async getNumOfPostsByProductID(
    @Ctx() { pool }: MyContext,
    @Arg("product_id") product_id: number
  ): Promise<number> {
    const [rows] = await pool.execute(
      `
        SELECT COUNT(*) as num_of_posts
        FROM Post
        WHERE product_id = ?
      `,
      [product_id + ""]
    );

    return (rows as { num_of_posts: number }[])[0].num_of_posts;
  }

  @Query(() => PostData)
  async getPostsByProductID(
    @Ctx() { pool }: MyContext,
    @Arg("product_id") product_id: number,
    @Arg("limit", { defaultValue: process.env.POST_LIMIT }) _limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<PostData> {
    const limit = parseInt(_limit as unknown as string);

    const [rows] = await pool.execute(
      `
        SELECT
          p.*,
          COUNT(pl.post_id) AS likeCount,
          a.name AS account_name,
          a.img_url AS account_img_url
        FROM
          PostLike AS pl
          RIGHT JOIN (
        
            SELECT
              p.*,
              COUNT(c.post_id) AS commentCount
            FROM
              Comment c
              RIGHT JOIN Post p ON p.id = c.post_id
            GROUP BY
              p.id
              
          ) AS p ON p.id = pl.post_id
          INNER JOIN Account AS a ON p.account_id = a.id
        WHERE
          p.product_id = ?
        GROUP BY
          p.id
        ORDER BY
          p.id DESC 
        LIMIT ?, ?     
      `,
      [product_id + "", offset + "", limit + 1 + ""]
    );

    if (
      (rows as PostDetail[]).length ===
      parseInt(limit as unknown as string) + 1
    ) {
      return {
        posts: (rows as PostDetail[]).slice(0, -1),
        hasMore: true,
      };
    }
    return {
      posts: rows as PostDetail[],
      hasMore: false,
    };
  }

  @Query(() => PostData)
  async getMostCommentsPostsByProductID(
    @Ctx() { pool }: MyContext,
    @Arg("product_id") product_id: number,
    @Arg("limit", { defaultValue: process.env.POST_LIMIT }) _limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<PostData> {
    const limit = parseInt(_limit as unknown as string);

    const [rows] = await pool.execute(
      `
        SELECT
          p.*,
          COUNT(pl.post_id) AS likeCount,
          a.name AS account_name,
          a.img_url AS account_img_url
        FROM
          PostLike AS pl
          RIGHT JOIN (
        
            SELECT
              p.*,
              COUNT(c.post_id) AS commentCount
            FROM
              Comment c
              RIGHT JOIN Post p ON Post.id = c.post_id
            GROUP BY
              p.id
              
          ) AS p ON p.id = pl.post_id
          INNER JOIN Account AS a ON p.account_id = a.id
        WHERE
          p.product_id = ?
        GROUP BY
          p.id
        ORDER BY
          p.commentCount DESC,
          p.id DESC  
        LIMIT ?, ?    
      `,
      [product_id + "", offset + "", limit + 1 + ""]
    );

    if (
      (rows as PostDetail[]).length ===
      parseInt(limit as unknown as string) + 1
    ) {
      return {
        posts: (rows as PostDetail[]).slice(0, -1),
        hasMore: true,
      };
    }
    return {
      posts: rows as PostDetail[],
      hasMore: false,
    };
  }

  @Query(() => PostData)
  async getMostLikePostsByProductID(
    @Ctx() { pool }: MyContext,
    @Arg("product_id") product_id: number,
    @Arg("limit", { defaultValue: process.env.POST_LIMIT }) _limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<PostData> {
    const limit = parseInt(_limit as unknown as string);

    const [rows] = await pool.execute(
      `
        SELECT
          p.*,
          COUNT(pl.post_id) AS likeCount,
          a.name AS account_name,
          a.img_url AS account_img_url
        FROM
          PostLike AS pl
          RIGHT JOIN (
        
            SELECT
              p.*,
              COUNT(c.post_id) AS commentCount
            FROM
              Comment c
              RIGHT JOIN Post p ON p.id = c.post_id
            GROUP BY
              p.id
              
          ) AS p ON p.id = pl.post_id
          INNER JOIN Account AS a ON p.account_id = a.id
        WHERE
          p.product_id = ?
        GROUP BY
          p.id
        ORDER BY
          likeCount DESC,
          p.id DESC 
        LIMIT ?, ?     
      `,
      [product_id + "", offset + "", limit + 1 + ""]
    );

    if (
      (rows as PostDetail[]).length ===
      parseInt(limit as unknown as string) + 1
    ) {
      return {
        posts: (rows as PostDetail[]).slice(0, -1),
        hasMore: true,
      };
    }
    return {
      posts: rows as PostDetail[],
      hasMore: false,
    };
  }

  @Mutation(() => NewPostData)
  @UseMiddleware(isAuth)
  async createPost(
    @Ctx() { pool, payload }: MyContext,
    @Arg("postInput") { content, account_id, product_id }: PostInput
  ): Promise<NewPostData> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    const [rows] = await pool.execute(
      `
        INSERT INTO
          Post(content, product_id, account_id)
        VALUES
          (?, ?, ?)
      `,
      [content, product_id + "", account_id + ""]
    );

    const postID = (rows as ResultSetHeader).insertId;

    const [postRows] = await pool.execute(
      `
        SELECT
          p.*,
          a.name AS account_name,
          a.img_url AS account_img_url
        FROM 
          Post AS p
          INNER JOIN Account AS a ON p.account_id = a.id
        WHERE p.id = ?         
      `,
      [postID + ""]
    );

    return {
      post: {
        ...(postRows as PostWithAccount[])[0],
        likeCount: 0,
        commentCount: 0,
        comments: [],
      },
    };
  }

  @Mutation(() => NewCommentData)
  @UseMiddleware(isAuth)
  async createComment(
    @Ctx() { pool, payload }: MyContext,
    @Arg("commentInput") { content, account_id, post_id }: CommentInput
  ): Promise<NewCommentData> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    const [rows] = await pool.execute(
      `
        INSERT INTO
          Comment(content, post_id, account_id)
        VALUES
          (?, ?, ?)
      `,
      [content, post_id + "", account_id + ""]
    );

    const commentID = (rows as ResultSetHeader).insertId;

    const [commentRows] = await pool.execute(
      `
        SELECT
          c.*,
          a.name AS account_name,
          a.img_url AS account_img_url
        FROM 
          Comment AS c
          INNER JOIN Account AS a ON c.account_id = a.id
        WHERE c.id = ?         
      `,
      [commentID + ""]
    );

    return {
      comment: {
        ...(commentRows as CommentWithAccount[])[0],
        commentLikeCount: 0,
      },
    };
  }

  @Mutation(() => NewPostLikeData)
  @UseMiddleware(isAuth)
  async createPostLike(
    @Ctx() { pool, payload }: MyContext,
    @Arg("postLikeInput") { post_id, account_id }: PostLikeInput
  ): Promise<NewPostLikeData> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    await pool.execute(
      `
        INSERT INTO
          PostLike(post_id, account_id)
        VALUES
          (?, ?)
      `,
      [post_id + "", account_id + ""]
    );

    const [likeRow] = await pool.execute(
      `
        SELECT COUNT(*) AS count FROM PostLike WHERE post_id = ?
      `,
      [post_id + ""]
    );

    return {
      postLike: (likeRow as { count: number }[])[0].count,
    };
  }

  @Mutation(() => NewCommentLikeData)
  @UseMiddleware(isAuth)
  async createCommentLike(
    @Ctx() { pool, payload }: MyContext,
    @Arg("commentLikeInput") { comment_id, account_id }: CommentLikeInput
  ): Promise<NewCommentLikeData> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    await pool.execute(
      `
        INSERT INTO
          CommentLike(comment_id, account_id)
        VALUES
          (?, ?)
      `,
      [comment_id + "", account_id + ""]
    );

    const [likeRow] = await pool.execute(
      `
        SELECT COUNT(*) AS count FROM CommentLike WHERE comment_id = ?
      `,
      [comment_id + ""]
    );

    return {
      commentLike: (likeRow as { count: number }[])[0].count,
    };
  }
}
