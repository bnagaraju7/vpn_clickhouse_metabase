-- =============================================================================
-- PROJECT 2: User Acquisition Dashboards
-- Metabase variables: date_from, date_to (Date), landing_page, source, device_type,
-- country, plan_filter, payment_method (Text - optional). landing_page = page viewed (same as page_name).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Page Views by Page
-- TITLE: Page Views by Page | CHART: Bar
-- -----------------------------------------------------------------------------
SELECT
    landing_page AS "Page",
    count() AS "View Count"
FROM web_events.events
WHERE event_type = 'page_viewed'
  AND event_date BETWEEN {{date_from}} AND {{date_to}}
  [[ AND landing_page = {{landing_page}} ]]
  [[ AND source = {{source}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND country = {{country}} ]]
GROUP BY landing_page
ORDER BY 2 DESC


-- -----------------------------------------------------------------------------
-- 2. Page Views by Traffic Source
-- TITLE: Page Views by Traffic Source | CHART: Bar
-- -----------------------------------------------------------------------------
SELECT
    landing_page AS "Page",
    source AS "Traffic Source",
    count() AS "View Count"
FROM web_events.events
WHERE event_type = 'page_viewed'
  AND event_date BETWEEN {{date_from}} AND {{date_to}}
  [[ AND landing_page = {{landing_page}} ]]
  [[ AND source = {{source}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND country = {{country}} ]]
GROUP BY landing_page, source
ORDER BY 3 DESC


-- -----------------------------------------------------------------------------
-- 3. Page Views by Device Type
-- TITLE: Page Views by Device Type | CHART: Bar
-- -----------------------------------------------------------------------------
SELECT
    landing_page AS "Page",
    device_type AS "Device Type",
    count() AS "View Count"
FROM web_events.events
WHERE event_type = 'page_viewed'
  AND event_date BETWEEN {{date_from}} AND {{date_to}}
  [[ AND landing_page = {{landing_page}} ]]
  [[ AND source = {{source}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND country = {{country}} ]]
GROUP BY landing_page, device_type
ORDER BY 3 DESC


-- -----------------------------------------------------------------------------
-- 4. Page Views by Country
-- TITLE: Page Views by Country | CHART: Bar
-- -----------------------------------------------------------------------------
SELECT
    landing_page AS "Page",
    country AS "Country",
    count() AS "View Count"
FROM web_events.events
WHERE event_type = 'page_viewed'
  AND event_date BETWEEN {{date_from}} AND {{date_to}}
  [[ AND landing_page = {{landing_page}} ]]
  [[ AND source = {{source}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND country = {{country}} ]]
GROUP BY landing_page, country
ORDER BY 3 DESC


-- -----------------------------------------------------------------------------
-- 5. Funnel 1: Pricing to Purchase
-- TITLE: Pricing to Purchase Funnel | CHART: Funnel
-- plan_filter: Weekly, Monthly, 3-Month, 6-Month, Yearly (optional)
-- -----------------------------------------------------------------------------
WITH users_with_plan AS (
    SELECT DISTINCT coalesce(device_id, session_id, toString(event_id)) AS user_key
    FROM web_events.events
    WHERE event_date BETWEEN {{date_from}} AND {{date_to}}
      AND event_type IN ('page_viewed', 'checkout_started', 'checkout_completed')
      [[ AND (toString(message.plan_selected) = {{plan_filter}} OR toString(message.plan_updated) = {{plan_filter}} OR toString(message.plan_purchased) = {{plan_filter}}) ]]
),
funnel_steps AS (
    SELECT
        coalesce(e.device_id, e.session_id, toString(e.event_id)) AS user_key,
        maxIf(1, e.event_type = 'page_viewed' AND e.landing_page = 'pricing') AS step1_pricing_page,
        maxIf(1, e.event_type IN ('checkout_started', 'page_viewed') AND (toString(e.message.plan_selected) != '' OR toString(e.message.plan_updated) != '')) AS step2_plan_selected,
        maxIf(1, e.event_type = 'page_viewed' AND e.landing_page = 'checkout') AS step3_checkout_page,
        maxIf(1, e.event_type = 'checkout_started') AS step4_checkout_started,
        maxIf(1, e.event_type = 'checkout_completed') AS step5_checkout_completed,
        maxIf(1, e.event_type = 'checkout_completed' AND toString(e.message.plan_purchased) != '') AS step6_purchase_confirmed
    FROM web_events.events e
    WHERE e.event_date BETWEEN {{date_from}} AND {{date_to}}
      AND e.event_type IN ('page_viewed', 'checkout_started', 'checkout_completed')
      AND coalesce(e.device_id, e.session_id, toString(e.event_id)) IN (SELECT user_key FROM users_with_plan)
    GROUP BY user_key
)
SELECT
    '1. Landed on pricing page' AS "Step",
    sum(step1_pricing_page) AS "Users",
    round(100.0 * sum(step1_pricing_page) / nullIf(sum(step1_pricing_page), 0), 2) AS "Conversion %"
FROM funnel_steps
UNION ALL
SELECT '2. Plan selected', sum(step2_plan_selected), round(100.0 * sum(step2_plan_selected) / nullIf(sum(step1_pricing_page), 0), 2) FROM funnel_steps
UNION ALL
SELECT '3. Checkout page', sum(step3_checkout_page), round(100.0 * sum(step3_checkout_page) / nullIf(sum(step1_pricing_page), 0), 2) FROM funnel_steps
UNION ALL
SELECT '4. Checkout started', sum(step4_checkout_started), round(100.0 * sum(step4_checkout_started) / nullIf(sum(step1_pricing_page), 0), 2) FROM funnel_steps
UNION ALL
SELECT '5. Checkout completed', sum(step5_checkout_completed), round(100.0 * sum(step5_checkout_completed) / nullIf(sum(step1_pricing_page), 0), 2) FROM funnel_steps
UNION ALL
SELECT '6. Purchase confirmed', sum(step6_purchase_confirmed), round(100.0 * sum(step6_purchase_confirmed) / nullIf(sum(step1_pricing_page), 0), 2) FROM funnel_steps


-- -----------------------------------------------------------------------------
-- 6. Funnel 2: Checkout to Purchase
-- TITLE: Checkout to Purchase Funnel | CHART: Funnel
-- payment_method filter optional
-- -----------------------------------------------------------------------------
WITH funnel_steps AS (
    SELECT
        coalesce(device_id, session_id, toString(event_id)) AS user_key,
        maxIf(1, event_type = 'checkout_started') AS step1_checkout_started,
        maxIf(1, event_type IN ('checkout_started', 'checkout_completed') AND toString(message.enter_email) = 'valid') AS step2_email_entered,
        maxIf(1, event_type IN ('payment_method_added', 'checkout_started', 'checkout_completed') AND toString(message.payment_method) != '') AS step3_payment_selected,
        maxIf(1, event_type = 'checkout_completed') AS step4_checkout_completed,
        maxIf(1, event_type = 'checkout_completed' AND toString(message.plan_purchased) != '') AS step5_purchase_confirmed
    FROM web_events.events
    WHERE event_date BETWEEN {{date_from}} AND {{date_to}}
      [[ AND toString(message.payment_method) = {{payment_method}} ]]
      AND event_type IN ('checkout_started', 'checkout_completed', 'payment_method_added')
    GROUP BY user_key
)
SELECT
    '1. Checkout started' AS "Step",
    sum(step1_checkout_started) AS "Users",
    round(100.0 * sum(step1_checkout_started) / nullIf(sum(step1_checkout_started), 0), 2) AS "Conversion %"
FROM funnel_steps
UNION ALL
SELECT '2. Email entered', sum(step2_email_entered), round(100.0 * sum(step2_email_entered) / nullIf(sum(step1_checkout_started), 0), 2) FROM funnel_steps
UNION ALL
SELECT '3. Payment method selected', sum(step3_payment_selected), round(100.0 * sum(step3_payment_selected) / nullIf(sum(step1_checkout_started), 0), 2) FROM funnel_steps
UNION ALL
SELECT '4. Checkout completed', sum(step4_checkout_completed), round(100.0 * sum(step4_checkout_completed) / nullIf(sum(step1_checkout_started), 0), 2) FROM funnel_steps
UNION ALL
SELECT '5. Purchase confirmed', sum(step5_purchase_confirmed), round(100.0 * sum(step5_purchase_confirmed) / nullIf(sum(step1_checkout_started), 0), 2) FROM funnel_steps


-- -----------------------------------------------------------------------------
-- 7. Checkout Abandonment by Date
-- TITLE: Checkout Abandonment by Date | CHART: Table or Line
-- -----------------------------------------------------------------------------
SELECT
    event_date AS "Date",
    count() AS "Abandoned",
    countIf(toString(message.plan_selected) != '' OR toString(message.plan_updated) != '') AS "With Plan Selected"
FROM web_events.events
WHERE event_type = 'checkout_incomplete'
  AND event_date BETWEEN {{date_from}} AND {{date_to}}
  [[ AND landing_page = {{landing_page}} ]]
  [[ AND source = {{source}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND country = {{country}} ]]
GROUP BY event_date
ORDER BY 1 DESC
