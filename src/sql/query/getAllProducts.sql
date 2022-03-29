SELECT
    p.*,
    AVG(r.score) AS `avg_rating`
FROM
    Product AS p
    LEFT JOIN Rate AS r ON r.product_id = p.id
WHERE
    isOnSale = TRUE
GROUP BY
    p.id;

SELECT
    p.*,
    COUNT(op.product_id) AS `total_order_count`,
    AVG(r.score) AS `avg_rating`
FROM
    OrderProduct AS op
    RIGHT JOIN Product AS p ON op.product_id = p.id
    LEFT JOIN Rate AS r ON r.product_id = p.id
GROUP BY
    p.id
ORDER BY
    `total_order_count` DESC;

SELECT
    p.*,
    COUNT(r.score) AS `rating_times`,
    AVG(r.score) AS `avg_rating`
FROM
    Rate AS r
    RIGHT JOIN Product AS p ON r.product_id = p.id
GROUP BY
    p.id
ORDER BY
    `avg_rating` DESC;