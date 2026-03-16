# Next.js Event Tracking → ClickHouse

Client-side and server-side event tracking that sends all events to ClickHouse via the Next.js API.

## Setup

### 1. Install dependencies

```bash
npm install
```

### 2. Configure environment

Copy `.env.example` to `.env.local` and set:

```env
CLICKHOUSE_HOST=http://localhost:8123
CLICKHOUSE_USER=default
CLICKHOUSE_PASSWORD=
```

### 3. Run ClickHouse

Ensure the ClickHouse schema is created (see root `README.md`):

```bash
clickhouse-client < clickhouse/01_schema_ddl.sql
```

### 4. Start Next.js

```bash
npm run dev
```

---

## Architecture

```
┌─────────────────┐     POST /api/events      ┌──────────────────┐
│  Client (Browser)│ ───────────────────────►│  Next.js API     │
│  trackEvent()   │                           │  /api/events     │
└─────────────────┘                           └────────┬─────────┘
                                                      │
┌─────────────────┐     trackEventServer()     ┌───────▼─────────┐
│  Server (RSC,   │ ───────────────────────►│  ClickHouse     │
│  API, Actions)  │     direct insert         │  web_events     │
└─────────────────┘                           └─────────────────┘
```

- **Client-side:** Events are sent via `fetch` to `/api/events`, which inserts into ClickHouse.
- **Server-side:** Events are inserted directly into ClickHouse (no API round-trip).

---

## Client-Side Tracking

Use in Client Components (`'use client'`):

```tsx
import {
  trackPageView,
  trackSignUpStarted,
  trackCheckoutStarted,
  trackCheckoutIncomplete,
  trackEvent,
} from '@/lib/analytics-client';

// Page view (auto-tracked by PageViewTracker in layout)
trackPageView('pricing', { source: 'Google', country: 'US' });

// Sign up
trackSignUpStarted(
  { signup_method: 'email', enter_email: 'valid' },
  { platform: 'web', device_type: 'Desktop' }
);

// Checkout
trackCheckoutStarted(
  { plan_selected: 'Yearly', payment_method: 'paypal', enter_email: 'valid' },
  { amount: 99.99, currency: 'USD', transaction_id: 'txn_123' }
);

// Abandonment (e.g. on beforeunload)
trackCheckoutIncomplete({ plan_selected: '6-Month' });

// Generic
trackEvent({
  event_type: 'payment_method_added',
  message: { payment_method: 'credit_card' },
  platform: 'web',
});
```

### PageViewTracker

Add to `app/layout.tsx` to auto-track page views on route change:

```tsx
import { PageViewTracker } from '@/components/PageViewTracker';

export default function Layout({ children }) {
  return (
    <html>
      <body>
        <PageViewTracker />
        {children}
      </body>
    </html>
  );
}
```

---

## Server-Side Tracking

Use in Server Components, Route Handlers, Server Actions:

```tsx
import { trackEventServer, trackEventsServer } from '@/lib/analytics-server';

// Single event
await trackEventServer({
  event_type: 'signup_completed',
  message: { signup_method: 'google', account_creation: 'Success' },
  platform: 'web',
  country: 'US',
});

// Batch
await trackEventsServer([
  { event_type: 'page_viewed', page: 'pricing', source: 'Direct' },
  { event_type: 'checkout_started', message: { plan_selected: 'Monthly' } },
]);
```

---

## API Endpoint

**POST** `/api/events`

**Body:** Single event object or array of events.

```json
{
  "event_type": "page_viewed",
  "page": "pricing",
  "source": "Google",
  "device_type": "Desktop",
  "country": "US",
  "platform": "web",
  "message": {}
}
```

**Response:**

```json
{ "ok": true, "count": 1 }
```

**Headers (optional):**

- `x-event-source: server` – marks event as server-originated (for analytics).

---

## Event Types

| event_type           | Use case                    |
|----------------------|-----------------------------|
| signup_started       | User started sign up        |
| signup_completed     | User completed sign up      |
| signin_started       | User started sign in        |
| signin_completed     | User completed sign in      |
| page_viewed          | Page view                   |
| checkout_started     | User started checkout       |
| checkout_completed   | Purchase completed          |
| checkout_incomplete  | Checkout abandoned          |
| payment_method_added | User added payment method   |

---

## File Structure

```
app/
├── api/events/route.ts       # POST /api/events
├── components/PageViewTracker.tsx
├── lib/
│   ├── analytics-client.ts   # Client-side trackEvent, trackPageView, etc.
│   ├── analytics-server.ts   # Server-side trackEventServer
│   ├── clickhouse.ts         # ClickHouse client
│   └── event-mapper.ts      # Payload → ClickHouse row
├── types/events.ts           # EventPayload, WebEvent, etc.
└── layout.tsx                # Includes PageViewTracker
```
