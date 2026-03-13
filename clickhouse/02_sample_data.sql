-- =============================================================================
-- Sample data for testing dashboards
-- Run after 01_schema_ddl.sql
-- message = parsed event properties (JSON)
-- =============================================================================

-- Sign Up & Sign In events
INSERT INTO web_events.events (event_type, event_date, device_type, platform, country, source, landing_page, app_version, message)
VALUES
    ('signup_started', today() - 1, 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.1.0', '{"signup_method":"email","enter_email":"valid"}'),
    ('signup_started', today() - 1, 'Mobile', 'Android', 'UK', 'Social', 'homepage', '2.0.5', '{"signup_method":"google","enter_email":"valid"}'),
    ('signup_started', today(), 'Tablet', 'iOS', 'US', 'Google', 'pricing', '2.2.0', '{"signup_method":"magic link","enter_email":"valid","magic_link":"sent"}'),
    ('signup_completed', today() - 1, 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.1.0', '{"signup_method":"email","enter_email":"valid","otp":"valid","account_creation":"Success"}'),
    ('signup_completed', today(), 'Mobile', 'Android', 'UK', 'Social', 'homepage', '2.0.5', '{"signup_method":"google","enter_email":"valid","account_creation":"Success"}'),
    ('signin_started', today(), 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.2.0', '{"signin_method":"email","enter_email":"valid"}'),
    ('signin_completed', today(), 'Desktop', 'web', 'US', 'Google', 'sign up page', '2.2.0', '{"signin_method":"email","enter_email":"valid"}');

-- User Acquisition events (landing_page = page viewed, same as page_name)
INSERT INTO web_events.events (event_type, event_date, source, device_type, country, app_version, platform, landing_page, transaction_id, plans, subscription_status, amount, currency, payment_method, message)
VALUES
    ('page_viewed', today() - 2, 'Google', 'Desktop', 'US', '2.0.3', 'web', 'homepage', NULL, NULL, NULL, NULL, NULL, NULL, '{}'),
    ('page_viewed', today() - 2, 'Google', 'Desktop', 'US', '2.0.3', 'web', 'pricing', NULL, NULL, NULL, NULL, NULL, NULL, '{}'),
    ('page_viewed', today() - 1, 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'pricing', NULL, NULL, NULL, NULL, NULL, NULL, '{}'),
    ('page_viewed', today() - 1, 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', NULL, NULL, NULL, NULL, NULL, NULL, '{}'),
    ('checkout_started', today() - 1, 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', 'txn_uk_001', '6-Month', NULL, 29.99, 'GBP', 'credit_card', '{"plan_selected":"6-Month","payment_method":"credit_card","enter_email":"valid"}'),
    ('checkout_completed', today() - 1, 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', 'txn_uk_001', '6-Month', 'active', 29.99, 'GBP', 'credit_card', '{"plan_purchased":"6-Month","payment_method":"credit_card"}'),
    ('page_viewed', today(), 'Google', 'Desktop', 'US', '2.2.0', 'web', 'pricing', NULL, NULL, NULL, NULL, NULL, NULL, '{}'),
    ('checkout_started', today(), 'Google', 'Desktop', 'US', '2.2.0', 'web', 'checkout', 'txn_us_002', 'Yearly', NULL, 99.99, 'USD', 'paypal', '{"plan_selected":"Yearly","plan_updated":"Yearly","payment_method":"paypal","enter_email":"valid"}'),
    ('payment_method_added', today(), NULL, 'Desktop', 'US', '2.2.0', 'web', NULL, NULL, NULL, NULL, NULL, 'paypal', '{"payment_method":"paypal"}'),
    ('checkout_incomplete', today() - 1, 'Social', 'Mobile', 'UK', '2.1.0', 'Android', 'checkout', NULL, NULL, NULL, NULL, NULL, NULL, '{"plan_selected":"6-Month"}');
