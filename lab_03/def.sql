create view cards_view as select * from cards;

create or replace function on_insert_card()
returns trigger as $$
declare
    old_row record;
begin
    select *
    from cards
    where
        cards.bank_id = new.bank_id and
        cards.release_date = new.release_date and
        cards.owner = new.owner and
        cards.is_credit = new.is_credit
    into old_row;

    if old_row.balance != new.balance then
        update cards
        set balance = new.balance
        where cards.bank_id = new.bank_id and
        cards.release_date = new.release_date and
        cards.owner = new.owner and
        cards.is_credit = new.is_credit;
    else
        insert into cards
        values
        (
            new.number,
            new.bank_id,
            new.owner,
            new.is_credit,
            new.balance,
            new.release_date
        );
    end if;

	return new;
end
$$ language plpgsql;

create or replace trigger on_insert_card
instead of insert on cards_view
for each row
execute function on_insert_card();

select * from cards limit 1;

insert into cards_view values
(
    '8410253235442054',
    649,
    'Gabriella Smith',
    false,
    40572,
    '2016-09-09'
);

select * from cards where number = '8410253235442051' or number = '8410253235442054';
delete from cards where number = '8410253235442051';

insert into cards_view values
(
    '8410253235442051',
    649,
    'Gabriella Smith',
    false,
    40570,
    '2016-09-09'
);

drop view cards_view;
drop trigger on_insert_card on cards_view;
drop function on_insert_card();