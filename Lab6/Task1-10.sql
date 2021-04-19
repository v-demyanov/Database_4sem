USE DVR_UNIVER;

-- 1. Сформировать список наименований кафедр,
-- которые находятся на факультете , обеспечивающем подготовку по специальности,
-- в наименовании которого содержится слово технология или технологии
-- Примечание: использовать в секции WHERE предикат IN c некоррелированным подзапросом
SELECT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT, FACULTY
WHERE PULPIT.FACULTY = FACULTY.FACULTY
	  AND 
	  PULPIT.FACULTY IN(SELECT FACULTY FROM PROFESSION WHERE (PROFESSION_NAME LIKE '%технология%' OR PROFESSION_NAME LIKE '%технологии%'));

-- 2. Переписать запрос пункта 1 таким образом,
-- чтобы тот же подзапрос был записан в конструкции INNER JOIN секции FROM внешнего запроса
SELECT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT INNER JOIN FACULTY
ON PULPIT.FACULTY = FACULTY.FACULTY
WHERE PULPIT.FACULTY IN(SELECT FACULTY FROM PROFESSION WHERE (PROFESSION_NAME LIKE '%технология%' OR PROFESSION_NAME LIKE '%технологии%'));

-- 3. Переписать запрос, реализующий 1 пункт без использования подзапроса.
-- Примечание: использовать соединение INNER JOIN трех таблиц. 
SELECT DISTINCT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT 
INNER JOIN FACULTY ON PULPIT.FACULTY = FACULTY.FACULTY
INNER JOIN PROFESSION ON PULPIT.FACULTY = PROFESSION.FACULTY  
	WHERE (PROFESSION_NAME LIKE '%технология%' OR PROFESSION_NAME LIKE '%технологии%');

-- 4. На основе таблицы AUDITORIUM сформировать список аудиторий самых больших вместимостей (столбец AUDITORIUM_CAPACITY)
-- для каждого типа аудитории (AUDITORIUM_TYPE). При этом результат следует отсортировать в порядке убывания вместимости. 
-- Примечание: использовать коррелируемый подзапрос c секциями TOP и ORDER BY. 
SELECT AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY
FROM AUDITORIUM a
WHERE AUDITORIUM_CAPACITY = (SELECT TOP(1) AUDITORIUM_CAPACITY FROM AUDITORIUM aa
							WHERE aa.AUDITORIUM_TYPE = a.AUDITORIUM_TYPE
							ORDER BY AUDITORIUM_CAPACITY DESC);

-- 5. На основе таблиц FACULTY и PULPIT сформировать список наименований факультетов (столбец FACULTY_NAME)
-- на котором нет ни одной кафедры (таблица PULPIT).
-- Примечание: использовать предикат EXISTS и кор-релированный подзапрос. 
SELECT FACULTY_NAME
FROM FACULTY
WHERE NOT EXISTS (SELECT * FROM PULPIT WHERE PULPIT.FACULTY = FACULTY.FACULTY);

-- 6. На основе таблицы PROGRESS сформировать строку, содержащую средние значения оценок (столбец NOTE) 
-- по дисциплинам, имеющим следующие коды: ОАиП, БД и СУБД. Примечание: использовать три
-- некоррелированных подзапроса в списке SELECT; в подзапросах применить агрегатные функции AVG.
SELECT TOP(1)
	(SELECT AVG(NOTE) FROM PROGRESS WHERE SUBJECT LIKE 'ОАиП')[ОАиП],
	(SELECT AVG(NOTE) FROM PROGRESS WHERE SUBJECT LIKE 'КГ')[КГ],
	(SELECT AVG(NOTE) FROM PROGRESS WHERE SUBJECT LIKE 'СУБД')[СУБД]
FROM PROGRESS;

-- 7. найти все аудитории, вместимость которых меньше чем у любой аудитории типа ЛК-К
SELECT *
FROM AUDITORIUM 
WHERE AUDITORIUM_CAPACITY < ALL(SELECT AUDITORIUM_CAPACITY FROM AUDITORIUM WHERE AUDITORIUM_TYPE = 'ЛК-К');

-- 8. найти все аудитории, вместимость которых меньше чем у хотя бы одной аудитории типа ЛК-К
SELECT *
FROM AUDITORIUM 
WHERE AUDITORIUM_CAPACITY < ANY(SELECT AUDITORIUM_CAPACITY FROM AUDITORIUM WHERE AUDITORIUM_TYPE = 'ЛК-К');

-- 10*. Найти в таблице STUDENT студентов, у которых день рождения в один день. Объяснить решение.
SELECT *, (SELECT DISTINCT DAY(BDAY) FROM STUDENT s2 WHERE DAY(s2.BDAY) = DAY(s1.BDAY)) AS [Day]
FROM STUDENT s1
ORDER BY Day;