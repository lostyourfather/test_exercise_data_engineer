#!/bin/bash

# DDL для создания таблицы
DDL="CREATE TABLE EventsTest(
user_id String,
product_identifier Nullable(String),
start_time DateTime,
end_time Nullable(DateTime),
price_in_usd Nullable(Float32)
)
ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMM(start_time)
ORDER BY (toDate(start_time), user_id);"

# Пересоздание таблицы в ClickHouse
echo "$DDL" | clickhouse-client

# Преобразование CSV в формат, соответствующий структуре таблицы
awk -F',' '{ printf "%s,%s,%s,%s,%s\n", $1, $2, $3, $4, $5 }' input.csv > formatted_data.csv

# Выгрузка данных из CSV в таблицу
clickhouse-client --query="INSERT INTO EventsTest FORMAT CSV" --input_format_allow_errors_ratio=0 < formatted_data.csv

# Удаление временного файла с отформатированными данными
rm formatted_data.csv