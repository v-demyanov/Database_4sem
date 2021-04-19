USE DVR_UNIVER;


-- 1. Разработать T-SQL-скрипт, в котором: 
-- 1) объявить переменные типа char, varchar, datetime,
-- time, int, smallint, tinint, numeric(12, 5); 
-- 2) первые две переменные проинициализировать в операторе объявления;
-- 3) присвоить произвольные значения следующим двум переменным с помощью оператора SET,
-- одной из этих переменных присвоить значение, полученное в результате запроса SELECT; 
-- 4) одну из переменных оставить без инициализации и не присваивать ей значения,
-- оставшимся переменным присвоить некоторые значения с помощью оператора SELECT; 
-- 5) значения одной половины переменных вывести с помощью оператора SELECT,
-- значения другой половины переменных распечатать с помощью оператора PRINT.

DECLARE @cvar char(1) = 't';
DECLARE @vcvar varchar = 'testVarchar';
DECLARE @dtvar datetime; -- +
DECLARE @tvar time(4) -- +
DECLARE @ivar int; -- +
DECLARE @sivar smallint; -- +
DECLARE @tivar tinyint;  -- +
DECLARE @nvar numeric(12,5);

SET @sivar = 12;
SET @ivar = (SELECT COUNT(*) FROM AUDITORIUM);
SET @dtvar = (SELECT MIN(BDAY) FROM STUDENT);
SET @tvar = GETDATE();
SET @tivar = (SELECT MIN(AUDITORIUM_CAPACITY) FROM AUDITORIUM);

PRINT 'Текущее время ' + CAST(@tvar AS VARCHAR(10));
PRINT 'Количество аудиторий: ' + cast(@ivar as varchar(10));
PRINT 'Дата рождения старшего студента: ' + cast(@dtvar as varchar(10));
SELECT @tivar AS 'Аудитория с мин вместимостью';

-- 2. Разработать скрипт, в котором определяется общая вместимость аудиторий.
-- Когда общая вместимость превышает 200, то вывести количество аудиторий,
-- среднюю вместимость аудиторий, количество аудиторий, вместимость которых меньше средней,
-- и процент таких аудиторий. Когда общая вместимость аудиторий меньше 200, то вывести
-- сообщение о размере общей вместимости.

DECLARE @y1 INT = (select sum(AUDITORIUM_CAPACITY) from AUDITORIUM),
@y2 int, @y3 numeric(8,3), @y4 int, @y5 numeric(8,3)
IF @y1 > 200
BEGIN
	select @y2 = (select count(*) from AUDITORIUM),
		   @y3 = (select cast(avg(AUDITORIUM_CAPACITY) as numeric(8,3)) from AUDITORIUM)
	set @y4 = (select count(*) from AUDITORIUM where AUDITORIUM_CAPACITY < @y3)
	set @y5 = (@y4 * 100) / @y2
	select @y1 'Общаяя вместительность', @y2 'Количество аудиторий',
		   @y3 'Средняя вместительность', @y4 'кол-во с вместимостью меньше средней',
		   @y5 'процент аудиторий, вместимость которых меньше средней'
END
ELSE IF @y1 < 200 PRINT 'Общая вместительность: ' + CAST(@y1 AS VARCHAR(10));
ELSE PRINT 'Общая вместительность равна 200';

SELECT * FROM AUDITORIUM;

-- 3.	Разработать T-SQL-скрипт, который выводит на печать глобальные переменные:
PRINT '@@ROWCOUNT (число обработанных строк): ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
PRINT '@@VERSION (версия SQL Server): ' + CAST(@@VERSION AS NVARCHAR(300));
PRINT '@@SPID (возвращает системный идентификатор процесса,' +
		'назначенный сервером текущему подключению): ' + CAST(@@SPID AS NVARCHAR(300));
PRINT '@@ERROR (код последней ошибки): ' + CAST(@@ERROR AS NVARCHAR(300));
PRINT '@@SERVERNAME (имя сервера): ' + CAST(@@SERVERNAME AS NVARCHAR(300));
PRINT '@@TRANCOUNT (возвращает уровень вложенности транзакции): ' + CAST(@@TRANCOUNT AS NVARCHAR(300));
PRINT '@@FETCH_STATUS (проверка результата считывания строк результирующего набора): ' + CAST(@@FETCH_STATUS AS NVARCHAR(300));
PRINT '@@NESTLEVEL (уровень вложенности текущей процедуры): ' + CAST(@@NESTLEVEL AS NVARCHAR(300));

-- 4.

--	   | sin^2(t), t > x
-- z = | 4 * (t + x), t < x
--	   | 1 - e^(x-2), t = x

DECLARE @t int = 1, @z float, @x int = 5;
IF (@t > @x) SET @z = POWER(SIN(@t), 2)
ELSE IF (@t < @x) SET @z = 4 * (@t + @x)
ELSE SET @z = 1 - EXP(@x - 2);

PRINT 'z= ' + CAST(@z AS VARCHAR(10));
 
-- преобразование полного ФИО студента в сокращенное
-- (например, Макейчик Татьяна Леонидовна в Макейчик Т. Л.)

DECLARE @data4b NVARCHAR(50);
DECLARE @result4b NVARCHAR(50);
SET @data4b = 'Демьянов Владислав Русланович';

PRINT 'Полное ФИО: ' + @data4b;

SET @result4b = SUBSTRING(@data4b, 1, CHARINDEX(' ', @data4b)) +
				SUBSTRING(@data4b, CHARINDEX(' ', @data4b) + 1, 1) + '.' +
				SUBSTRING(@data4b, CHARINDEX(' ', @data4b, CHARINDEX(' ', @data4b) + 1) + 1, 1) + '.';

PRINT 'Сокращённое ФИО: ' + @result4b;

-- поиск студентов, у которых день рождения в следующем месяце, и определение их возраста
DECLARE @month NCHAR(2) = MONTH(DATEADD(MONTH, 1, GETDATE()));

SELECT IDSTUDENT, IDGROUP, NAME, BDAY, DATEDIFF(YEAR, BDAY, GETDATE()) AS AGE
FROM STUDENT WHERE MONTH(BDAY) = @month;

-- поиск дня недели, в который студенты некоторой группы сдавали экзамен по СУБД
DECLARE @group_number INT = 4;

SELECT TOP(1) DATENAME(WEEKDAY, PDATE) AS "WEEKDAY"
FROM PROGRESS
JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON STUDENT.IDGROUP = GROUPS.IDGROUP
WHERE GROUPS.IDGROUP =  @group_number;

-- 5. Продемонстрировать конструкцию IF… ELSE на примере анализа данных таблиц базы данных Х_UNIVER
USE DVR_MyBase_Test;

DECLARE @x1 INT = (select sum(HOURS_NUMBERS) from CURRICULUM),
@x2 int, @x3 numeric(8,3), @x4 int, @x5 numeric(8,3)
IF @x1 < 0 PRINT 'Ошибка: количество часов не может быть отрицательным' + '(' + CAST(@x1 AS VARCHAR(10)) + ')'
ELSE IF @x1 < 450
BEGIN
	select @x2 = (select count(*) from CURRICULUM),
		   @x3 = (select cast(avg(HOURS_NUMBERS) as numeric(8,3)) from CURRICULUM)
	select @x1 'Общее количество часов', @x2 'Количество курсов',
		   @x3 'Среднее количество часов'
END
ELSE PRINT 'Общее количество часов: ' + CAST(@x1 AS VARCHAR(10));

-- 6. Разработать сценарий, в котором с помощью CASE анализируются оценки,
-- полученные студентами некоторого факультета при сдаче экзаменов.
USE DVR_UNIVER;

DECLARE @faculty_name NVARCHAR(10) = 'ХТиТ';

SELECT CASE
	   when NOTE BETWEEN 1 AND 3 then 'не сдал'
	   when NOTE BETWEEN 3 AND 6 then 'удовлетворительно'
	   when NOTE BETWEEN 6 AND 8 THEN 'хорошо'
	   when NOTE BETWEEN 8 AND 10 THEN 'отлично'
	   else 'ошибка'
	   end Оценка, count(*) [Количество студентов]
FROM PROGRESS
JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON STUDENT.IDGROUP = GROUPS.IDGROUP
WHERE FACULTY = @faculty_name
GROUP BY CASE
	   when NOTE BETWEEN 1 AND 3 then 'не сдал'
	   when NOTE BETWEEN 3 AND 6 then 'удовлетворительно'
	   when NOTE BETWEEN 6 AND 8 THEN 'хорошо'
	   when NOTE BETWEEN 8 AND 10 THEN 'отлично'
	   else 'ошибка'
	   end;

-- 7. Создать временную локальную таблицу из трех столбцов и 10 строк,
-- заполнить ее и вывести содержимое. Использовать оператор WHILE.

CREATE TABLE #FIRST_TEMP_TABLE
(
	COL1 INT IDENTITY(1,1),
	COL2 NVARCHAR(50),
	COL3 NVARCHAR(50)
);

DECLARE @rows INT = 10;
DECLARE @i INT = 0;

WHILE @i < @rows
BEGIN
	insert #FIRST_TEMP_TABLE (COL2, COL3)
		values(CAST(CONCAT('row', @i) + ' col2' AS NVARCHAR(50)), CAST(CONCAT('row', @i) + ' col3' AS NVARCHAR(50)));
	set @i = @i + 1;
END;

SELECT * FROM #FIRST_TEMP_TABLE;

-- 8. Разработать скрипт, демонстрирующий использование оператора RETURN.
DECLARE @y INT = 0;

WHILE @y < 10
BEGIN
	if @y = 5 return;
	else begin
		print @y;
		set @y = @y + 1;
	end
END;

-- 9. Разработать сценарий с ошибками, в котором используются для обработки ошибок блоки TRY и CATCH.
-- Применить функции ERROR_NUMBER (код последней ошибки), ERROR_ES-SAGE (сообщение об ошибке),
-- ERROR_LINE (код последней ошибки), ERROR_PROCEDURE (имя процедуры или NULL),
-- ERROR_SEVERITY (уровень серьезности ошибки), ERROR_ STATE (метка ошибки).
-- Проанализировать результат.

BEGIN TRY
	DECLARE @a INT = 3;
	DECLARE @b NVARCHAR = 'TEST';
	DECLARE @result INT;
	SET @result = @a / @b;
END TRY
BEGIN CATCH 
	print 'Код последней ошибки: ' + CAST(ERROR_NUMBER() AS VARCHAR(50))
	print 'Сообщение об ошибке: ' + CAST(ERROR_MESSAGE() AS VARCHAR(50))
	print 'Номер строки последней ошибки: ' + CAST(ERROR_LINE() AS VARCHAR(50))
	print 'Имя процедуры или NULL: ' + CAST(ERROR_PROCEDURE() AS VARCHAR(50))
	print 'Уровень серьёзности ошибки: ' + CAST(ERROR_SEVERITY() AS VARCHAR(50))
	print 'Метка ошибки: ' + CAST(ERROR_STATE() AS VARCHAR(50))
END CATCH;

