SELECT
    p.*,
    COUNT(p.`id`) AS `number_of_Category`
FROM
    `CategoryProduct` AS cp
    INNER JOIN `Product` AS p ON cp.`product_id` = p.`id`
GROUP BY
    cp.`product_id`;