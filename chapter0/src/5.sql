WITH regional_sales AS (
  SELECT
    td.location,
    SUM(td.amount) AS total_sales,
    COUNT(*) AS transaction_count
  FROM
    transaction_data AS td
  GROUP BY
    td.location
),
low_sales_regions AS (
  SELECT
    location
  FROM
    regional_sales
  ORDER BY
    total_sales ASC
  LIMIT
    5
), regional_characteristics AS (
  SELECT
    td.location,
    td.category,
    td.payment,
    cd.age,
    cd.income,
    cd.job,
    cd.device,
    cd.education,
    cd.gender,
    MIN(td.date) AS start_date,
    MAX(td.date) AS end_date,
    COUNT(*) AS transaction_count,
    SUM(td.amount) AS total_amount,
    AVG(td.amount) AS avg_amount
  FROM
    transaction_data AS td
    LEFT OUTER JOIN customer_data AS cd ON td.userid = cd.userid
  WHERE
    td.location IN (
      SELECT
        location
      FROM
        low_sales_regions
    )
  GROUP BY
    td.location,
    td.category,
    td.payment,
    cd.age,
    cd.income,
    cd.job,
    cd.device,
    cd.education,
    cd.gender
)
SELECT
  location,
  category,
  payment,
  age,
  income,
  job,
  device,
  education,
  gender,
  start_date,
  end_date,
  transaction_count,
  total_amount,
  avg_amount
FROM
  regional_characteristics
ORDER BY
  location,
  total_amount DESC NULLS LAST