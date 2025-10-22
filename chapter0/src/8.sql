WITH local_consumption AS (
  SELECT
    td.userid,
    SUM(td.amount) AS local_spending_amount,
    COUNT(*) AS local_transaction_count
  FROM
    transaction_data AS td
    LEFT OUTER JOIN customer_data AS cd ON td.userid = cd.userid
  WHERE
    td.location = cd.area
  GROUP BY
    td.userid
),
high_local_spenders AS (
  SELECT
    userid
  FROM
    local_consumption
  ORDER BY
    local_spending_amount DESC
  LIMIT
    100
), customer_analysis AS (
  SELECT
    cd.income,
    cd.age,
    cd.job,
    cd.device,
    cd.education,
    cd.gender,
    cd.family,
    cd.interest,
    MIN(td.date) AS start_date,
    MAX(td.date) AS end_date,
    COUNT(DISTINCT cd.userid) AS customer_count,
    AVG(lc.local_spending_amount) AS avg_local_spending,
    SUM(lc.local_spending_amount) AS total_local_spending,
    AVG(lc.local_transaction_count) AS avg_local_transactions
  FROM
    customer_data AS cd
    INNER JOIN high_local_spenders AS hls ON cd.userid = hls.userid
    LEFT OUTER JOIN local_consumption AS lc ON cd.userid = lc.userid
    LEFT OUTER JOIN transaction_data AS td ON cd.userid = td.userid
  WHERE
    NOT cd.income IS NULL
  GROUP BY
    cd.income,
    cd.age,
    cd.job,
    cd.device,
    cd.education,
    cd.gender,
    cd.family,
    cd.interest
)
SELECT
  income,
  age,
  job,
  device,
  education,
  gender,
  family,
  interest,
  start_date,
  end_date,
  customer_count,
  avg_local_spending,
  total_local_spending,
  avg_local_transactions
FROM
  customer_analysis
ORDER BY
  income,
  avg_local_spending DESC NULLS LAST