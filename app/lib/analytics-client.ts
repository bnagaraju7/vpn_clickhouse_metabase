'use client';

import { v4 as uuidV4 } from 'uuid';
import type { WebEvent } from '../types/events';

const DEFAULT_ENDPOINT = '/api/events';
const VISITOR_STORAGE_KEY = 'analytics_visitor_id';

/** Get or create visitor ID (persists for browser tab session) */
function getOrCreateVisitorId(): string {
  if (typeof window === 'undefined') return '';
  try {
    let id = sessionStorage.getItem(VISITOR_STORAGE_KEY);
    if (!id) {
      id = uuidV4();
      sessionStorage.setItem(VISITOR_STORAGE_KEY, id);
    }
    return id;
  } catch {
    return '';
  }
}

/**
 * Client-side event tracking.
 * Sends events to the Next.js API (which forwards to ClickHouse).
 * Injects visitor_id and event_time if not provided.
 */
export async function trackEvent(event: WebEvent): Promise<void> {
  const endpoint =
    typeof window !== 'undefined'
      ? (process.env.NEXT_PUBLIC_ANALYTICS_ENDPOINT ?? DEFAULT_ENDPOINT)
      : DEFAULT_ENDPOINT;

  try {
    const enriched: WebEvent = {
      ...event,
      visitor_id: event.visitor_id ?? getOrCreateVisitorId() || undefined,
      event_time: event.event_time ?? new Date().toISOString(),
    };
    const res = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(enriched),
      keepalive: true,
    });

    if (!res.ok) {
      console.warn('[analytics] Event send failed:', res.status, await res.text());
    }
  } catch (err) {
    console.warn('[analytics] Event send error:', err);
  }
}

/**
 * Track page view (client-side).
 */
export function trackPageView(
  page: WebEvent['page'],
  options?: Partial<Pick<WebEvent, 'source' | 'device_type' | 'country' | 'platform' | 'visitor_id'>>
) {
  trackEvent({
    event_type: 'page_viewed',
    page: page,
    ...options,
  });
}

/**
 * Track sign up started.
 */
export function trackSignUpStarted(
  message: WebEvent['message'] & { signup_method?: string; enter_email?: string },
  options?: Partial<WebEvent>
) {
  trackEvent({
    event_type: 'signup_started',
    message,
    ...options,
  });
}

/**
 * Track sign up completed.
 */
export function trackSignUpCompleted(
  message: WebEvent['message'] & { signup_method?: string; account_creation?: string },
  options?: Partial<WebEvent>
) {
  trackEvent({
    event_type: 'signup_completed',
    message,
    ...options,
  });
}

/**
 * Track sign in started.
 */
export function trackSignInStarted(
  message: WebEvent['message'] & { signin_method?: string },
  options?: Partial<WebEvent>
) {
  trackEvent({
    event_type: 'signin_started',
    message,
    ...options,
  });
}

/**
 * Track sign in completed.
 */
export function trackSignInCompleted(
  message: WebEvent['message'] & { signin_method?: string },
  options?: Partial<WebEvent>
) {
  trackEvent({
    event_type: 'signin_completed',
    message,
    ...options,
  });
}

/**
 * Track checkout started.
 */
export function trackCheckoutStarted(
  message: WebEvent['message'] & { plan_selected?: string; payment_method?: string },
  options?: Partial<WebEvent>
) {
  trackEvent({
    event_type: 'checkout_started',
    message,
    ...options,
  });
}

/**
 * Track checkout completed.
 */
export function trackCheckoutCompleted(
  message: WebEvent['message'] & { plan_purchased?: string; payment_method?: string },
  options?: Partial<WebEvent>
) {
  trackEvent({
    event_type: 'checkout_completed',
    message,
    ...options,
  });
}

/**
 * Track checkout incomplete (abandonment).
 */
export function trackCheckoutIncomplete(
  message: WebEvent['message'] & { plan_selected?: string },
  options?: Partial<WebEvent>
) {
  trackEvent({
    event_type: 'checkout_incomplete',
    message,
    page: 'checkout',
    ...options,
  });
}

/**
 * Track payment method added.
 */
export function trackPaymentMethodAdded(
  message: WebEvent['message'] & { payment_method?: string; card_type?: string },
  options?: Partial<WebEvent>
) {
  trackEvent({
    event_type: 'payment_method_added',
    message,
    ...options,
  });
}
