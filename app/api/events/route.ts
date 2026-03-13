import { NextRequest, NextResponse } from 'next/server';
import { insertEvents } from '@/lib/clickhouse';
import { mapEventToClickHouse } from '@/lib/event-mapper';
import type { EventPayload } from '@/types/events';

const VALID_EVENT_TYPES = [
  'signup_started',
  'signup_completed',
  'signin_started',
  'signin_completed',
  'page_viewed',
  'checkout_started',
  'checkout_completed',
  'checkout_incomplete',
  'payment_method_added',
] as const;

function isValidEventType(type: string): type is (typeof VALID_EVENT_TYPES)[number] {
  return VALID_EVENT_TYPES.includes(type as (typeof VALID_EVENT_TYPES)[number]);
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    // Support single event or batch
    const payloads: EventPayload[] = Array.isArray(body) ? body : [body];

    if (payloads.length === 0) {
      return NextResponse.json({ error: 'No events provided' }, { status: 400 });
    }

    const events: Record<string, unknown>[] = [];

    for (let i = 0; i < payloads.length; i++) {
      const p = payloads[i];

      if (!p || typeof p !== 'object') {
        return NextResponse.json(
          { error: `Invalid event at index ${i}: must be an object` },
          { status: 400 }
        );
      }

      if (!p.event_type || !isValidEventType(String(p.event_type))) {
        return NextResponse.json(
          {
            error: `Invalid event_type at index ${i}. Must be one of: ${VALID_EVENT_TYPES.join(', ')}`,
          },
          { status: 400 }
        );
      }

      const mapped = mapEventToClickHouse(p as Omit<EventPayload, '_source'>);

      events.push(mapped);
    }

    await insertEvents(events);

    return NextResponse.json({
      ok: true,
      count: events.length,
    });
  } catch (err) {
    console.error('[events] Insert error:', err);
    return NextResponse.json(
      { error: 'Failed to store events' },
      { status: 500 }
    );
  }
}
