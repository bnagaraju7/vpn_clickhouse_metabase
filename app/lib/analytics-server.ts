import type { WebEvent } from '../types/events';
import { insertEvent, insertEvents } from './clickhouse';
import { mapEventToClickHouse } from './event-mapper';

/**
 * Server-side event tracking.
 * Inserts directly into ClickHouse (no API round-trip).
 * Use in Server Components, Route Handlers, Server Actions.
 */
export async function trackEventServer(event: WebEvent): Promise<void> {
  try {
    const mapped = mapEventToClickHouse(event as Parameters<typeof mapEventToClickHouse>[0]);
    await insertEvent(mapped);
  } catch (err) {
    console.warn('[analytics-server] Event insert error:', err);
  }
}

/**
 * Track events in batch (server-side).
 */
export async function trackEventsServer(events: WebEvent[]): Promise<void> {
  if (events.length === 0) return;

  try {
    const mapped = events.map((e) =>
      mapEventToClickHouse(e as Parameters<typeof mapEventToClickHouse>[0])
    );
    await insertEvents(mapped);
  } catch (err) {
    console.warn('[analytics-server] Batch insert error:', err);
  }
}
