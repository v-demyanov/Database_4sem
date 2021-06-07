USE DVR_UNIVER;

-- 1. Разработать хранимую процедуру без парамет-ров с именем PSUBJECT
go
CREATE PROCEDURE PSUBJECT AS
BEGIN
	DECLARE @n INT = (SELECT COUNT(*) FROM SUBJECT);
	SELECT SUBJECT[код], SUBJECT_NAME[дисциплина], PULPIT[кафедра] FROM SUBJECT;
	RETURN @n;
END;
go

DECLARE @str_count INT;
EXEC @str_count = PSUBJECT;
PRINT 'Количество строк выведенных в результирующий набор: ' + CAST(@str_count AS nvarchar(4));

-- DROP PROCEDURE PSUBJECT;


-- 2. Изменить процедуру PSUBJECT, созданную в за-дании 1, таким образом, чтобы она принимала
-- два па-раметра с именами @p и @c. Параметр @p является входным, имеет тип VARCHAR(20)
-- и значение по умолчанию NULL. Параметр @с является выходным, имеет тип INT.
go
ALTER PROCEDURE PSUBJECT @p VARCHAR(20) = NULL, @c INT OUTPUT AS
BEGIN
	DECLARE @subj_count INT = (SELECT COUNT(*) FROM SUBJECT);
	SELECT SUBJECT[код], SUBJECT_NAME[дисциплина], PULPIT[кафедра]
	FROM SUBJECT WHERE PULPIT = @p;
	SET @c = @@ROWCOUNT;
	RETURN @subj_count;
END;
go

DECLARE @subj_count_all INT = 0,
		@pulpit_key VARCHAR(20) = 'ИСиТ',
		@row_count INT = 0;
EXEC @subj_count_all = PSUBJECT @pulpit_key, @c = @row_count OUTPUT;
PRINT 'Кол-во дисциплин всего: ' + cast(@subj_count_all AS VARCHAR(4));
PRINT 'Кол-во дисциплин кафедры: ' + @pulpit_key + ' ' + CAST(@row_count AS VARCHAR(4));


-- 3. Создать временную локальную таблицу с именем #SUBJECT. 
-- Наименование и тип столбцов таблицы должны соответствовать
-- столбцам результирующего набора процедуры PSUBJECT, разработанной в зада-нии 2. 
-- Изменить процедуру PSUBJECT таким образом, чтобы она не содержала выходного параметра.
-- Применив конструкцию INSERT… EXECUTE с мо-дифицированной процедурой PSUBJECT,
-- добавить строки в таблицу #SUBJECT.
go
ALTER PROCEDURE PSUBJECT @p VARCHAR(20) = NULL AS
BEGIN
	DECLARE @subj_count INT = (SELECT COUNT(*) FROM SUBJECT);
	SELECT SUBJECT[код], SUBJECT_NAME[дисциплина], PULPIT[кафедра]
	FROM SUBJECT WHERE PULPIT = @p;
	RETURN @subj_count;
END;
go

CREATE TABLE #SUBJECT
(
	NAME VARCHAR(20),
	SUBJECT VARCHAR(100),
	PULPIT VARCHAR(50)
);

INSERT #SUBJECT EXEC PSUBJECT @p = 'ИСиТ';
SELECT * FROM #SUBJECT;

DROP TABLE #SUBJECT;

-- 4. Разработать процедуру с именем PAUDITORI-UM_INSERT. 
-- Процедура принимает четыре входных параметра: @a, @n, @c и @t.
-- Параметр @a имеет тип CHAR(20), параметр @n имеет тип VARCHAR(50),
-- параметр @c имеет тип INT и значение по умолчанию 0, параметр @t имеет тип CHAR(10).
go
CREATE PROCEDURE PAUDITORIUM_INSERT @a CHAR(20), @n VARCHAR(50), @c INT = 0, @t CHAR(10) AS
BEGIN

BEGIN TRY
	insert into AUDITORIUM(AUDITORIUM, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY, AUDITORIUM_NAME)
		values(@a, @n, @c, @t);
	return 1;
END TRY
BEGIN CATCH
	print 'номер ошибки: ' + cast(error_number() as varchar(6));
	print 'сообщение: ' + error_message();
	print 'уровень: ' + cast(error_severity() as varchar(6));
	print 'метка: ' + cast(error_state() as varchar(8));
	print 'номер строки: ' + cast(error_line() as varchar(8));
	if error_procedure() is not null   
	print 'имя процедуры: ' + error_procedure();
	return -1;
END CATCH;

END;
go

DECLARE @rc INT;
EXEC @rc = PAUDITORIUM_INSERT @a = 'ex4_l13', @n = 'ЛК', @c = 50, @t = 'ex4_l13';
PRINT 'код ошибки: ' + CAST(@rc AS VARCHAR(4));

SELECT * FROM AUDITORIUM;

DELETE AUDITORIUM WHERE AUDITORIUM = 'ex4_l13';

-- 5.
go
CREATE PROCEDURE SUBJECT_REPORT @p CHAR(10) AS
BEGIN

declare @rc int = 0;
BEGIN TRY
	declare @subj char(10), @result varchar(100) = '';
	declare SUBJ_CURSOR cursor for
		select SUBJECT from SUBJECT where PULPIT = @p;
	if not exists(select SUBJECT from SUBJECT where PULPIT = @p)
		raiserror('ошибка', 11, 10);
	else
		open SUBJ_CURSOR;
		fetch SUBJ_CURSOR into @subj;
		print 'краткие названия дисциплин: ';
		while @@fetch_status = 0
		begin
			set @result = rtrim(@subj) + ', ' + @result;  
			set @rc = @rc + 1;
			fetch SUBJ_CURSOR into @subj;
		end
		print @result;
		close SUBJ_CURSOR;
		return @rc;
END TRY
BEGIN CATCH
	print 'ошибка в параметрах';
	if error_procedure() is not null
		print 'имя процедуры: ' + error_procedure();
	return @rc;
END CATCH;

END;
go

drop procedure SUBJECT_REPORT;

DECLARE @subj_count int;  
EXEC @subj_count = SUBJECT_REPORT @p ='ИСиТ';  
PRINT 'количество дисциплин в отчёте: ' + cast(@subj_count as varchar(4));

-- 6.
go
CREATE PROCEDURE PAUDITORIUM_INSERTX @a char(20), @n varchar(50), @c int = 0, 
									 @t char(10), @tn varchar(50) AS
BEGIN
DECLARE @rc int = 1;

BEGIN TRY
	set transaction isolation level serializable;          
	begin tran
	INSERT into AUDITORIUM_TYPE(AUDITORIUM_TYPE, AUDITORIUM_TYPENAME)
				values(@n, @tn);
	EXEC @rc = PAUDITORIUM_INSERT @a, @n, @c, @t;
	commit tran;
	return @rc;
END TRY
BEGIN CATCH
	print 'номер ошибки: ' + cast(error_number() as varchar(6));
	print 'сообщение: ' + error_message();
	print 'уровень: ' + cast(error_severity() as varchar(6));
	print 'метка: ' + cast(error_state() as varchar(8));
	print 'номер строки: ' + cast(error_line() as varchar(8));
	if error_procedure() is not null   
		print 'имя процедуры: ' + error_procedure(); 
	if @@trancount > 0 rollback tran; 
	return -1;
END CATCH;
END;
go

DECLARE @rc INT;
EXEC @rc = PAUDITORIUM_INSERTX 'ex6_lab13', @n = 'ex6_lab13', @c = 50, @t = 'ex6_lab13', @tn = 'ex6_lab13';
PRINT 'код ошибки=' + CAST(@rc AS VARCHAR(3));

SELECT * FROM AUDITORIUM;
SELECT * FROM AUDITORIUM_TYPE;

DELETE AUDITORIUM WHERE AUDITORIUM = 'ex6_lab13';
DELETE AUDITORIUM_TYPE WHERE AUDITORIUM_TYPE = 'ex6_lab13';

DROP PROCEDURE PAUDITORIUM_INSERTX;

-- 8. ==================================================================================
DROP PROCEDURE PRINT_REPORT;

GO
CREATE PROCEDURE PRINT_REPORT @f CHAR(10) = null, @p CHAR(10) = null AS
declare @faculty char(50), @pulpit char(10), @subject char(10), @cnt_teacher int;
declare @temp_fac char(50), @temp_pul char(10), @list varchar(100), 
		@DISCIPLINES char(12) = 'Дисциплины: ', @DISCIPLINES_NONE char(16) = 'Дисциплины: нет.';
BEGIN TRY
	if (@p is not null and not exists (select FACULTY from PULPIT where PULPIT = @p))
		raiserror('Ошибка в параметрах', 11, 1);
	declare @count int = 0;
	declare EX8 cursor local static 
			for select FACULTY.FACULTY, PULPIT.PULPIT, SUBJECT.SUBJECT, count(TEACHER.TEACHER)
				from FACULTY 
			    join PULPIT on FACULTY.FACULTY = PULPIT.FACULTY
				left join SUBJECT on PULPIT.PULPIT = SUBJECT.PULPIT
				left join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT
				where FACULTY.FACULTY = isnull(@f, FACULTY.FACULTY)
				and PULPIT.PULPIT = isnull(@p, PULPIT.PULPIT)
				group by FACULTY.FACULTY, PULPIT.PULPIT, SUBJECT.SUBJECT
				order by FACULTY, PULPIT, SUBJECT;
	open EX8;
	fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
	while @@FETCH_STATUS = 0
	begin 
		print 'Факультет ' + rtrim(@faculty) + ': ';
		set @temp_fac = @faculty;
		while (@faculty = @temp_fac)
		begin
			print char(9) + 'Кафедра ' + rtrim(@pulpit) + ': ';
			set @count += 1;
			print char(9) + char(9) + 'Количество преподавателей: ' + rtrim(@cnt_teacher) + '.';
			set @list = @DISCIPLINES;

			if(@subject is not null)
			begin
				if(@list = @DISCIPLINES)
					set @list += rtrim(@subject);
				else
					set @list += ', ' + rtrim(@subject);
			end;
			if (@subject is null) set @list = @DISCIPLINES_NONE;

			set @temp_pul = @pulpit;
			fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
			while (@pulpit = @temp_pul)
			begin
				if(@subject is not null)
				begin
					if(@list = @DISCIPLINES)
						set @list += rtrim(@subject);
					else
						set @list += ', ' + rtrim(@subject);
				end;
				fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
				if(@@FETCH_STATUS != 0) break;
			end;
			if(@list != @DISCIPLINES_NONE)
				set @list += '.';
			print char(9) + char(9) + @list;
			if(@@FETCH_STATUS != 0) break;
		end;
	end;
	close EX8;
	deallocate EX8;
	return @count;
END TRY
BEGIN CATCH
	print 'Номер ошибки: ' + convert(varchar, error_number());
	print 'Сообщение: ' + error_message();
	print 'Уровень: ' + convert(varchar, error_severity());
	print 'Метка: ' + convert(varchar, error_state());
	print 'Номер строки: ' + convert(varchar, error_line());
	if error_procedure() is not null
		print 'Имя процедуры: ' + error_procedure();
	return -1;
END CATCH;
GO

-- для всех факультетов и кафедр
DECLARE @full INT;
EXEC @full = PRINT_REPORT null, null;
SELECT @full;

-- для заданного факультета и кафедры
DECLARE @faculty_pulp INT;
EXEC @faculty_pulp = PRINT_REPORT 'ИДиП', 'ПП';
SELECT @faculty_pulp;

-- для только для заданного факультета
DECLARE @only_by_faculty INT;
EXEC @only_by_faculty = PRINT_REPORT 'ИТ', null;
SELECT @only_by_faculty;

-- определение факультета по кафедре
DECLARE @only_by_pulp INT;
EXEC @only_by_pulp = PRINT_REPORT null, 'ИСиТ';
SELECT @only_by_pulp;

-- ошибка в параметрах
DECLARE @error_param INT;
EXEC @error_param = PRINT_REPORT null, 'error';
SELECT @error_param;
