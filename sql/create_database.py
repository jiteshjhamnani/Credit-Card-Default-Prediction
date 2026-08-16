import pandas as pd
import sqlite3

csv_path = "data/processed/clean_credit_data.csv"

db_path = "sql/credit_risk.db"

df = pd.read_csv(csv_path)

print("Dataset loaded successfully.")
print("Rows:", len(df))
print("Columns:", len(df.columns))

connection = sqlite3.connect(db_path)

df.to_sql(
    "customers",
    connection,
    if_exists="replace",
    index=False
)

print("\nDatabase created successfully.")
print("Table: customers")

# Check number of records
cursor = connection.cursor()

cursor.execute("SELECT COUNT(*) FROM customers")

count = cursor.fetchone()[0]

print("Records in database:", count)

cursor.execute("SELECT * FROM customers LIMIT 5")

rows = cursor.fetchall()

print("\nSample records:")

for row in rows:
    print(row)

connection.close()