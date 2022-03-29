INSERT INTO
    Rate(score, product_id, account_id)
VALUES
    (5, 1, 1),
    (2, 1, 2),
    (3, 2, 1);

INSERT INTO
    Post(content, product_id, account_id)
VALUES
    ("I like this one", 1, 1),
    ("I like this one", 2, 1),
    ("I like this one", 1, 2),
    ("I like this one", 1, 2),
    ("I like this one", 3, 1);    

INSERT INTO
    Comment(content, post_id, account_id)
VALUES
    ("me, too", 1, 2),
    ("me, too", 2, 2),
    ("me, too", 1, 1),
    ("me, too", 3, 1);

INSERT INTO
    PostLike(post_id, account_id)
VALUES
    (1, 2),
    (2, 2),
    (1, 1),
    (3, 1);

INSERT INTO
    CommentLike(comment_id, account_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 1),
    (4, 1),
    (3, 2);    

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

INSERT INTO
    BlogLike(blog_id, account_id)
VALUES
    (1, 1),
    (1, 2),
    (2, 1),
    (3, 1),
    (3, 2);

INSERT INTO
    BlogComment(content, blog_id, account_id)
VALUES
    ("I agree", 1, 1),
    ("I agree", 1, 2),
    ("I agree", 2, 1),
    ("I agree", 3, 1),
    ("I agree", 3, 2);    

INSERT INTO
    BlogCommentLike(blog_comment_id, account_id)
VALUES
    (1, 1),
    (1, 2),
    (3, 1);

INSERT INTO
    MyOrder(account_id, session_id)
VALUES
    (1, "session_id_0001");

INSERT INTO
    OrderProduct(quantity, product_id, order_id, payment)
VALUES
    (10, 1, 1, "Succeeded"),
    (5, 2, 1, "Succeeded"),
    (20, 3, 1, "Succeeded");

INSERT INTO
    MyOrder(account_id, session_id)
VALUES
    (2, "session_id_0002");

INSERT INTO
    OrderProduct(quantity, product_id, order_id, payment)
VALUES
    (35, 2, 2, "Succeeded"),
    (40, 3, 2, "Succeeded");
       
INSERT INTO
    Favorite(product_id, account_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 1);
