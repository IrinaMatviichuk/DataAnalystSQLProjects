# Monthly Email Account Share View

## Project Overview

This project focuses on building a reusable BigQuery view for monthly email activity analysis at the account level.

The goal was to calculate each account’s contribution to the total number of sent email messages within a specific month.

---

## Business Problem

Email activity often varies significantly across accounts.
To better understand account-level engagement, it is useful to identify:

* which accounts generate the highest share of sent emails;
* when email activity starts during the month;
* when the last email activity occurs.

This helps analyze account activity distribution and identify highly active accounts.

---

## Original Task

Create a SQL view with the following output structure:

* `sent_month`
* `id_account`
* `sent_msg_percent_from_this_month`
* `first_sent_date`
* `last_sent_date`

The solution had an additional technical requirement:

* nested subqueries could not exceed one level.

To satisfy this requirement, the query was structured using Common Table Expressions (CTEs).

---

## SQL Approach

The view was built in several transformation steps.

### 1. Email Sent Data Preparation

The first CTE prepares source email data.

It calculates:

* account identifier
* email message identifier
* actual sent date
* corresponding month of the sent email

Since `sent_date` is stored as an offset relative to session date, `DATE_ADD()` is used to calculate the actual email sent date.

---

### 2. Account-Level Monthly Metrics

The second CTE aggregates data at the account and month level.

For each account and month, the query calculates:

* number of sent messages
* first sent email date
* last sent email date

Aggregation functions used:

* `COUNT`
* `MIN`
* `MAX`

---

### 3. Monthly Totals

The third CTE calculates total sent messages for each month.

This provides the denominator for calculating account-level monthly share.

---

### 4. Final View Calculation

The final query joins account-level metrics with monthly totals and calculates:

**sent_msg_percent_from_this_month**

This metric shows what percentage of all sent emails in a given month belongs to a specific account.

Formula:

```sql
sent messages by account / total sent messages in month * 100
```

---

## Key Metrics

### sent_msg_percent_from_this_month

Percentage contribution of an account to total monthly sent emails.

### first_sent_date

The earliest sent email date for the account within the month.

### last_sent_date

The latest sent email date for the account within the month.

---

## SQL Techniques Used

* CREATE VIEW
* Common Table Expressions (CTEs)
* JOINs
* Aggregation
* COUNT
* MIN / MAX
* DATE_ADD
* EXTRACT
* Date transformation

---

## Result

The final view provides a reusable monthly analytical dataset that can be used for:

* reporting
* activity monitoring
* downstream analytics
* BI dashboards

It enables efficient analysis of account-level email activity and monthly contribution.

---

## Tools

* SQL
* Google BigQuery
* GitHub
