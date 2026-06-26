# Email Metrics Query Optimization

## Project Overview

This project focuses on optimizing a BigQuery SQL query used to calculate email engagement metrics by operating system.

The goal was to keep the same business logic while improving query performance and reducing resource usage.

---

## Original Task

The task was to optimize an existing query that calculated email metrics across operating systems.

The required metrics were:

* sent emails
* opened emails
* clicked emails
* open rate
* click rate
* click-to-open rate (CTOR)

---

## Initial Query

```sql
SELECT
 account_session.operating_system,
 COUNT(DISTINCT id_message_sent) AS sent_msg,
 COUNT(DISTINCT id_message_open) AS open_msg,
 COUNT(DISTINCT id_message_visit) AS vist_msg,
 COUNT(DISTINCT id_message_open) / COUNT(DISTINCT id_message_sent) * 100 AS open_rate,
 COUNT(DISTINCT id_message_visit) / COUNT(DISTINCT id_message_sent) * 100 AS click_rate,
 COUNT(DISTINCT id_message_visit) / COUNT(DISTINCT id_message_open) * 100 AS ctor,
FROM
 `DA.account` a
JOIN (
 SELECT
   es.id_account AS id_account_sent,
   es.id_message AS id_message_sent,
   es.letter_type AS letter_type_sent,
   es.sent_date,
   eo.id_account AS id_account_open,
   eo.id_message AS id_message_open,
   eo.letter_type AS letter_type_open,
   eo.open_date,
   ev.id_account AS id_account_visit,
   ev.id_message AS id_message_visit,
   ev.letter_type AS letter_type_visit,
   ev.visit_date,
 FROM
   `DA.email_sent` es
 LEFT JOIN (
   SELECT
     *
   FROM
     `DA.email_open` eo )eo
 ON
   es.id_message = eo.id_message
 LEFT JOIN (
   SELECT
     *
   FROM
     `DA.email_visit` ev )ev
 ON
   es.id_message = ev.id_message ) email_sent
ON
 a.id = email_sent.id_account_sent
JOIN (
 SELECT
   acs.account_id,
   acs.ga_session_id,
   sp.continent,
   sp.device,
   sp.country,
   sp.channel,
   sp.language,
   sp.mobile_model_name,
   sp.operating_system
 FROM
   `DA.account_session` acs
 JOIN
   `DA.session_params` sp
 ON
   acs.ga_session_id = sp.ga_session_id )account_session
ON
 a.id = account_session.account_id
WHERE
 a.is_unsubscribed = 0
GROUP BY
 account_session.operating_system
```

---

## Optimization Approach

The original query selected many columns that were not used in the final result and contained redundant nested subqueries.

The optimized version improves performance by:

* selecting only required columns;
* removing unnecessary `SELECT *` subqueries;
* simplifying the query structure with CTEs;
* reducing intermediate data volume;
* reducing data shuffling during joins.

---

## Optimized Query

The optimized SQL script is available here:

`02_email_metrics_query_optimization.sql`

---

## Performance Comparison

### Before Optimization

* Elapsed time: **3.44 sec**
* Slot time consumed: **8.08 sec**
* Bytes shuffled: **57.57 MB**

### After Optimization

* Elapsed time: **1.06 sec**
* Slot time consumed: **2.4 sec**
* Bytes shuffled: **354 B**

---

## Result

The optimized query runs approximately **3 times faster** and significantly reduces resource usage.

The business logic stayed the same, but the query became cleaner, more readable, and more efficient.

---

## Tools

* SQL
* Google BigQuery
* GitHub
