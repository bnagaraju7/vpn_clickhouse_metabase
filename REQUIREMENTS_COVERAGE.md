# Requirements Coverage Checklist

Verification against project scope: **Sign Up & Sign In** + **User Acquisition** tracking.

---

## 1. Event Types (Schema Support)

| Event | Schema | Sample Data | Metabase Query |
|-------|--------|-------------|----------------|
| signup_started | ✅ | ✅ | ✅ |
| signup_completed | ✅ | ✅ | ✅ |
| signin_started | ✅ | ✅ | ✅ |
| signin_completed | ✅ | ✅ | ✅ |
| page_viewed | ✅ | ✅ | ✅ |
| checkout_started | ✅ | ✅ | ✅ |
| checkout_completed | ✅ | ✅ | ✅ |
| checkout_incomplete | ✅ | ✅ | ✅ |
| payment_method_added | ✅ | ✅ | ✅ (in Checkout funnel) |

---

## 2. Sign Up & Sign In Dashboards

| Requirement | Status | Notes |
|-------------|--------|-------|
| Sign Up Started (total + filters) | ✅ | Query 1 |
| Sign Up Completed (total + filters) | ✅ | Query 2 |
| Sign Up Breakdown (by method, device) | ✅ | Query 3 |
| Magic Link Funnel | ✅ | Query 4 |
| Password/OTP Funnel | ✅ | Query 5 |
| Sign In Started | ✅ | Query 6 |
| Sign In Completed | ✅ | Query 7 |
| Sign In Breakdown | ✅ | Query 8 |

---

## 3. User Acquisition Dashboards

| Requirement | Status | Notes |
|-------------|--------|-------|
| Page Views by Page Name | ✅ | Query 1 |
| Page Views by Traffic Source | ✅ | Query 2 |
| Page Views by Device Type | ✅ | Query 3 |
| Page Views by Country | ✅ | Query 4 |
| Pricing → Purchase Funnel | ✅ | Query 5 |
| Checkout → Purchase Funnel | ✅ | Query 6 |
| checkout_incomplete (abandonment) | ✅ | Query 7 |

---

## 4. Global Filters

| Filter | Status | Variable |
|--------|--------|----------|
| Date Range | ✅ | date_from, date_to |
| Device Type | ✅ | device_type |
| Sign Up Method | ✅ | signup_method |
| Sign In Method | ✅ | signin_method |
| Platform | ✅ | platform |
| Country | ✅ | country |
| Page / Landing | ✅ | page |
| Traffic Source | ✅ | source |
| Plan | ✅ | plan_filter |
| Payment Method | ✅ | payment_method |

---

## 5. Schema & Infrastructure

| Item | Status |
|------|--------|
| Unified events table | ✅ |
| ReplacingMergeTree (deduplicates by event_id) | ✅ |
| Partitioning by month | ✅ |
| Materialized views (signup, page views) | ✅ |
| Enums (device_type, os_type, platform, plans, sub_status) | ✅ |
| LowCardinality (source, page, currency, payment_method, card_type) | ✅ |
| message JSON for event properties | ✅ |

---

## 6. Gaps Summary

All requirements are now covered. No open gaps.

---

## 7. Overall

- **Schema:** Fully covers all 9 event types.
- **Sign Up:** Fully covered (5 queries).
- **Sign In:** Fully covered (3 queries: Started, Completed, Breakdown).
- **User Acquisition:** Page views, both funnels, and checkout_incomplete abandonment query.
