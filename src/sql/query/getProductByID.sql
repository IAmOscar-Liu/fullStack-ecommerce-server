SELECT
    p.*,
    a.id AS `account_id`,
    a.name AS `account_name`,
    a.img_url AS `account_img_url`
FROM
    Account AS a
    INNER JOIN Product AS p ON p.createdBy = a.id
    AND p.id = 3;

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
            product_id = 3
    );