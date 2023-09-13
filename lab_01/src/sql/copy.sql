\copy banks(name, owner, is_international, created_date) from 'C:\Users\Admin\OneDrive\Documents\GitHub\DB\lab_01\src\data\banks_data.csv' delimiter ';' csv header;
\copy repairers(full_name, age, country, salary) from 'C:\Users\Admin\OneDrive\Documents\GitHub\DB\lab_01\src\data\repairers_data.csv' delimiter ';' csv header;
\copy cash_machines(bank_id, model, current_cash, mount_day) from 'C:\Users\Admin\OneDrive\Documents\GitHub\DB\lab_01\src\data\cash_machine_data.csv' delimiter ';' csv header;
\copy repairers_cash_machines(repairer_id, cash_machine_id) from 'C:\Users\Admin\OneDrive\Documents\GitHub\DB\lab_01\src\data\repairers_cash_machines_data.csv' delimiter ';' csv header;
\copy cards(number, bank_id, owner, is_credit, balance, release_date) from 'C:\Users\Admin\OneDrive\Documents\GitHub\DB\lab_01\src\data\cards_data.csv' delimiter ';' csv header;
\copy transactions(id, cash_machine_id, card_number, type, cash, time) from 'C:\Users\Admin\OneDrive\Documents\GitHub\DB\lab_01\src\data\transactions_data.csv' delimiter ';' csv header;
