/**
 * Event types matching ClickHouse schema (web_events.events)
 */

export type EventType =
  | 'signup_started'
  | 'signup_completed'
  | 'signin_started'
  | 'signin_completed'
  | 'page_viewed'
  | 'checkout_started'
  | 'checkout_completed'
  | 'checkout_incomplete'
  | 'payment_method_added';

export type Source = 'Google' | 'Social' | 'Bing' | 'Direct' | 'Referral' | 'Other';
export type DeviceType = 'Desktop' | 'Mobile' | 'Tablet' | 'Android' | 'Android TV' | 'Apple TV';
export type Platform = 'iOS' | 'Android' | 'web' | 'Windows' | 'iPadOS' | 'MacOS' | 'Linux' | 'Android TV' | 'Apple TV' | 'Other';
export type LandingPage = 'homepage' | 'pricing' | 'sign up page' | 'checkout' | 'Other';
export type Plan = 'Weekly' | 'Monthly' | '3-Month' | '6-Month' | 'Yearly';
export type PaymentMethod = 'paypal' | 'stripe' | 'credit_card' | 'google_pay' | 'apple_pay';
export type Currency = 'USD' | 'EUR' | 'GBP' | 'Other';

/** ISO 3166-1 alpha-2 country code (e.g. US, UK, DE) */
export type CountryCode = string;

export interface WebEventBase {
  event_type: EventType;
  /** Optional; defaults to today */
  event_date?: string;
  source?: Source;
  device_type?: DeviceType;
  country?: CountryCode;
  landing_page?: LandingPage;
  platform?: Platform;
  app_version?: string;
  user_id?: number;
  device_id?: string;
  session_id?: string;
  /** SHA-512 hash of email (for PII-safe tracking) */
  email_hash?: string;
}

export interface SignUpSignInMessage {
  signup_method?: 'email' | 'google' | 'magic link';
  signin_method?: 'email' | 'google' | 'magic link';
  enter_email?: 'valid' | 'invalid';
  otp?: 'sent' | 'valid';
  magic_link?: 'sent';
  account_creation?: 'Success' | 'Failure';
}

export interface CheckoutMessage {
  plan_selected?: Plan;
  plan_updated?: Plan;
  plan_purchased?: Plan;
  payment_method?: PaymentMethod;
  enter_email?: 'valid' | 'invalid';
}

export interface PageViewMessage {
  page_name?: string;
}

export type EventMessage = SignUpSignInMessage | CheckoutMessage | PageViewMessage | Record<string, unknown>;

export interface WebEvent extends WebEventBase {
  message?: EventMessage;
  transaction_id?: string;
  plans?: Plan;
  subscription_status?: string;
  amount?: number;
  currency?: Currency;
  payment_method?: PaymentMethod;
}

/** Payload sent from client/server to the API */
export interface EventPayload extends WebEvent {
  /** Set by API: 'client' | 'server' */
  _source?: 'client' | 'server';
}
