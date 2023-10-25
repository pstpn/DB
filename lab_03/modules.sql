--Скалярная функция
create or replace function get_repairers_count()
returns int as
$$
    begin
        return (select count(*)
        from repairers);
    end;
$$ language plpgsql;

select get_repairers_count();
drop function get_repairers_count();


--Подставляемая табличная функция
create or replace function get_cash_machines_with_model(machine_model text)
returns table
(
    id           int,
    current_cash int
) as
$$
    begin
        return query

        select cash_machines.id, cash_machines.current_cash
        from cash_machines
        where cash_machines.model = machine_model;
	end
$$ language plpgsql;

select get_cash_machines_with_model('ModelC');
drop function get_cash_machines_with_model(text);


--Многооператорная табличная функция
create or replace function get_banks_info()
returns table
(
    name text,
    owner text
) as $$
begin
	drop table if exists tmp_banks;
	create temp table if not exists tmp_banks(name text, owner text);

	insert into tmp_banks(name, owner)
	select b.name, b.owner
	from banks b
	where created_date < '24.09.2000';

	return query
	select *
	from tmp_banks;
end;
$$ language plpgsql;

select * from get_banks_info();
drop function get_banks_info();


--Рекурсивная функция или функция с рекурсивным ОТВ
create or replace function get_all_cash_in_cash_machines()
returns int as
$$
    begin
        return (with recursive cte(n) as (select 0 as n, 1 as i

                                          union all

                                          select n + (select current_cash from cash_machines where id = i) as n,
                                                 i + 1                                                     as i
                                          from cte
                                          where i <= (select max(id) from cash_machines))
                select max(n)
                from cte);
	end
$$ language plpgsql;

select * from get_all_cash_in_cash_machines();
drop function get_all_cash_in_cash_machines();


--Хранимая процедура без параметров или с параметрами
create or replace procedure add_cash_with_transaction(transaction_type text)
as $$
begin 
	update transactions
	set cash = cash + 10
	where type = transaction_type;
end;
$$ language plpgsql;

call add_cash_with_transaction('Transfer');
drop procedure add_cash_with_transaction(text);

select *
from transactions
where type = 'Transfer';


--Рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ
create or replace procedure print_all_cash_from_id(cid int)
as $$
begin
    if cid > 0 then
        raise notice 'current id and cash: (%, %)',
            cid,
            (select current_cash from cash_machines where id = cid);

        call print_all_cash_from_id(cid - 1);
    else
        raise notice 'stop';
    end if;
end;
$$ language plpgsql;

call print_all_cash_from_id(10);
drop procedure print_all_cash_from_id(int);


--Хранимая процедура с курсором
create or replace procedure get_banks_from_date(cur_date date)
as $$
declare
	cur cursor for
		select name
		from banks
		where created_date >= cur_date;
    bank text;
begin
	open cur;
	loop
		fetch cur into bank;
		exit when not found;
		raise notice 'bank name: %', bank;
	end loop;
	close cur;
end;
$$ language plpgsql;

call get_banks_from_date('24.10.2023');
drop procedure get_banks_from_date(cur_date date);


--Хранимая процедура доступа к метаданным
create or replace procedure get_metadata(my_table_name text)
as $$
declare
	cur cursor for
		select *
		from information_schema.columns
		where table_name = my_table_name;
	metadata record;
begin
	open cur;
	loop
		fetch cur into metadata;
		exit when not found;
		raise notice '%, %', metadata.column_name, metadata.data_type;
	end loop;
	close cur;
end
$$ language plpgsql;

call get_metadata('banks');
drop procedure get_metadata(my_table_name text);


--Триггер AFTER
create or replace function on_banks_insert()
returns trigger as $$
begin
    raise notice 'Information has been added to the table banks';
    return new;
end
$$ language plpgsql;

create or replace trigger on_banks_insert
after insert on banks
for each row
execute function on_banks_insert();
drop trigger if exists on_banks_insert on banks;
drop function on_banks_insert();

insert into banks(name, owner, is_international, created_date) values
(
    'MyBank',
    'Ya',
    True,
    '25.10.2023'
);


--Триггер INSTEAD OF
drop view if exists banks_view;
create view banks_view as select * from banks;

create or replace function on_insert_bank()
returns trigger as $$
declare
    bank_name text = new.name;
begin
	if new.name = 'BadBank' then
	    bank_name = 'GoodBank';
	end if;

    insert into banks_view(name, owner, is_international, created_date) values
    (
        bank_name,
        new.owner,
        new.is_international,
        new.created_date
    );
	return new;
end
$$ language plpgsql;

create or replace trigger on_insert_bank
instead of insert on banks_view
for each row
execute function on_insert_bank();
drop trigger if exists on_insert_bank on banks_view;
drop function on_insert_bank();

insert into banks_view(name, owner, is_international, created_date) values
(
    'BadBank',
    'IU7',
    False,
    now()
);

insert into banks_view(name, owner, is_international, created_date) values
(
    'NiceBank',
    'IU6',
    False,
    now()
);

select *
from banks_view
where name = 'BadBank' or name = 'GoodBank' or name = 'NiceBank';