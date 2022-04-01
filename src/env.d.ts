declare global {
  namespace NodeJS {
    interface ProcessEnv {
      DATABASE_HOST: string;
      DATABASE_USER: string;
      DATABASE_PASSWORD: string;
      DATABASE_NAME: string;
      DATABASE_PORT: string;
      PORT: string;
      CORS_ORIGIN: string;
      REFRESH_TOKEN_SECRET: string;
      ACCESS_TOKEN_SECRET: string;
      POPULAR_PRODUCT_LIMIT: string;
      TOPRATED_PRODUCT_LIMIT: string;
      ONSALE_PRODUCT_LIMIT: string;
      ALL_PRODUCT_LIMIT: string;
      CATEGORY_PRODUCT_LIMIT: string;
      SIMILAR_PRODUCT_LIMIT: string;
      PERSONAL_PRODUCT_LIMIT: string;
      PERSONAL_ORDER_LIMIT: string;
      POST_LIMIT: string;
      BLOG_LIMIT: string;
      RECENT_ORDER_LIMIT: string;
      RECENT_ACCOUNT_LIMIT: string;
      FIREBASE_API_KEY: string;
      FIREBASE_AUTHDOMAIN: string;
      FIREBASE_PROJECT_ID: string;
      FIREBASE_STORAGE_BUCKET: string;
      FIREBASE_MESSAGING_SENDER_ID: string;
      FIREBASE_APP_ID: string;
      FIREBASE_MEASUREMENT_ID: string;
      GOOGLE_CLIENT_ID: string;
      GOOGLE_CLIENT_SECRET: string;
      GOOGLE_CALLBACK_URL: string;
      FRONT_END_REDIRECT: string;
      FRONT_END_CART_URL: string;
      FRONT_END_CHECKOUT_SUCCESS_URL: string;
      STRIPE_SECRET_KEY: string;
    }
  }
}

export {}
