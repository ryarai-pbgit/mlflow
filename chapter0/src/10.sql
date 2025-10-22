SELECT
  cd.age,
  COUNT(*) AS overdue_user_count
FROM
  overdue_table AS ot
  INNER JOIN customer_data AS cd ON ot.userid = cd.userid
WHERE
  NOT cd.age IS NULL
GROUP BY
  cd.age
ORDER BY
  overdue_user_count DESC NULLS LAST