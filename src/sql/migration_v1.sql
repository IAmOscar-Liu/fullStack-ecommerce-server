set session sql_mode='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

DROP TABLE IF EXISTS Favorite;
DROP TABLE IF EXISTS OrderProduct;
DROP TABLE IF EXISTS MyOrder;
DROP TABLE IF EXISTS BlogCommentLike;
DROP TABLE IF EXISTS BlogComment;
DROP TABLE IF EXISTS BlogLike;
DROP TABLE IF EXISTS Blog;
DROP TABLE IF EXISTS CommentLike;
DROP TABLE IF EXISTS PostLike;
DROP TABLE IF EXISTS Comment;
DROP TABLE IF EXISTS Post;
DROP TABLE IF EXISTS Rate;
DROP TABLE IF EXISTS CategoryProduct;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Account;

CREATE TABLE Account (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password TEXT NOT NULL,
    img_url VARCHAR(2000) DEFAULT '/images/default_user.png',
    phone VARCHAR(20),
    address VARCHAR(100),
    description TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updateAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    provider CHAR(30) DEFAULT 'local',
    provider_id CHAR(200),
    CONSTRAINT unique_name UNIQUE (name, provider)
);

CREATE TABLE Category (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    img_url TEXT NOT NULL,
    CONSTRAINT unique_category_name UNIQUE (name)
);

CREATE TABLE Product (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(500) NOT NULL,
    img_url TEXT NOT NULL,
    description TEXT NOT NULL,
    price FLOAT(8) NOT NULL,
    isOnSale BOOLEAN DEFAULT FALSE,
    createdBy INT(6) UNSIGNED NOT NULL,
    addedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updateAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    isAvailable BOOLEAN DEFAULT TRUE,
    CONSTRAINT unique_product_name UNIQUE (name),
    FOREIGN KEY(createdBy) REFERENCES Account(id)
);

CREATE TABLE CategoryProduct (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT(6) UNSIGNED NOT NULL,
    product_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(category_id) REFERENCES Category(id),
    FOREIGN KEY(product_id) REFERENCES Product(id)
);

CREATE TABLE Rate (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    score INT NOT NULL,
    ratedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    CONSTRAINT unique_rate UNIQUE (product_id, account_id),
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE Post (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE Comment (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    post_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(post_id) REFERENCES Post(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE PostLike (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    post_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(post_id) REFERENCES Post(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_post_like UNIQUE (post_id, account_id)
);

CREATE TABLE CommentLike (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comment_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(comment_id) REFERENCES Comment(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_comment_like UNIQUE (comment_id, account_id)
);

CREATE TABLE Blog (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    img_url TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE BlogLike (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blog_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(blog_id) REFERENCES Blog(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_blog_like UNIQUE (blog_id, account_id)
);

CREATE TABLE BlogComment (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blog_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(blog_id) REFERENCES Blog(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE BlogCommentLike (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blog_comment_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(blog_comment_id) REFERENCES BlogComment(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_blog_comment_like UNIQUE (blog_comment_id, account_id)
);

CREATE TABLE MyOrder (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updateAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    session_id VARCHAR(500) NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_session_id UNIQUE (session_id)
);

CREATE TABLE OrderProduct (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    quantity INT(2) NOT NULL,
    payment ENUM('Incomplete', 'Succeeded', 'Failed') DEFAULT 'Incomplete',
    status ENUM('Pending', 'Cancel', 'In Progress', 'Delivered', 'Return') DEFAULT 'Pending',
    product_id INT(6) UNSIGNED NOT NULL,
    order_id INT(6) UNSIGNED NOT NULL,
    orderedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updateAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(order_id) REFERENCES MyOrder(id)
);

CREATE TABLE Favorite (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    addedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_favorite UNIQUE (product_id, account_id)
);
