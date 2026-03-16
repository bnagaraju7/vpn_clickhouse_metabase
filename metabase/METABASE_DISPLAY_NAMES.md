# Metabase Display Names & Titles

Use these names when creating dashboards and questions in Metabase.

---

## Dashboard Names

| Dashboard | Display Name |
|-----------|--------------|
| Sign Up & Sign In | **Sign Up & Sign In Overview** |
| User Acquisition | **User Acquisition & Checkout** |

---

## Filter Widget Labels (Display Names)

| Variable | Filter Label | Type |
|----------|--------------|------|
| `date_from` | **Date From** | Date |
| `date_to` | **Date To** | Date |
| `signup_method` | **Sign Up Method** | Text / Dropdown |
| `signin_method` | **Sign In Method** | Text / Dropdown |
| `device_type` | **Device Type** | Text / Dropdown |
| `platform` | **Platform** | Text / Dropdown |
| `country` | **Country** | Text / Dropdown |
| `page` | **Page** | Text / Dropdown |
| `source` | **Traffic Source** | Text / Dropdown |
| `plan_filter` | **Plan** | Text / Dropdown |
| `payment_method` | **Payment Method** | Text / Dropdown |

---

## Sign Up & Sign In Dashboard – Question Titles & Chart Types

| # | Question Title | Chart Type | Notes |
|---|----------------|------------|-------|
| 1 | **Sign Up Started – Total** | Number | Single stat |
| 2 | **Sign Up Completed – Total** | Number | Single stat |
| 3 | **Sign Up Breakdown by Method & Device** | Bar chart | X: Sign Up Method, Y: Event Count |
| 4 | **Magic Link Sign Up Funnel** | Funnel | Step → Users → Conversion % |
| 5 | **Password/OTP Sign Up Funnel** | Funnel | Step → Users → Conversion % |
| 6 | **Sign In Started – Total** | Number | Single stat |
| 7 | **Sign In Completed – Total** | Number | Single stat |
| 8 | **Sign In Breakdown by Method & Device** | Bar chart | X: Sign In Method, Y: Event Count |

---

## User Acquisition Dashboard – Question Titles & Chart Types

| # | Question Title | Chart Type | Notes |
|---|----------------|------------|-------|
| 1 | **Page Views by Page** | Bar chart | X: Page, Y: View Count |
| 2 | **Page Views by Traffic Source** | Bar chart | X: Page + Source, Y: View Count |
| 3 | **Page Views by Device Type** | Bar chart | X: Page + Device Type, Y: View Count |
| 4 | **Page Views by Country** | Bar chart | X: Page + Country, Y: View Count |
| 5 | **Pricing to Purchase Funnel** | Funnel | Step → Users → Conversion % |
| 6 | **Checkout to Purchase Funnel** | Funnel | Step → Users → Conversion % |
| 7 | **Checkout Abandonment by Date** | Table or Line chart | Date → Abandoned Count |

---

## Column Display Names (SQL Aliases)

These aliases are used in the queries. Metabase shows them as column headers.

| Query | Column Alias | Display Name |
|-------|--------------|--------------|
| Sign Up Started | `total_signup_started` | **Total Sign Up Started** |
| Sign Up Started | `valid_email_entries` | **Valid Email Entries** |
| Sign Up Completed | `total_signup_completed` | **Total Sign Up Completed** |
| Sign Up Completed | `successful_accounts` | **Successful Accounts** |
| Sign Up Breakdown | `signup_method` | **Sign Up Method** |
| Sign Up Breakdown | `device_type` | **Device Type** |
| Sign Up Breakdown | `event_count` | **Event Count** |
| Funnels | `step` | **Step** |
| Funnels | `users` | **Users** |
| Funnels | `conversion_pct` | **Conversion %** |
| Sign In Started | `total_signin_started` | **Total Sign In Started** |
| Sign In Completed | `total_signin_completed` | **Total Sign In Completed** |
| Sign In Breakdown | `signin_method` | **Sign In Method** |
| Page Views | `page` | **Page** |
| Page Views | `source` | **Traffic Source** |
| Page Views | `view_count` | **View Count** |
| Checkout Abandonment | `toDate(event_time)` | **Date** |
| Checkout Abandonment | `abandoned_count` | **Abandoned** |
| Checkout Abandonment | `with_plan_selected` | **With Plan Selected** |
