-- Project: Revenue by Device and Continent Analysis
-- Description:
-- This query calculates revenue, account, verified account,
-- and session metrics by continent and device type.

WITH
  CTE_revenue_usd AS (
    -- Calculate total revenue for each session.
    SELECT
      o.ga_session_id,
      SUM(p.price) AS revenue
    FROM `DA.order` o
    JOIN `DA.product` p
      ON o.item_id = p.item_id
    GROUP BY o.ga_session_id
  ),

  CTE_session_params AS (
    -- Prepare session-level data with account, device,
    -- continent, and account verification status.
    SELECT DISTINCT
      sp.ga_session_id,
      acs.account_id AS account_id,
      sp.device,
      sp.continent,
      a.is_verified AS is_verified
    FROM `DA.session_params` sp
    LEFT JOIN `DA.account_session` acs
      ON sp.ga_session_id = acs.ga_session_id
    LEFT JOIN `DA.account` a
      ON acs.account_id = a.id
  ),

  CTE_aggregated AS (
    -- Aggregate revenue, account, verified account,
    -- and session metrics by continent.
    SELECT
      sp.continent,
      SUM(r.revenue) AS revenue,
      SUM(CASE WHEN sp.device = 'mobile' THEN r.revenue ELSE 0 END)
        AS revenue_from_mobile,
      SUM(CASE WHEN sp.device = 'desktop' THEN r.revenue ELSE 0 END)
        AS revenue_from_desktop,
      COUNT(DISTINCT sp.account_id) AS account_cnt,
      COUNT(DISTINCT CASE WHEN sp.is_verified = 1 THEN sp.account_id END)
        AS verified_account,
      COUNT(DISTINCT sp.ga_session_id) AS session_cnt
    FROM CTE_session_params sp
    LEFT JOIN CTE_revenue_usd r
      ON sp.ga_session_id = r.ga_session_id
    GROUP BY sp.continent
  )

-- Final result with revenue split, revenue share,
-- account metrics, and session count by continent.
SELECT
  continent AS `Continent`,
  revenue AS `Revenue`,
  revenue_from_mobile AS `Revenue from Mobile`,
  revenue_from_desktop AS `Revenue from Desktop`,
  revenue / SUM(revenue) OVER () * 100 AS `% Revenue from Total`,
  account_cnt AS `Account Count`,
  verified_account AS `Verified Account`,
  session_cnt AS `Session Count`
FROM CTE_aggregated;
