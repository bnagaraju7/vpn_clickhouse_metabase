-- =============================================================================
-- Web Data Infrastructure & Tracking - ClickHouse Schema
-- Covers: Sign Up/Sign In (Project 1) + User Acquisition (Project 2)
-- =============================================================================

-- Drop existing objects (run in dev only)
-- DROP TABLE IF EXISTS web_events.events;
-- DROP DATABASE IF EXISTS web_events;

CREATE DATABASE IF NOT EXISTS web_events;

-- =============================================================================
-- Main Events Table (Unified schema for both projects)
-- ReplacingMergeTree: deduplicates by primary key (event_time, visitor_id).
-- =============================================================================
CREATE TABLE IF NOT EXISTS web_events.events
(
    visitor_id        LowCardinality(String) DEFAULT '',  -- Required; client-generated, persisted in sessionStorage

    -- Identity & timing (type, timestamps)
    event_type        LowCardinality(String),  -- signup_started, signup_completed, signin_started, signin_completed, page_viewed, checkout_started, checkout_completed, checkout_incomplete, payment_method_added
    event_time        DateTime64(3, 'UTC') DEFAULT now64(3),   -- When event occurred (client or server)

    -- Common properties - LowCardinality for flexible evolution (add sources/pages without ALTER)
    source            Nullable(LowCardinality(String)),  -- Google, Social, Direct, Other
    device_type       Nullable(Enum8('Desktop' = 1, 'Mobile' = 2, 'Tablet' = 3, 'Android' = 4, 'Android TV' = 5, 'Apple TV' = 6)),
    os_type           Nullable(Enum8('Mac' = 1, 'Android' = 2, 'Windows' = 3, 'Linux' = 4, 'iOS' = 5, 'Other' = 6)),
    country           Nullable(LowCardinality(String)),  -- Country code (ISO 3166-1 alpha-2); keep String (high cardinality)
    page      Nullable(LowCardinality(String)),  -- Page viewed/landed (same as page_name): homepage, pricing, sign up page, checkout, Other
    platform          Nullable(Enum8('iOS' = 1, 'Android' = 2, 'web' = 3, 'Windows' = 4, 'iPadOS' = 5, 'MacOS' = 6, 'Linux' = 7, 'Android TV' = 8, 'Apple TV' = 9, 'Other' = 10)),  -- SubscriptionPlatformEnum + TV platforms
    app_version       Nullable(LowCardinality(String)),    -- App version for identification (e.g., 1.2.3, 2.0.0)
    transaction_id    Nullable(LowCardinality(String)),   -- Payment/checkout transaction identifier
    plans             Nullable(Enum8('Weekly' = 1, 'Monthly' = 2, '3-Month' = 3, '6-Month' = 4, 'Yearly' = 5)),  -- SubscriptionLengthEnum
    subscription_status Nullable(Enum8('active' = 1, 'cancelled' = 2, 'canceled' = 3, 'expired' = 4, 'in_trial' = 5, 'past_due' = 6, 'incomplete_expired' = 7, 'free_trial' = 8)),  -- SubscriptionStatusEnum
    -- Payment fields
    amount            Nullable(Decimal64(2)),              -- Transaction/payment amount
    currency          Nullable(Enum8('USD' = 1, 'EUR' = 2, 'GBP' = 3, 'Other' = 4)),
    payment_method    Nullable(LowCardinality(String)),    -- Credit Card, PayPal, Google Pay (method added/selected)
    card_type         Nullable(LowCardinality(String)),    -- visa, mastercard, amex (credit card brand, if applicable)

    -- Event properties (ClickHouse native JSON type, requires 25.3+)
    message           Nullable(JSON),                     -- Parsed JSON: {"signup_method":"email",...} (page name in message)

    -- Identifiers (PII - consider retention/access policies)
    user_id           Nullable(UInt64),
    device_id         Nullable(LowCardinality(String)),
    email_hash        Nullable(LowCardinality(String))     -- SHA-512 hash
)
ENGINE = ReplacingMergeTree()
PARTITION BY toYYYYMM(event_time)   -- Monthly partition (YYYYMM)
ORDER BY (event_time, visitor_id)
TTL toDate(event_time) + INTERVAL 2 YEAR
SETTINGS index_granularity = 8192;

-- =============================================================================
-- Materialized View: Daily Sign Up Started (Project 1 - Dashboard acceleration)
-- =============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS web_events.mv_daily_signup_started
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(event_time)
ORDER BY (event_date, signup_method, device_type)
AS SELECT
    toDate(event_time) AS event_date,
    toString(message.signup_method) AS signup_method,
    device_type,
    count() AS event_count
FROM web_events.events
WHERE event_type = 'signup_started'
GROUP BY toDate(event_time), signup_method, device_type;

-- =============================================================================
-- Materialized View: Daily Sign Up Completed (Project 1)
-- =============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS web_events.mv_daily_signup_completed
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(event_time)
ORDER BY (event_date, signup_method, device_type)
AS SELECT
    toDate(event_time) AS event_date,
    toString(message.signup_method) AS signup_method,
    device_type,
    count() AS event_count
FROM web_events.events
WHERE event_type = 'signup_completed'
GROUP BY toDate(event_time), signup_method, device_type;

-- =============================================================================
-- Materialized View: Daily Page Views (Project 2 - Dashboard acceleration)
-- =============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS web_events.mv_daily_page_views
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(event_time)
ORDER BY (event_date, page, source, device_type, country)
AS SELECT
    toDate(event_time) AS event_date,
    page,
    source,
    device_type,
    country,
    count() AS view_count
FROM web_events.events
WHERE event_type = 'page_viewed'
GROUP BY toDate(event_time), page, source, device_type, country;
