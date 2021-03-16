USE DVR_UNIVER;

-- Сформировать список наименований кафедр,
-- которые находятся на факультете , обеспечивающем подготовку по специальности,
-- в наименовании которого содержится слово технология или технологии
-- Примечание: использовать в секции WHERE предикат IN c некоррелированным подзапросом
SELECT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT, FACULTY
WHERE PULPIT.FACULTY = FACULTY.FACULTY
	  AND 
	  PULPIT.FACULTY IN(SELECT FACULTY FROM PROFESSION WHERE (PROFESSION_NAME LIKE '%технология%' OR PROFESSION_NAME LIKE '%технологии%'));

-- Переписать запрос пункта 1 таким об-разом,
-- чтобы тот же подзапрос был записан в конструкции INNER JOIN секции FROM внешнего запроса
SELECT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT INNER JOIN FACULTY
ON PULPIT.FACULTY = FACULTY.FACULTY
WHERE PULPIT.FACULTY IN(SELECT FACULTY FROM PROFESSION WHERE (PROFESSION_NAME LIKE '%технология%' OR PROFESSION_NAME LIKE '%технологии%'));

-- Переписать запрос, реализующий 1 пункт без использования подзапроса.
-- Примечание: использовать соединение INNER JOIN трех таблиц. 
SELECT DISTINCT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT 
INNER JOIN FACULTY ON PULPIT.FACULTY = FACULTY.FACULTY
INNER JOIN PROFESSION ON PULPIT.FACULTY = PROFESSION.FACULTY  
	WHERE (PROFESSION_NAME LIKE '%технология%' OR PROFESSION_NAME LIKE '%технологии%');