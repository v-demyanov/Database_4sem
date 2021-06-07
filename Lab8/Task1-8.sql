USE DVR_UNIVER;

-- 1. Разработать представление с именем Преподаватель. Представление должно быть построено на основе SELECT-запроса
-- к таблице TEACHER и содержать следующие столбцы: код (TEACHER), имя преподавателя (TEACHER_NAME), пол (GENDER), код кафедры (PULPIT). 
CREATE VIEW [Преподаватель]
	AS SELECT TEACHER.TEACHER[Код],
		      TEACHER.TEACHER_NAME[Имя преподавателя],
			  TEACHER.GENDER[Пол],
			  TEACHER.PULPIT[Код кафедры] FROM TEACHER;

SELECT * FROM [Преподаватель];

-- 2. Разработать и создать представление с именем Количество кафедр.
-- Представление должно быть построено на основе SELECT-запроса к таблицам FACULTY и PULPIT.
-- Представление должно содержать следующие столбцы: факультет (FACULTY.FACULTY_ NAME), количество кафедр (вычисляется на основе строк таблицы PULPIT). 
-- а
CREATE VIEW [Количество кафедр]
	AS SELECT FACULTY.FACULTY_NAME[Факультет],
			  (select count(*)
			  from PULPIT where PULPIT.FACULTY = FACULTY.FACULTY)[Количество кафедр]
	FROM FACULTY;
-- б
CREATE VIEW [Количество кафедр]
	AS SELECT DISTINCT(FACULTY.FACULTY_NAME)[Факультет],
				COUNT(PULPIT.FACULTY)[Количество кафедр]
	FROM dbo.FACULTY JOIN dbo.PULPIT
	ON PULPIT.FACULTY = FACULTY.FACULTY
	GROUP BY FACULTY.FACULTY_NAME;

-- 3. Разработать и создать представление с именем Аудитории. Представление должно быть построено на основе
-- таблицы AUDITORIUM и содержать столбцы: код (AUDITORIUM), наименование аудитории (AUDITORIUM_NAME). 
-- Представление должно отображать только лекционные аудитории (в столбце AUDITORIUM_ TYPE строка, начинающаяся с символа ЛК)
-- и допускать выполнение оператора INSERT, UPDATE и DELETE.
CREATE VIEW [Аудитории]
	AS SELECT AUDITORIUM.AUDITORIUM[Код],
			  AUDITORIUM.AUDITORIUM_NAME[Наименование аудитории]
	FROM AUDITORIUM WHERE AUDITORIUM.AUDITORIUM_TYPE LIKE 'ЛК%';

INSERT  [Аудитории]
	VALUES('339-6', '333-1');

SELECT * FROM AUDITORIUM;

-- 4. Разработать и создать представление с именем Лекционные_аудитории.
-- Представление должно быть построено на основе SELECT-запроса к таблице AUDITORIUM и содержать следующие столбцы:
-- код (AUDITORIUM), наименование аудитории (AUDITORIUM_NAME). Представление должно отображать только
-- лекционные аудитории (в столбце AUDITORIUM_TYPE строка, начинающаяся с символов ЛК). 
-- Выполнение INSERT и UPDATE допускается, но с учетом ограничения, задаваемого опцией WITH CHECK OPTION.
CREATE VIEW Лекционные_аудитории
	AS SELECT AUDITORIUM.AUDITORIUM[Код],
			  AUDITORIUM.AUDITORIUM_NAME[Наименование аудитории],
			  AUDITORIUM.AUDITORIUM_TYPE[Тип аудитории]
	FROM AUDITORIUM WHERE AUDITORIUM.AUDITORIUM_TYPE LIKE 'ЛК%'
	WITH CHECK OPTION; 

INSERT Лекционные_аудитории
	VALUES('233-1', '233-1', 'ЛБ-К');

SELECT * FROM Лекционные_аудитории;

-- 5. Разработать и создать представление с именем Дисциплины. Представление должно быть построено 
-- на основе SELECT-запроса к таблице SUBJECT, отображать все дисциплины в алфавитном порядке 
-- и содержать следующие столбцы: код (SUBJECT), наименование дисциплины (SUBJECT_NAME) и код кафедры (PULPIT). 
-- Использовать секции TOP и ORDER BY.
CREATE VIEW Дисциплины
	AS SELECT TOP 150 SUBJECT.SUBJECT[Код],
			  SUBJECT.SUBJECT_NAME[Наименование дисциплины],
			  SUBJECT.PULPIT
	FROM SUBJECT ORDER BY SUBJECT.SUBJECT_NAME;

SELECT * FROM Дисциплины;

-- 6. Изменить представление Количество_кафедр, созданное в задании 2 так, чтобы оно было привязано к базовым таблицам.
-- Продемонстрировать свойство привязанности представления к базовым таблицам. Примечание: использовать опцию SCHEMABINDING. 
ALTER VIEW [Количество кафедр] WITH SCHEMABINDING 
	AS SELECT FACULTY.FACULTY_NAME[Факультет],
			  (select count(*)
			  from dbo.PULPIT where PULPIT.FACULTY = FACULTY.FACULTY)[Количество кафедр]
	FROM dbo.FACULTY;

-- 8*. Разработать представление для таблицы TIMETABLE (лабораторная работа 6) в виде расписания.
-- Изучить оператор PIVOT и использовать его.
CREATE VIEW Расписание
	AS SELECT TOP(100) [День], [Пара], [1 группа], [2 группа], [3 группа], [4 группа], [5 группа], [6 группа], [7 группа], [8 группа]
		FROM (select top(100) WEEKDAY [День],
				 CLASS_NUMBER [Пара],
				 cast(IDGROUP as varchar(4)) + ' группа' [Группа],
				 SUBJECT + ' ' + AUDITORIUM [Дисциплина и аудитория]
			from TIMETABLE) tbl
		PIVOT
			(max([Дисциплина и аудитория]) 
			for [Группа] -- значения, которые станут именами столбцов
			in ([1 группа], [2 группа], [3 группа], [4 группа], [5 группа], [6 группа], [7 группа], [8 группа]) -- значения по горизонтали
			) as pvt
		ORDER BY 
		(CASE
			WHEN [День] LIKE 'пн' THEN 1
		    WHEN [День] LIKE 'вт' THEN 2
			WHEN [День] LIKE 'ср' THEN 3
			WHEN [День] LIKE 'чт' THEN 4
			WHEN [День] LIKE 'пт' THEN 5
			WHEN [День] LIKE 'сб' THEN 6
		 END), [Пара] ASC;

DROP VIEW Расписание;
SELECT * FROM Расписание;






