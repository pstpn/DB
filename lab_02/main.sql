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
    END AS when
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


-- -- 12. Инструкция SELECT, использующая вложенные коррелированные
-- -- подзапросы в качестве производных таблиц в предложении FROM.
-- SELECT 'By units' AS Criteria, ProductName as BestSelling
-- FROM Products P JOIN ( SELECT TOP 1 ProductID, SUM(Quantity) AS SQ
-- FROM [Order Details]
-- GROUP BY productID
-- ORDER BY SQ DESC ) AS OD ON OD.ProductID = P.ProductID
-- UNION
-- SELECT 'By revenue' AS Criteria, ProductName as 'Best Selling'
-- FROM Products P JOIN ( SELECT TOP 1 ProductID,
-- SUM(UnitPrice*Quantity*(1-Discount)) AS SR
-- FROM [Order Details]
-- GROUP BY ProductID
-- ORDER BY SR DESC) AS OD ON OD.ProductID = P.ProductID;
--
--
-- -- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
-- SELECT 'By units' AS Criteria, ProductName as 'Best Selling'
-- FROM Products
-- WHERE ProductID = ( SELECT ProductID
--                     FROM [Order Details]
-- GROUP BY ProductID
-- HAVING SUM(Quantity) = ( SELECT MAX(SQ)
--     FROM ( SELECT SUM(Quantity) as SQ
--     FROM [Order Details]
--     GROUP BY ProductID
--     ) AS OD
--     )
--     )
--     14. Инструкция SELECT, консолидирующая данные с помощью предложения
--                    GROUP BY, но без предложения HAVING.
-- -- Для каждого заказанного продукта категории 1 получить его цену, среднюю цену,
--                        минимальную цену и название продукта
-- SELECT P.ProductID, P.UnitPrice, P.ProductName
--     AVG(OD.UnitPrice) AS AvgPrice,
--         MIN(OD.UnitPrice) AS MinPrice,
-- FROM Products P LEFT OUTER JOIN [Order Details] OD ON OD.ProductID = P.ProductID
-- WHERE CategoryID = 1
-- GROUP BY P.productID, P.UnitPrice, P.ProductName
--
--
