# Metabase Global Filter Implementation Guide

For **display names, question titles, and chart types**, see **[METABASE_DISPLAY_NAMES.md](METABASE_DISPLAY_NAMES.md)**.

This guide explains how to implement **dashboard-level global filters** that apply across all questions (cards) on your Metabase dashboards, covering both **Sign Up/Sign In** and **User Acquisition** project requirements.

---

## 1. Global Filter Overview

**Dashboard-level filters** allow users to filter data across all cards on a dashboard from a single set of filter widgets. When you connect a dashboard filter to a card's SQL variable, changing the filter updates that card's query.

### Filter Types by Use Case

| Filter Name   | Type           | Variable Names   | Use In                    |
|---------------|----------------|------------------|---------------------------|
| Date Range    | Date picker    | `date_from`, `date_to` | All dashboards            |
| Sign Up Method| Text/Category  | `signup_method`  | Sign Up dashboards         |
| Sign In Method| Text/Category  | `signin_method`  | Sign In dashboards         |
| Device Type   | Text/Category  | `device_type`    | All dashboards            |
| Platform      | Text/Category  | `platform`       | Sign Up & Sign In, Funnels|
| Country       | Text/Category  | `country`        | All dashboards            |
| Page / Landing | Text/Category  | `page`   | User Acquisition (homepage, pricing, sign up page, checkout) |
| Traffic Source| Text/Category  | `source`         | User Acquisition         |
| Plan          | Text/Category  | `plan_filter`    | Pricing funnel            |
| Payment Method| Text/Category  | `payment_method` | Checkout funnel (values: credit_card, paypal, google_pay) |

---

## 2. Step-by-Step: Add Global Filters to a Dashboard

### Step 1: Create a New Dashboard

1. Go to **Dashboards** → **New dashboard**
2. Name it (e.g., "Sign Up & Sign In Overview" or "User Acquisition")

### Step 2: Add Filter Widgets (Dashboard-Level)

1. Click the **filter icon** (funnel) in the dashboard header
2. Click **Add a filter**
3. Choose filter type and configure:

#### Date Range Filter (Required for all cards)

- **Filter type:** Date picker
- **Filter widget:** Date Range (or "All Options" for flexibility)
- **Filter label:** "Date Range"
- **Save**

#### Category Filters (Optional)

- **Filter type:** Text or category
- **Filter widget:** Dropdown list (or "Search box" for long lists)
- **Filter label:** e.g., "Device Type", "Platform", "Sign Up Method"
- **Save**

### Step 3: Connect Filters to Cards

1. Add a **Question** card to the dashboard (use the SQL from `queries/` folder)
2. After adding the card, click the **pencil icon** on the filter widget
3. Under **Which questions does this filter apply to?**, select the cards that use this filter
4. Map the filter to the correct **Variable** in each card:
   - Dashboard filter "Date Range" → map to variables `date_from` and `date_to` (Metabase splits date range automatically)
   - Dashboard filter "Device Type" → map to variable `device_type`
   - etc.

### Step 4: Variable Mapping for Date Range

For **Date Range** filters with ClickHouse, use two variables:

1. Add **two** Date picker filters: "Date From" and "Date To"
2. Or add **one** "Date Range" filter — Metabase may map it to `date_from` and `date_to` automatically
3. In SQL: `WHERE toDate(event_time) BETWEEN {{date_from}} AND {{date_to}}`
4. Set variable types: **Date** for both
5. Set defaults: `date_from` = 30 days ago, `date_to` = Today

---

## 3. SQL Variable Configuration in Metabase

Each native SQL question must declare variables that match the dashboard filter widgets.

### Variable Declaration (in SQL Editor)

When you add `{{variable_name}}` in your SQL, Metabase shows a variable configuration panel. Configure:

| Variable       | Type        | Default Value        | Required |
|----------------|-------------|----------------------|----------|
| `date_from`    | Date        | 30 days ago          | Yes      |
| `date_to`      | Date        | Today                | Yes      |
| `signup_method`| Text        | (empty)              | No       |
| `signin_method`| Text        | (empty)              | No       |
| `device_type`  | Text        | (empty)              | No       |
| `platform`     | Text        | (empty)              | No       |
| `country`      | Text        | (empty)              | No       |
| `page` | Text        | (empty)              | No       |
| `source`       | Text        | (empty)              | No       |
| `plan_filter`  | Text        | (empty)              | No       |
| `payment_method`| Text       | (empty)              | No       |

**Payment method values** (for dropdown): `paypal`, `stripe`, `credit_card`, `google_pay`, `apple_pay`

**Landing page values** (same as page_name): `homepage`, `pricing`, `sign up page`, `checkout`, `Other`

### Optional Variables ([[ ]])

Use `[[ AND column = {{variable}} ]]` so the filter is omitted when the variable is empty:

```sql
WHERE toDate(event_time) BETWEEN {{date_from}} AND {{date_to}}
  [[ AND signup_method = {{signup_method}} ]]
  [[ AND device_type = {{device_type}} ]]
```

---

## 4. Dashboard Layout Recommendations

### Sign Up & Sign In Dashboard

- **Row 1:** Date Range, Device Type, Sign Up Method, Sign In Method, Platform, Country filters
- **Row 2:** Sign Up Started (number), Sign Up Completed (number), Sign In Started (number), Sign In Completed (number)
- **Row 3:** Sign Up Breakdown (bar chart), Sign In Breakdown (bar chart)
- **Row 4:** Magic Link Funnel (funnel chart)
- **Row 5:** Password/OTP Funnel (funnel chart)

### User Acquisition Dashboard

- **Row 1:** Date Range, Page/Landing, Source, Device Type, Country filters
- **Row 2:** Page Views by Page Name (bar chart)
- **Row 3:** Page Views by Traffic Source (bar chart)
- **Row 4:** Page Views by Device Type (bar chart)
- **Row 5:** Page Views by Country (bar chart)
- **Row 6:** Pricing to Purchase Funnel (with Plan filter)
- **Row 7:** Checkout to Purchase Funnel (with Payment Method filter)
- **Row 8:** Checkout Incomplete / Abandonment (optional)

---

## 5. Field Filters (Alternative for Dropdowns)

For dropdowns populated from the database, use **Field filters**:

1. In SQL: `[[ AND {{signup_method_filter}} ]]`
2. Add variable `signup_method_filter` as **Field filter**
3. Map to: `web_events.events.signup_method`
4. Users see only values that exist in the data

---

## 6. Linked Filters (Optional)

To restrict one filter based on another (e.g., only show platforms that have data for the selected country):

1. Add the filters
2. Use **Linked filters** (filter icon → filter settings)
3. Configure which filters limit the options of others

---

## 7. Tab-Specific Filters

If the dashboard has tabs:

- **Header-level widgets:** Filter only cards on that tab
- **Dashboard-level widgets:** Filter all cards; connect only to cards on the active tab if you want tab-specific behavior

---

## 8. Quick Reference: Filter → Variable Mapping

| Dashboard Filter | Variable(s)    | Cards to Connect                    |
|-----------------|----------------|-------------------------------------|
| Date Range      | `date_from`, `date_to` | All cards                          |
| Device Type     | `device_type`  | All cards                           |
| Sign Up Method  | `signup_method`| Sign Up Started, Sign Up Completed, Sign Up Breakdown |
| Sign In Method  | `signin_method`| Sign In Started, Sign In Completed, Sign In Breakdown |
| Platform        | `platform`     | Funnels (Magic Link, Password/OTP)  |
| Country         | `country`      | All cards                           |
| Page / Landing  | `page` | Page Views, Checkout Incomplete      |
| Source          | `source`       | Page Views cards                    |
| Plan            | `plan_filter`  | Pricing to Purchase funnel          |
| Payment Method  | `payment_method` | Checkout to Purchase funnel      |

---

## 9. Troubleshooting

| Issue | Solution |
|-------|----------|
| Filter not applied to card | Connect the filter to the card in filter settings |
| "No results" when filter is empty | Use `[[ ]]` for optional filters |
| Date filter error | Use Date type for `date_from`/`date_to`; ensure format is compatible with ClickHouse |
| Variable not found | Ensure variable names match exactly (case-sensitive) |
