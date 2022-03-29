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
    CONSTRAINT unique_name UNIQUE (name)
);

INSERT INTO
    Account(name, email, password)
VALUES
    ("Oscar", "karta0989006@gmail.com", "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"),
    ("David", "david@gmail.com", "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"),
    ("John", "david@gmail.com", "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa");

CREATE TABLE Category (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    img_url TEXT NOT NULL,
    CONSTRAINT unique_category_name UNIQUE (name)
);

INSERT INTO
    Category(name, img_url)
VALUES
    ("electronics", "/images/categories/electronics"),
    (
        "applications",
        "/images/categories/applications"
    ),
    (
        "entertainments",
        "/images/categories/entertainments"
    ),
    ("others", "/images/categories/others");

CREATE TABLE Product (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    img_url TEXT NOT NULL,
    description TEXT NOT NULL,
    price FLOAT(8) NOT NULL,
    isOnSale BOOLEAN DEFAULT FALSE,
    createdBy INT(6) UNSIGNED NOT NULL,
    addedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updateAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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

INSERT INTO
    Product(name, img_url, description, price, createdBy)
VALUES
    (
        "adaptor",
        "images/adaptor.png",
        "This is a brand-new adaptor",
        3.99,
        1
    ),
    (
        "extension cords",
        "images/extension_cords.png",
        "This is a brand-new extension cords",
        2.99,
        1
    ),
    (
        "drone",
        "images/drone.png",
        "This is a brand-new drone",
        5.99,
        2
    );

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
    (
        "display",
        "images/display.png",
        "This is a brand-new display",
        7.99,
        2,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 1),
    (4, 1),
    (1, 2),
    (2, 2),
    (4, 2),
    (1, 3),
    (3, 3),
    (1, 4),
    (4, 4);

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

INSERT INTO
    Rate(score, product_id, account_id)
VALUES
    (5, 1, 1),
    (2, 1, 2),
    (3, 2, 1);

CREATE TABLE Post (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

INSERT INTO
    Post(content, product_id, account_id)
VALUES
    ("I like this one", 1, 1),
    ("I like this one", 2, 1),
    ("I like this one", 1, 2),
    ("I like this one", 1, 2),
    ("I like this one", 3, 1);

CREATE TABLE Comment (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    post_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(post_id) REFERENCES Post(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

INSERT INTO
    Comment(content, post_id, account_id)
VALUES
    ("me, too", 1, 2),
    ("me, too", 2, 2),
    ("me, too", 1, 1),
    ("me, too", 3, 1);

CREATE TABLE PostLike (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    post_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(post_id) REFERENCES Post(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_post_like UNIQUE (post_id, account_id)
);

INSERT INTO
    PostLike(post_id, account_id)
VALUES
    (1, 2),
    (2, 2),
    (1, 1),
    (3, 1);

CREATE TABLE CommentLike (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comment_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(comment_id) REFERENCES Comment(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_comment_like UNIQUE (comment_id, account_id)
);

INSERT INTO
    CommentLike(comment_id, account_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 1),
    (4, 1),
    (3, 2);

CREATE TABLE Blog (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    img_url TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

INSERT INTO
    Blog(content, account_id)
VALUES
    ("This is the sample blog 1.", 1);

INSERT INTO
    Blog(content, account_id, img_url)
VALUES
    (
        "This is the sample blog 2.",
        1,
        "/images/blog2.png"
    );

INSERT INTO
    Blog(content, account_id)
VALUES
    ("This is the sample blog 3.", 2);

INSERT INTO
    Blog(content, account_id, img_url)
VALUES
    (
        "This is the sample blog 4.",
        2,
        "/images/blog4.png"
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

INSERT INTO
    BlogLike(blog_id, account_id)
VALUES
    (1, 1),
    (1, 2),
    (2, 1),
    (3, 1),
    (3, 2);

CREATE TABLE BlogComment (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blog_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(blog_id) REFERENCES Blog(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

INSERT INTO
    BlogComment(content, blog_id, account_id)
VALUES
    ("I agree", 1, 1),
    ("I agree", 1, 2),
    ("I agree", 2, 1),
    ("I agree", 3, 1),
    ("I agree", 3, 2);

CREATE TABLE BlogCommentLike (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blog_comment_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(blog_comment_id) REFERENCES BlogComment(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_blog_comment_like UNIQUE (blog_comment_id, account_id)
);

INSERT INTO
    BlogCommentLike(blog_comment_id, account_id)
VALUES
    (1, 1),
    (1, 2),
    (3, 1);

CREATE TABLE MyOrder (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    account_id INT(6) UNSIGNED NOT NULL,
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE OrderProduct (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    quantity INT(2) NOT NULL,
    payment ENUM('Due', 'Paid') DEFAULT 'Due',
    status ENUM('Pending', 'In Progress', 'Delivered', 'Return') DEFAULT 'Pending',
    product_id INT(6) UNSIGNED NOT NULL,
    order_id INT(6) UNSIGNED NOT NULL,
    orderedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updateAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(order_id) REFERENCES MyOrder(id)
);

INSERT INTO
    MyOrder(account_id)
VALUES
    (1);

INSERT INTO
    OrderProduct(quantity, product_id, order_id)
VALUES
    (10, 1, 1),
    (5, 2, 1),
    (20, 3, 1);

INSERT INTO
    MyOrder(account_id)
VALUES
    (2);

INSERT INTO
    OrderProduct(quantity, product_id, order_id)
VALUES
    (35, 2, 2),
    (40, 3, 2);
    
 CREATE TABLE Favorite (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT(6) UNSIGNED NOT NULL,
    account_id INT(6) UNSIGNED NOT NULL,
    addedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);   

INSERT INTO
    Favorite(product_id, account_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 1);