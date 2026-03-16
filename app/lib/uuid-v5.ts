import { v5 as uuidV5 } from 'uuid';

/** Namespace for event_id UUID v5 (custom app namespace) */
const EVENT_NAMESPACE = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

/**
 * Generate UUID v5 for event_id.
 * Unique per event; app generates when client omits.
 */
export function generateEventId(input: {
  event_type: string;
  event_time?: string;
  visitor_id?: string;  // UUID
}): string {
  const { event_type, event_time, visitor_id } = input;
  const ts = event_time ?? new Date().toISOString();
  const vid = visitor_id ?? '';
  const name = `${event_type}|${ts}|${vid}|${Date.now()}-${Math.random().toString(36).slice(2)}`;
  return uuidV5(name, EVENT_NAMESPACE);
}
