WITH monthly_sales AS (
  SELECT
    DATE_TRUNC('MONTH', td.date) AS month,
    SUM(td.amount) AS monthly_sales,
    COUNT(*) AS transaction_count,
    AVG(td.amount) AS avg_transaction_amount
  FROM
    transaction_data AS td
  WHERE
    td.category = 'Food & Drink'
  GROUP BY
    DATE_TRUNC('MONTH', td.date)
),
mom_analysis AS (
  SELECT
    curr.month AS curr_month,
    prev.month AS prev_month,
    curr.monthly_sales AS curr_monthly_sales,
    prev.monthly_sales AS prev_monthly_sales,
    curr.transaction_count AS curr_transaction_count,
    prev.transaction_count AS prev_transaction_count,
    curr.avg_transaction_amount AS curr_avg_transaction_amount,
    prev.avg_transaction_amount AS prev_avg_transaction_amount,
    curr.monthly_sales - prev.monthly_sales AS mom_sales_chg,
    CASE
      WHEN prev.monthly_sales <> 0 THEN (curr.monthly_sales - prev.monthly_sales) / NULLIF(prev.monthly_sales, 0)
    END AS mom_sales_pct_chg
  FROM
    monthly_sales AS curr
    LEFT JOIN monthly_sales AS prev ON curr.month = prev.month + INTERVAL '1 MONTH'
)
SELECT
  curr_month,
  prev_month,
  curr_monthly_sales,
  prev_monthly_sales,
  curr_transaction_count,
  prev_transaction_count,
  curr_avg_transaction_amount,
  prev_avg_transaction_amount,
  mom_sales_chg,
  mom_sales_pct_chg,
  (
    SELECT
      MIN(date)
    FROM
      transaction_data
    WHERE
      category = 'Food & Drink'
  ) AS start_date,
  (
    SELECT
      MAX(date)
    FROM
      transaction_data
    WHERE
      category = 'Food & Drink'
  ) AS end_date
FROM
  mom_analysis
ORDER BY
  curr_month DESC NULLS LAST