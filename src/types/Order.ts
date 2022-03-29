import { Field, ID, registerEnumType, ObjectType } from "type-graphql";

enum Status {
  Pending = "Pending",
  Cancel = "Cancel",
  InProgress = "In Progress",
  Delivered = "Delivered",
  Return = "Return",
}

enum Payment {
  Incomplete = "Incomplete",
  Succeeded = "Succeeded",
  Failed = "Failed",
}

registerEnumType(Status, {
  name: "Status",
  description:
    "There are 5 status Pending | Cancel | In Progress | Delivered | Return",
});

registerEnumType(Payment, {
  name: "Payment",
  description: "There are 2 Payment Incomplete | Succeeded",
});

@ObjectType()
export class OrderProduct {
  @Field(() => ID)
  id: number;

  @Field()
  quantity: number;

  @Field()
  payment: Payment;

  @Field()
  status: Status;

  @Field(() => ID)
  order_id: number;

  @Field(() => ID)
  product_id: number;

  @Field()
  orderedAt: string;

  @Field()
  updateAt: string;
}

@ObjectType()
export class OrderProductDetail extends OrderProduct {
  @Field()
  product_name: string;

  @Field()
  product_price: number;

  @Field()
  product_img_url: string;
}

@ObjectType()
export class Order {
  @Field(() => ID)
  id: number;

  @Field()
  createdAt: string;

  @Field()
  updateAt: string;

  @Field()
  session_id: string;

  @Field(() => ID)
  account_id: number;
}

@ObjectType()
export class OrderDetail extends Order {
  @Field(() => [OrderProductDetail], { nullable: true })
  products: OrderProductDetail[];
}

@ObjectType()
export class RecentOrder {
  @Field(() => ID)
  id: number;

  @Field(() => ID)
  product_id: number;

  @Field()
  product_name: string;

  @Field()
  product_price: number;

  @Field()
  product_img_url: string;

  @Field()
  payment: Payment;

  @Field()
  status: Status;
}
