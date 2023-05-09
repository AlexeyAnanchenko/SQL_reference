-- Пример однострочного комментария
/* Пример
   многострочного
   комментария */

/****************************************************************************************/

-- ПРОСТЫЕ ЗАПРОСЫ К БАЗАМ ДАННЫМ

SELECT name AS "Наименование", -- Переименовываем столбец "на лету" (обязательно ДВОЙНЫЕ КАВЫЧКИ)
	   last_update
FROM category
LIMIT 2 OFFSET 0;

---------------------------------------

SELECT *  -- выгрузить все столбцы
FROM film
LIMIT 3 OFFSET 7;

---------------------------------------

SELECT film_id::smallint,  -- преобразуем форматы "на лету"
	   CAST(language_id AS varchar) -- -- преобразуем форматы "на лету" с помощью CAST
FROM film
LIMIT 6;

---------------------------------------

-- ВАРИАНТЫ ФИЛЬТРАЦИИ

SELECT *
FROM film
WHERE replacement_cost >= 29.99;

---------

SELECT *
FROM country
WHERE country = 'Brazil';

---------

SELECT *
FROM country
WHERE country <> 'Brazil'; -- "!=" тоже подходит

---------------------------------------

-- ДОБАВЛЯЕМ ЛОГИЧЕСКИЕ ОПЕРАТОРЫ

SELECT *
FROM country
WHERE country <> 'Brazil'
  AND country != 'Afghanistan';
 
---------
 
SELECT *
FROM country
WHERE NOT country <> 'Brazil'
   OR NOT country != 'Afghanistan';

---------
  
SELECT *
FROM payment
WHERE customer_id = 341
   OR customer_id = 342
LIMIT 10;

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
WHERE actor_id BETWEEN 10 AND 20; -- ищем значения между 10 и 20 включительно

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
GROUP BY 1 -- в Postgre при группировке можно обращаться к столбцам из SELECT по порядковому номеру
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
UNION SELECT first_name, last_name
	  -- в итоговой таблице никакие данные не добавяться, т.к.  UNION не допускает дубликатов
	  FROM staff;
	 
----------------

SELECT first_name, last_name
FROM staff
UNION ALL SELECT first_name, last_name
	  -- а здесь данные будут задублированы, т.к. оператор UNION ALL допускает это
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

/* ОКОННЫЕ ФУНКЦИИ (позволяют добавлять агрегированные данные без группировки записей
 * исходной таблицы в результирующую) */

SELECT f.film_id,
	   f.title,
	   f.length,
	   f.rating,
	   AVG(length) OVER (PARTITION BY f.rating) AS avg_length
	   -- не лету вычислили среднюю длину фильма в зависимости от категории без группировки записей
FROM public.film f;
/* в данном случае обратились к конкретной схеме (public) и таблице film.
 * В предыдущих запросах public используется по умолчанию */

---------------------

SELECT f.title,
	   f.length,
	   f.rating,
	   SUM(length) OVER () AS avg_length
	   -- такой запрос применит агрегирующую функцию ко всем записям без разбивки по категориям
FROM public.film f;

---------------------

SELECT f.title,
	   f.length,
	   f.rating,
	   f.rental_rate,
	   SUM(length) OVER (PARTITION BY f.rating, rental_rate) AS avg_length
	   -- аналогично GROUP BY можно группировать данные сразу по нескольким столбцам
FROM public.film f;

---------------------

SELECT f.title,
	   f.rating,
	   ROW_NUMBER() OVER (PARTITION BY f.rating)
	   -- ROW_NUMBER последовательно нумерует строки в каждом окне независимо
FROM public.film f;

---------------------

SELECT f.title,
	   f.rating,
	   ROW_NUMBER() OVER (ORDER BY film_id ASC)
	   -- такой запрос проранжирует все записи по film_id - от меньшего к большему
FROM public.film f;

---------------------

WITH film_rn AS -- для визуального удобства используем временную таблицу
	(SELECT f.title,
	   		ROW_NUMBER() OVER (ORDER BY rating, film_id) AS rn
			-- можно сортировать по нескольким столбцам (в данном случае raiting самый приоритетный)
	 FROM public.film f)

SELECT *
FROM film_rn
WHERE rn <> 1; -- полученный после ранжирования столбец можем сразу отфильтровать

---------------------

SELECT *,
	   RANK() OVER (ORDER BY "length") -- RANK пронумерует одинаковую длину фильма одним номером
FROM film;

/* ВАЖНЫЙ МОМЕНТ: RANK для каждого следующего ранга номер вычисляется не от предыдущего
 * номера ранга а по номеру записи в таблице */

---------------------

SELECT *,
	   DENSE_RANK() OVER (ORDER BY "length") -- DENSE_RANK номера рангов присваивает полседовательно
FROM film;

---------------------

SELECT f.title,
	   f.rating,
	   NTILE(5) OVER (ORDER BY film_id ASC)
	   -- NTILE делит все записи на максимально равные части по кол-ву и ранжирует их
FROM public.film f
LIMIT 201; -- оконная функция проранжирует все данные до срабатывания ограничения LIMIT

---------------------

-- можно использовать сразу несколько операторов оконных функций последовательно

WITH film_rn AS
	(SELECT f.title,
			f.rating,
			f.length,
	   		ROW_NUMBER() OVER (PARTITION BY f.rating ORDER BY f.length DESC) AS rn
			-- порядок написания имеет значения
	 FROM public.film f)

SELECT *
FROM film_rn
WHERE film_rn.rn = 1; -- получим самый длинный фильм в каждом из рейтингов!

---------------------

SELECT *,
	   NTILE(3) OVER (PARTITION BY f.rating ORDER BY film_id)
	   -- здесь сначала резделим на рейтинги, далее ранжирование NTILE и наконец сортировка по id
FROM public.film f;

---------------------

-- с помощью окон. функ. можно производить и кумулятивные вычисления (с накоплением)

WITH film_rn AS -- проранжированные фильмы внутри каждого рейтинга
	(SELECT *,
			ROW_NUMBER() OVER (PARTITION BY rating ORDER BY film_id) AS row_n
	 FROM film)
			
SELECT film_id,
	   title,
	   rating,
	   "length",
	   row_n,
	   SUM("length") OVER (ORDER BY rating) AS length_cum
	   /* такой запрос просуммирует длины каждого фильма, но отобразит одинаковые одно значения для одного рейтинга.
	    * Это значение будет равно сумме накопительным итогом, включая последнюю запись такущего рейтинга*/
FROM film_rn
WHERE row_n < 4; -- достанем только первые 4 позиции из каждого рейтинга

---------------------

WITH film_rn AS
	(SELECT *,
			ROW_NUMBER() OVER (PARTITION BY rating ORDER BY film_id) AS row_n
	 FROM film)
			
SELECT film_id,
	   title,
	   rating,
	   "length",
	   row_n,
	   -- остальные агрегатные функции тоже работают кумулятивно
	   AVG("length") OVER (PARTITION BY rating ORDER BY film_id) AS length_cum
	   /* такой запрос отобразит среднее значение накопительным итогом в разрезе каждой группы отдельно
	    * и отобразит при этом не одинаковую цифру, а разные в каждой записе, т.к. ORDER BY уже по уникальным film_id */
FROM film_rn
WHERE row_n < 4
ORDER BY rating;

---------------------

/* Функции LEAD() и LAG() имеют следующий синтаксис
 * LEAD(<поле, из которого берём данные>, <смещение по вертикали>, <значение по умолчанию>) OVER (<определение окна>)
 * LAG(<поле, из которого берём данные>, <смещение по вертикали>, <значение по умолчанию>) OVER (<определение окна>).
 * 
 * Функции смещения возвращают данные из других записей в зависимости от их расстояния от текущего значения. */

SELECT p.customer_id,
	   c.full_name,
	   p.payment_id,
	   p.payment_date::date AS "Дата оплаты",
	   LEAD(p.payment_date::date, 1, '2000-01-01') OVER (PARTITION BY p.customer_id) AS "След. дата оплаты",
	   -- в качестве значения по умолчанию - дата
	   LAG(p.payment_date::date, 2, NULL) OVER (PARTITION BY p.customer_id ORDER BY payment_id) AS "Пред. дата оплаты"
	   -- смещение на 2 строки
	   -- ORDER BY определяет сортировку по полю относительно которого будем смотреть данные по функции
FROM (SELECT customer_id,
			 CONCAT(first_name, ' ', last_name) AS full_name
	  FROM customer) AS c
JOIN payment AS p ON c.customer_id = p.customer_id;


----------------------

-- можно различные математические операции с помощью функций LEAD и LAG

SELECT p.customer_id,
	   c.full_name,
	   p.payment_id,
	   p.payment_date::date AS "Дата оплаты",
	   LAG(p.payment_date::date, 1, NULL) OVER (PARTITION BY p.customer_id) AS "Пред. дата оплаты",
	   p.payment_date::date - LAG(p.payment_date::date, 1, NULL) OVER (PARTITION BY p.customer_id) AS "Прошло дней с пред. оплаты"
FROM (SELECT customer_id,
			 CONCAT(first_name, ' ', last_name) AS full_name
	  FROM customer) AS c
JOIN payment AS p ON c.customer_id = p.customer_id;

-----------------------

-- определение оконной функции после OVER можно вынести отдельно с помощью WINDOW

SELECT *,
	   RANK() OVER my_window,
	   ROW_NUMBER() OVER my_window,
	   SUM("length") OVER my_window AS "len_sum" -- так удобно использовать сразу несколько оконных функций
FROM film
WHERE language_id = 1 -- WINDOW записывается после WHERE
WINDOW my_window AS (ORDER BY "length") -- определяем окно отдельным оператором
ORDER BY "length"; -- -- WINDOW записывается до ORDER BY

/****************************************************************************************/

/* 
 * ОГРАНИЧЕНИЯ ОКОННЫХ ФУНКЦИЙ:
 *  1. В отличие от GROUP BY с агрегирующими функциями нельзя использовать оператор DISTINCT
 *  2. Оконные функции нельзя использовать в одном запросе с GROUP BY
 *  3. После WHERE нельзя использовать OVER
 */ 

/****************************************************************************************/

-- РАМКИ В ОКОННЫХ ФУНКЦИЯХ

/* Рамки позволяют указать записи, которые попадут в рамку, — до и после текущей.
 * Конструкция с ROWS (RANGE) выглядит так: ROWS BETWEEN <начало рамки> AND <конец рамки>
 * Начало рамки задают выражением N PRECEDING, где N — это количество записей до текущей.
 * Конец рамки задают выражением N FOLLOWING, где N — это количество записей после текущей. */

SELECT *,
	   AVG(amount) OVER (ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS avg_amount
	   -- порядок операторов важен внутри OVER
FROM payment p;

------------------------------------

SELECT *,
	   AVG(amount) OVER (ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS avg_amount
	   -- CURRENT_ROW значит рамка начинается с текущей строчки
FROM payment p;

------------------------------------

SELECT *,
	   -- строка ниже разделяет сначала на окна по staff_id, потом внутри окон на рамки от 1 до 3 строчек
	   SUM(amount) OVER (PARTITION BY staff_id ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS avg_amount
FROM payment p;

------------------------------------

-- запрос ниже полностью идентичен верхнему, но с более лаконичным синтаксисом

SELECT *,
	   SUM(amount) OVER (PARTITION BY staff_id ROWS 1 PRECEDING) AS avg_amount
FROM payment p;

------------------------------------

-- Помимо ROWS есть режим RANGE. С помощью него можно задавать рамки исходя из значений данных

SELECT *,
	   -- такой запрос выведет среднюю сумму за последние 3 дня до текущего
	   AVG(amount) OVER (ORDER BY payment_date RANGE '3 day' PRECEDING) AS avg_amount -- ORDER BY (допустим только с 1 столбцом) c RANGE обязателен!
FROM payment p;

------------------------------------

SELECT *,
	   -- запрос выведет сумму всех значений amount, где значение customer_id в диапазоне (тек.-1 <= тек. >= тек.+1)
	   SUM(amount) OVER (ORDER BY customer_id RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING)
FROM payment p
WHERE amount = 0.99;

------------------------------------

SELECT *,
	   -- Такой запрос выведет сумму всех значений накопительным итогом начиная с конца с постепенным уменьшением
	   SUM(amount) OVER (ORDER BY payment_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) -- здесь UNBOUNDED берёт все строки до текущего от начала окна
FROM payment p

/****************************************************************************************/

-- РАБОТА РАМОК ПО УМОЛЧАНИЮ

SELECT *,
	   -- такая запись окна равна SUM(amount) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	   SUM(amount) OVER () 
FROM payment p;

SELECT *,
	   -- такая запись окна равна SUM(amount) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	   SUM(amount) OVER (ORDER BY payment_id) 
FROM payment p;

/****************************************************************************************/

-- ДОПОЛНИТЕЛЬНЫЕ ОКОКННЫЕ ФУНКЦИИ. LAST_VALUE(), FIRST_VALUE(), NTH_VALUE(), EXCLUDE()

SELECT *,
	   -- выведет первое значение amount исходной таблицы из каждого окна по customer_id
	   FIRST_VALUE(amount) OVER (PARTITION BY customer_id)
FROM payment p;

---------------------------------------

SELECT *,
	   /* выведет самое маленькое значение amount из каждого окна по customer_id
	    * из-за использования ORDER BY рамки по умолчанию стали равны промежутку: 
	    * от всех предыдущих значений до текущего (CURRENT ROW). Поэтому рамки вручную надо расширить */
	   LAST_VALUE(amount) OVER (
							PARTITION BY customer_id ORDER BY amount DESC
							ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
						)
FROM payment p;

---------------------------------------

SELECT *,
	   -- NTH_VALUE в данном случае позволяет 2 по величине число (от большего к меньшему). Рамки тоже расширяем вручную 
	   NTH_VALUE(amount, 2) OVER (
								PARTITION BY customer_id ORDER BY amount DESC
								ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
							)
FROM payment p;

---------------------------------------

SELECT *,
	   -- EXCLUDE CURRENT ROW исключит текущие записи в каждой рамке
	   SUM(amount) OVER (ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING EXCLUDE CURRENT ROW)
	   -- EXCLUDE только после рамки можно писать
FROM payment p;

---------------------------------------

SELECT *,
	   -- EXCLUDE GROUP исключит текущую запись и все, что одинаковые с ней (по customer_id) в каждой рамке
	   SUM(amount) OVER (ORDER BY customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE GROUP)
FROM payment p;

---------------------------------------

SELECT *,
	   /* EXCLUDE GROUP исключит текущую запись и все что одинаковые с ней по customer_id в каждой рамке.
	    * В данном случае сумма посчитается накопительным итогом и в каждой рамке customer_id текущей строчки
	    * не будет попадать в расчёт */
	   SUM(amount) OVER (ORDER BY customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE GROUP)
FROM payment p;

---------------------------------------

SELECT *,
	   /* EXCLUDE TIES исключит все записи группы по customer_id, кроме самой текущей записи группы.
	    * все остальные группы до текущей записи будут в итоговой сумме */
	   SUM(amount) OVER (ORDER BY customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE TIES)
FROM payment p;

---------------------------------------

SELECT *,
	   -- EXCLUDE NO OTHERS не исключит никакие записи из всех рамок. Это значение по умолчанию!
	   SUM(amount) OVER (ORDER BY customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS)
FROM payment p;


/****************************************************************************************************************/

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
	last_update timestamp NOT NULL DEFAULT now(), -- дата и время, не возможен ноль, по умолчанию дата создания записи
	special_features text[], -- скобки означают массив в каждой записи
	fulltext tsvector -- текстовый формат оптимизированный для поиска
);

-- со связями

CREATE TABLE film_category (
	film_id serial4 PRIMARY KEY,
	category_id integer, -- четырёхбайтовое целове число
	last_update timestamp NOT NULL DEFAULT now(),
	FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE SET NULL,
	-- при удалении объекта на который ссылаемся, проставить NULL
	FOREIGN KEY (film_id) REFERENCES movie (film_id) ON DELETE CASCADE
	-- при удалении объекта на который ссылаемся, удалить и этот объект
);

-- создание таблицы из другой таблицы

CREATE TABLE actor_two AS
SELECT actor_id, first_name
FROM actor;

-- УДАЛИТЬ ТАБЛИЦУ

DROP TABLE actor_two;

/****************************************************************************************************************/

-- ДОБАВЛЕНИЕ ЗАПИСЕЙ В ТАБЛИЦУ

INSERT INTO actor (first_name, last_name) -- таблица (столбцы)
VALUES
	('Ivan', 'Ivanov'), -- кортеж новый значений
	('Petr', 'Petrov'); -- кортеж новый значений

-- можно добавить значение из другой таблицы

INSERT INTO actor (first_name, last_name)
SELECT first_name, last_name
FROM customer
LIMIT 2;

-- ОБНОВЛЕНИЕ ТАБЛИЦЫ

UPDATE actor -- какую таблицу
SET last_update = NOW(), -- что и как обновляем
	last_name = 'Updatov'
WHERE actor_id IN (SELECT actor_id -- какие строки
				   FROM actor
				   ORDER BY actor_id DESC
				   LIMIT 4);

-- обновление таблицы используя связи

UPDATE city -- какую таблицу обновляем
SET last_update = NOW()
FROM country -- с какой соединяем
WHERE city.country_id = country.country_id -- по каким столбцам соединяем
	  AND country.country = 'Zambia';
				  
-- УДАЛЕНИЕ СТРОК ИЗ ТАБЛИЦЫ

DELETE FROM actor -- откуда удаляем
WHERE actor_id IN (SELECT actor_id -- какие строки
				   FROM actor
				   ORDER BY actor_id DESC
				   LIMIT 4);

-- удаление строк использя связи в таблицах

DELETE FROM city -- из какой таблицы
USING country -- с учётом какой таблицы
WHERE city.country_id = country.country_id -- как эти таблицы связаны
	  AND country.country = 'Страна';

/****************************************************************************************************************/

-- загрузить данные из .csv

COPY film_category -- в какую таблицу
FROM 'D:\BASE_DATA\film_category.csv' -- из какого файла 
DELIMITER '	' -- какой используется разделитель
csv -- какой формат
header; -- есть ли заголовок

/****************************************************************************************/

/* Команда для бэкапа базы из дампа: psql -f D:\mushrooms.sql -h localhost -p 5432 -U postgres -d mushrooms
   Выполняем из директории с исполняемым файлом psql (C:\Program Files\PostgreSQL\15\bin)
   'mushrooms' - это название созданной пустой базы для бэкапа
*/

/****************************************************************************************/
