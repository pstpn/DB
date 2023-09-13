create table if not exists banks
(
    id               serial,
    name             varchar(100),
    owner            varchar(100),
    is_international bool,
    created_date     date not null
);

create table if not exists repairers
(
    id        serial,
    full_name varchar(100),
    age       int,
    country   varchar(100),
    salary    int
);

create table if not exists cash_machines
(
    id           serial,
    bank_id      int,
    model        varchar(100),
    current_cash int,
    mount_day    date
);

create table if not exists repairers_cash_machines
(
    repairer_id     int,
    cash_machine_id int
);

create table if not exists cards
(
    number       text,
    bank_id      int,
    owner        varchar(100),
    is_credit    bool,
    balance      int,
    release_date date
);

create table if not exists transactions
(
    id              text,
    cash_machine_id int,
    card_number     text,
    type            text,
    cash            int,
    time            timestamp
);
