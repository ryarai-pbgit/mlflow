SELECT
  cd.education,
  MIN(td.date) AS start_date,
  MAX(td.date) AS end_date,
  AVG(td.amount) AS avg_transaction_amount
FROM
  transaction_data AS td
  LEFT OUTER JOIN customer_data AS cd ON td.userid = cd.userid
WHERE
  NOT cd.education IS NULL
GROUP BY
  cd.education
ORDER BY
  avg_transaction_amount DESC NULLS LAST