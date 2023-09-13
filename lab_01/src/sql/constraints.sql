alter table banks
    add constraint pk_bank_id primary key(id),

    add constraint valid_name check(name != ''),
    add constraint valid_owner check(owner != ''),

    alter column name set not null,
    alter column owner set not null,
    alter column is_international set not null,
    alter column created_date set not null;

alter table repairers
    add constraint pk_repairer_id primary key(id),

    add constraint valid_full_name check(full_name != ''),
    add constraint valid_age check(age >= 18 and age < 90),
    add constraint valid_country check(country != ''),
    add constraint valid_salary check(salary > 0),

    alter column full_name set not null,
    alter column age set not null,
    alter column country set not null,
    alter column salary set not null;

alter table cash_machines
    add constraint pk_cash_machine_id primary key(id),
    add constraint fk_bank_id foreign key(bank_id) references banks(id),

    add constraint valid_model check(model != ''),
    add constraint valid_current_cash check(current_cash >= 0),

    alter column model set not null,
    alter column current_cash set not null,
    alter column mount_day set not null;

alter table repairers_cash_machines
    add constraint fk_repairer_id foreign key(repairer_id) references repairers(id),
    add constraint fk_cash_machine_id foreign key(cash_machine_id) references cash_machines(id);

alter table cards
    add constraint pk_card_number primary key(number),
    add constraint fk_bank_id foreign key(bank_id) references banks(id),

    add constraint valid_owner check(owner != ''),

    alter column owner set not null,
    alter column is_credit set not null,
    alter column balance set not null,
    alter column release_date set not null;

alter table transactions
    add constraint pk_transaction_id primary key(id),
    add constraint fk_cash_machine_id foreign key(cash_machine_id) references cash_machines(id),
    add constraint fk_card_number foreign key(card_number) references cards(number),

    add constraint valid_type check(type != ''),
    add constraint valid_cash check(cash > 0),

    alter column type set not null,
    alter column cash set not null,
    alter column time set not null;
