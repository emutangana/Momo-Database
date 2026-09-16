-- =====================================================
-- MoMo SMS Database - Test Queries
-- Run database_setup.sql first.
-- =====================================================

USE momo_sms_db;

-- 1. READ: View each table.
SELECT * FROM users;
SELECT * FROM transaction_categories;
SELECT * FROM transactions;
SELECT * FROM transaction_participants;
SELECT * FROM system_logs;

-- 2. JOIN QUERY: Shows that the relationships work.
SELECT
    t.transaction_id,
    c.category_name,
    t.amount,
    t.currency,
    u.display_name,
    tp.participant_role
FROM transactions t
JOIN transaction_categories c
    ON t.category_id = c.category_id
JOIN transaction_participants tp
    ON t.transaction_id = tp.transaction_id
JOIN users u
    ON tp.user_id = u.user_id
ORDER BY t.transaction_id, tp.participant_role;

-- 3. CREATE: Add a temporary test user.
INSERT INTO users (display_name, user_type)
VALUES ('Test User', 'CUSTOMER');

-- 4. READ: Confirm the temporary user exists.
SELECT * FROM users
WHERE display_name = 'Test User';

-- 5. UPDATE: Change the temporary user's name.
UPDATE users
SET display_name = 'Updated Test User'
WHERE display_name = 'Test User';

SELECT * FROM users
WHERE display_name = 'Updated Test User';

-- 6. DELETE: Remove the temporary user.
DELETE FROM users
WHERE display_name = 'Updated Test User';

SELECT * FROM users
WHERE display_name = 'Updated Test User';

-- 7. DATA-INTEGRITY TESTS
-- These statements are intentionally invalid. Run them ONE AT A TIME
-- if you want screenshots showing MySQL rejecting bad data.

-- Negative amount should fail because amount must be > 0.
-- INSERT INTO transactions
-- (transaction_id, category_id, sms_address, sms_date, amount,
--  currency, fee, balance_after, raw_message)
-- VALUES
-- ('BAD001', 1, 'MoMo', NOW(), -5000, 'RWF', 0, 10000,
--  'Invalid negative amount test');

-- Invalid participant role should fail.
-- INSERT INTO transaction_participants
-- (transaction_id, user_id, participant_role)
-- VALUES ('78901234', 4, 'OBSERVER');

-- Invalid log level should fail.
-- INSERT INTO system_logs
-- (transaction_id, log_level, message, processed_at)
-- VALUES ('78901234', 'DEBUG', 'Invalid log level test', NOW());
