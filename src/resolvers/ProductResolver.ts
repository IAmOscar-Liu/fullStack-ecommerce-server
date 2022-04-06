import { Max, Min } from "class-validator";
import { getStorage, ref } from "firebase/storage";
import { FileUpload } from "graphql-upload";
import { ResultSetHeader } from "mysql2";
import { stream2buffer } from "../utils/stream2buffer";
import {
  Arg,
  Ctx,
  Field,
  ID,
  InputType,
  Int,
  Mutation,
  ObjectType,
  Query,
  Resolver,
  UnauthorizedError,
  UseMiddleware,
} from "type-graphql";
import { isAuth } from "../middleware/isAuth";
import { MyContext } from "../types";
import { Category } from "../types/Category";
import {
  NumberOfProductAllTypes,
  Product,
  ProductBrief,
  ProductDetail,
  ProductWithAccount,
} from "../types/Product";
import { firebaseUpload } from "../utils/firebaseUpload";
import {
  numOfpopularProduct,
  numOfTopRatedProduct,
} from "../utils/numOfpopularAndTopRated";
import { GraphQLUpload } from "graphql-upload";

@ObjectType()
class ProductData {
  @Field(() => [ProductBrief], { nullable: true })
  products: ProductBrief[];

  @Field({ nullable: true })
  hasMore?: boolean;

  @Field({ nullable: true })
  total?: number;
}

@InputType()
class ProductInput {
  @Field()
  title: string;

  @Field()
  price: number;

  @Field(() => ID)
  createdBy: number;

  @Field(() => [String])
  descriptions: string[];

  @Field()
  isOnSale: boolean;

  @Field(() => [ID])
  categories: number[];
}

@InputType()
class ProductUpdateInput {
  @Field(() => [String], { nullable: true })
  descriptions?: string[];

  @Field({ nullable: true })
  isOnSale?: boolean;

  @Field(() => [ID], { nullable: true })
  categories?: number[];

  @Field(() => [String], { nullable: true })
  imgs_url?: string[];
}

@InputType()
class RateInput {
  @Field(() => ID)
  account_id: number;

  @Field(() => ID)
  product_id: number;

  @Field(() => Int)
  @Min(1)
  @Max(5)
  score: number;
}

@ObjectType()
class RateProduct {
  @Field()
  avg_rating: number;

  @Field()
  rating_times: number;
}

@Resolver()
export class ProductResolver {
  @Query(() => NumberOfProductAllTypes)
  async getNumberOfProductAllTypes(
    @Ctx() { pool }: MyContext
  ): Promise<NumberOfProductAllTypes> {
    const [rows] = await pool.query(
      `SELECT id, isOnSale FROM Product WHERE isAvailable = TRUE`
    );

    const products = rows as { id: number; isOnSale: boolean }[];

    return {
      all: products.length,
      onSale: products.filter((p) => p.isOnSale).length,
      popular: numOfpopularProduct(products.length),
      topRated: numOfTopRatedProduct(products.length),
    };
  }

  @Query(() => ProductData)
  async getOnSaleProducts(
    @Ctx() { pool }: MyContext,
    @Arg("limit", { defaultValue: process.env.ONSALE_PRODUCT_LIMIT })
    limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<ProductData> {
    // const poolPromise = pool.promise();

    const [rows] = await pool.execute(
      `
        SELECT
          p.id,
          p.name,
          p.img_url,
          p.price,
          p.isOnSale,
          p.rating_times,
          p.avg_rating,
          p.isAvailable,
          SUM(op.quantity) AS total_order_count
        FROM
          (SELECT * FROM OrderProduct WHERE payment = 'Succeeded') AS op
          RIGHT JOIN (
            
            SELECT
              p.*,
              COUNT(r.id) AS rating_times,
              AVG(r.score) AS avg_rating
            FROM
              Product p
              LEFT JOIN Rate r ON r.product_id = p.id
            GROUP BY
              p.id
            
            ) AS p ON op.product_id = p.id
        WHERE 
          p.isOnSale = true AND p.isAvailable = TRUE   
        GROUP BY
          p.id
        ORDER BY
          p.avg_rating DESC,
          p.rating_times DESC,
          p.id DESC
        LIMIT ?, ?  
      `,
      [offset + "", limit + ""]
    );

    // console.log(rows);

    return {
      products: rows as ProductBrief[],
    };
  }

  @Query(() => ProductData)
  async getPopularProducts(
    @Ctx() { pool }: MyContext,
    @Arg("limit", { defaultValue: process.env.POPULAR_PRODUCT_LIMIT })
    _limit: number,
    @Arg("offset", { defaultValue: 0 }) _offset: number,
    @Arg("total", { nullable: true }) _total: number
  ): Promise<ProductData> {
    const total = parseInt(_total as unknown as string) || Infinity;
    const offset = parseInt(_offset as unknown as string);
    let limit = parseInt(_limit as unknown as string);

    if (offset >= total) return { products: [] };

    if (total - offset < limit) limit = total - offset;

    const [rows] = await pool.execute(
      `
        SELECT
          p.id,
          p.name,
          p.img_url,
          p.price,
          p.isOnSale,
          p.rating_times,
          p.avg_rating,
          p.isAvailable,
          SUM(op.quantity) AS total_order_count
        FROM
          (SELECT * FROM OrderProduct WHERE payment = 'Succeeded') AS op
          RIGHT JOIN (
            
            SELECT
              p.*,
              COUNT(r.id) AS rating_times,
              AVG(r.score) AS avg_rating
            FROM
              Product p
              LEFT JOIN Rate r ON r.product_id = p.id
            GROUP BY
              p.id
            
            ) AS p ON op.product_id = p.id
        WHERE p.isAvailable = TRUE       
        GROUP BY
          p.id
        ORDER BY
          total_order_count DESC,
          p.avg_rating DESC,
          p.rating_times DESC,
          p.id DESC
        LIMIT ?, ?   
      `,
      [offset + "", limit + ""]
    );

    return { products: rows as ProductBrief[] };
  }

  @Query(() => ProductData)
  async getTopRatedProducts(
    @Ctx() { pool }: MyContext,
    @Arg("limit", { defaultValue: process.env.TOPRATED_PRODUCT_LIMIT })
    _limit: number,
    @Arg("offset", { defaultValue: 0 }) _offset: number,
    @Arg("total", { nullable: true }) _total: number
  ): Promise<ProductData> {
    const total = parseInt(_total as unknown as string) || Infinity;
    const offset = parseInt(_offset as unknown as string);
    let limit = parseInt(_limit as unknown as string);

    if (offset >= total) return { products: [] };

    if (total - offset < limit) limit = total - offset;

    const [rows] = await pool.execute(
      `
        SELECT
          p.id,
          p.name,
          p.img_url,
          p.price,
          p.isOnSale,
          p.rating_times,
          p.avg_rating,
          p.isAvailable,
          SUM(op.quantity) AS total_order_count
        FROM
          (SELECT * FROM OrderProduct WHERE payment = 'Succeeded') AS op
          RIGHT JOIN (
            
            SELECT
              p.*,
              COUNT(r.id) AS rating_times,
              AVG(r.score) AS avg_rating
            FROM
              Product p
              LEFT JOIN Rate r ON r.product_id = p.id
            GROUP BY
              p.id
            
            ) AS p ON op.product_id = p.id
        WHERE p.isAvailable = TRUE       
        GROUP BY
          p.id
        ORDER BY
          p.avg_rating DESC,
          p.rating_times DESC,
          p.id DESC
        LIMIT ?, ?  
      `,
      [offset + "", limit + ""]
    );

    return { products: rows as ProductBrief[] };
  }

  @Query(() => ProductData)
  async getAllProducts(
    @Ctx() { pool }: MyContext,
    @Arg("limit", { defaultValue: process.env.ALL_PRODUCT_LIMIT })
    limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<ProductData> {
    // const poolPromise = pool.promise();

    const [rows] = await pool.execute(
      `
        SELECT
          p.id,
          p.name,
          p.img_url,
          p.price,
          p.isOnSale,
          p.rating_times,
          p.avg_rating,
          p.isAvailable,
          SUM(op.quantity) AS total_order_count
        FROM
          (SELECT * FROM OrderProduct WHERE payment = 'Succeeded') AS op
          RIGHT JOIN (
            
            SELECT
              p.*,
              COUNT(r.id) AS rating_times,
              AVG(r.score) AS avg_rating
            FROM
              Product p
              LEFT JOIN Rate r ON r.product_id = p.id
            GROUP BY
              p.id
            
            ) AS p ON op.product_id = p.id
        WHERE p.isAvailable = TRUE       
        GROUP BY
          p.id
        ORDER BY
          p.id
        LIMIT ?, ?  
      `,
      [offset + "", limit + ""]
    );

    // console.log(rows);

    return {
      products: rows as ProductBrief[],
    };
  }

  @Query(() => ProductData)
  async getProductsByIDs(
    @Ctx() { pool }: MyContext,
    @Arg("product_ids", () => [ID]) product_ids: number[]
  ): Promise<ProductData> {
    if (product_ids.length === 0) return { products: [] };

    const [rows] = await pool.query(
      `
        SELECT
          p.id,
          p.name,
          p.img_url,
          p.price,
          p.isOnSale,
          p.rating_times,
          p.avg_rating,
          p.isAvailable,
          SUM(op.quantity) AS total_order_count
        FROM
          (SELECT * FROM OrderProduct WHERE payment = 'Succeeded') AS op
          RIGHT JOIN (
            
            SELECT
              p.*,
              COUNT(r.id) AS rating_times,
              AVG(r.score) AS avg_rating
            FROM
              Product p
              LEFT JOIN Rate r ON r.product_id = p.id
            GROUP BY
              p.id
            
            ) AS p ON op.product_id = p.id
        WHERE p.id IN (${product_ids.join(", ")})       
        GROUP BY
          p.id
      `
    );

    // console.log(rows);

    return {
      products: rows as ProductBrief[],
    };
  }

  @Query(() => ProductData)
  async getProductByCategoryID(
    @Ctx() { pool }: MyContext,
    @Arg("category_id") category_id: number,
    @Arg("limit", { defaultValue: process.env.TOPRATED_PRODUCT_LIMIT })
    limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<ProductData> {
    const [rows] = await pool.execute(
      `
        SELECT 
          p.id,
          p.name,
          p.img_url,
          p.price,
          p.isOnSale,
          p.rating_times,
          p.avg_rating,
          p.isAvailable,
          p.total_order_count
        FROM (
    
          SELECT
            allProduct.*,
            SUM(op.quantity) AS total_order_count
          FROM
            (SELECT * FROM OrderProduct WHERE payment = 'Succeeded') AS op
            RIGHT JOIN (

              SELECT
                p.*,
                COUNT(r.id) AS rating_times,
                AVG(r.score) AS avg_rating
              FROM
                Product p
                LEFT JOIN Rate r ON r.product_id = p.id
              GROUP BY
                p.id

            ) AS allProduct ON op.product_id = allProduct.id
          GROUP BY
            allProduct.id
            
          ) AS p
          RIGHT JOIN CategoryProduct AS cp ON p.id = cp.product_id
        WHERE 
          cp.category_id = ? AND p.isAvailable = TRUE
        ORDER BY
          p.avg_rating DESC,
          p.rating_times DESC,
          p.total_order_count DESC,
          p.id DESC 
        LIMIT ?, ?         
       `,
      [category_id + "", offset + "", limit + ""]
    );

    return { products: rows as ProductBrief[] };
  }

  @Query(() => ProductData)
  async getProductByCreatedBy(
    @Ctx() { pool }: MyContext,
    @Arg("createdBy") createdBy: number,
    @Arg("limit", { defaultValue: process.env.PERSONAL_PRODUCT_LIMIT })
    _limit: number,
    @Arg("offset", { defaultValue: 0 }) offset: number
  ): Promise<ProductData> {
    const limit = parseInt(_limit as unknown as string);

    const [totalRows] = await pool.execute(
      `SELECT COUNT(id) AS total_product FROM Product WHERE createdBy = ?`,
      [createdBy + ""]
    );

    const total = (totalRows as { total_product: number }[])[0].total_product;

    if (total === 0)
      return {
        products: [],
        hasMore: false,
        total,
      };

    const [rows] = await pool.execute(
      `     
        SELECT
          p.id,
          p.name,
          p.img_url,
          p.price,
          p.isOnSale,
          p.rating_times,
          p.avg_rating,
          p.isAvailable,
          SUM(op.quantity) AS total_order_count
        FROM
          (SELECT * FROM OrderProduct WHERE payment = 'Succeeded') AS op
        RIGHT JOIN (
        
          SELECT
            p.*,
            COUNT(r.id) AS rating_times,
            AVG(r.score) AS avg_rating
          FROM
            Product p
            LEFT JOIN Rate r ON r.product_id = p.id
          GROUP BY
            p.id
        
        ) AS p ON op.product_id = p.id
        WHERE 
          p.createdBy = ?    
        GROUP BY
          p.id
        ORDER BY
          total_order_count DESC 
        LIMIT ?, ?                
      `,
      [createdBy + "", offset + "", limit + 1 + ""]
    );

    if ((rows as ProductBrief[]).length === limit + 1) {
      return {
        products: (rows as ProductBrief[]).slice(0, -1),
        hasMore: true,
        total,
      };
    }

    return {
      products: rows as ProductBrief[],
      hasMore: false,
      total,
    };
  }

  @Query(() => ProductDetail, { nullable: true })
  async getProductDetail(
    @Ctx() { pool }: MyContext,
    @Arg("product_id") product_id: number
  ): Promise<ProductDetail | null> {
    // const poolPromise = pool.promise();

    const [productRows] = await pool.execute(
      `
        SELECT
          p.*,
          SUM(op.quantity) AS total_order_count,
          a.id AS account_id,
          a.name AS account_name,
          a.img_url AS account_img_url
        FROM
          (SELECT * FROM OrderProduct WHERE payment = 'Succeeded') AS op
          RIGHT JOIN (
            
            SELECT
              p.*,
              COUNT(r.id) AS rating_times,
              AVG(r.score) AS avg_rating
            FROM
              Product p
              LEFT JOIN Rate r ON r.product_id = p.id
            GROUP BY
              p.id
            
            ) AS p ON op.product_id = p.id
            INNER JOIN Account AS a ON p.createdBy = a.id
        WHERE 
          p.id = ?    
        GROUP BY
          p.id
        ORDER BY
          p.id DESC
      `,
      [product_id + ""]
    );

    if ((productRows as ProductWithAccount[]).length === 0) return null;
    const productWithAccount = (productRows as ProductWithAccount[])[0];

    const [categoryRows] = await pool.execute(
      `
        SELECT
          *
        FROM
          Category
        WHERE
          id IN (
            SELECT
              category_id
            FROM
              CategoryProduct AS cp
            WHERE
              product_id = ?
          )
      `,
      [product_id + ""]
    );

    const categories = categoryRows as Category[];
    const limit = process.env.SIMILAR_PRODUCT_LIMIT as unknown as number;

    const [similarProductRows] = await pool.execute(
      `
        SELECT 
          DISTINCT p.id,
          p.name,
          p.img_url,
          p.price,
          p.isOnSale,
          p.rating_times,
          p.avg_rating,
          p.total_order_count,
          p.isAvailable
        FROM (
    
          SELECT
            allProduct.*,
            COUNT(op.product_id) AS total_order_count
          FROM
            OrderProduct AS op
            RIGHT JOIN (

              SELECT
                p.*,
                COUNT(r.id) AS rating_times,
                AVG(r.score) AS avg_rating
              FROM
                Product p
                LEFT JOIN Rate r ON r.product_id = p.id
              GROUP BY
                p.id

            ) AS allProduct ON op.product_id = allProduct.id
          GROUP BY
            allProduct.id
            
          ) AS p
          RIGHT JOIN CategoryProduct AS cp ON p.id = cp.product_id
        WHERE 
          cp.category_id IN (${
            categories.length === 1 && categories[0].name === "others"
              ? categories[0].id
              : categories
                  .filter((cat) => cat.name !== "others")
                  .map((cat) => cat.id)
                  .join(", ")
          })
        ORDER BY
          p.avg_rating DESC,
          p.rating_times DESC,
          p.total_order_count DESC,
          p.id DESC 
        LIMIT ?       
       `,
      [limit + 1 + ""]
    );

    const simularProducts = (similarProductRows as ProductBrief[])
      .filter((p) => p.id !== productWithAccount.id)
      .slice(0, limit);

    return {
      ...productWithAccount,
      categories,
      simularProducts,
    };
  }

  @Mutation(() => Product, { nullable: true })
  @UseMiddleware(isAuth)
  async createProduct(
    @Ctx() { pool, payload }: MyContext,
    @Arg("productInput")
    {
      title,
      price,
      descriptions,
      createdBy,
      isOnSale,
      categories,
    }: ProductInput,
    @Arg("file_1", () => GraphQLUpload) file_1: FileUpload,
    @Arg("file_2", () => GraphQLUpload, { nullable: true }) file_2: FileUpload,
    @Arg("file_3", () => GraphQLUpload, { nullable: true }) file_3: FileUpload,
    @Arg("file_4", () => GraphQLUpload, { nullable: true }) file_4: FileUpload,
    @Arg("file_5", () => GraphQLUpload, { nullable: true }) file_5: FileUpload
  ): Promise<Product | null> {
    if (createdBy + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    if (categories.length === 0)
      throw new Error("You should select at least one category.");

    const files = [file_1, file_2, file_3, file_4, file_5].filter(
      (file) => file
    );

    if (files.length === 0)
      throw new Error("Each product should have at least 1 image.");

    const files_url = Array(files.length).map(() => "");

    const poolTransaction = await pool.getConnection();
    await poolTransaction.beginTransaction();

    try {
      const [rows] = await poolTransaction.execute(
        `
        INSERT INTO
          Product(
              name,
              img_url,
              description,
              price,
              createdBy,
              isOnSale
          )
        VALUES
          (?, ?, ?, ?, ?, ?)
      `,
        [
          title,
          "/images/default_user.png",
          descriptions.join("<br/>"),
          price,
          createdBy,
          isOnSale,
        ]
      );

      const productID = (rows as ResultSetHeader).insertId;

      for (let i = 0; i < files.length; i++) {
        const { createReadStream, filename, mimetype } = files[i];

        const stream = createReadStream();

        const buffer: Buffer = await stream2buffer(stream);

        // product/product_${productID}/${images_name[i]}

        const storage = getStorage();
        const storageRef = ref(
          storage,
          `product/product_${productID}/${filename}`
        );

        files_url[i] = (
          await firebaseUpload({ storageRef, buffer, mimetype })
        ).img_url;
      }

      await poolTransaction.execute(
        `
          UPDATE Product 
          SET img_url = ?
          WHERE id = ?
        `,
        [files_url.join("<br/>"), productID]
      );

      await poolTransaction.query(
        `
          INSERT INTO
            CategoryProduct(category_id, product_id)
          VALUES
            ${categories.map((cID) => "(" + cID + "," + productID + ")")}
        `
      );

      await poolTransaction.commit();

      const [productRows] = await pool.execute(
        `SELECT * FROM Product WHERE id = ?`,
        [productID + ""]
      );

      return (productRows as Product[])[0];
    } catch (e) {
      await poolTransaction.rollback();
      throw e;
    }
  }

  @Mutation(() => Product, { nullable: true })
  @UseMiddleware(isAuth)
  async updateProduct(
    @Ctx() { pool, payload }: MyContext,
    @Arg("account_id", () => ID) account_id: number,
    @Arg("product_id", () => ID) product_id: number,
    @Arg("productUpdateInput")
    { descriptions, isOnSale, categories, imgs_url }: ProductUpdateInput,
    @Arg("file_1", () => GraphQLUpload, { nullable: true }) file_1: FileUpload,
    @Arg("file_2", () => GraphQLUpload, { nullable: true }) file_2: FileUpload,
    @Arg("file_3", () => GraphQLUpload, { nullable: true }) file_3: FileUpload,
    @Arg("file_4", () => GraphQLUpload, { nullable: true }) file_4: FileUpload,
    @Arg("file_5", () => GraphQLUpload, { nullable: true }) file_5: FileUpload
  ): Promise<Product | null> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    const [productCreatedByRows] = await pool.execute(
      `SELECT createdBy FROM Product WHERE id = ?`,
      [product_id + ""]
    );
    const createdBy = (productCreatedByRows as { createdBy: any }[])[0]
      .createdBy;

    if (createdBy + "" !== account_id + "") throw new UnauthorizedError();

    const files = [file_1, file_2, file_3, file_4, file_5].filter(
      (file) => file
    );

    const files_url = imgs_url ?? [];

    if (files_url.filter((url) => url === "TBD").length !== files.length)
      throw new Error(
        "Length of 'imgs_url' doesn't match number of file to be uploaded"
      );

    const poolTransaction = await pool.getConnection();
    await poolTransaction.beginTransaction();

    try {
      let indexOfFile = 0;
      for (let i = 0; i < files_url.length; i++) {
        if (files_url[i] === "TBD") {
          const { createReadStream, filename, mimetype } = files[indexOfFile];

          const stream = createReadStream();

          const buffer: Buffer = await stream2buffer(stream);

          // product/product_${productID}/${images_name[i]}

          const storage = getStorage();
          const storageRef = ref(
            storage,
            `product/product_${product_id}/${filename}`
          );

          files_url[i] = (
            await firebaseUpload({ storageRef, buffer, mimetype })
          ).img_url;

          indexOfFile++;
        }
      }

      const setArr = [];
      if (descriptions)
        setArr.push(`description = "${descriptions.join("<br/>")}"`);
      if (isOnSale !== undefined) setArr.push(`isOnSale = ${isOnSale}`);
      if (files_url.length > 0)
        setArr.push(`img_url = "${files_url.join("<br/>")}"`);

      if (setArr.length > 0) {
        await poolTransaction.execute(
          `
            UPDATE Product 
            SET 
              ${setArr.join(", ")}
            WHERE id = ?
          `,
          [product_id]
        );
      }

      if (categories) {
        await poolTransaction.execute(
          `
            DELETE FROM CategoryProduct
            WHERE product_id = ?
          `,
          [product_id]
        );
        await poolTransaction.query(
          `
            INSERT INTO
              CategoryProduct(category_id, product_id)
            VALUES
              ${categories.map((cID) => "(" + cID + "," + product_id + ")")}
          `
        );
      }

      await poolTransaction.commit();

      const [productRows] = await pool.execute(
        `SELECT * FROM Product WHERE id = ?`,
        [product_id + ""]
      );

      return (productRows as Product[])[0];
    } catch (e) {
      await poolTransaction.rollback();
      throw e;
    }
  }

  @Mutation(() => Product, { nullable: true })
  @UseMiddleware(isAuth)
  async freezeOrUnFreezeProduct(
    @Ctx() { pool, payload }: MyContext,
    @Arg("account_id", () => ID) account_id: number,
    @Arg("product_id", () => ID) product_id: number,
    @Arg("isAvailable") isAvailable: boolean
  ): Promise<Product | null> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    const [productCreatedByRows] = await pool.execute(
      `SELECT createdBy FROM Product WHERE id = ?`,
      [product_id + ""]
    );
    const createdBy = (productCreatedByRows as { createdBy: any }[])[0]
      .createdBy;

    if (createdBy + "" !== account_id + "") throw new UnauthorizedError();

    await pool.execute(
      `
        UPDATE Product 
        SET 
          isAvailable = ?
        WHERE id = ?
      `,
      [isAvailable + "", product_id + ""]
    );

    const [productRows] = await pool.execute(
      `SELECT * FROM Product WHERE id = ?`,
      [product_id + ""]
    );

    return (productRows as Product[])[0];
  }

  @Mutation(() => RateProduct)
  @UseMiddleware(isAuth)
  async rateProduct(
    @Ctx() { pool, payload }: MyContext,
    @Arg("rateInput") { score, account_id, product_id }: RateInput
  ): Promise<RateProduct> {
    if (account_id + "" !== payload?.account_id + "")
      throw new UnauthorizedError();

    await pool.execute(
      `
      INSERT INTO
        Rate(score, product_id, account_id)
      VALUES
        (?, ?, ?)    
    `,
      [score + "", product_id + "", account_id + ""]
    );

    const [rateRows] = await pool.execute(
      `
        SELECT
          COUNT(r.id) AS rating_times,
          AVG(r.score) AS avg_rating
        FROM
          Product p
          LEFT JOIN Rate r ON r.product_id = p.id
        WHERE 
          r.product_id = ?  
        GROUP BY
          p.id
      `,
      [product_id + ""]
    );

    return (rateRows as RateProduct[])[0];
  }
}
