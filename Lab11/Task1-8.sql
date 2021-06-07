USE DVR_UNIVER;

-- 1. Разработать сценарий, формиру-ющий список дисциплин на кафедре ИСиТ.
-- В отчет должны быть выведены краткие названия (поле SUBJECT) 
-- из таблицы SUBJECT в одну строку через запятую. 
-- Использовать встроенную функцию RTRIM.
DECLARE @subj nchar(20), @result nchar(300) = '';
DECLARE ShortSubjName CURSOR 
					FOR SELECT SUBJECT FROM SUBJECT;

OPEN ShortSubjName;
FETCH ShortSubjName INTO @subj;

PRINT 'Краткие названия предметов';
WHILE @@FETCH_STATUS = 0
	BEGIN
	 set @result = rtrim(@subj) + ',' + @result;
	 FETCH ShortSubjName INTO @subj;
	END;
PRINT @result;
CLOSE ShortSubjName;

-- 2. Разработать сценарий, демонстрирующий отличие глобального курсора
-- от локального на примере базы данных X_UNIVER.

-- CURSOR LOCAL
DECLARE Auditorium CURSOR LOCAL
		FOR SELECT AUDITORIUM, AUDITORIUM_CAPACITY FROM AUDITORIUM;
DECLARE @audit NVARCHAR(20), @capac INT;

OPEN Auditorium;
FETCH Auditorium INTO @audit, @capac;
PRINT 'Аудитория №' + @audit + ' с вместимостью ' + cast(@capac as VARCHAR(8));
GO

DECLARE @audit NVARCHAR(20), @capac INT;
FETCH Auditorium INTO @audit, @capac;
PRINT 'Аудитория №' + @audit + ' с вместимостью ' + cast(@capac as VARCHAR(8));
GO

-- CURSOR GLOBAL
DECLARE Auditorium CURSOR GLOBAL
		FOR SELECT AUDITORIUM, AUDITORIUM_CAPACITY FROM AUDITORIUM;
DECLARE @audit NVARCHAR(20), @capac INT;

OPEN Auditorium;
FETCH Auditorium INTO @audit, @capac;
PRINT 'Аудитория №' + @audit + ' с вместимостью ' + cast(@capac as VARCHAR(8));
GO

DECLARE @audit NVARCHAR(20), @capac INT;
FETCH Auditorium INTO @audit, @capac;
PRINT 'Аудитория №' + @audit + ' с вместимостью ' + cast(@capac as VARCHAR(8));
GO

-- 3. Разработать сценарий, демонстрирующий отличие статических курсоров
-- от динамических на примере базы данных X_UNIVER.

-- при демонстрации поменять static на dynamic
GO

DECLARE @subj NVARCHAR(20), @pulp NVARCHAR(20);
DECLARE SubjectCursor CURSOR LOCAL static
		FOR SELECT SUBJECT, PULPIT FROM dbo.SUBJECT WHERE PULPIT = 'ЛУ';

OPEN SubjectCursor;
PRINT 'Количество строк: ' + CAST(@@CURSOR_ROWS AS VARCHAR(6));

INSERT SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT)
	VALUES('SUBJ_LAB11', 'SUBJECT_LAB11', 'ЛУ');

FETCH SubjectCursor INTO @subj, @pulp;
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @subj + '' + @pulp;
	FETCH SubjectCursor INTO @subj, @pulp;
END;
CLOSE SubjectCursor;

DELETE SUBJECT WHERE SUBJECT = 'SUBJ_LAB11';

GO

-- 4. Разработать сценарий, демонстрирующий свойства навигации 
-- в результирующем наборе курсора с атрибутом SCROLL на примере базы данных X_UNIVER.
-- Использовать все известные ключевые слова в операторе FETCH.
GO

DECLARE @subj NVARCHAR(20), @pulp NVARCHAR(20);
DECLARE SubjectCursor CURSOR LOCAL DYNAMIC SCROLL
		FOR SELECT SUBJECT, PULPIT
			FROM dbo.SUBJECT WHERE PULPIT = 'ИСиТ';

OPEN SubjectCursor;
FETCH LAST FROM SubjectCursor INTO @subj, @pulp;
PRINT 'последняя строка: ' + @subj + '' + @pulp;
FETCH FIRST FROM SubjectCursor INTO @subj, @pulp;
PRINT 'первая строка: ' + @subj + '' + @pulp;
FETCH NEXT FROM SubjectCursor INTO @subj, @pulp;
PRINT 'следующая после первой строка: ' + @subj + '' + @pulp;
FETCH RELATIVE 2 FROM SubjectCursor INTO @subj, @pulp;
PRINT 'вторая строка от текущей: ' + @subj + '' + @pulp;
CLOSE SubjectCursor;

GO

-- 5. Создать курсор, демонстрирующий применение конструкции CURRENT OF
-- в секции WHERE с использованием операторов UPDATE и DELETE.
GO

INSERT PULPIT (PULPIT, PULPIT_NAME, FACULTY)
	VALUES('L11_EX5', 'L11_EX5', 'ИДиП');

INSERT SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT)
	VALUES('L11_EX51', 'L11_EX51', 'L11_EX5'),
		  ('L11_EX52', 'L11_EX52', 'L11_EX5'),
		  ('L11_EX53', 'L11_EX53', 'L11_EX5'),
		  ('L11_EX54', 'L11_EX54', 'L11_EX5'),
		  ('L11_EX55', 'L11_EX55', 'L11_EX5');

DECLARE @subj NVARCHAR(20), @pulp NVARCHAR(20);
DECLARE SubjectCursor CURSOR LOCAL DYNAMIC
		FOR SELECT SUBJECT, PULPIT
			FROM dbo.SUBJECT WHERE PULPIT = 'L11_EX5' FOR UPDATE;

OPEN SubjectCursor;
FETCH SubjectCursor INTO @subj, @pulp;
DELETE dbo.SUBJECT WHERE CURRENT OF SubjectCursor;
FETCH SubjectCursor INTO @subj, @pulp;
UPDATE dbo.SUBJECT SET PULPIT = 'ЛУ' WHERE CURRENT OF SubjectCursor;
CLOSE SubjectCursor;


GO

-- 6. Разработать SELECT-запрос, с помощью которого из таблицы PROGRESS
-- удаляются строки, содержащие информацию о студентах, получивших оценки ниже 4
-- (использовать объединение таблиц PROGRESS, STUDENT, GROUPS). 

INSERT PROGRESS (SUBJECT, IDSTUDENT,NOTE)
	VALUES ('КГ', 1000, 3),
		   ('КГ', 1001, 3),
		   ('КГ', 1002, 3),
		   ('КГ', 1003, 3),
		   ('КГ', 1004, 3),
		   ('КГ', 1005, 3),
		   ('КГ', 1006, 3);

SELECT * FROM PROGRESS;

GO

DECLARE @name NVARCHAR(20), @note INT;
DECLARE ProgressCursor CURSOR LOCAL DYNAMIC
		FOR SELECT NAME, NOTE
			FROM PROGRESS JOIN STUDENT
			ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT 
			WHERE NOTE < 4 FOR UPDATE;

OPEN ProgressCursor;
FETCH ProgressCursor INTO @name, @note;
WHILE @@FETCH_STATUS = 0
BEGIN 
	DELETE PROGRESS WHERE CURRENT OF ProgressCursor;
	FETCH ProgressCursor INTO @name, @note;
END
CLOSE ProgressCursor;

GO

-- Разработать SELECT-запрос, с по-мощью которого в таблице PROGRESS
-- для студента с конкретным номером IDSTUDENT корректируется оценка 
-- (увеличивается на единицу).

INSERT PROGRESS (SUBJECT, IDSTUDENT,NOTE)
	VALUES ('КГ', 1007, 6);

GO

DECLARE @name NVARCHAR(20), @note INT;
DECLARE ProgressCursor CURSOR LOCAL DYNAMIC
		FOR SELECT NAME, NOTE
			FROM PROGRESS JOIN STUDENT
			ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT 
			WHERE PROGRESS.IDSTUDENT = 1007 FOR UPDATE;

OPEN ProgressCursor;
FETCH ProgressCursor INTO @name, @note;
WHILE @@FETCH_STATUS = 0
BEGIN 
	UPDATE PROGRESS SET NOTE = NOTE + 1
			WHERE CURRENT OF ProgressCursor;
	FETCH ProgressCursor INTO @name, @note;
END
CLOSE ProgressCursor;

GO

DELETE PROGRESS WHERE IDSTUDENT = 1007;
SELECT * FROM PROGRESS;

-- 8.

DECLARE Ex8Cursor CURSOR LOCAL STATIC 
	FOR SELECT FACULTY.FACULTY, PULPIT.PULPIT, SUBJECT.SUBJECT, COUNT(TEACHER.TEACHER)
	FROM FACULTY 
    JOIN PULPIT ON FACULTY.FACULTY = PULPIT.FACULTY
	LEFT JOIN SUBJECT ON PULPIT.PULPIT = SUBJECT.PULPIT
	LEFT JOIN TEACHER ON PULPIT.PULPIT = TEACHER.PULPIT
	GROUP BY FACULTY.FACULTY, PULPIT.PULPIT, SUBJECT.SUBJECT
	ORDER BY FACULTY, PULPIT, SUBJECT;

DECLARE @faculty CHAR(10), @pulpit CHAR(10), @subject CHAR(10), @cnt_teacher INT;
DECLARE @temp_fac CHAR(10), @temp_pul CHAR(10), @list VARCHAR(100), @DISCIPLINES CHAR(12) = 'Дисциплины: ', @DISCIPLINES_NONE CHAR(16) = 'Дисциплины: нет.';

OPEN Ex8Cursor;
FETCH Ex8Cursor INTO @faculty, @pulpit, @subject, @cnt_teacher;
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT 'Факультет ' + (@faculty) + ': ';
	SET @temp_fac = @faculty;
	-- пока не встретим новый факультет
	WHILE (@faculty = @temp_fac)
	BEGIN
		PRINT CHAR(9) + 'Кафедра ' + RTRIM(@pulpit) + ': ';
		PRINT CHAR(9) + CHAR(9) + 'Количество преподавателей: ' + RTRIM(@cnt_teacher) + '.';
		SET @list = @DISCIPLINES;

		IF(@subject IS NOT NULL)
		BEGIN
			IF(@list = @DISCIPLINES)
				SET @list += RTRIM(@subject);
			ELSE
				SET @list += ', ' + RTRIM(@subject);
		END;

		IF (@subject is null) SET @list = @DISCIPLINES_NONE;

		SET @temp_pul = @pulpit;
		FETCH Ex8Cursor INTO @faculty, @pulpit, @subject, @cnt_teacher;
		-- пока не встретим новую кафедру
		WHILE (@pulpit = @temp_pul)
		BEGIN
			IF(@subject is not null)
			BEGIN
				IF(@list = @DISCIPLINES)
					SET @list += RTRIM(@subject);
				ELSE
					SET @list += ', ' + RTRIM(@subject);
			END;
			FETCH Ex8Cursor INTO @faculty, @pulpit, @subject, @cnt_teacher;
			IF(@@FETCH_STATUS != 0) BREAK;
		END;

		IF(@list != @DISCIPLINES_NONE) SET @list += '.';
		PRINT CHAR(9) + CHAR(9) + @list;
		IF(@@FETCH_STATUS != 0) BREAK;
	END;
END;
CLOSE Ex8Cursor;
DEALLOCATE Ex8Cursor;