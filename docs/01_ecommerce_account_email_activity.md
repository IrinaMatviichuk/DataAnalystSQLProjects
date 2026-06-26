# E-commerce Account and Email Activity Analysis

## Project Overview

This project focuses on building an analytical dataset for evaluating account creation and email engagement in an e-commerce environment.

The goal was to combine user account data and email interaction data into a single dataset suitable for BI reporting and further analytical exploration.

---

## Business Problem

Marketing and product teams need to understand:

* how account creation changes over time;
* which countries generate the most subscribers;
* how users interact with email campaigns;
* how customer segments differ by subscription and verification status.

This analysis helps identify high-performing markets and evaluate email communication effectiveness.

---

## Dataset

The analysis was built using multiple relational tables from an e-commerce database:

* `account`
* `account_session`
* `session`
* `session_params`
* `email_sent`
* `email_open`
* `email_visit`

The final dataset combines account-level and email-level activity.

---

## Analytical Dimensions

Metrics were analyzed across the following dimensions:

* **date**
* **country**
* **send_interval**
* **is_verified**
* **is_unsubscribed**

These dimensions enable segmentation by geography, account status, and communication preferences.

---

## SQL Approach

The analytical dataset was built in Google BigQuery using several transformation stages:

### 1. Account Metrics Calculation

Calculated the number of created accounts by analytical dimensions.

### 2. Email Metrics Calculation

Calculated email engagement metrics:

* sent emails
* opened emails
* visited emails (clicks)

### 3. Dataset Union

Account and email metrics were calculated separately because the `date` dimension has different business meaning:

* account creation date for account metrics
* email sent date for email metrics

The datasets were combined using `UNION ALL`.

### 4. Aggregation and Ranking

The final step aggregated metrics and calculated country rankings using window functions.

Implemented SQL techniques:

* CTEs
* INNER JOIN / LEFT JOIN
* Aggregation
* COUNT DISTINCT
* UNION ALL
* Window Functions (`RANK`)
* Date transformation (`DATE_ADD`)

---

## Key Metrics

### Core Metrics

* **account_cnt** — number of created accounts
* **sent_msg** — number of sent emails
* **open_msg** — number of opened emails
* **visit_msg** — number of email visits/clicks

### Additional Metrics

* **total_country_account_cnt**
* **total_country_sent_cnt**
* **rank_total_country_account_cnt**
* **rank_total_country_sent_cnt**

---

## Dashboard

The final dataset was used to build a Looker Studio dashboard.

Dashboard visualizations included:

* total accounts by country
* total sent emails by country
* country rankings
* email activity trends over time

> Add dashboard screenshots below.

---

## Key Outcome

This project demonstrates the ability to:

* transform raw relational data into analytical datasets;
* design reusable reporting datasets;
* apply advanced SQL for business analytics;
* prepare clean datasets for BI dashboards and stakeholder reporting.

---

## Tools

* SQL
* Google BigQuery
* Looker Studio
* GitHub
