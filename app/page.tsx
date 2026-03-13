export default function Home() {
  return (
    <main style={{ padding: '2rem', fontFamily: 'system-ui' }}>
      <h1>Web Data Infrastructure</h1>
      <p>Events are sent to ClickHouse via /api/events.</p>
      <p>
        <a href="/pricing">Pricing</a> | <a href="/checkout">Checkout</a>
      </p>
    </main>
  );
}
