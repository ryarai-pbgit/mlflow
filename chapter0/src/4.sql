WITH device_overdue_analysis AS (
  SELECT
    cd.device,
    COUNT(*) AS total_users,
    COUNT(ot.userid) AS overdue_users
  FROM
    customer_data AS cd
    LEFT OUTER JOIN overdue_table AS ot ON cd.userid = ot.userid
  GROUP BY
    cd.device
)
SELECT
  device,
  total_users,
  overdue_users,
  CASE
    WHEN total_users > 0 THEN CAST(overdue_users AS FLOAT) / NULLIF(total_users, 0)
    ELSE 0
  END AS overdue_rate
FROM
  device_overdue_analysis
ORDER BY
  overdue_rate ASC