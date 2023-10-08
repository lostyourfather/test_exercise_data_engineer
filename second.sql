CREATE TABLE deposite_full
(
    `user_id` UInt64,
    `created_at` Date,
    `deposit_amount` AggregateFunction(sum, Decimal(18, 5)),
    `deposit_withdrawal` AggregateFunction(sum, Decimal(18, 5)),
    `balance` Decimal(18, 5)
)
ENGINE = AggregatingMergeTree
ORDER BY (user_id, created_at);


CREATE MATERIALIZED VIEW deposite_full_mv TO deposite_full AS
SELECT
    Deposit.user_id AS user_id,
    Deposit.created_at AS created_at,
    sumState(Deposit.amount) AS deposit_amount,
    sumState(Withdrawal.amount) AS deposit_withdrawal,
    SUM(Deposit.amount) - SUM(Withdrawal.amount) AS balance
FROM Deposit
INNER JOIN Withdrawal USING (user_id)
GROUP BY
    user_id,
    created_at;

SELECT
    Deposit.user_id,
    Deposit.created_at,
    SUM(Deposit.amount),
    SUM(Withdrawal.amount),
    SUM(Deposit.amount)-SUM(Withdrawal.amount)
FROM Deposit
    INNER JOIN Withdrawal USING(user_id)
GROUP BY user_id, created_at ORDER BY Deposit.user_id;


ALTER TABLE deposite_full_mv MODIFY SETTING materialized_view_refresh_interval = 10;
