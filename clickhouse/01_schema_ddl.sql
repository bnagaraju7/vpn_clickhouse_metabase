CREATE DATABASE IF NOT EXISTS web_events;

CREATE TABLE IF NOT EXISTS web_events.events
(
    event_id          UUID,
    visitor_id        UUID,
    user_id           Nullable(UUID),
    event_type        LowCardinality(String),
    event_time        DateTime64(3, 'UTC') DEFAULT now64(3),
    source            Nullable(LowCardinality(String)),
    device_type       Nullable(Enum8('Desktop' = 1, 'Mobile' = 2, 'Tablet' = 3, 'Android' = 4, 'Android TV' = 5, 'Apple TV' = 6)),
    os_type           Nullable(Enum8('Mac' = 1, 'Android' = 2, 'Windows' = 3, 'Linux' = 4, 'iOS' = 5, 'Other' = 6)),
    country           Nullable(LowCardinality(String)),
    page              Nullable(LowCardinality(String)),
    platform          Nullable(Enum8('iOS' = 1, 'Android' = 2, 'web' = 3, 'Windows' = 4, 'iPadOS' = 5, 'MacOS' = 6, 'Linux' = 7, 'Android TV' = 8, 'Apple TV' = 9, 'Other' = 10)),
    app_version       Nullable(LowCardinality(String)),
    message           Nullable(JSON)
)
ENGINE = ReplacingMergeTree()
PARTITION BY toYYYYMM(event_time)
ORDER BY (event_id)
SETTINGS index_granularity = 8192;

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
