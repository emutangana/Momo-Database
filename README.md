# MoMo SMS Data Processing & Analysis

## Team Name
Ctrl Freaks!

## Team Members
- Orion Seruvumba - `OrionS24`
- Elvis Gatunzi Mutangana - `emutangana`
- Ezio Munyengano - `chuloezi`

## Project Description
This project processes Mobile Money (MoMo) SMS transaction data provided in XML format. The data is parsed, cleaned, normalized and categorized before being stored in a relational MySQL database. The structured data can then be serialized into JSON and used by an API or frontend dashboard.

This Week 2 task focuses on database design, MySQL implementation, relationships, constraints, CRUD testing and JSON serialization.

## Database Design
The database contains five main tables:

- `users` - people and businesses involved in transactions.
- `transaction_categories` - transaction types such as RECEIVED, PAYMENT and TRANSFER.
- `transactions` - information extracted from each MoMo SMS.
- `transaction_participants` - junction table connecting users and transactions and storing each participant's role.
- `system_logs` - information about transaction processing.

### Relationships
- One transaction category can have many transactions.
- One transaction can have many system logs.
- One user can participate in many transactions.
- One transaction can have multiple participants.
- The many-to-many relationship between users and transactions is resolved using `transaction_participants`.

## XML Data
The XML file is stored at:

```text
data/raw/momo.xml
```

The first three SMS messages came from the provided XML sample. Two additional clearly identified test records were added so the database has enough sample data for testing.

## MySQL Setup
1. Open MySQL Workbench.
2. Open `database/database_setup.sql`.
3. Run the full script.
4. Confirm that the `momo_sms_db` database was created.
5. Open `database/test_queries.sql` and run the test queries.

Example:

```sql
USE momo_sms_db;
SELECT * FROM transactions;
```

## JSON Examples
JSON examples are stored in:

```text
examples/json_schemas.json
```

The complete transaction example shows how related SQL records can be serialized into one nested JSON object for an API or frontend application.

## Scrum Board
https://github.com/users/chuloezi/projects/1/views/1

## Original Repository
https://github.com/OrionS24/momo-sms-etl

## Team task sheet link
https://docs.google.com/spreadsheets/d/13jCSyGdXpnGZYsQkS5OAhYI3jhWQJSRcDvm6dBZxpX4/edit?usp=sharing
