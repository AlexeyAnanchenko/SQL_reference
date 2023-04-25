
-- Пример однострочного комментария
/* Пример
   многострочного
   комментария */

/****************************************************************************************/

-- СОЗДАТЬ БАЗУ ДАННЫХ

CREATE DATABASE usersdb; -- стандартные настройки

-- СОЗДАТЬ ТАБЛИЦЫ

CREATE TABLE movie (
	film_id serial4 PRIMARY KEY, -- первичный ключ, тип числового автозаполнения
	title varchar(255), -- символьная строка с максимальной длиной в 255 символов
	description text, -- символьная строка произвольной длины
	release_year smallint, -- двухбайтное целое число
	language_id smallint,
	rental_duration smallint,
	rental_rate numeric(4, 2),  --- вещественное число от -999,99 до 999,99
	length smallint,
	replacement_cost numeric(5, 2),
	rating character varying(50), -- тоже самое, что varchar(50)
	last_update timestamp NOT NULL DEFAULT now(), -- дата и время, не возможен NULL, по умолчанию дата создания записи
	special_features text[], -- скобки означают массив в каждой записи
	fulltext tsvector -- текстовый формат оптимизированный для поиска
);

-- со связями

CREATE TABLE film_category (
	film_id serial4 PRIMARY KEY,
	category_id integer, -- четырёхбайтное целове число
	last_update timestamp NOT NULL DEFAULT now(),
	FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE SET NULL, -- при удалении объекта на который ссылаемся, проставить NULL
	FOREIGN KEY (film_id) REFERENCES movie (film_id) ON DELETE CASCADE -- при удалении объекта на который ссылаемся, удалить и этот объект
);

-- как загрузить данные из .csv

COPY film_category -- в какую таблицу
FROM 'D:\BASE_DATA\film_category.csv' -- из какого файла 
DELIMITER '	' -- какой используется разделитель
csv -- какой формат
header; -- есть ли заголовок

/****************************************************************************************/

/* Команда для бэкапа базы из дампа: psql -f D:\mushrooms.sql -h localhost -p 5432 -U postgres -d mushrooms
   Выполняем из директории с исполняемым файлом psql (C:\Program Files\PostgreSQL\15\bin)
   'mushrooms' - это название созданной пустой базы для бэкапа */

/****************************************************************************************/

-- ПРОСТЫЕ ЗАПРОСЫ К БАЗАМ ДАННЫМ

SELECT name AS "Наименование", -- Переименовываем столбец "на лету" (обязательно ДВОЙНЫЕ КАВЫЧКИ)
	   last_update
FROM category -- из таблицы category
LIMIT 2; -- первые 2 строчки

---------------------------------------

SELECT *  -- выгрузить все столбцы
FROM film
LIMIT 3 OFFSET 7; -- OFFSET игнорирует первые 7 строк и переходит к 8-й

---------------------------------------

SELECT film_id::smallint,  -- преобразуем форматы "на лету"
	   CAST(language_id AS varchar) -- -- преобразуем форматы "на лету" с помощью CAST
FROM film
LIMIT 6;

---------------------------------------

-- ВАРИАНТЫ ФИЛЬТРАЦИИ

SELECT *
FROM film
WHERE replacement_cost >= 29.99; -- больше или равно 29,99

---------

SELECT *
FROM country
WHERE country = 'Brazil'; -- равно работает со строками тоже

---------

SELECT *
FROM country
WHERE country <> 'Brazil'; -- "!=" тоже подходит

---------------------------------------

-- ДОБАВЛЯЕМ ЛОГИЧЕСКИЕ ОПЕРАТОРЫ

SELECT *
FROM country
WHERE country <> 'Brazil'
  AND country != 'Afghanistan'; -- когда AND оба условия должны быть верны 
 
---------
 
SELECT *
FROM country
WHERE NOT country <> 'Brazil' -- NOT меняет TRUE на FALSE, и наоборот
   OR NOT country != 'Afghanistan'; -- когда OR одно из условий должно быть TRUE для записи, чтобы попасть в итог

---------------------------------------

SELECT *
FROM payment
WHERE customer_id IN (341, '342'); -- числа можно и в строковом формате искать

---------------------------------------

-- ФИЛЬТРАЦИЯ СТРОК ПО ШАБЛОНУ

SELECT *
FROM actor
WHERE actor_id::varchar LIKE '%9%'
	OR actor_id::varchar LIKE '%8%'; -- '8' или '9' содерижться в любом месте строки

SELECT *
FROM actor
WHERE actor_id::varchar SIMILAR TO '%(8|9)%'; -- '8' или '9' содерижться в любом месте строки (с учётом POSIX конструкции '( | )')

SELECT *
FROM actor
WHERE actor_id::varchar ~ '.*(8|9).*'; -- тоже самое чисто в POSIX

/* 1. В PG шаблон применяется ко всей строке при использовании констукций LIKE и SIMILAR TO!
 * 2. POSIX стандарт поддерживает оператор SIMILAR TO (в нём реализован некий гибрид стандарта рег. выражений SQL (как в LIKE) и POSIX)
 * 3. в обоих операторах выше:
 * 		вместо '.' тут '_',
 * 		вместо '.*' тут '%',
 * 		место начало и конец слова (\b и \B) используется (\m и \M)
 * 		и т.д.
 * 4. Операторы '~', '~*', '!~', '!~*' поддерживают обычный синтаксис POSIX, что крайне удобно
 * */

---------------------------------------

SELECT actor_id,
	   first_name,
	   last_name
FROM actor
WHERE actor_id BETWEEN 10 AND 20; -- ищем значения между 10 включительно и 20 включительно

---------------------------------------

SELECT *
FROM actor
WHERE last_update BETWEEN '2013-05-25' AND '2013-05-27'; -- можно промежуток по времени выбирать

---------------------------------------

SELECT film_id, title, rental_duration
FROM film
WHERE rental_duration NOT IN (5, 4, 6, 3); -- выводим значения, которые не входят в кортеж значений

---------------------------------------

SELECT *
FROM film
WHERE description LIKE '%Mexico'
	AND (rental_rate < 2 OR rating != 'PG-13'); -- скобки влияют на приоритетность фильтрации

/****************************************************************************************/

Функции для работы со строками:

LENGTH(строка) -- длина строки
INITCAP(строка) -- Первая буква будет заглавная, последующие строчными
LOWER(строка) -- все буквы будут в нижнем регистре
UPPER(строка) -- все буквы заглавные
LTRIM(строка, подстрока) -- удаляет указанные символы слева по первому вхождению
RTRIM(строка, подстрока) -- удаляет указанные символы справа по первому вхождению
REPLACE(строка, подстрока заменяемая, подстрока заменяющая) -- заменяет одни симолы на другие
CONCAT(строка1, строка2, ...) - конкатенация строк

/****************************************************************************************/

SELECT LENGTH(CONCAT(address, district))
FROM address
LIMIT 10;

---------------------------------------

SELECT UPPER(title), LOWER(REPLACE(rating::varchar, '-', ' '))
FROM film
LIMIT 10;

/****************************************************************************************/

Функции для работы с временем:

CURRENT_DATE -- вернёт текущую дату
CURRENT_TIME -- вернёт текущее время
CURRENT_TIMESTAMP -- вернёт текущие дату и время
DATE_TRUNC('отрезок времени', поле) -- усекает(ОКРУГЛЯЕТ) дату и время согласно указанному отрезку времени, НО СОХРАНЯЕТ ФОРМАТ
		---------------------------------------------------------------------------------
		'microseconds' — микросекунды; 'milliseconds' — миллисекунды; 'second' — секунда;
		'minute' — минута; 'hour' — час; 'day' — день; 'week' — неделя; 'month' — месяц;
		'quarter' — квартал; 'year' — год; 'decade' — декада года; 'century' — век.
		---------------------------------------------------------------------------------
EXTRACT(отрезок времени FROM поле) -- усекает дату и время до нужного значения (только год или только месяц), т.е МЕНЯЕТ ФОРМАТ ДАТЫ
		---------------------------------------------------------------------------------
		CENTURY — век; DAY — день; DOY (от англ. day of the year) — день года(от 1 до 365(366));
		DOW (от англ. day of the week) — день недели (от 0(sunday) до 6(monday)); 
		ISODOW (от англ. day of the week и ISO 8601) — день недели (от 1(monday) до 7(sunday));
		HOUR — час; MILLISECOND — миллисекунда; MINUTE — минута; MONTH — месяц;
		SECOND — секунда; QUARTER — квартал; WEEK — неделя в году; YEAR — год.
		---------------------------------------------------------------------------------

/****************************************************************************************/

-- ПРИМЕР РАБОТЫ С ФУНКЦЯМИ ВРЕМЕНИ
		
SELECT payment_id,
	customer_id,
	DATE_TRUNC('month', payment_date::timestamp) AS "Месяц заказа",
	EXTRACT(WEEK FROM payment_date::timestamp) AS "Неделя заказа" -- лучше всегда преобразовывать самостоятельно входящие данные в тип timestamp (без timezone)
FROM payment
WHERE EXTRACT(WEEK FROM payment_date::timestamp) IN (1, 3, 7); -- сначала выполняется WHERE, потом SELECT (т.е. "Неделя заказа" ещё не существует)

---------------------------------------

-- Работа с NULL

SELECT email, fax
FROM client
WHERE fax IS NULL; -- IS NULL специальный оператор (фильтровать NULL можно ТОЛЬКО такими операторами)

---------

SELECT email, fax
FROM client
WHERE fax IS NOT NULL; -- IS NOT NULL специальный опретор

---------------------------------------

-- Оператор CASE

SELECT total_sales,
       CASE
           WHEN total_sales >= 30000 AND total_sales < 30629 THEN 'средний'
           WHEN total_sales >= 40000 THEN 'крупный'
           ELSE 'маленький' -- необязательный параметр
       END AS "Категория продажи" -- псевдоним по умолчанию - "CASE"
FROM sales_by_store;

/****************************************************************************************/

-- МАТЕМАТИЧЕСКИЕ ОПЕРАЦИИ (выполняются для каждой записи в указанном поле)

1. Стандартные операторы выглядят так: +, -, *, / -- Строки складывать НЕЛЬЗЯ в SQL
2. ABS(поле) - Возвращает модуль числа
3. CEILING(поле) - Возвращает число, округлённое до целого в большую сторону
4. FLOOR(поле) - Возвращает число, округлённое до целого в меньшую сторону
5. ROUND(поле, разрядность=0) - Округляет значение до ближайшего числа
6. POWER(поле, степень) - Возвращает число, возведённое в степень
7. SQRT(поле) - Извлекает квадратный корень из числа -- Не сработае с отрицательными числами

/****************************************************************************************/

SELECT CEILING(amount),
	   FLOOR(amount),
	   ROUND(amount, 1),
	   payment_date::date + time '03:00' AS "К дате добавили время", -- на выходе timemstamp
	   payment_date::date + 1 AS "К дате добавили 1 день", -- на выходе date
	   payment_date::timestamp - interval '10 hours' AS "От даты отняли 10 часов", -- на выходе timestamp
	   payment_date::timestamp - timestamp '2001-09-28 23:00' AS "Отрезок между датами" -- на выходе interval
FROM payment;

/****************************************************************************************/

-- АГРЕГИРУЮЩИЕ ФУНКЦИИ (Они выполняют вычисления на наборе значений, а возвращают одно.)

1. SUM(поле) - возвращает сумму значений в поле;
2. AVG(поле) - находит среднее арифметическое для значений в поле;
3. MIN(поле) - возвращает минимальное значение в поле;
4. МАХ(поле) - возвращает максимальное значение в поле;
5. COUNT(*) - выводит количество записей в ТАБЛИЦЕ,
6. COUNT(поле) — выводит количество записей в ПОЛЕ. -- значения NULL в данном случае не учитывается!

-- Оператор  DISTINCT

SELECT DISTINCT customer_id,
                staff_id -- в данном случае запрос выведет комбинацию уникальных пар указанных столбцов
FROM payment;

---------

SELECT MIN(amount),
	   MAX(amount),
	   ROUND(AVG(amount)),
	   COUNT(DISTINCT customer_id),
	   SUM(amount),
	   COUNT(*) - COUNT(amount) AS "Кол-во значений NULL",
FROM payment
WHERE staff_id <> 1;

---------

SELECT country_id, COUNT(city) AS "Кол-во городов"
FROM city
WHERE city ILIKE '%ab%' -- город содержит 'ab' независимо от регистра и местоположения
GROUP BY country_id; -- группировка по странам происходит после фильтра WHERE

---------

SELECT CASE
		WHEN store_id = 1 THEN 'Первый магазин'
		WHEN store_id = 2 THEN 'Второй магазин'
	   END AS "Номер магазина",
	   SUM(active) AS "Кол-во активных клиентов"
FROM customer
WHERE address_id > 550
GROUP BY "Номер магазина"; -- в Postgre можно обращаться к псевдонимам во время группировки

--------------------------------------------------------------

-- + СОРТИРОВКА ДАННЫХ

-- При сортировке важен порядок столбов: первый записанный столбец имеет высший приоритет

SELECT rating, rental_rate, COUNT(film_id) AS "Кол-во фильмов"
FROM film
GROUP BY rating, rental_rate -- не важен порядок столбцов при группировке нескольких столбцов сразу
ORDER BY rating, -- по умолчанию сортировка ASC (по возрастанию)
		 rental_rate ASC, -- 
		"Кол-во фильмов" DESC -- по убыванию
LIMIT 10; -- лимит устанавливается самым последним

--------------------------------------------------------------

-- ФИЛЬТРАЦИЯ HAVING (фильтрует данные после группировки)

SELECT rating, AVG(rental_rate) "Средняя ставка аренды" -- Псевдоним (или алиас) можно указать без AS, просто через пробел (фишка Postgre)
FROM film
GROUP BY rating -- в Postgre при группировке можно обращаться к столбцам из SELECT по порядковому номеру
HAVING AVG(rental_rate) > 3 -- псевдоним "Средняя ставка аренды" появиться позже, поэтому дублируем агрегатную функцию
ORDER BY "Средняя ставка аренды" DESC;

/****************************************************************************************/

-- JOIN-ы

SELECT c.first_name "Имя",
       c.last_name  "Фамилия",
       SUM(p.amount) "Сумма по кол-ву", -- ОБЯЗАТЕЛЬНО либо агрегатная функция, либо столбец должен быть в GROUP BY!!!
       MAX(r.rental_date) "Максимальная дата" -- ОБЯЗАТЕЛЬНО либо агрегатная функция, либо столбец должен быть в GROUP BY!!!
FROM payment AS p -- Псевдоним можно так же присвоить и таблице!
INNER JOIN customer AS c ON p.customer_id = c.customer_id -- INNER JOIN выведет данные исключительно по пересекающимся номерам customer_id
JOIN rental AS r ON p.customer_id = r.customer_id -- можно записать без "INNER"
WHERE p.amount > 1
GROUP BY first_name, last_name
ORDER BY "Сумма по кол-ву" DESC
LIMIT 20;

---------------

SELECT CONCAT(first_name, ' ', last_name) "Полное имя",
	   f.title "Название фильма",
	   cat.name "Название категории"
FROM actor AS a
JOIN film_actor AS f_a USING (actor_id) -- можно вместо ON использовать USING, если столбцы называются одинаково
JOIN film AS f ON f_a.film_id = f.film_id
JOIN film_category AS f_c ON f_a.film_id = f_c.film_id
JOIN category AS cat ON f_c.category_id = cat.category_id -- данные можно подтягивать используя множество таблиц посредников!!!
WHERE a.first_name LIKE '%Uma%';

---------------

SELECT DISTINCT l.name "Имя", -- DISTINCT удалит из результирующей таблицы все дубликаты!  
	   			f.rental_rate
FROM "language" AS l
LEFT OUTER JOIN film AS f ON l.language_id = f.language_id; -- оператор оставит все записи из таблицы language, но добавит пересекающиеся поля из film

-- LEFT OUTER JOIN можно записать как LEFT JOIN

---------------

SELECT DISTINCT l.name "Имя",
	   			f.rental_rate
FROM film AS f
RIGHT JOIN "language" AS l ON l.language_id = f.language_id; -- оператор оставит все записи из таблицы language, но добавит пересекающиеся поля из film

-- RIGHT JOIN можно записать как RIGHT OUTER JOIN

---------------

/* 
 * В PostgreSQL можно объединять таблицы не только по ключам, но и по содержанию ячеек
 * На примере ниже last_name двух таблиц никак не связан, но всё равно можно объединить
 * по одинаковым фамилиям
 * */

SELECT s.staff_id,
	   s.first_name,
	   s.last_name,
	   c.first_name,
	   c.last_name
FROM staff AS s
FULL OUTER JOIN customer AS c ON s.last_name = c.last_name -- FULL OUTER выведен вообще все возможные данные с двух таблиц, но сопоставит и пересечения
WHERE c.last_name IS NOT NULL -- фильтрация данных производиться после объединения таблиц 
ORDER BY s.staff_id
LIMIT 10;

/****************************************************************************************/

ПОРЯДОК ВЫПОЛНЕНИЯ ОПЕРАТОРОВ В SQL:
1. FROM
2. JOIN
3. WHERE
4. GROUP BY
5. HAVING
6. SELECT (DISTINCT)
7. ORDER BY
8. OFFSET
9. LIMIT

/****************************************************************************************/

-- UNION (ALL)

/* UNION позволяет объединять данные по горизонтали (подливать одну таблицу под другую в теже поля)
 * В свою очередь оператор JOIN объединяет данные по вертикали, т.е. добавляет поля прежде всего */

SELECT first_name, last_name
FROM staff
UNION SELECT first_name, last_name -- в итоговой таблице никакие данные не добавяться, т.к.  UNION не допускает дубликатов
	  FROM staff;
	 
----------------

SELECT first_name, last_name
FROM staff
UNION ALL SELECT first_name, last_name -- а здесь данные будут задублированы, т.к. оператор UNION ALL допускает это
	  FROM staff;

/****************************************************************************************/
	 
-- ПОДЗАПРОСЫ

SELECT rating,
	   MIN("length") AS "min_length",
	   MAX("length") AS "max_length",
	   ROUND(AVG("length"), 1) AS "avg_length"
FROM (SELECT title, --пример подзапроса во FROM
	   		rental_rate,
	   		"length",
	   		rating
	  FROM film
	  WHERE rental_rate > 2
	  ORDER BY "length" DESC
	  LIMIT 40) AS "subtable" -- жалательно таблице из подзапроса всегда давать псевдоним
GROUP BY rating
ORDER BY "avg_length";

------------------

SELECT *
FROM actor
WHERE actor_id IN (SELECT actor_id -- пример подзапроса в WHERE
				   FROM film_actor
				   GROUP BY actor_id
				   HAVING COUNT(film_id) >= 40);
				  
/* Подобный результат можно получить и через JOIN, но в таком случае это менее эффективно,
   т.к. JOIN соберёт данные из двух таблиц раньше чем произойдёт фильтрация WHERE */
				  
------------------
				  
SELECT one.film_id,
	   title,
	   "Максимальная длина фильма",
	   count
FROM 
	(SELECT film_id,
			title,
			MAX("length") AS "Максимальная длина фильма"
	 FROM film
	 GROUP BY film_id
	 ORDER BY "Максимальная длина фильма" DESC
	 LIMIT 5) AS one
LEFT JOIN -- Два подзапросы объединены с помощью JOIN
	(SELECT film_id,
			COUNT(store_id)
	 FROM inventory
	 GROUP BY film_id) AS two
ON one.film_id = two.film_id;

/****************************************************************************************/

-- ВРЕМЕННЫЕ ТАБЛИЦЫ

-- Реализуем такой же запрос как выше только используя временные таблицы
WITH 
-- первый подзапрос (временная таблица) с псевдонимом one
one AS (SELECT film_id,
			title,
			MAX("length") AS "Максимальная длина фильма"
	 	FROM film
	 	GROUP BY film_id
	 	ORDER BY "Максимальная длина фильма" DESC
	 	LIMIT 5), -- подзапросы разделяют запятыми
-- второй подзапрос (временная таблица) с псевдонимом two
two AS (SELECT film_id,
			COUNT(store_id)
	 	 FROM inventory
	 	 GROUP BY film_id)

-- основной запрос, в котором указаны псевдонимы для подзапросов
SELECT one.film_id,
	   title,
	   "Максимальная длина фильма",
	   count
FROM one LEFT JOIN two ON one.film_id = two.film_id;

/****************************************************************************************/

-- ОКОННЫЕ ФУНКЦИИ (позволяют добавлять агрегированные данные без группировки записей)

SELECT f.film_id,
	   f.title,
	   f.length,
	   f.rating,
	   AVG(length) OVER (PARTITION BY f.rating) AS avg_length -- не лету вычислили среднюю длину фильма в зависимости от категории без группировки записей
FROM public.film f; -- в данном случае обратились к конкретной схеме (public) и таблице film. В предыдущих запросах public используется по умолчанию

---------------------

SELECT f.title,
	   f.length,
	   f.rating,
	   SUM(length) OVER () AS avg_length -- такой запрос применит агрегирующую функцию ко всем записям без разбивки по категориям
FROM public.film f;

---------------------

SELECT f.title,
	   f.length,
	   f.rating,
	   f.rental_rate,
	   SUM(length) OVER (PARTITION BY f.rating, rental_rate) AS avg_length -- аналогично GROUP BY можно группировать данные сразу по нескольким столбцам
FROM public.film f;

---------------------

SELECT f.title,
	   f.rating,
	   ROW_NUMBER() OVER (PARTITION BY f.rating) -- ROW_NUMBER последовательно нумерует строки в каждом окне независимо
FROM public.film f;

---------------------

SELECT f.title,
	   f.rating,
	   ROW_NUMBER() OVER (ORDER BY film_id ASC) -- такой запрос проранжирует все записи по film_id - от меньшего к большему
FROM public.film f;

---------------------

WITH film_rn AS -- для визуального удобства используем временную таблицу
	(SELECT f.title,
	   		ROW_NUMBER() OVER (ORDER BY rating, film_id) AS rn -- можно сортировать по нескольким столбцам (в данном случае raiting самый приоритетный)
	 FROM public.film f)

SELECT *
FROM film_rn
WHERE rn <> 1; -- полученный после ранжирования столбец можем сразу отфильтровать

---------------------

SELECT *,
	   RANK() OVER (ORDER BY "length") -- RANK пронумерует одинаковую длину фильма одним номером
FROM film;

-- ВАЖНЫЙ МОМЕНТ: RANK для каждого следующего ранга номер вычисляется не от предыдущего номера ранга а по номеру записи в таблице

---------------------

SELECT *,
	   DENSE_RANK() OVER (ORDER BY "length") -- DENSE_RANK номера рангов присваивает полседовательно
FROM film;

---------------------