import { ObjectType, Field, ID } from "type-graphql";

@ObjectType()
export class AccountBrief {
  @Field(() => ID)
  id: number;

  @Field()
  name: string;

  @Field()
  img_url: string;

  @Field()
  createdAt: string;

  @Field()
  updateAt: string;
}

@ObjectType()
export class Account extends AccountBrief {
  @Field()
  email: string;

  @Field({ nullable: true })
  description: string;

  @Field({ nullable: true })
  phone: string;

  @Field({ nullable: true })
  address: string;

  @Field()
  provider: string;

  @Field({ nullable: true })
  provider_id: string;
}

@ObjectType()
export class AccountWithPassword extends Account {
  @Field()
  password: string;
}

@ObjectType()
export class AccountDetail {
  @Field(() => Account, { nullable: true })
  account?: Account;

  @Field({ nullable: true })
  access_token?: string;
}

export const removePasswordField = (account: AccountWithPassword): Account => ({
  id: account.id,
  name: account.name,
  email: account.email,
  img_url: account.img_url,
  description: account.description,
  phone: account.phone,
  address: account.address,
  createdAt: account.createdAt,
  updateAt: account.updateAt,
  provider: account.provider,
  provider_id: account.provider_id,
});
