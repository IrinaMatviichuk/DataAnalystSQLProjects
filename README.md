# SQL Portfolio

This repository contains SQL projects completed during my Data Analytics learning journey.

Each project focuses on solving real analytical tasks using SQL and demonstrates practical skills in:

* data cleaning and transformation
* joins and aggregations
* Common Table Expressions (CTEs)
* window functions
* analytical dataset preparation for BI dashboards

Detailed project documentation, business context, methodology, and dashboard screenshots are available in the `/docs` folder.

## Projects

### 01. E-commerce Account and Email Activity Analysis

Builds an analytical dataset for tracking account creation and email engagement across countries and customer segments.

**Skills:**
SQL, BigQuery, CTEs, JOINs, UNION ALL, Window Functions, Looker Studio

**Key metrics:**

* account count
* sent emails
* opened emails
* email visits
* country rankings

### 02. Email Metrics Query Optimization

Optimized a BigQuery SQL query for calculating email engagement metrics by operating system.

**Skills:**
SQL, BigQuery, Query Optimization, CTEs, JOINs, Aggregation, Performance Analysis

**Key result:**
Reduced elapsed time from 3.44 sec to 1.06 sec and bytes shuffled from 57.57 MB to 354 B.

### 03. Monthly Email Account Share View

Creates a BigQuery view that calculates each account’s share of total sent emails within a month, including first and last email activity dates.

**Skills:**
SQL, BigQuery, CREATE VIEW, CTEs, Aggregation, Date Functions

**Key metrics:**

* monthly sent email share by account
* first sent date
* last sent date

