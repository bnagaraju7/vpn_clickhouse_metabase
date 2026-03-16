# Key Questions for the Data Engineer

---

## Executive Summary

This proposal outlines a strategic enhancement to the existing ClickHouse web events tracking schema. The objective is to transition from a rigid, unstructured data model to a highly optimized, columnar architecture. This upgrade will significantly improve query performance, enable scalable reporting for user acquisition and authentication analytics, and ensure data accuracy through automated deduplication.

### The Challenge: Current Implementation

Currently, event data is stored primarily as raw JSON strings within a standard MergeTree table. While this allows for flexible data ingestion, it creates severe bottlenecks for analytics:

- **Query Latency:** Extracting data requires parsing JSON on every query, which is highly CPU-intensive and slow.
- **Data Accuracy:** The current engine lacks a deduplication mechanism, risking inflated event counts if a client sends the same event twice.
- **Inefficient Scans:** Without structured columns for common dimensions (like device, platform, or source), queries must scan the entire table rather than targeting specific column files.
- **Limited Capabilities:** Tracking complex flows like user acquisition, checkout funnels, and authentication drop-offs is cumbersome and difficult to scale.

### The Solution: Proposed Architecture Highlights

We propose moving to a structured, unified event schema using ClickHouse's ReplacingMergeTree engine. This design extracts key business dimensions into dedicated columns while retaining flexibility for custom event properties.

### Key Technical Upgrades

- **ReplacingMergeTree Engine:** Automatically handles event deduplication by ORDER BY key (event_id), ensuring your dashboards always report accurate numbers.
- **Optimized Column Types:** Heavy use of LowCardinality(String) and Enum8 for dimensions like source, device_type, and platform. This drastically reduces storage size and accelerates filter/aggregation queries.
- **Native JSON Support:** Replaces the raw string column with ClickHouse's Native JSON type (requires v25.3+), allowing dynamic event properties to be queried much faster.
- **Automated Lifecycle Management:** Monthly partitioning (toYYYYMM) ensures queries scanning specific date ranges are lightning-fast.

### Current vs. Proposed Schema Comparison

| Feature | Current Schema | Proposed Schema | Business Impact |
|---------|----------------|-----------------|-----------------|
| Data Format | Unstructured (Raw JSON String) | Structured Columns + Native JSON | Queries will execute exponentially faster; simpler SQL for analysts. |
| Deduplication | None (MergeTree) | Automated (ReplacingMergeTree) | Guaranteed accuracy for critical metrics like sign-ups and payments. |
| Storage Engine | Standard table | Partitioned by Month | Reduced cloud infrastructure costs and efficient date-range queries. |
| ORDER BY | N/A or arbitrary | (event_id) | Deterministic deduplication; unique event_id per row. |
| Key Dimensions | Hidden inside JSON payload | Top-level optimized columns | Instant filtering by Country, Device, Traffic Source, and Subscription Plan. |

---

## Part 1: Create Table Query (Full DDL)

```sql
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
```

### Schema Column Reference

| Column | Type | Notes |
|--------|------|-------|
| event_id | UUID | Required; UUID for deduplication |
| visitor_id | UUID | Required; client-generated |
| user_id | Nullable(UUID) | Optional |
| event_type | LowCardinality(String) | signup_started, page_viewed, etc. |
| event_time | DateTime64(3, 'UTC') | Default now64(3); partition key |
| source | Nullable(LowCardinality(String)) | Google, Social, Direct, etc. |
| device_type | Nullable(Enum8) | Desktop, Mobile, Tablet, etc. |
| os_type | Nullable(Enum8) | Mac, Android, Windows, etc. |
| country | Nullable(LowCardinality(String)) | ISO 3166-1 alpha-2 |
| page | Nullable(LowCardinality(String)) | homepage, pricing, checkout, etc. |
| platform | Nullable(Enum8) | iOS, Android, web, etc. |
| app_version | Nullable(LowCardinality(String)) | e.g. 1.2.3 |
| message | Nullable(JSON) | transaction_id, device_id, email_hash in message; also plans, sub_status, amount, currency, payment_method, card_type for checkout events |

---

## Part 2: Key Questions & Answers

### Question 1: Unified vs. Separate Tables

**Should all events live in a single wide table (with an event_type column) or should each event have its own table? What are the trade-offs for our query patterns?**

### Answer

**Recommendation: Use a single unified table** (with an `event_type` column).

| Aspect | Unified Table | Separate Tables |
|--------|---------------|------------------|
| **Funnel queries** | Single table, `event_type IN (...)` – no JOINs | Requires JOINs across multiple tables |
| **Schema evolution** | Add columns; event-specific fields use Nullable | Each table evolves independently |
| **Storage** | Sparse columns; Nullable for event-specific fields | More tables, more parts to manage |
| **Metabase** | One connection, simpler dashboards | Multiple tables, more complex joins |
| **Materialized views** | One source table, filter by `event_type` | One MV per table or more complex logic |

**Use separate tables only if:** event types differ significantly in schema, retention, or access control requirements.

**Note:** Later, based on need, we can create Materialized views.

---

## Question 2: Column Types

**What is the recommended ClickHouse type for source and page_name (LowCardinality(String) vs Enum)? How should we handle nullable fields like card_type?**

### Answer

| Column | Recommendation | Rationale |
|--------|----------------|-----------|
| **source** | `LowCardinality(String)` | Easy to add new values (e.g., "TikTok") without ALTER |
| **page_name / page** | `LowCardinality(String)` | Same flexibility for dynamic page catalogs |
| **Nullable fields (card_type, etc.)** | In `message` JSON | Use `message.card_type`, `message.payment_method`, etc. for optional event-specific fields |

**LowCardinality vs Enum:**
- **LowCardinality(String):** Flexible; good when values evolve (new sources, pages).
- **Enum8/Enum16:** Strict and compact, but requires `ALTER` for new values.

**card_type:** In `message` JSON – only populated when `payment_method` is Credit Card.

---

## Question 3: Timestamp Handling

**What timestamp columns should be added (event_time)? What timezone convention should be used?**

### Answer

| Column | Type | Purpose |
|--------|------|---------|
| **event_time** | `DateTime64(3, 'UTC')` | When the event occurred (client or server); partitioning uses `toDate(event_time)` |

**Timezone convention:** Store all timestamps in **UTC**. Apply timezone conversion only in Metabase or the application layer for display.

---

## Question 4: Session Tracking

**Should we implement session_id to group page_viewed events into sessions? If so, what is the recommended approach?**

### Answer

**Current approach:** We use `visitor_id`, stored in a cookie with a 1-year expiry. This identifies returning visitors and groups their page views across visits.

**Future:** If needed, we can add a separate `session_id` cookie for session-level grouping (e.g., shorter-lived sessions within a visit).

---

## Question 5: Query Patterns

**What are the most performance-critical queries we need to optimize for? (e.g., daily page views by source, weekly conversion funnels)**

### Answer

Once we start loading real data, we'll analyze actual query patterns and recommend optimizations accordingly.

---

## Question 6: Data Volume

**What is the expected event volume (events/day) and retention period? This affects partitioning strategy.**

### Answer

Once we start loading real data, we'll analyze actual query patterns and recommend optimizations accordingly.

---

## Question 7: Metabase Configuration

**Are there specific Metabase best practices for ClickHouse connections? (e.g., query timeouts, caching)**

### Answer

| Setting | Recommendation |
|--------|-----------------|
| **Caching** | 1h cache; we'll adjust based on need |
| **Connection** | Use native HTTP or JDBC; HTTP preferred for simplicity |
| **Sync metadata** | Limit to `web_events` database to avoid long syncs |
| **FINAL usage** | Use `FINAL` only when deduplication is required; most aggregates work without it |

---

## Question 8: Access Patterns

**Who will query the data? Analysts via SQL, dashboards only, or application-layer queries?**

### Answer

We currently assume analysts and dashboards will use this data. If we need to expose it to customer-facing applications, we'll create materialized views optimized for that use case.

---

*Document generated from project design decisions.*
