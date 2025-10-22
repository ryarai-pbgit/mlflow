WITH customer_overdue_status AS (
  SELECT
    cd.userid,
    cd.age,
    cd.area,
    cd.device,
    cd.education,
    cd.family,
    cd.gender,
    cd.income,
    cd.interest,
    cd.job,
    CASE
      WHEN NOT ot.userid IS NULL THEN 'Has Overdue'
      ELSE 'No Overdue'
    END AS overdue_status
  FROM
    customer_data AS cd
    LEFT OUTER JOIN overdue_table AS ot ON cd.userid = ot.userid
),
travel_spending AS (
  SELECT
    td.userid,
    AVG(td.amount) AS avg_travel_amount,
    SUM(td.amount) AS total_travel_amount,
    COUNT(*) AS travel_transaction_count
  FROM
    transaction_data AS td
  WHERE
    td.category = 'Travel'
  GROUP BY
    td.userid
),
customer_analysis AS (
  SELECT
    cos.overdue_status,
    cos.age,
    cos.area,
    cos.device,
    cos.education,
    cos.family,
    cos.gender,
    cos.income,
    cos.interest,
    cos.job,
    COALESCE(ts.avg_travel_amount, 0) AS avg_travel_amount,
    COALESCE(ts.total_travel_amount, 0) AS total_travel_amount,
    COALESCE(ts.travel_transaction_count, 0) AS travel_transaction_count
  FROM
    customer_overdue_status AS cos
    LEFT OUTER JOIN travel_spending AS ts ON cos.userid = ts.userid
)
SELECT
  overdue_status,
  COUNT(*) AS customer_count,
  AVG(avg_travel_amount) AS avg_travel_spending_per_customer,
  AVG(total_travel_amount) AS avg_total_travel_spending,
  AVG(travel_transaction_count) AS avg_travel_transactions,
  COUNT(
    CASE
      WHEN income = '300-500万円' THEN 1
    END
  ) AS income_300_500,
  COUNT(
    CASE
      WHEN income = '500-700万円' THEN 1
    END
  ) AS income_500_700,
  COUNT(
    CASE
      WHEN income = '1000万円以上' THEN 1
    END
  ) AS income_1000_plus,
  COUNT(
    CASE
      WHEN age = '25-34' THEN 1
    END
  ) AS age_25_34,
  COUNT(
    CASE
      WHEN age = '35-44' THEN 1
    END
  ) AS age_35_44,
  COUNT(
    CASE
      WHEN age = '65+' THEN 1
    END
  ) AS age_65_plus,
  COUNT(
    CASE
      WHEN gender = '男性' THEN 1
    END
  ) AS male_count,
  COUNT(
    CASE
      WHEN gender = '女性' THEN 1
    END
  ) AS female_count
FROM
  customer_analysis
GROUP BY
  overdue_status
ORDER BY
  overdue_status