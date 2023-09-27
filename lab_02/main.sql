-- 1. Инструкция SELECT, использующая предикат сравнения.
SELECT *
FROM repairers
WHERE age > 27
ORDER BY salary;


-- 2. Инструкция SELECT, использующая предикат BETWEEN.
SELECT owner, balance, release_date
FROM cards
WHERE release_date BETWEEN '2007-01-01' AND '2010-03-31';


-- 3. Инструкция SELECT, использующая предикат LIKE.
SELECT id, country, age
FROM repairers
WHERE lower(country) LIKE '%ia';


-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
SELECT *
FROM cash_machines
WHERE bank_id IN (
    SELECT id
    FROM banks
    WHERE is_international = true
)
AND model = 'ModelC';


-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
SELECT *
FROM banks
WHERE EXISTS (
    SELECT *
    FROM cash_machines
    WHERE bank_id > 1000
);


-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
SELECT *
FROM cards
WHERE '2030-01-01' > ALL (
    SELECT created_date
    FROM banks
    WHERE is_international = true
);


-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
SELECT AVG(TotalSalary.salary) AS "Salary AVG"
FROM (
    SELECT salary
    FROM repairers
) AS TotalSalary;


-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
SELECT
    (
        SELECT AVG(current_cash)
        FROM cash_machines
        WHERE model = 'ModelC'
    ) AS AvgCash,
    (
        SELECT MIN(created_date)
        FROM banks
        WHERE is_international = false
    ) AS MinDate,
    *
FROM transactions
WHERE cash_machine_id = 1;


-- 9. Инструкция SELECT, использующая простое выражение CASE.
SELECT *,
    CASE extract(YEAR FROM time)
        WHEN '2018' THEN 'Wow, 5 years have passed'
        ELSE concat(CAST(abs(extract(YEAR FROM time) - extract(YEAR FROM CAST('2023-01-01' AS date)))
            AS varchar(5)), ' years ago')
    END AS delta
FROM transactions;


-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
SELECT name,
    CASE
        WHEN is_international = true THEN 'Inter'
        ELSE 'Local'
    END AS International
FROM banks;


-- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
SELECT id, max(length(full_name)) AS Lens
INTO LongestName
FROM repairers
GROUP BY id
ORDER BY salary;

select *
from LongestName;

drop table LongestName;


-- 12. Инструкция SELECT, использующая вложенные коррелированные
-- подзапросы в качестве производных таблиц в предложении FROM.
SELECT *
FROM cash_machines
JOIN
(
    SELECT id
    FROM banks
    WHERE created_date > '2013-01-01'
) AS banks_machines ON cash_machines.bank_id = banks_machines.id;


-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
SELECT *
FROM transactions
WHERE transactions.cash_machine_id
IN
(
    SELECT cash_machines.id
    FROM cash_machines
    WHERE cash_machines.current_cash >
    (
        SELECT avg(repairers.salary)
        FROM repairers
        WHERE repairers.salary BETWEEN 10000 AND
        (
            SELECT max(repairers.salary)
            FROM repairers
        )
    )
);


-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY, но без предложения HAVING.
SELECT model, count(*)
FROM cash_machines
GROUP BY model;


-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
SELECT country, count(country)
FROM repairers
GROUP BY country
HAVING count(country) < 10;


-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
INSERT INTO banks (name, owner, is_international, created_date)
VALUES ('Tinkoff', 'Oleg', true, '2004-03-31');

SELECT *
FROM banks
ORDER BY id DESC;

DELETE
FROM banks
WHERE name = 'Tinkoff';


-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу
-- результирующего набора данных вложенного подзапроса.
INSERT INTO repairers (full_name, age, country, salary)
SELECT full_name, age, 'Italy', salary + 20000
FROM repairers
WHERE salary < 50000;

SELECT *
FROM repairers
WHERE country = 'Italy';


-- 18. Простая инструкция UPDATE.
SELECT *
FROM cash_machines
WHERE id = 13;

UPDATE cash_machines
SET current_cash = 1
WHERE id = 13;


-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
SELECT *
FROM repairers
WHERE country = 'Italy';

UPDATE repairers
SET salary =
(
    SELECT max(salary)
    FROM repairers
    WHERE country = 'Brazil'
)
WHERE country = 'Italy';


-- 20. Простая инструкция DELETE.
SELECT *
FROM cards;

SELECT *
FROM transactions
WHERE card_number = '5016839381801631';

DELETE FROM transactions
WHERE card_number = '5016839381801631';


-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
SELECT *
FROM cards;

SELECT *
FROM cards
WHERE owner = 'Victor Jackson';

DELETE FROM transactions
WHERE transactions.card_number =
(
    SELECT number
    FROM cards
    WHERE owner = 'Victor Jackson'
);

SELECT * FROM transactions
WHERE transactions.card_number =
(
    SELECT number
    FROM cards
    WHERE owner = 'Victor Jackson'
);


-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
WITH cte (age, salary) AS
(
    SELECT age, count(age), max(salary)
    FROM repairers
    GROUP BY age
)
SELECT *
FROM cte
WHERE age > 40;


-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение
CREATE TABLE partners
(
    id              serial primary key,
    partner_bank_id int
);

SELECT *
FROM partners;

INSERT INTO partners(partner_bank_id)
VALUES
    (1000),
    (92),
    (1001),
    (1);

SELECT *
FROM partners;

WITH RECURSIVE CalcAvg (id, partner_bank_id) AS
(
    SELECT partners.id, partners.partner_bank_id
    FROM partners
    WHERE partner_bank_id = 1
    UNION ALL

    SELECT partners.id, partners.partner_bank_id
    FROM partners
    JOIN CalcAvg AS calc_rec ON partners.id = calc_rec.partner_bank_id
)
SELECT *
FROM CalcAvg;

DROP TABLE partners;


-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
SELECT *,
       AVG(current_cash) OVER(PARTITION BY model) AS AvgCash,
       MIN(current_cash) OVER(PARTITION BY model) AS MinCash,
       MAX(current_cash) OVER(PARTITION BY model) AS MaxCash
FROM cash_machines;


-- 25. Оконные функции для устранения дублей
WITH Dubl AS
(
    SELECT *
    FROM banks

    UNION ALL

    SELECT *
    FROM banks
),
DelDubl AS
(
    SELECT *, row_number() over (partition by id) AS num
    FROM Dubl
)
SELECT *
FROM DelDubl
WHERE num = 1;


-- -- **Дополнительное задание на дополнительные баллы**
--
-- -- Создать таблицы:
-- -- • Table1{id: integer, var1: string, valid_from_dttm: date, valid_to_dttm: date}
-- -- • Table2{id: integer, var2: string, valid_from_dttm: date, valid_to_dttm: date}
-- -- Версионность в таблицах непрерывная, разрывов нет (если valid_to_dttm =
-- -- '2018-09-05', то для следующей строки соответствующего ID valid_from_dttm =
-- -- '2018-09-06', т.е. на день больше). Для каждого ID дата начала версионности и
-- -- дата конца версионности в Table1 и Table2 совпадают.
-- -- Выполнить версионное соединение двух таблиц по полю id.
-- DROP TABLE IF EXISTS  Table_1, Table_2;
--
-- CREATE TABLE IF NOT EXISTS Table_1
-- (
--     id              int,
--     var1            varchar(100),
--     valid_from_dttm date,
--     valid_to_dttm   date
-- );
--
-- CREATE TABLE IF NOT EXISTS Table_2
-- (
--     id              int,
--     var2            varchar(100),
--     valid_from_dttm date,
--     valid_to_dttm   date
-- );
--
-- INSERT INTO table_1(id, var1, valid_from_dttm, valid_to_dttm)
-- VALUES
--     (1, 'A', '2018-09-01', '2018-09-15'),
--     (1, 'B', '2018-09-16', '5999-12-31');
--
-- INSERT INTO table_2(id, var2, valid_from_dttm, valid_to_dttm)
-- VALUES
--     (1, 'A', '2018-09-01', '2018-09-18'),
--     (1, 'B', '2018-09-19', '5999-12-31');
--
-- WITH select_all AS
-- (
--     SELECT *
--     FROM table_1
--
--     UNION ALL
--
--     SELECT *
--     FROM table_2
-- )
-- SELECT *
-- FROM select_all;
--
--
-- WITH ordered_dates AS
-- (
--     SELECT *
--     FROM table_1
--
--     UNION ALL
--
--     SELECT *
--     FROM table_2
-- )
-- SELECT *
-- FROM ordered_dates;
--
-- DROP TABLE IF EXISTS table_1;
-- DROP TABLE IF EXISTS table_2;
