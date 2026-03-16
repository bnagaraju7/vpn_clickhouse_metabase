-- =============================================================================
-- PROJECT 1: Sign Up & Sign In Dashboards
-- Metabase variables: date_from, date_to (Date), signup_method, device_type,
-- platform, country (Text - optional). Use [[optional]] for optional filters.
-- Connect dashboard filter widgets to map to these variable names.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Sign Up Started - Total events with filters
-- TITLE: Sign Up Started – Total | CHART: Number
-- Filters: signup_method, device_type, platform, country
-- -----------------------------------------------------------------------------
SELECT
    count() AS "Total Sign Up Started",
    countIf(toString(message.enter_email) = 'valid') AS "Valid Email Entries"
FROM web_events.events
WHERE event_type = 'signup_started'
  AND toDate(event_time) BETWEEN {{date_from}} AND {{date_to}}
  [[ AND toString(message.signup_method) = {{signup_method}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND platform = {{platform}} ]]
  [[ AND country = {{country}} ]]


-- -----------------------------------------------------------------------------
-- 2. Sign Up Completed - Total events with filters
-- TITLE: Sign Up Completed – Total | CHART: Number
-- Filters: signup_method, device_type, platform, country
-- -----------------------------------------------------------------------------
SELECT
    count() AS "Total Sign Up Completed",
    countIf(toString(message.account_creation) = 'Success') AS "Successful Accounts"
FROM web_events.events
WHERE event_type = 'signup_completed'
  AND toDate(event_time) BETWEEN {{date_from}} AND {{date_to}}
  [[ AND toString(message.signup_method) = {{signup_method}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND platform = {{platform}} ]]
  [[ AND country = {{country}} ]]


-- -----------------------------------------------------------------------------
-- 3. Sign Up Started - Breakdown by method and device
-- TITLE: Sign Up Breakdown by Method & Device | CHART: Bar
-- -----------------------------------------------------------------------------
SELECT
    toString(message.signup_method) AS "Sign Up Method",
    device_type AS "Device Type",
    count() AS "Event Count"
FROM web_events.events
WHERE event_type = 'signup_started'
  AND toDate(event_time) BETWEEN {{date_from}} AND {{date_to}}
  [[ AND toString(message.signup_method) = {{signup_method}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND platform = {{platform}} ]]
  [[ AND country = {{country}} ]]
GROUP BY 1, 2
ORDER BY 3 DESC


-- -----------------------------------------------------------------------------
-- 4. Funnel 1: Magic Link Sign Up Flow (with platform filter)
-- TITLE: Magic Link Sign Up Funnel | CHART: Funnel
-- -----------------------------------------------------------------------------
WITH funnel_steps AS (
    SELECT
        coalesce(device_id, email_hash, visitor_id) AS user_key,
        maxIf(1, event_type = 'signup_started') AS step1_landed,
        maxIf(1, event_type = 'signup_started' AND toString(message.enter_email) = 'valid') AS step2_valid_email,
        maxIf(1, event_type = 'signup_started' AND toString(message.signup_method) = 'magic link' AND toString(message.magic_link) = 'sent') AS step3_magic_link_sent,
        maxIf(1, event_type = 'signup_completed') AS step4_signup_completed,
        maxIf(1, event_type = 'signup_completed' AND toString(message.account_creation) = 'Success') AS step5_account_created
    FROM web_events.events
    WHERE toDate(event_time) BETWEEN {{date_from}} AND {{date_to}}
      [[ AND platform = {{platform}} ]]
      AND event_type IN ('signup_started', 'signup_completed')
    GROUP BY user_key
)
SELECT
    '1. Landed on sign up page' AS "Step",
    sum(step1_landed) AS "Users",
    round(100.0 * sum(step1_landed) / nullIf(sum(step1_landed), 0), 2) AS "Conversion %"
FROM funnel_steps
UNION ALL
SELECT '2. Valid email entered', sum(step2_valid_email), round(100.0 * sum(step2_valid_email) / nullIf(sum(step1_landed), 0), 2) FROM funnel_steps
UNION ALL
SELECT '3. Magic link sent', sum(step3_magic_link_sent), round(100.0 * sum(step3_magic_link_sent) / nullIf(sum(step1_landed), 0), 2) FROM funnel_steps
UNION ALL
SELECT '4. Sign up completed', sum(step4_signup_completed), round(100.0 * sum(step4_signup_completed) / nullIf(sum(step1_landed), 0), 2) FROM funnel_steps
UNION ALL
SELECT '5. Account created', sum(step5_account_created), round(100.0 * sum(step5_account_created) / nullIf(sum(step1_landed), 0), 2) FROM funnel_steps


-- -----------------------------------------------------------------------------
-- 5. Funnel 2: Password/OTP Sign Up Flow (with platform filter)
-- TITLE: Password/OTP Sign Up Funnel | CHART: Funnel
-- -----------------------------------------------------------------------------
WITH funnel_steps AS (
    SELECT
        coalesce(device_id, email_hash, visitor_id) AS user_key,
        maxIf(1, event_type = 'signup_started') AS step1_landed,
        maxIf(1, event_type = 'signup_started' AND toString(message.signup_method) = 'email') AS step2_password_flow,
        maxIf(1, event_type = 'signup_started' AND toString(message.enter_email) = 'valid') AS step3_valid_email,
        maxIf(1, event_type = 'signup_started' AND toString(message.otp) = 'sent') AS step4_otp_sent,
        maxIf(1, event_type = 'signup_completed') AS step5_signup_completed,
        maxIf(1, event_type = 'signup_completed' AND toString(message.account_creation) = 'Success') AS step6_account_created
    FROM web_events.events
    WHERE toDate(event_time) BETWEEN {{date_from}} AND {{date_to}}
      [[ AND platform = {{platform}} ]]
      AND event_type IN ('signup_started', 'signup_completed')
    GROUP BY user_key
)
SELECT
    '1. Landed on sign up page' AS "Step",
    sum(step1_landed) AS "Users",
    round(100.0 * sum(step1_landed) / nullIf(sum(step1_landed), 0), 2) AS "Conversion %"
FROM funnel_steps
UNION ALL
SELECT '2. Password sign up selected', sum(step2_password_flow), round(100.0 * sum(step2_password_flow) / nullIf(sum(step1_landed), 0), 2) FROM funnel_steps
UNION ALL
SELECT '3. Valid email entered', sum(step3_valid_email), round(100.0 * sum(step3_valid_email) / nullIf(sum(step1_landed), 0), 2) FROM funnel_steps
UNION ALL
SELECT '4. OTP sent', sum(step4_otp_sent), round(100.0 * sum(step4_otp_sent) / nullIf(sum(step1_landed), 0), 2) FROM funnel_steps
UNION ALL
SELECT '5. Sign up completed', sum(step5_signup_completed), round(100.0 * sum(step5_signup_completed) / nullIf(sum(step1_landed), 0), 2) FROM funnel_steps
UNION ALL
SELECT '6. Account created', sum(step6_account_created), round(100.0 * sum(step6_account_created) / nullIf(sum(step1_landed), 0), 2) FROM funnel_steps


-- -----------------------------------------------------------------------------
-- 6. Sign In Started - Total events with filters
-- TITLE: Sign In Started – Total | CHART: Number
-- Filters: signin_method, device_type, platform, country
-- -----------------------------------------------------------------------------
SELECT
    count() AS "Total Sign In Started",
    countIf(toString(message.enter_email) = 'valid') AS "Valid Email Entries"
FROM web_events.events
WHERE event_type = 'signin_started'
  AND toDate(event_time) BETWEEN {{date_from}} AND {{date_to}}
  [[ AND toString(message.signin_method) = {{signin_method}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND platform = {{platform}} ]]
  [[ AND country = {{country}} ]]


-- -----------------------------------------------------------------------------
-- 7. Sign In Completed - Total events with filters
-- TITLE: Sign In Completed – Total | CHART: Number
-- -----------------------------------------------------------------------------
SELECT
    count() AS "Total Sign In Completed"
FROM web_events.events
WHERE event_type = 'signin_completed'
  AND toDate(event_time) BETWEEN {{date_from}} AND {{date_to}}
  [[ AND toString(message.signin_method) = {{signin_method}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND platform = {{platform}} ]]
  [[ AND country = {{country}} ]]


-- -----------------------------------------------------------------------------
-- 8. Sign In Breakdown - by method and device
-- TITLE: Sign In Breakdown by Method & Device | CHART: Bar
-- -----------------------------------------------------------------------------
SELECT
    toString(message.signin_method) AS "Sign In Method",
    device_type AS "Device Type",
    count() AS "Event Count"
FROM web_events.events
WHERE event_type = 'signin_started'
  AND toDate(event_time) BETWEEN {{date_from}} AND {{date_to}}
  [[ AND toString(message.signin_method) = {{signin_method}} ]]
  [[ AND device_type = {{device_type}} ]]
  [[ AND platform = {{platform}} ]]
  [[ AND country = {{country}} ]]
GROUP BY 1, 2
ORDER BY 3 DESC
