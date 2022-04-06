import {
  Ctx,
  Query,
  Resolver,
  ObjectType,
  Field,
  FieldResolver,
  Root,
  InputType,
  ID,
  Mutation,
  Arg,
  UseMiddleware,
  UnauthorizedError,
  Int,
} from "type-graphql";
import { BlogDetail, BlogWithAccount } from "../types/Blog";
import { MyContext } from "../types";
import {
  BlogCommentDetail,
  BlogCommentWithAccount,
} from "../types/BlogComment";
import { ResultSetHeader } from "mysql2";
import { FileUpload, GraphQLUpload } from "graphql-upload";
import { isAuth } from "../middleware/isAuth";
import { getStorage, ref } from "firebase/storage";
import { stream2buffer } from "../utils/stream2buffer";
import { firebaseUpload } from "../utils/firebaseUpload";

@InputType()
class BlogInput {
  @Field()
  content: string;

  @Field(() => ID)
  account_id: number;
}

@InputType()
class BlogLikeInput {
  @Field(() => ID)
  blog_id: number;

  @Field(() => ID)
  account_id: number;
}

@InputType()
class BlogCommentInput extends BlogLikeInput {
  @Field()
  content: string;
}

@InputType()
class BlogCommentLikeInput {
  @Field(() => ID)
  blog_comment_id: number;

  @Field(() => ID)
  account_id: number;
}

@ObjectType()
class BlogData {
  @Field(() => [BlogDetail], { nullable: true })
  blogs: BlogDetail[];

  @Field({ nullable: true })
  hasMore?: boolean;
}

@ObjectType()
class NewBlogData {
  @Field(() => BlogDetail)
  blog: BlogDetail;
}

@ObjectType()
class NewBlogCommentData {
  @Field(() => BlogCommentDetail)
  blogComment: BlogCommentDetail;
}

@ObjectType()
class NewBlogLikeData {
  @Field()
  blogLike: number;
}

@ObjectType()
class NewBlogCommentLikeData {
  @Field()
  blogCommentLike: number;
}

@Resolver(BlogDetail)
export class BlogResolver {
  @FieldResolver(() => [BlogCommentDetail])
  blogComments(
    @Root() blog: BlogDetail,
    @Ctx() { blogCommentLoader }: MyContext
  ) {
    return blogCommentLoader.load(blog.id);
  }

  @Query(() => Int)
  async getNumOfBlogs(@Ctx() { pool }: MyContext): Promise<number> {
    const [rows] = await pool.query(
      `
        SELECT COUNT(*) AS num_of_blog FROM Blog
      `
    );

    return (rows as { num_of_blog: number }[])[0].num_of_blog;
  }

  @Query(() => BlogData)
  async getAllBlogs(
    @Ctx() { pool }: MyContext,
    @Arg("limit", { defaultValue: process.env.BLOG_LIMIT }) _limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<BlogData> {
    const limit = parseInt(_limit as unknown as string);

    const [rows] = await pool.execute(
      `
        SELECT
            b.*,
            COUNT(bc.blog_id) AS blogCommentCount,
            a.name AS account_name,
            a.img_url AS account_img_url
        FROM
            BlogComment AS bc
            RIGHT JOIN (
            
                SELECT
                    b.*,
                    COUNT(bl.blog_id) blogLikeCount
                FROM
                    BlogLike bl 
                    RIGHT JOIN Blog b ON b.id = bl.blog_id
                GROUP BY
                    b.id
            
            ) AS b ON b.id = bc.blog_id
            INNER JOIN Account AS a ON b.account_id = a.id
        GROUP BY
            b.id
        ORDER BY
            b.id DESC
        LIMIT ?, ?    
        `,
      [offset + "", limit + 1 + ""]
    );

    if ((rows as BlogDetail[]).length === limit + 1) {
      return {
        blogs: (rows as BlogDetail[]).slice(0, -1),
        hasMore: true,
      };
    }

    return {
      blogs: rows as BlogDetail[],
      hasMore: false,
    };
  }

  @Query(() => BlogData)
  async getMostCommentsBlog(
    @Ctx() { pool }: MyContext,
    @Arg("limit", { defaultValue: process.env.BLOG_LIMIT }) _limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<BlogData> {
    const limit = parseInt(_limit as unknown as string);

    const [rows] = await pool.execute(
      `
        SELECT
            b.*,
            COUNT(bc.blog_id) AS blogCommentCount,
            a.name AS account_name,
            a.img_url AS account_img_url
        FROM
            BlogComment AS bc
            RIGHT JOIN (
            
              SELECT
                  b.*,
                  COUNT(bl.blog_id) blogLikeCount
              FROM
                  BlogLike bl 
                  RIGHT JOIN Blog b ON b.id = bl.blog_id
              GROUP BY
                  b.id
            
            ) AS b ON b.id = bc.blog_id
            INNER JOIN Account AS a ON b.account_id = a.id
        GROUP BY
            b.id
        ORDER BY
            blogCommentCount DESC,
            b.id DESC
        LIMIT ?, ?    
      `,
      [offset + "", limit + 1 + ""]
    );

    if (
      (rows as BlogDetail[]).length ===
      parseInt(limit as unknown as string) + 1
    ) {
      return {
        blogs: (rows as BlogDetail[]).slice(0, -1),
        hasMore: true,
      };
    }

    return {
      blogs: rows as BlogDetail[],
      hasMore: false,
    };
  }

  @Query(() => BlogData)
  async getMostLikeBlog(
    @Ctx() { pool }: MyContext,
    @Arg("limit", { defaultValue: process.env.BLOG_LIMIT }) _limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<BlogData> {
    const limit = parseInt(_limit as unknown as string);

    const [rows] = await pool.execute(
      `
        SELECT
            b.*,
            COUNT(bc.blog_id) AS blogCommentCount,
            a.name AS account_name,
            a.img_url AS account_img_url
        FROM
            BlogComment AS bc
            RIGHT JOIN (
      
              SELECT
                  b.*,
                  COUNT(bl.blog_id) blogLikeCount
              FROM
                  BlogLike bl 
                  RIGHT JOIN Blog b ON b.id = bl.blog_id
              GROUP BY
                  b.id
            
            ) AS b ON b.id = bc.blog_id
            INNER JOIN Account AS a ON b.account_id = a.id
        GROUP BY
            b.id
        ORDER BY
            b.blogLikeCount DESC,
            b.id DESC
        LIMIT ?, ?       
      `,
      [offset + "", limit + 1 + ""]
    );

    if ((rows as BlogDetail[]).length === limit + 1) {
      return {
        blogs: (rows as BlogDetail[]).slice(0, -1),
        hasMore: true,
      };
    }

    return {
      blogs: rows as BlogDetail[],
      hasMore: false,
    };
  }

  @Mutation(() => NewBlogData, { nullable: true })
  @UseMiddleware(isAuth)
  async createBlog(
    @Ctx() { pool, payload }: MyContext,
    @Arg("blogInput") { content, account_id }: BlogInput,
    @Arg("user_img", () => GraphQLUpload, { nullable: true }) file: FileUpload
  ): Promise<NewBlogData> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    const poolTransaction = await pool.getConnection();
    await poolTransaction.beginTransaction();

    try {
      const [rows] = await poolTransaction.execute(
        `
        INSERT INTO
          Blog(content, account_id)
        VALUES
          (?, ?)    
      `,
        [content, account_id]
      );

      const blogID = (rows as ResultSetHeader).insertId;

      let img_url = "";
      if (file) {
        const { createReadStream, filename, mimetype } = file;
        const stream = createReadStream();

        const buffer: Buffer = await stream2buffer(stream);

        const storage = getStorage();
        const storageRef = ref(storage, `blog/blog_${blogID}/${filename}`);

        img_url = (await firebaseUpload({ storageRef, buffer, mimetype }))
          .img_url;
      }

      if (img_url)
        await poolTransaction.execute(
          `
          UPDATE Blog 
          SET img_url = ?
          WHERE id = ?
        `,
          [img_url, blogID + ""]
        );

      await poolTransaction.commit();

      const [blogRows] = await pool.execute(
        `
        SELECT
          b.*,
          a.name AS account_name,
          a.img_url AS account_img_url
        FROM 
          Blog AS b
          INNER JOIN Account AS a ON b.account_id = a.id
        WHERE b.id = ?         
      `,
        [blogID + ""]
      );

      return {
        blog: {
          ...(blogRows as BlogWithAccount[])[0],
          blogLikeCount: 0,
          blogCommentCount: 0,
          blogComments: [],
        },
      };
    } catch (error) {
      await poolTransaction.rollback();
      console.log("Fail to create blog - ", error);
      throw error;
    }
  }

  @Mutation(() => NewBlogCommentData)
  @UseMiddleware(isAuth)
  async createBlogComment(
    @Ctx() { pool, payload }: MyContext,
    @Arg("blogCommentInput") { content, account_id, blog_id }: BlogCommentInput
  ): Promise<NewBlogCommentData> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    const [rows] = await pool.execute(
      `
        INSERT INTO
          BlogComment(content, blog_id, account_id)
        VALUES
          (?, ?, ?)
      `,
      [content, blog_id + "", account_id + ""]
    );

    const blogCommentID = (rows as ResultSetHeader).insertId;

    const [blogCommentRows] = await pool.execute(
      `
        SELECT
          bc.*,
          a.name AS account_name,
          a.img_url AS account_img_url
        FROM 
          BlogComment AS bc
          INNER JOIN Account AS a ON bc.account_id = a.id
        WHERE bc.id = ?         
      `,
      [blogCommentID + ""]
    );

    return {
      blogComment: {
        ...(blogCommentRows as BlogCommentWithAccount[])[0],
        blogCommentLikeCount: 0,
      },
    };
  }

  @Mutation(() => NewBlogLikeData)
  @UseMiddleware(isAuth)
  async createBlogLike(
    @Ctx() { pool, payload }: MyContext,
    @Arg("blogLikeInput") { blog_id, account_id }: BlogLikeInput
  ): Promise<NewBlogLikeData> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    await pool.execute(
      `
        INSERT INTO
          BlogLike(blog_id, account_id)
        VALUES
          (?, ?)
      `,
      [blog_id + "", account_id + ""]
    );

    const [blogLikeRow] = await pool.execute(
      `
        SELECT COUNT(*) AS count FROM BlogLike WHERE blog_id = ?
      `,
      [blog_id + ""]
    );

    return {
      blogLike: (blogLikeRow as { count: number }[])[0].count,
    };
  }

  @Mutation(() => NewBlogCommentLikeData)
  @UseMiddleware(isAuth)
  async createBlogCommentLike(
    @Ctx() { pool, payload }: MyContext,
    @Arg("blogCommentLikeInput")
    { blog_comment_id, account_id }: BlogCommentLikeInput
  ): Promise<NewBlogCommentLikeData> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    await pool.execute(
      `
        INSERT INTO
          BlogCommentLike(blog_comment_id, account_id)
        VALUES
          (?, ?)
      `,
      [blog_comment_id + "", account_id + ""]
    );

    const [blogCommentlikeRow] = await pool.execute(
      `
        SELECT COUNT(*) AS count FROM BlogCommentLike WHERE blog_comment_id = ?
      `,
      [blog_comment_id + ""]
    );

    return {
      blogCommentLike: (blogCommentlikeRow as { count: number }[])[0].count,
    };
  }
}
