CREATE OR REPLACE TABLE `Students.im_sql_advanced_module_task`
AS

-- Final dataset for e-commerce account and email activity analysis.
-- The dataset combines account creation metrics and email engagement metrics
-- by date, country, send interval, verification status, and subscription status.
WITH
  CTE_accounts AS (
    -- Calculate the number of created accounts.
    -- For account metrics, the date represents the account/session creation date.
    SELECT
      s.date AS date,
      sp.country,
      a.send_interval,
      a.is_verified,
      a.is_unsubscribed,
      COUNT(DISTINCT a.id) AS account_cnt,
      0 AS sent_msg,
      0 AS open_msg,
      0 AS visit_msg
    FROM `DA.account_session` acs
    JOIN `DA.account` a
      ON acs.account_id = a.id
    JOIN `DA.session` s
      ON acs.ga_session_id = s.ga_session_id
    JOIN `DA.session_params` sp
      ON acs.ga_session_id = sp.ga_session_id
    GROUP BY
      s.date,
      sp.country,
      a.send_interval,
      a.is_verified,
      a.is_unsubscribed
  ),
  CTE_emails AS (
    -- Calculate email engagement metrics:
    -- sent messages, opened messages, and visited messages.
    -- For email metrics, the date represents the email sent date.
    -- DATE_ADD is used because sent_date is stored as an offset from the session date.
    SELECT
      DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
      sp.country,
      a.send_interval,
      a.is_verified,
      a.is_unsubscribed,
      0 AS account_cnt,
      COUNT(DISTINCT es.id_message) AS sent_msg,
      COUNT(DISTINCT eo.id_message) AS open_msg,
      COUNT(DISTINCT ev.id_message) AS visit_msg
    FROM `DA.email_sent` es
    JOIN `DA.account` a
      ON es.id_account = a.id
    JOIN `DA.account_session` acs
      ON a.id = acs.account_id
    JOIN `DA.session` s
      ON acs.ga_session_id = s.ga_session_id
    JOIN `DA.session_params` sp
      ON acs.ga_session_id = sp.ga_session_id
    LEFT JOIN `DA.email_open` eo
      ON es.id_message = eo.id_message
    LEFT JOIN `DA.email_visit` ev
      ON es.id_message = ev.id_message
    GROUP BY
      DATE_ADD(s.date, INTERVAL es.sent_date DAY),
      sp.country,
      a.send_interval,
      a.is_verified,
      a.is_unsubscribed
  ),
  CTE_union AS (
    -- Combine account metrics and email metrics into one dataset.
    -- UNION ALL is used to keep all records and avoid removing valid rows.
    SELECT * FROM CTE_accounts
    UNION ALL
    SELECT * FROM CTE_emails
  ),
  CTE_grouped AS (
    -- Aggregate metrics after UNION ALL to get final values
    -- for each combination of analytical dimensions.
    SELECT
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed,
      SUM(account_cnt) AS account_cnt,
      SUM(sent_msg) AS sent_msg,
      SUM(open_msg) AS open_msg,
      SUM(visit_msg) AS visit_msg
    FROM CTE_union
    GROUP BY
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed
  ),
  CTE_country_totals AS (
    -- Calculate country-level totals and country rankings.
    -- Window functions are used to rank countries by account creation
    -- and email sending volume.
    SELECT
      country,
      SUM(account_cnt) AS total_country_account_cnt,
      SUM(sent_msg) AS total_country_sent_cnt,
      RANK()
        OVER (ORDER BY SUM(account_cnt) DESC) AS rank_total_country_account_cnt,
      RANK() OVER (ORDER BY SUM(sent_msg) DESC) AS rank_total_country_sent_cnt
    FROM CTE_grouped
    GROUP BY country
  )

-- Final dataset with only top countries by account creation
-- or email sending volume.
SELECT
  g.date,
  g.country,
  g.send_interval,
  g.is_verified,
  g.is_unsubscribed,
  g.account_cnt,
  g.sent_msg,
  g.open_msg,
  g.visit_msg,
  ct.total_country_account_cnt,
  ct.total_country_sent_cnt,
  ct.rank_total_country_account_cnt,
  ct.rank_total_country_sent_cnt
FROM CTE_grouped g
JOIN CTE_country_totals ct
  ON g.country = ct.country
WHERE
  ct.rank_total_country_account_cnt <= 10
  OR ct.rank_total_country_sent_cnt <= 10;
