SELECT
    p.*,
    a.name AS `account_name`,
    a.img_url AS `account_img_url`
FROM
    Account AS a
    INNER JOIN Post AS p ON p.account_id = a.id
WHERE
    p.product_id = 1
ORDER BY
    p.id DESC;

SELECT
    p.*,
    COUNT(c.post_id) AS `commentCount`,
    a.name AS `account_name`,
    a.img_url AS `account_img_url`
FROM
    Comment AS c
    RIGHT JOIN Post AS p ON p.id = c.post_id
    INNER JOIN Account AS a ON p.account_id = a.id
WHERE
    p.product_id = 1
GROUP BY
    p.id
ORDER BY
    `commentCount` DESC;

SELECT
    p.*,
    COUNT(pl.post_id) AS `likeCount`,
    a.name AS `account_name`,
    a.img_url AS `account_img_url`
FROM
    PostLike AS pl
    RIGHT JOIN Post AS p ON p.id = pl.post_id
    INNER JOIN Account AS a ON p.account_id = a.id
WHERE
    p.product_id = 1
GROUP BY
    p.id
ORDER BY
    `likeCount` DESC;

SELECT
    c.*,
    COUNT(cl.comment_id) AS `commentLikeCount`,
    a.name AS `account_name`,
    a.img_url AS `account_img_url`
FROM
    CommentLike AS cl
    RIGHT JOIN Comment AS c ON c.id = cl.comment_id
    INNER JOIN Account AS a ON c.account_id = a.id
WHERE
    c.post_id IN(1, 3, 4)
GROUP BY
    c.id;