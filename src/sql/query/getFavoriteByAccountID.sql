SELECT
    f.*,
    p.name AS 'product_name',
    p.price AS 'product_price',
    p.isOnSale AS 'product_isOnSale',
    p.avg_rating AS 'product_avg_rating'
FROM
    Account AS a
    LEFT JOIN Favorite AS f ON a.id = f.account_id
    INNER JOIN (
        SELECT
            Product.*,
            AVG(Rate.score) AS 'avg_rating'
        FROM
            Product
            LEFT JOIN Rate ON Rate.product_id = Product.id
        GROUP BY
            Product.id
    ) AS p ON f.product_id = p.id
WHERE
    a.id = 1;