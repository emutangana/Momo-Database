-- =====================================================
-- MoMo SMS Database - Week 2
-- Team: Ctrl Freaks!
-- MySQL 8+
-- =====================================================

CREATE DATABASE IF NOT EXISTS momo_sms_db;
USE momo_sms_db;

-- Re-running this file will recreate the tables from scratch.
DROP TABLE IF EXISTS system_logs;
DROP TABLE IF EXISTS transaction_participants;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS transaction_categories;
DROP TABLE IF EXISTS users;

-- =====================================================
-- USERS
-- People and businesses involved in MoMo transactions.
-- =====================================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    user_type VARCHAR(20) NOT NULL,
    CONSTRAINT chk_user_type
        CHECK (user_type IN ('CUSTOMER', 'MERCHANT'))
);

-- =====================================================
-- TRANSACTION CATEGORIES
-- Lookup table for transaction types.
-- =====================================================
CREATE TABLE transaction_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- =====================================================
-- TRANSACTIONS
-- Main information extracted from each MoMo SMS.
-- =====================================================
CREATE TABLE transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    category_id INT NOT NULL,
    sms_address VARCHAR(20) NOT NULL,
    sms_date DATETIME NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'RWF',
    fee DECIMAL(12,2) NOT NULL DEFAULT 0,
    balance_after DECIMAL(12,2) NOT NULL,
    raw_message TEXT NOT NULL,

    CONSTRAINT fk_transaction_category
        FOREIGN KEY (category_id)
        REFERENCES transaction_categories(category_id),

    CONSTRAINT chk_transaction_amount
        CHECK (amount > 0),

    CONSTRAINT chk_transaction_fee
        CHECK (fee >= 0),

    CONSTRAINT chk_transaction_balance
        CHECK (balance_after >= 0)
);

-- =====================================================
-- TRANSACTION PARTICIPANTS
-- Junction table resolving the many-to-many relationship
-- between users and transactions.
-- =====================================================
CREATE TABLE transaction_participants (
    transaction_id VARCHAR(50) NOT NULL,
    user_id INT NOT NULL,
    participant_role VARCHAR(20) NOT NULL,

    PRIMARY KEY (transaction_id, user_id),

    CONSTRAINT fk_participant_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES transactions(transaction_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_participant_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT chk_participant_role
        CHECK (participant_role IN ('SENDER', 'RECEIVER')),

    CONSTRAINT unique_transaction_role
        UNIQUE (transaction_id, participant_role)
);

-- =====================================================
-- SYSTEM LOGS
-- Records information about ETL/database processing.
-- =====================================================
CREATE TABLE system_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(50),
    log_level VARCHAR(20) NOT NULL,
    message VARCHAR(255) NOT NULL,
    processed_at DATETIME NOT NULL,

    CONSTRAINT fk_log_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES transactions(transaction_id)
        ON DELETE SET NULL,

    CONSTRAINT chk_log_level
        CHECK (log_level IN ('INFO', 'WARNING', 'ERROR'))
);

-- =====================================================
-- INDEXES
-- =====================================================
CREATE INDEX idx_transaction_date
    ON transactions(sms_date);

CREATE INDEX idx_transaction_category
    ON transactions(category_id);

CREATE INDEX idx_participant_user
    ON transaction_participants(user_id);

CREATE INDEX idx_log_transaction
    ON system_logs(transaction_id);

-- =====================================================
-- SAMPLE DATA: USERS
-- =====================================================
INSERT INTO users (user_id, display_name, user_type) VALUES
(1, 'Account Owner', 'CUSTOMER'),
(2, 'Jean Claude Uwimana', 'CUSTOMER'),
(3, 'Kigali Coffee Shop', 'MERCHANT'),
(4, 'Alice Mukamana', 'CUSTOMER'),
(5, 'Patrick Habimana', 'CUSTOMER'),
(6, 'City Supermarket', 'MERCHANT');

-- =====================================================
-- SAMPLE DATA: TRANSACTION CATEGORIES
-- The first three categories appear in the XML dataset.
-- The last two are extra sample lookup values.
-- =====================================================
INSERT INTO transaction_categories
(category_id, category_name, description) VALUES
(1, 'RECEIVED', 'Money received from another person'),
(2, 'PAYMENT', 'Payment made to a person or business'),
(3, 'TRANSFER', 'Money transferred to another person'),
(4, 'WITHDRAWAL', 'Money withdrawn from a MoMo account'),
(5, 'AIRTIME', 'Purchase of mobile airtime');

-- =====================================================
-- SAMPLE DATA: TRANSACTIONS
-- First 3 records come from the original XML provided.
-- Last 2 are clearly added sample/test records.
-- =====================================================
INSERT INTO transactions
(transaction_id, category_id, sms_address, sms_date, amount,
 currency, fee, balance_after, raw_message) VALUES
('78901234', 1, 'MoMo', '2024-05-10 14:06:40', 5000.00,
 'RWF', 0.00, 25000.00,
 'You have received 5000 RWF from Jean Claude Uwimana. Your new balance is 25000 RWF. Transaction Id: 78901234.'),
('78901235', 2, 'MoMo', '2024-05-10 15:06:40', 2000.00,
 'RWF', 0.00, 23000.00,
 'You have made a payment of 2000 RWF to Kigali Coffee Shop. Your new balance is 23000 RWF. Transaction Id: 78901235.'),
('78901236', 3, 'MoMo', '2024-05-10 16:06:40', 10000.00,
 'RWF', 100.00, 12900.00,
 'You have transferred 10000 RWF to Alice Mukamana. Fee: 100 RWF. Your new balance is 12900 RWF. Transaction Id: 78901236.'),
('78901237', 1, 'MoMo', '2024-05-10 17:06:40', 7500.00,
 'RWF', 0.00, 20400.00,
 'You have received 7500 RWF from Patrick Habimana. Your new balance is 20400 RWF. Transaction Id: 78901237.'),
('78901238', 2, 'MoMo', '2024-05-10 18:06:40', 3000.00,
 'RWF', 0.00, 17400.00,
 'You have made a payment of 3000 RWF to City Supermarket. Your new balance is 17400 RWF. Transaction Id: 78901238.');

-- =====================================================
-- SAMPLE DATA: TRANSACTION PARTICIPANTS
-- =====================================================
INSERT INTO transaction_participants
(transaction_id, user_id, participant_role) VALUES
('78901234', 2, 'SENDER'),
('78901234', 1, 'RECEIVER'),
('78901235', 1, 'SENDER'),
('78901235', 3, 'RECEIVER'),
('78901236', 1, 'SENDER'),
('78901236', 4, 'RECEIVER'),
('78901237', 5, 'SENDER'),
('78901237', 1, 'RECEIVER'),
('78901238', 1, 'SENDER'),
('78901238', 6, 'RECEIVER');

-- =====================================================
-- SAMPLE DATA: SYSTEM LOGS
-- =====================================================
INSERT INTO system_logs
(transaction_id, log_level, message, processed_at) VALUES
('78901234', 'INFO', 'Received transaction processed successfully', '2024-05-10 14:06:45'),
('78901235', 'INFO', 'Payment transaction processed successfully', '2024-05-10 15:06:45'),
('78901236', 'INFO', 'Transfer transaction processed successfully', '2024-05-10 16:06:45'),
('78901237', 'INFO', 'Received transaction processed successfully', '2024-05-10 17:06:45'),
('78901238', 'INFO', 'Payment transaction processed successfully', '2024-05-10 18:06:45');
