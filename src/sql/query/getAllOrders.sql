SELECT
    *
FROM
    Product
WHERE
    isOnSale = TRUE;

SELECT
    p.*,
    COUNT(op.product_id) AS `total_order_count`
FROM
    OrderProduct AS op
    RIGHT JOIN Product AS p ON op.product_id = p.id
GROUP BY
    p.id
ORDER BY
    `total_order_count`;