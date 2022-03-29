SELECT
    c.*,
    COUNT(c.`id`) AS `number_of_product`
FROM
    `CategoryProduct` AS cp
    INNER JOIN `Category` AS c ON cp.`category_id` = c.`id`
GROUP BY
    cp.`category_id`;