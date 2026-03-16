-- =============================================================================
-- Sample data for testing dashboards
-- Run after 01_schema_ddl.sql
-- message = parsed event properties (JSON)
-- event_time required; visitor_id defaults to ''; event_date removed
-- =============================================================================

-- Sign Up & Sign In events (event_time = toDateTime64 of date)
INSERT INTO web_events.events (event_type, event_time, device_type, platform, country, source, page, app_version, message)
VALUES
    ('signup_started', toDateTime64(today() - 1, 3, 'UTC'), 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.1.0', '{"signup_method":"email","enter_email":"valid"}'),
    ('signup_started', toDateTime64(today() - 1, 3, 'UTC'), 'Mobile', 'Android', 'UK', 'Social', 'homepage', '2.0.5', '{"signup_method":"google","enter_email":"valid"}'),
    ('signup_started', toDateTime64(today(), 3, 'UTC'), 'Tablet', 'iOS', 'US', 'Google', 'pricing', '2.2.0', '{"signup_method":"magic link","enter_email":"valid","magic_link":"sent"}'),
    ('signup_completed', toDateTime64(today() - 1, 3, 'UTC'), 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.1.0', '{"signup_method":"email","enter_email":"valid","otp":"valid","account_creation":"Success"}'),
    ('signup_completed', toDateTime64(today(), 3, 'UTC'), 'Mobile', 'Android', 'UK', 'Social', 'homepage', '2.0.5', '{"signup_method":"google","enter_email":"valid","account_creation":"Success"}'),
    ('signin_started', toDateTime64(today(), 3, 'UTC'), 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.2.0', '{"signin_method":"email","enter_email":"valid"}'),
    ('signin_completed', toDateTime64(today(), 3, 'UTC'), 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.2.0', '{"signin_method":"email","enter_email":"valid"}');

-- User Acquisition events (page = page viewed, same as page_name)
INSERT INTO web_events.events (event_type, event_time, source, device_type, country, app_version, platform, page, transaction_id, plans, subscription_status, amount, currency, payment_method, card_type, message)
VALUES
    ('page_viewed', toDateTime64(today() - 2, 3, 'UTC'), 'Google', 'Desktop', 'US', '2.0.3', 'web', 'homepage', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}'),
    ('page_viewed', toDateTime64(today() - 2, 3, 'UTC'), 'Google', 'Desktop', 'US', '2.0.3', 'web', 'pricing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}'),
    ('page_viewed', toDateTime64(today() - 1, 3, 'UTC'), 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'pricing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}'),
    ('page_viewed', toDateTime64(today() - 1, 3, 'UTC'), 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}'),
    ('checkout_started', toDateTime64(today() - 1, 3, 'UTC'), 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', 'txn_uk_001', '6-Month', NULL, 29.99, 'GBP', 'credit_card', 'visa', '{"plan_selected":"6-Month","payment_method":"credit_card","enter_email":"valid"}'),
    ('checkout_completed', toDateTime64(today() - 1, 3, 'UTC'), 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', 'txn_uk_001', '6-Month', 'active', 29.99, 'GBP', 'credit_card', 'visa', '{"plan_purchased":"6-Month","payment_method":"credit_card"}'),
    ('page_viewed', toDateTime64(today(), 3, 'UTC'), 'Google', 'Desktop', 'US', '2.2.0', 'web', 'pricing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}'),
    ('checkout_started', toDateTime64(today(), 3, 'UTC'), 'Google', 'Desktop', 'US', '2.2.0', 'web', 'checkout', 'txn_us_002', 'Yearly', NULL, 99.99, 'USD', 'paypal', NULL, '{"plan_selected":"Yearly","plan_updated":"Yearly","payment_method":"paypal","enter_email":"valid"}'),
    ('payment_method_added', toDateTime64(today(), 3, 'UTC'), NULL, 'Desktop', 'US', '2.2.0', 'web', NULL, NULL, NULL, NULL, NULL, 'paypal', NULL, '{"payment_method":"paypal"}'),
    ('checkout_incomplete', toDateTime64(today() - 1, 3, 'UTC'), 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"plan_selected":"6-Month"}');
