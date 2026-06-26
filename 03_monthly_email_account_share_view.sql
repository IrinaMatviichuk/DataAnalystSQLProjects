-- Project: Monthly Email Account Share View
-- Description:
-- Create a BigQuery view that calculates each account's share
-- of sent email messages within each month.

CREATE VIEW `Students.im_aggregation_data_with_view`
AS
WITH
  CTE_email_sent_data AS (
    -- Prepare email sent data and calculate:
    -- 1. actual sent date
    -- 2. first day of the corresponding month
    SELECT
      es.id_message,
      es.id_account,
      DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS sent_date,
      DATE(
        EXTRACT(YEAR FROM DATE_ADD(s.date, INTERVAL es.sent_date DAY)),
        EXTRACT(MONTH FROM DATE_ADD(s.date, INTERVAL es.sent_date DAY)),
        1) AS sent_month
    FROM `DA.email_sent` AS es
    JOIN `DA.account_session` AS ac
      ON es.id_account = ac.account_id
    JOIN `DA.session` AS s
      ON ac.ga_session_id = s.ga_session_id
  ),
  CTE_account_month_metrics AS (
    -- Calculate account-level monthly metrics:
    -- number of sent messages,
    -- first sent date,
    -- last sent date
    SELECT
      sent_month,
      id_account,
      COUNT(id_message) AS sent_msg_count,
      MIN(sent_date) AS first_sent_date,
      MAX(sent_date) AS last_sent_date
    FROM CTE_email_sent_data
    GROUP BY
      sent_month,
      id_account
  ),
  CTE_month_metrics AS (
    -- Calculate total number of sent messages for each month
    SELECT
      sent_month,
      COUNT(id_message) AS total_sent_msg_count
    FROM CTE_email_sent_data
    GROUP BY sent_month
  )

-- Calculate each account's percentage contribution
-- to total monthly sent messages
SELECT
  es.sent_month,
  es.id_account,
  es.sent_msg_count / mm.total_sent_msg_count * 100
    AS sent_msg_percent_from_this_month,
  es.first_sent_date,
  es.last_sent_date
FROM CTE_account_month_metrics AS es
JOIN CTE_month_metrics AS mm
  ON es.sent_month = mm.sent_month;

-- Query the created view for validation
SELECT *
FROM `Students.im_aggregation_data_with_view`
ORDER BY sent_msg_percent_from_this_month DESC;
