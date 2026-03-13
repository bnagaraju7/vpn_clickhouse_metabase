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
-- Uses ReplacingMergeTree for deduplication (keeps row with latest ingestion_time per ORDER BY key)
-- =============================================================================
CREATE TABLE IF NOT EXISTS web_events.events
(
    -- Identity & timing (id, type, date)
    event_id          String DEFAULT generateUUIDv4(),
    event_type        LowCardinality(String),  -- signup_started, signup_completed, signin_started, signin_completed, page_viewed, checkout_started, checkout_completed, checkout_incomplete, payment_method_added
    event_date        Date DEFAULT toDate(now()),
    ingestion_time    DateTime64(3) DEFAULT now64(3),   -- Required for ReplacingMergeTree version column (deduplication)

    -- Common properties (Sign Up/Sign In + User Acquisition) - Enum for strict validation
    source            Nullable(Enum8('Google' = 1, 'Social' = 2, 'Bing' = 3, 'Direct' = 4, 'Referral' = 5, 'Other' = 6)),
    device_type       Nullable(Enum8('Desktop' = 1, 'Mobile' = 2, 'Tablet' = 3, 'Android' = 4, 'Android TV' = 5, 'Apple TV' = 6)),
    os_type           Nullable(Enum8('Mac' = 1, 'Android' = 2, 'Windows' = 3, 'Linux' = 4, 'iOS' = 5, 'Other' = 6)),
    country           Nullable(Enum16(
        'AD'=1,'AE'=2,'AF'=3,'AG'=4,'AI'=5,'AL'=6,'AM'=7,'AO'=8,'AQ'=9,'AR'=10,'AS'=11,'AT'=12,'AU'=13,'AW'=14,'AX'=15,'AZ'=16,
        'BA'=17,'BB'=18,'BD'=19,'BE'=20,'BF'=21,'BG'=22,'BH'=23,'BI'=24,'BJ'=25,'BL'=26,'BM'=27,'BN'=28,'BO'=29,'BQ'=30,'BR'=31,'BS'=32,'BT'=33,'BV'=34,'BW'=35,'BY'=36,'BZ'=37,
        'CA'=38,'CC'=39,'CD'=40,'CF'=41,'CG'=42,'CH'=43,'CI'=44,'CK'=45,'CL'=46,'CM'=47,'CN'=48,'CO'=49,'CR'=50,'CU'=51,'CV'=52,'CW'=53,'CX'=54,'CY'=55,'CZ'=56,
        'DE'=57,'DJ'=58,'DK'=59,'DM'=60,'DO'=61,'DZ'=62,
        'EC'=63,'EE'=64,'EG'=65,'EH'=66,'ER'=67,'ES'=68,'ET'=69,
        'FI'=70,'FJ'=71,'FK'=72,'FM'=73,'FO'=74,'FR'=75,
        'GA'=76,'GB'=77,'GD'=78,'GE'=79,'GF'=80,'GG'=81,'GH'=82,'GI'=83,'GL'=84,'GM'=85,'GN'=86,'GP'=87,'GQ'=88,'GR'=89,'GS'=90,'GT'=91,'GU'=92,'GW'=93,'GY'=94,
        'HK'=95,'HM'=96,'HN'=97,'HR'=98,'HT'=99,'HU'=100,
        'ID'=101,'IE'=102,'IL'=103,'IM'=104,'IN'=105,'IO'=106,'IQ'=107,'IR'=108,'IS'=109,'IT'=110,
        'JE'=111,'JM'=112,'JO'=113,'JP'=114,
        'KE'=115,'KG'=116,'KH'=117,'KI'=118,'KM'=119,'KN'=120,'KP'=121,'KR'=122,'KW'=123,'KY'=124,'KZ'=125,
        'LA'=126,'LB'=127,'LC'=128,'LI'=129,'LK'=130,'LR'=131,'LS'=132,'LT'=133,'LU'=134,'LV'=135,'LY'=136,
        'MA'=137,'MC'=138,'MD'=139,'ME'=140,'MF'=141,'MG'=142,'MH'=143,'MK'=144,'ML'=145,'MM'=146,'MN'=147,'MO'=148,'MP'=149,'MQ'=150,'MR'=151,'MS'=152,'MT'=153,'MU'=154,'MV'=155,'MW'=156,'MX'=157,'MY'=158,'MZ'=159,
        'NA'=160,'NC'=161,'NE'=162,'NF'=163,'NG'=164,'NI'=165,'NL'=166,'NO'=167,'NP'=168,'NR'=169,'NU'=170,'NZ'=171,
        'OM'=172,
        'PA'=173,'PE'=174,'PF'=175,'PG'=176,'PH'=177,'PK'=178,'PL'=179,'PM'=180,'PN'=181,'PR'=182,'PS'=183,'PT'=184,'PW'=185,'PY'=186,
        'QA'=187,
        'RE'=188,'RO'=189,'RS'=190,'RU'=191,'RW'=192,
        'SA'=193,'SB'=194,'SC'=195,'SD'=196,'SE'=197,'SG'=198,'SH'=199,'SI'=200,'SJ'=201,'SK'=202,'SL'=203,'SM'=204,'SN'=205,'SO'=206,'SR'=207,'SS'=208,'ST'=209,'SV'=210,'SX'=211,'SY'=212,'SZ'=213,
        'TC'=214,'TD'=215,'TF'=216,'TG'=217,'TH'=218,'TJ'=219,'TK'=220,'TL'=221,'TM'=222,'TN'=223,'TO'=224,'TR'=225,'TT'=226,'TV'=227,'TW'=228,'TZ'=229,
        'UA'=230,'UG'=231,'UM'=232,'US'=233,'UY'=234,'UZ'=235,
        'VA'=236,'VC'=237,'VE'=238,'VG'=239,'VI'=240,'VN'=241,'VU'=242,
        'WF'=243,'WS'=244,
        'YE'=245,'YT'=246,
        'ZA'=247,'ZM'=248,'ZW'=249,
        'UK'=250,'Other'=251
    )),
    landing_page      Nullable(Enum8('homepage' = 1, 'pricing' = 2, 'sign up page' = 3, 'checkout' = 4, 'Other' = 5)),  -- Page viewed/landed (same as page_name)
    platform          Nullable(Enum8('iOS' = 1, 'Android' = 2, 'web' = 3, 'Windows' = 4, 'iPadOS' = 5, 'MacOS' = 6, 'Linux' = 7, 'Android TV' = 8, 'Apple TV' = 9, 'Other' = 10)),  -- SubscriptionPlatformEnum + TV platforms
    app_version       Nullable(String),                   -- App version for identification (e.g., 1.2.3, 2.0.0)
    transaction_id    Nullable(String),                   -- Payment/checkout transaction identifier
    plans             Nullable(Enum8('Weekly' = 1, 'Monthly' = 2, '3-Month' = 3, '6-Month' = 4, 'Yearly' = 5)),  -- SubscriptionLengthEnum
    subscription_status Nullable(Enum8('active' = 1, 'cancelled' = 2, 'canceled' = 3, 'expired' = 4, 'in_trial' = 5, 'past_due' = 6, 'incomplete_expired' = 7, 'free_trial' = 8)),  -- SubscriptionStatusEnum

    -- Payment fields
    amount            Nullable(Decimal64(2)),              -- Transaction/payment amount
    currency          Nullable(Enum8('USD' = 1, 'EUR' = 2, 'GBP' = 3, 'Other' = 4)),
    payment_method    Nullable(Enum8('paypal' = 1, 'stripe' = 2, 'credit_card' = 3, 'google_pay' = 4, 'apple_pay' = 5)),

    -- Event properties (ClickHouse native JSON type, requires 25.3+)
    message           Nullable(JSON),                     -- Parsed JSON: {"signup_method":"email",...} (page in landing_page)

    -- Identifiers (PII - consider retention/access policies)
    user_id           Nullable(UInt64),
    device_id         Nullable(String),
    email_hash        Nullable(String),                   -- SHA-512 hash
    session_id        Nullable(String)
)
ENGINE = ReplacingMergeTree(ingestion_time)
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_type, event_date, event_id)
SETTINGS index_granularity = 8192;

-- =============================================================================
-- Materialized View: Daily Sign Up Started (Project 1 - Dashboard acceleration)
-- =============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS web_events.mv_daily_signup_started
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, signup_method, device_type)
AS SELECT
    event_date,
    toString(message.signup_method) AS signup_method,
    device_type,
    count() AS event_count
FROM web_events.events
WHERE event_type = 'signup_started'
GROUP BY event_date, signup_method, device_type;

-- =============================================================================
-- Materialized View: Daily Sign Up Completed (Project 1)
-- =============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS web_events.mv_daily_signup_completed
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, signup_method, device_type)
AS SELECT
    event_date,
    toString(message.signup_method) AS signup_method,
    device_type,
    count() AS event_count
FROM web_events.events
WHERE event_type = 'signup_completed'
GROUP BY event_date, signup_method, device_type;

-- =============================================================================
-- Materialized View: Daily Page Views (Project 2 - Dashboard acceleration)
-- =============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS web_events.mv_daily_page_views
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, landing_page, source, device_type, country)
AS SELECT
    event_date,
    landing_page,
    source,
    device_type,
    country,
    count() AS view_count
FROM web_events.events
WHERE event_type = 'page_viewed'
GROUP BY event_date, landing_page, source, device_type, country;
