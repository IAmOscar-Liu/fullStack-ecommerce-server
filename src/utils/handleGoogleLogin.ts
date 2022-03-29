import bcrypt from "bcryptjs";
import mysql from "mysql2/promise";
import { AccountWithPassword } from "../types/Account";

type ProviderProfile = {
  name: string;
  email: string;
  img_url: string;
  provider: string;
  provider_id: string;
};

export const handleGoogleLogin = async (
  pool: mysql.Pool,
  profile: ProviderProfile
) => {
  const { name, email, img_url, provider, provider_id } = profile;

  const [rows] = await pool.execute(
    `
      SELECT * FROM Account WHERE name = ? AND provider = ? AND provider_id = ?
    `,
    [name, provider, provider_id]
  );

  if ((rows as AccountWithPassword[]).length >= 1) return;

  const poolTransaction = await pool.getConnection();
  try {
    const hashedPassword = await bcrypt.hash(provider_id, 12);
    await poolTransaction.execute(
      `
            INSERT INTO
            Account(name, email, password, img_url, provider, provider_id)
            VALUES
            (?, ?, ?, ?, ?, ?)
        `,
      [name, email, hashedPassword, img_url, provider, provider_id]
    );

    await poolTransaction.commit();
  } catch (e) {
    await poolTransaction.rollback();
    throw e;
  }
};
