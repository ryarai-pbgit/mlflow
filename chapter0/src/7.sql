WITH food_drink_users AS (
  SELECT
    DISTINCT td.userid
  FROM
    transaction_data AS td
  WHERE
    td.category = 'Food & Drink'
),
food_drink_transactions AS (
  SELECT
    td.userid,
    td.date,
    td.category
  FROM
    transaction_data AS td
  WHERE
    td.userid IN (
      SELECT
        userid
      FROM
        food_drink_users
    )
    AND td.category = 'Food & Drink'
),
subsequent_transactions AS (
  SELECT
    fdt.userid,
    fdt.date AS food_drink_date,
    td.date AS subsequent_date,
    td.category AS subsequent_category
  FROM
    food_drink_transactions AS fdt
    JOIN transaction_data AS td ON fdt.userid = td.userid
  WHERE
    td.date > fdt.date
    AND td.category <> 'Food & Drink'
),
next_category_analysis AS (
  SELECT
    subsequent_category,
    COUNT(*) AS purchase_count,
    COUNT(DISTINCT userid) AS unique_users
  FROM
    subsequent_transactions
  GROUP BY
    subsequent_category
)
SELECT
  subsequent_category,
  purchase_count,
  unique_users,
  CAST(purchase_count AS FLOAT) / NULLIF(
    NULLIF(
      (
        SELECT
          SUM(purchase_count)
        FROM
          next_category_analysis
      ),
      0
    ),
    0
  ) AS category_ratio
FROM
  next_category_analysis
ORDER BY
  purchase_count DESC NULLS LAST