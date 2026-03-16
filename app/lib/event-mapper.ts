import type { EventPayload } from '../types/events';
import { v4 as uuidV4 } from 'uuid';
import { generateEventId } from './uuid-v5';

/**
 * Maps API payload to ClickHouse column format.
 * Validates and sanitizes values for enum columns.
 */
export function mapEventToClickHouse(payload: Omit<EventPayload, '_source'>): Record<string, unknown> {
  const {
    event_type,
    event_id,
    event_time,
    source,
    device_type,
    os_type,
    country,
    page,
    platform,
    app_version,
    transaction_id,
    plans,
    sub_status,
    amount,
    currency,
    payment_method,
    card_type,
    message: msg,
    user_id,
    device_id,
    email_hash,
    visitor_id,
  } = payload;

  // transaction_id, device_id, email_hash, plans, sub_status, amount, currency, payment_method, card_type live in message
  const message = {
    ...(msg && typeof msg === 'object' ? msg : {}),
    ...(transaction_id != null && { transaction_id }),
    ...(device_id != null && { device_id }),
    ...(email_hash != null && { email_hash }),
    ...(plans != null && { plans }),
    ...(sub_status != null && { sub_status }),
    ...(amount != null && { amount }),
    ...(currency != null && { currency }),
    ...(payment_method != null && { payment_method }),
    ...(card_type != null && { card_type }),
  };
  const messageValue = Object.keys(message).length > 0 ? message : null;

  const row: Record<string, unknown> = {
    event_id: event_id ?? generateEventId({ event_type, event_time, visitor_id }),
    event_type,
    event_time: event_time ?? undefined,
    source: source ?? null,
    device_type: device_type ?? null,
    os_type: os_type ?? null,
    country: country ?? null,
    page: page ?? null,
    platform: platform ?? null,
    app_version: app_version ?? null,
    message: messageValue,
    user_id: user_id ?? null,
    visitor_id: visitor_id ?? uuidV4(),
  };

  // Remove undefined values so ClickHouse uses defaults
  return Object.fromEntries(
    Object.entries(row).filter(([, v]) => v !== undefined)
  ) as Record<string, unknown>;
}
