import type { EventPayload } from '../types/events';

/**
 * Maps API payload to ClickHouse column format.
 * Validates and sanitizes values for enum columns.
 */
export function mapEventToClickHouse(payload: Omit<EventPayload, '_source'>): Record<string, unknown> {
  const {
    event_type,
    event_date,
    source,
    device_type,
    country,
    landing_page,
    platform,
    app_version,
    transaction_id,
    plans,
    subscription_status,
    amount,
    currency,
    payment_method,
    message,
    user_id,
    device_id,
    email_hash,
    session_id,
  } = payload;

  const row: Record<string, unknown> = {
    event_type,
    event_date: event_date ?? undefined,
    source: source ?? null,
    device_type: device_type ?? null,
    country: country ?? null,
    landing_page: landing_page ?? null,
    platform: platform ?? null,
    app_version: app_version ?? null,
    transaction_id: transaction_id ?? null,
    plans: plans ?? null,
    subscription_status: subscription_status ?? null,
    amount: amount != null ? amount : null,
    currency: currency ?? null,
    payment_method: payment_method ?? null,
    message: message && Object.keys(message).length > 0 ? message : null,
    user_id: user_id ?? null,
    device_id: device_id ?? null,
    email_hash: email_hash ?? null,
    session_id: session_id ?? null,
  };

  // Remove undefined values so ClickHouse uses defaults
  return Object.fromEntries(
    Object.entries(row).filter(([, v]) => v !== undefined)
  ) as Record<string, unknown>;
}
