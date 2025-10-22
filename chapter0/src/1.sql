SELECT
  cd.age,
  cd.income,
  cd.job,
  td.category,
  MIN(td.date) AS start_date,
  MAX(td.date) AS end_date,
  COUNT(*) AS transaction_count,
  SUM(td.amount) AS total_amount
FROM
  overdue_table AS ot
  INNER JOIN customer_data AS cd ON ot.userid = cd.userid
  LEFT OUTER JOIN transaction_data AS td ON cd.userid = td.userid
WHERE
  td.payment = 'Credit Card'
GROUP BY
  cd.age,
  cd.income,
  cd.job,
  td.category
ORDER BY
  cd.age,
  cd.income,
  cd.job,
  td.category
```

- 2件目：一番取引が多いユーザは誰で、どのような取引をしていますか？
```sql
WITH transaction_counts AS (
  SELECT
    t.userid,
    COUNT(t.userid) AS transaction_count
  FROM
    transaction_data AS t
  WHERE
    t.date >= DATE_TRUNC('MONTH', CURRENT_DATE) - INTERVAL '1 MONTH'
    AND t.date < DATE_TRUNC('MONTH', CURRENT_DATE)
  GROUP BY
    t.userid
  ORDER BY
    transaction_count DESC
  LIMIT
    1
), user_transactions AS (
  SELECT
    t.userid,
    t.category,
    t.location,
    t.payment,
    t.date,
    t.amount,
    t.quantity,
    t.unit
  FROM
    transaction_data AS t
    JOIN transaction_counts AS tc ON t.userid = tc.userid
)
SELECT
  ut.userid,
  ut.category,
  ut.location,
  ut.payment,
  ut.date,
  ut.amount,
  ut.quantity,
  ut.unit
FROM
  user_transactions AS ut