import { createClient, ClickHouseClient } from '@clickhouse/client';

let client: ClickHouseClient | null = null;

export function getClickHouseClient(): ClickHouseClient {
  if (!client) {
    const host = process.env.CLICKHOUSE_HOST ?? 'http://localhost:8123';
    const user = process.env.CLICKHOUSE_USER ?? 'default';
    const password = process.env.CLICKHOUSE_PASSWORD ?? '';

    client = createClient({
      host,
      username: user,
      password: password || undefined,
    });
  }
  return client;
}

export async function insertEvent(event: Record<string, unknown>): Promise<void> {
  const ch = getClickHouseClient();

  await ch.insert({
    table: 'web_events.events',
    values: [event],
    format: 'JSONEachRow',
  });
}

export async function insertEvents(events: Record<string, unknown>[]): Promise<void> {
  if (events.length === 0) return;

  const ch = getClickHouseClient();

  await ch.insert({
    table: 'web_events.events',
    values: events,
    format: 'JSONEachRow',
  });
}
