import csv
import random
import uuid
import hashlib
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()

# Number of rows to generate tables
bank_rows = 2000
cash_machine_rows = 2000
repairers_rows = 2000
transactions_rows = 2000
card_numbers_rows = 2000


# Function to generate random bank name
def generate_bank_name():
    bank_suffixes = ["Bank", "Credit Union", "Savings and Loan", "Trust Company"]
    return fake.company() + " " + random.choice(bank_suffixes)


# Function to generate a random full name
def generate_full_name():
    return fake.name()


# Function to generate a random international flag (boolean)
def generate_bool():
    return random.choice([True, False])


# Function to generate a random age
def generate_age():
    return random.randint(18, 80)


# Function to generate a random country
def generate_country():
    return fake.country()


# Function to generate a random created date
def generate_date():
    year = random.randint(2000, 2023)
    month = random.randint(1, 12)
    day = random.randint(1, 28)
    return f"{year}-{month:02d}-{day:02d}"


# Function to generate random bank ID
def generate_bank_id():
    return random.randint(1, bank_rows)


# Function to generate random repairer ID
def generate_repairer_id():
    return random.randint(1, repairers_rows)


# Function to generate a random cash machine ID
def generate_cash_machine_id():
    return random.randint(1, cash_machine_rows)


# Function to generate a random cash machine model
def generate_cash_machine_model():
    cash_machine_models = ["ModelA", "ModelB", "ModelC", "ModelD"]
    return random.choice(cash_machine_models)


# Function to generate random current cash in the cash machine
def generate_current_cash():
    return random.randint(100, 100000)


# Function to generate a random transaction type
def generate_transaction_type():
    transaction_types = ["Purchase", "Withdrawal", "Deposit", "Transfer"]
    return random.choice(transaction_types)


# Function to generate a random card number
def generate_card_number():
    return ''.join(random.choice('0123456789') for _ in range(16))


# Function to generate a unique hash
def generate_hash():
    unique_value = uuid.uuid4().hex
    return hashlib.sha256(unique_value.encode()).hexdigest()


# Function to generate a timestamp between 2000 and 2023
def generate_timestamp():
    start_date = datetime(2000, 1, 1)
    end_date = datetime(2023, 8, 31)

    random_days = random.randint(0, (end_date - start_date).days)
    random_time = start_date + timedelta(days=random_days)

    return random_time.strftime("%Y-%m-%d %H:%M:%S")


# Generate cards data and write to a CSV file
def generate_cards(card_numbers: set):
    with open("./src/data/cards_data.csv", mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["number", "bank_id", "owner", "is_credit", "balance", "release_date"])

        for _ in range(card_numbers_rows):
            writer.writerow([
                card_numbers.pop(),
                generate_bank_id(),
                generate_full_name(),
                generate_bool(),
                generate_current_cash(),
                generate_date()
            ])


# Generate transactions data and write to a CSV file
def generate_transactions() -> set:
    unique_numbers = set()

    with open("./src/data/transactions_data.csv", mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["id", "cash_machine_id", "card_number", "type", "cash", "time"])

        for _ in range(transactions_rows):
            bank_card_number = generate_card_number()

            # Ensure generated number is unique
            while bank_card_number in unique_numbers:
                bank_card_number = generate_card_number()

            unique_numbers.add(bank_card_number)

            writer.writerow([
                generate_hash(),
                generate_cash_machine_id(),
                bank_card_number,
                generate_transaction_type(),
                generate_current_cash(),
                generate_timestamp()
            ])

    return unique_numbers


# Generate repairers data and write to a CSV file
def generate_repairers():
    with open("./src/data/repairers_data.csv", mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["full_name", "age", "country", "salary"])

        for _ in range(repairers_rows):
            writer.writerow([
                generate_full_name(),
                generate_age(),
                generate_country(),
                generate_current_cash()
            ])


# Generate cash machines and write data to a CSV file
def generate_cash_machines():
    with open("./src/data/cash_machine_data.csv", mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["bank_id", "repairer_id", "model", "current_cash", "mount_date"])

        for _ in range(cash_machine_rows):
            writer.writerow([
                generate_bank_id(),
                generate_repairer_id(),
                generate_cash_machine_model(),
                generate_current_cash(),
                generate_date()
            ])


# Generate banks data and write to a CSV file
def generate_banks():
    with open("./src/data/banks_data.csv", mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["name", "owner", "is_international", "created_date"])

        for _ in range(bank_rows):
            writer.writerow([
                generate_bank_name(),
                generate_full_name(),
                generate_bool(),
                generate_date()
            ])


if __name__ == '__main__':
    generate_banks()
    generate_cash_machines()
    generate_repairers()
    card_numbers = generate_transactions()
    generate_cards(card_numbers)
