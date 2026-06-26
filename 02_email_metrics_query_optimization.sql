-- Project: Email Metrics Query Optimization
-- Description:
-- This query calculates email engagement metrics by operating system
-- and demonstrates query optimization in BigQuery.
--
-- Optimization goals:
-- 1. Select only required columns
-- 2. Remove redundant nested subqueries
-- 3. Reduce data shuffling during joins
-- 4. Keep the same business logic with better performance

WITH
  account_session AS (
    -- Keep only the columns required for final aggregation.
    SELECT
      acs.account_id,
      sp.operating_system
    FROM `DA.account_session` acs
    JOIN `DA.session_params` sp
      ON acs.ga_session_id = sp.ga_session_id
  ),
  email_events AS (
    -- Combine sent, opened, and visited email events.
    -- Message ID is used as the joining key.
    SELECT
      es.id_account,
      es.id_message AS id_message_sent,
      eo.id_message AS id_message_open,
      ev.id_message AS id_message_visit
    FROM `DA.email_sent` es
    LEFT JOIN `DA.email_open` eo
      ON es.id_message = eo.id_message
    LEFT JOIN `DA.email_visit` ev
      ON es.id_message = ev.id_message
  )
SELECT
  acs.operating_system,
  COUNT(DISTINCT ee.id_message_sent) AS sent_msg,
  COUNT(DISTINCT ee.id_message_open) AS open_msg,
  COUNT(DISTINCT ee.id_message_visit) AS visit_msg,
  COUNT(DISTINCT ee.id_message_open) / COUNT(DISTINCT ee.id_message_sent) * 100
    AS open_rate,
  COUNT(DISTINCT ee.id_message_visit) / COUNT(DISTINCT ee.id_message_sent) * 100
    AS click_rate,
  COUNT(DISTINCT ee.id_message_visit) / COUNT(DISTINCT ee.id_message_open) * 100
    AS ctor
FROM `DA.account` a
JOIN email_events ee
  ON a.id = ee.id_account
JOIN account_session acs
  ON a.id = acs.account_id
WHERE a.is_unsubscribed = 0
GROUP BY acs.operating_system;

-- Optimization results:
-- Elapsed time: 3.44 sec -> 1.06 sec (~3x faster)
-- Slot time consumed: 8.08 sec -> 2.4 sec (~3x lower)
-- Bytes shuffled: 57.57 MB -> 354 B
