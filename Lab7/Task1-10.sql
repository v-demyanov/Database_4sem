USE DVR_UNIVER;

-- 1. На основе таблицы AUDITORIUM разработать SELECT-запрос,
-- вычисляющий максимальную, минимальную и среднюю вместимость аудиторий,
-- суммарную вместимость всех аудиторий и общее количество аудиторий.
SELECT MAX(AUDITORIUM_CAPACITY)[Максимальная вместимость аудитории],
	   MIN(AUDITORIUM_CAPACITY)[Минимальная вместимость аудитории],
	   AVG(AUDITORIUM_CAPACITY)[Средняя вместимость аудитории],
	   SUM(AUDITORIUM_CAPACITY)[Суммарная вместимость аудиторий],
	   COUNT(*)[Общее количество аудиторий]
FROM AUDITORIUM;

-- 2. На основе таблиц AUDITORIUM и AUDITORIUM_TYPE разработать запрос,
-- вычисляющий для каждого типа аудиторий максимальную, минимальную,
-- среднюю вместимость аудиторий, суммарную вместимость всех аудиторий
-- и общее количество аудиторий данного типа. 
-- Результирующий набор должен содержать столбец с наименованием
-- типа аудиторий (столбец AUDITORIUM_TYPE.AUDITORIUM_TYPENAME)
-- и столбцы с вычисленными величинами.
SELECT AUDITORIUM_TYPE.AUDITORIUM_TYPENAME[Тип аудитории],
	   MAX(AUDITORIUM_CAPACITY)[Максимальная вместимость аудитории],
	   MIN(AUDITORIUM_CAPACITY)[Минимальная вместимость аудитории],
	   AVG(AUDITORIUM_CAPACITY)[Средняя вместимость аудитории],
	   SUM(AUDITORIUM_CAPACITY)[Суммарная вместимость аудиторий],
	   COUNT(*)[Общее количество аудиторий]
FROM AUDITORIUM 
JOIN AUDITORIUM_TYPE ON AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
GROUP BY AUDITORIUM_TYPENAME;

-- 3. Разработать запрос на основе таблицы PROGRESS, который содержит количество экзаменационных оценок в заданном интервале.
-- При этом учесть, что сортировка строк должна осуществляться в порядке, обратном величине оценки;
-- сумма значений в столбце количество должна быть равна количеству строк в таблице PROGRESS. 
SELECT *
FROM (select 
		case
		when NOTE between 4 and 5 then '4-5'
		when NOTE between 6 and 7 then '6-7'
		when NOTE between 8 and 9 then '8-9'
		else '10'
		end [Оценки], count(*)[Количество]
	  from PROGRESS group by case
		when NOTE between 4 and 5 then '4-5'
		when NOTE between 6 and 7 then '6-7'
		when NOTE between 8 and 9 then '8-9'
		else '10'
		end
	  ) AS T
ORDER BY CASE[Оценки]
		 WHEN '4-5' THEN 5
		 WHEN '6-7' THEN 4
		 WHEN '8-9' THEN 3
		 WHEN '4-5' THEN 2
		 WHEN '10' THEN 1
		 ELSE 0
		 END;

-- 4. Разработать SELECT-запроса на основе таблиц FACULTY, GROUPS, STUDENT и PROGRESS, 
-- который содержит среднюю экзаменационную оценку для каждого курса каждой специальности.
-- Строки отсортированы в порядке убывания средней оценки.
-- При этом следует учесть, что средняя оценка должна рассчитываться с точностью до двух знаков после запятой. 
-- Использовать внутреннее соединение таблиц, агрегатную функцию AVG и встроенные функции CAST и ROUND.
SELECT FACULTY.FACULTY[Факультет],
	   GROUPS.PROFESSION[Специальность],
	   GROUPS.YEAR_FIRST[Курс],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
GROUP BY FACULTY.FACULTY, GROUPS.PROFESSION, GROUPS.YEAR_FIRST
ORDER BY [Средняя оценка] DESC;

-- Переписать SELECT-запрос, разработанный в задании 4 так, чтобы в расчете среднего значения оценок 
-- использовались оценки только по дисциплинам с кодами БД и ОАиП. Ис-пользовать WHERE.
SELECT FACULTY.FACULTY[Факультет],
	   GROUPS.PROFESSION[Специальность],
	   GROUPS.YEAR_FIRST[Курс],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
WHERE PROGRESS.SUBJECT = 'СУБД'
GROUP BY FACULTY.FACULTY, GROUPS.PROFESSION, GROUPS.YEAR_FIRST
ORDER BY [Средняя оценка] DESC;

-- 5. На основе таблиц FACULTY, GROUPS, STUDENT и PROGRESS разработать SELECT-запрос,
-- в котором выводятся специальность, дисциплины и средние оценки при сдаче экзаменов 
-- на факультете ТОВ. Использовать группировку по полям FACULTY, PROFESSION, SUBJECT.
SELECT GROUPS.FACULTY[Факультет],
	   GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
WHERE GROUPS.FACULTY = 'ИДиП'
GROUP BY GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT; 

-- Добавить в запрос конструкцию ROLLUP и проанализировать результат.
SELECT GROUPS.FACULTY[Факультет],
	   GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
WHERE GROUPS.FACULTY = 'ИДиП'
GROUP BY ROLLUP (GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- 6. Выполнить исходный SELECT-запрос п.5 с использованием CUBE-группировки. Проанализировать результат.
SELECT FACULTY.FACULTY[Факультет],
	   GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
WHERE GROUPS.FACULTY = 'ИДиП'
GROUP BY CUBE (FACULTY.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- 7. На основе таблиц GROUPS, STUDENT и PROGRESS разработать SELECT-запрос,
-- в котором определяются результаты сдачи экзаменов.

-- !!!!!!!
-- в запрос специально добавлено условие: OR (GROUPS.FACULTY = 'ИДиП' AND GROUPS.PROFESSION = '1-40 01 02')
-- чтобы создать одинаковые строки у двух запросов

-- UNION
(SELECT GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = 'ХТиТ' OR (GROUPS.FACULTY = 'ИДиП' AND GROUPS.PROFESSION = '1-40 01 02')
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT)
	UNION
(SELECT GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = 'ИДиП'
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- UNION ALL
(SELECT GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = 'ХТиТ' OR (GROUPS.FACULTY = 'ИДиП' AND GROUPS.PROFESSION = '1-40 01 02')
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT)
	UNION ALL
(SELECT GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = 'ИДиП'
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- 8. Получить пересечение двух множеств строк, созданных в результате выполнения запросов пункта 8.
-- Объяснить результат. Использовать оператор INTERSECT.
(SELECT GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = 'ХТиТ' OR (GROUPS.FACULTY = 'ИДиП' AND GROUPS.PROFESSION = '1-40 01 02')
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT)
	INTERSECT
(SELECT GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = 'ИДиП'
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- 9. Получить разницу между множеством строк, созданных в результате запросов пункта 8. Объяснить результат. 
-- Использовать оператор EXCEPT.
(SELECT GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = 'ХТиТ' OR (GROUPS.FACULTY = 'ИДиП' AND GROUPS.PROFESSION = '1-40 01 02')
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT)
	EXCEPT
(SELECT GROUPS.PROFESSION[Специальность],
	   PROGRESS.SUBJECT[Дисциплина],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[Средняя оценка]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = 'ИДиП'
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- 10. На основе таблицы PROGRESS определить для каждой дисциплины количество студентов, получивших оценки 8 и 9.
-- Использовать группировку, секцию HAVING, сортировку.
SELECT p1.SUBJECT[Дисциплина], p1.NOTE,
(
	select count(*) from PROGRESS p2
	where p2.SUBJECT = p1.SUBJECT and p2.NOTE = p1.NOTE
)[Количество студентов]
FROM PROGRESS p1
GROUP BY p1.SUBJECT, p1.NOTE
HAVING p1.NOTE = 9 OR p1.NOTE = 8;

-- 12*. Подсчитать количество студентов в каждой группе, на каждом факультете и всего в университете одним запросом.
-- Подсчитать количество аудиторий по типам и суммарной вместимости в корпусах и всего одним запросом.

SELECT COALESCE(GROUPS.FACULTY, 'Всего в университете') AS Факультет,
	   GROUPS.IDGROUP AS Группа,
	   COUNT(STUDENT.IDSTUDENT) AS [Количество студентов]
FROM STUDENT JOIN GROUPS
ON STUDENT.IDGROUP = GROUPS.IDGROUP 
GROUP BY ROLLUP(GROUPS.FACULTY, GROUPS.IDGROUP);

SELECT COALESCE(AUDITORIUM_TYPE.AUDITORIUM_TYPE, 'Всего') AS [Тип аудитории],
	   SUM(AUDITORIUM.AUDITORIUM_CAPACITY) AS [Суммарная вместимость],
	   COUNT(AUDITORIUM.AUDITORIUM) AS [Количество аудиторий]
FROM AUDITORIUM_TYPE JOIN AUDITORIUM
ON AUDITORIUM_TYPE.AUDITORIUM_TYPE = AUDITORIUM.AUDITORIUM_TYPE
GROUP BY ROLLUP(AUDITORIUM_TYPE.AUDITORIUM_TYPE);

