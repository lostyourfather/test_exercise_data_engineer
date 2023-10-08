SELECT id, property, created_at
FROM Item
INNER JOIN
(
    SELECT
        id,
        MAX(created_at) AS m_created_at
    FROM Item GROUP BY id
) AS max_date ON max_date.id = Item.id AND max_date.m_created_at = Item.created_at;
