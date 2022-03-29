SELECT
    b.*,
    a.name AS `account_name`,
    a.img_url AS `account_img_url`
FROM
    Account AS a
    INNER JOIN Blog AS b ON b.account_id = a.id
ORDER BY
    b.id DESC;

SELECT
    b.*,
    COUNT(bl.blog_id) AS `blogLikeCount`,
    a.name AS `account_name`,
    a.img_url AS `account_img_url`
FROM
    BlogLike AS bl
    RIGHT JOIN Blog AS b ON b.id = bl.blog_id
    INNER JOIN Account AS a ON b.account_id = a.id
GROUP BY
    b.id
ORDER BY
    `blogLikeCount` DESC;

SELECT
    b.*,
    COUNT(bc.blog_id) AS `blogCommentCount`,
    a.name AS `account_name`,
    a.img_url AS `account_img_url`
FROM
    BlogComment AS bc
    RIGHT JOIN Blog AS b ON b.id = bc.blog_id
    INNER JOIN Account AS a ON b.account_id = a.id
GROUP BY
    b.id
ORDER BY
    `blogCommentCount` DESC;

SELECT
    bc.*,
    COUNT(bcl.blog_comment_id) AS `blogCommentLikeCount`,
    a.name AS `account_name`,
    a.img_url AS `account_img_url`
FROM
    BlogCommentLike AS bcl
    RIGHT JOIN BlogComment AS bc ON bc.id = bcl.blog_comment_id
    INNER JOIN Account AS a ON bc.blog_id IN(1, 3, 2, 4)
    AND bc.account_id = a.id
GROUP BY
    bc.id;