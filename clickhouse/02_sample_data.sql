-- =============================================================================
-- Sample data for testing dashboards
-- Run after 01_schema_ddl.sql
-- message = parsed event properties (JSON)
-- event_id required; event_time required; visitor_id required
-- =============================================================================

-- Sign Up & Sign In events (event_time = toDateTime64 of date; device_id/email_hash in message for funnel user key)
INSERT INTO web_events.events (event_id, event_type, event_time, device_type, platform, country, source, page, app_version, visitor_id, message)
VALUES
    (generateUUIDv4(), 'signup_started', toDateTime64(today() - 1, 3, 'UTC'), 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.1.0', toUUID('550e8400-e29b-41d4-a716-446655440001'), '{"signup_method":"email","enter_email":"valid","device_id":"d1"}'),
    (generateUUIDv4(), 'signup_started', toDateTime64(today() - 1, 3, 'UTC'), 'Mobile', 'Android', 'UK', 'Social', 'homepage', '2.0.5', toUUID('550e8400-e29b-41d4-a716-446655440002'), '{"signup_method":"google","enter_email":"valid","device_id":"d2"}'),
    (generateUUIDv4(), 'signup_started', toDateTime64(today(), 3, 'UTC'), 'Tablet', 'iOS', 'US', 'Google', 'pricing', '2.2.0', toUUID('550e8400-e29b-41d4-a716-446655440003'), '{"signup_method":"magic link","enter_email":"valid","magic_link":"sent","device_id":"d3"}'),
    (generateUUIDv4(), 'signup_completed', toDateTime64(today() - 1, 3, 'UTC'), 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.1.0', toUUID('550e8400-e29b-41d4-a716-446655440001'), '{"signup_method":"email","enter_email":"valid","otp":"valid","account_creation":"Success","device_id":"d1"}'),
    (generateUUIDv4(), 'signup_completed', toDateTime64(today(), 3, 'UTC'), 'Mobile', 'Android', 'UK', 'Social', 'homepage', '2.0.5', toUUID('550e8400-e29b-41d4-a716-446655440002'), '{"signup_method":"google","enter_email":"valid","account_creation":"Success","device_id":"d2"}'),
    (generateUUIDv4(), 'signin_started', toDateTime64(today(), 3, 'UTC'), 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.2.0', toUUID('550e8400-e29b-41d4-a716-446655440004'), '{"signin_method":"email","enter_email":"valid","device_id":"d4"}'),
    (generateUUIDv4(), 'signin_completed', toDateTime64(today(), 3, 'UTC'), 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.2.0', toUUID('550e8400-e29b-41d4-a716-446655440004'), '{"signin_method":"email","enter_email":"valid","device_id":"d4"}');

-- User Acquisition events (page = page viewed; transaction_id, device_id, plans, sub_status, amount, currency, payment_method, card_type in message)
INSERT INTO web_events.events (event_id, event_type, event_time, source, device_type, country, app_version, platform, page, visitor_id, message)
VALUES
    (generateUUIDv4(), 'page_viewed', toDateTime64(today() - 2, 3, 'UTC'), 'Google', 'Desktop', 'US', '2.0.3', 'web', 'homepage', toUUID('550e8400-e29b-41d4-a716-446655440011'), '{"device_id":"ua1"}'),
    (generateUUIDv4(), 'page_viewed', toDateTime64(today() - 2, 3, 'UTC'), 'Google', 'Desktop', 'US', '2.0.3', 'web', 'pricing', toUUID('550e8400-e29b-41d4-a716-446655440011'), '{"device_id":"ua1"}'),
    (generateUUIDv4(), 'page_viewed', toDateTime64(today() - 1, 3, 'UTC'), 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'pricing', toUUID('550e8400-e29b-41d4-a716-446655440012'), '{"device_id":"ua2"}'),
    (generateUUIDv4(), 'page_viewed', toDateTime64(today() - 1, 3, 'UTC'), 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', toUUID('550e8400-e29b-41d4-a716-446655440012'), '{"device_id":"ua2"}'),
    (generateUUIDv4(), 'checkout_started', toDateTime64(today() - 1, 3, 'UTC'), 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', toUUID('550e8400-e29b-41d4-a716-446655440012'), '{"plan_selected":"6-Month","plans":"6-Month","amount":29.99,"currency":"GBP","payment_method":"credit_card","card_type":"visa","enter_email":"valid","transaction_id":"txn_uk_001","device_id":"ua2"}'),
    (generateUUIDv4(), 'checkout_completed', toDateTime64(today() - 1, 3, 'UTC'), 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', toUUID('550e8400-e29b-41d4-a716-446655440012'), '{"plan_purchased":"6-Month","plans":"6-Month","sub_status":"active","amount":29.99,"currency":"GBP","payment_method":"credit_card","card_type":"visa","transaction_id":"txn_uk_001","device_id":"ua2"}'),
    (generateUUIDv4(), 'page_viewed', toDateTime64(today(), 3, 'UTC'), 'Google', 'Desktop', 'US', '2.2.0', 'web', 'pricing', toUUID('550e8400-e29b-41d4-a716-446655440013'), '{"device_id":"ua3"}'),
    (generateUUIDv4(), 'checkout_started', toDateTime64(today(), 3, 'UTC'), 'Google', 'Desktop', 'US', '2.2.0', 'web', 'checkout', toUUID('550e8400-e29b-41d4-a716-446655440013'), '{"plan_selected":"Yearly","plan_updated":"Yearly","plans":"Yearly","amount":99.99,"currency":"USD","payment_method":"paypal","enter_email":"valid","transaction_id":"txn_us_002","device_id":"ua3"}'),
    (generateUUIDv4(), 'payment_method_added', toDateTime64(today(), 3, 'UTC'), NULL, 'Desktop', 'US', '2.2.0', 'web', NULL, toUUID('550e8400-e29b-41d4-a716-446655440013'), '{"payment_method":"paypal","device_id":"ua3"}'),
    (generateUUIDv4(), 'checkout_incomplete', toDateTime64(today() - 1, 3, 'UTC'), 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', toUUID('550e8400-e29b-41d4-a716-446655440014'), '{"plan_selected":"6-Month","device_id":"ua4"}');
