USE DVR_UNIVER;

-- 1. ����������� �������� ��������� ��� �������-��� � ������ PSUBJECT
go
CREATE PROCEDURE PSUBJECT AS
BEGIN
	DECLARE @n INT = (SELECT COUNT(*) FROM SUBJECT);
	SELECT SUBJECT[���], SUBJECT_NAME[����������], PULPIT[�������] FROM SUBJECT;
	RETURN @n;
END;
go

DECLARE @str_count INT;
EXEC @str_count = PSUBJECT;
PRINT '���������� ����� ���������� � �������������� �����: ' + CAST(@str_count AS nvarchar(4));

-- DROP PROCEDURE PSUBJECT;


-- 2. �������� ��������� PSUBJECT, ��������� � ��-����� 1, ����� �������, ����� ��� ���������
-- ��� ��-������� � ������� @p � @c. �������� @p �������� �������, ����� ��� VARCHAR(20)
-- � �������� �� ��������� NULL. �������� @� �������� ��������, ����� ��� INT.
go
ALTER PROCEDURE PSUBJECT @p VARCHAR(20) = NULL, @c INT OUTPUT AS
BEGIN
	DECLARE @subj_count INT = (SELECT COUNT(*) FROM SUBJECT);
	SELECT SUBJECT[���], SUBJECT_NAME[����������], PULPIT[�������]
	FROM SUBJECT WHERE PULPIT = @p;
	SET @c = @@ROWCOUNT;
	RETURN @subj_count;
END;
go

DECLARE @subj_count_all INT = 0,
		@pulpit_key VARCHAR(20) = '����',
		@row_count INT = 0;
EXEC @subj_count_all = PSUBJECT @pulpit_key, @c = @row_count OUTPUT;
PRINT '���-�� ��������� �����: ' + cast(@subj_count_all AS VARCHAR(4));
PRINT '���-�� ��������� �������: ' + @pulpit_key + ' ' + CAST(@row_count AS VARCHAR(4));


-- 3. ������� ��������� ��������� ������� � ������ #SUBJECT. 
-- ������������ � ��� �������� ������� ������ ���������������
-- �������� ��������������� ������ ��������� PSUBJECT, ������������� � ����-��� 2. 
-- �������� ��������� PSUBJECT ����� �������, ����� ��� �� ��������� ��������� ���������.
-- �������� ����������� INSERT� EXECUTE � ��-�������������� ���������� PSUBJECT,
-- �������� ������ � ������� #SUBJECT.
go
ALTER PROCEDURE PSUBJECT @p VARCHAR(20) = NULL AS
BEGIN
	DECLARE @subj_count INT = (SELECT COUNT(*) FROM SUBJECT);
	SELECT SUBJECT[���], SUBJECT_NAME[����������], PULPIT[�������]
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

INSERT #SUBJECT EXEC PSUBJECT @p = '����';
SELECT * FROM #SUBJECT;

DROP TABLE #SUBJECT;

-- 4. ����������� ��������� � ������ PAUDITORI-UM_INSERT. 
-- ��������� ��������� ������ ������� ���������: @a, @n, @c � @t.
-- �������� @a ����� ��� CHAR(20), �������� @n ����� ��� VARCHAR(50),
-- �������� @c ����� ��� INT � �������� �� ��������� 0, �������� @t ����� ��� CHAR(10).
go
CREATE PROCEDURE PAUDITORIUM_INSERT @a CHAR(20), @n VARCHAR(50), @c INT = 0, @t CHAR(10) AS
BEGIN

BEGIN TRY
	insert into AUDITORIUM(AUDITORIUM, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY, AUDITORIUM_NAME)
		values(@a, @n, @c, @t);
	return 1;
END TRY
BEGIN CATCH
	print '����� ������: ' + cast(error_number() as varchar(6));
	print '���������: ' + error_message();
	print '�������: ' + cast(error_severity() as varchar(6));
	print '�����: ' + cast(error_state() as varchar(8));
	print '����� ������: ' + cast(error_line() as varchar(8));
	if error_procedure() is not null   
	print '��� ���������: ' + error_procedure();
	return -1;
END CATCH;

END;
go

DECLARE @rc INT;
EXEC @rc = PAUDITORIUM_INSERT @a = 'ex4_l13', @n = '��', @c = 50, @t = 'ex4_l13';
PRINT '��� ������: ' + CAST(@rc AS VARCHAR(4));

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
		raiserror('������', 11, 10);
	else
		open SUBJ_CURSOR;
		fetch SUBJ_CURSOR into @subj;
		print '������� �������� ���������: ';
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
	print '������ � ����������';
	if error_procedure() is not null
		print '��� ���������: ' + error_procedure();
	return @rc;
END CATCH;

END;
go

drop procedure SUBJECT_REPORT;

DECLARE @subj_count int;  
EXEC @subj_count = SUBJECT_REPORT @p ='����';  
PRINT '���������� ��������� � ������: ' + cast(@subj_count as varchar(4));

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
	print '����� ������: ' + cast(error_number() as varchar(6));
	print '���������: ' + error_message();
	print '�������: ' + cast(error_severity() as varchar(6));
	print '�����: ' + cast(error_state() as varchar(8));
	print '����� ������: ' + cast(error_line() as varchar(8));
	if error_procedure() is not null   
		print '��� ���������: ' + error_procedure(); 
	if @@trancount > 0 rollback tran; 
	return -1;
END CATCH;
END;
go

DECLARE @rc INT;
EXEC @rc = PAUDITORIUM_INSERTX 'ex6_lab13', @n = 'ex6_lab13', @c = 50, @t = 'ex6_lab13', @tn = 'ex6_lab13';
PRINT '��� ������=' + CAST(@rc AS VARCHAR(3));

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
		@DISCIPLINES char(12) = '����������: ', @DISCIPLINES_NONE char(16) = '����������: ���.';
BEGIN TRY
	if (@p is not null and not exists (select FACULTY from PULPIT where PULPIT = @p))
		raiserror('������ � ����������', 11, 1);
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
		print '��������� ' + rtrim(@faculty) + ': ';
		set @temp_fac = @faculty;
		while (@faculty = @temp_fac)
		begin
			print char(9) + '������� ' + rtrim(@pulpit) + ': ';
			set @count += 1;
			print char(9) + char(9) + '���������� ��������������: ' + rtrim(@cnt_teacher) + '.';
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
	print '����� ������: ' + convert(varchar, error_number());
	print '���������: ' + error_message();
	print '�������: ' + convert(varchar, error_severity());
	print '�����: ' + convert(varchar, error_state());
	print '����� ������: ' + convert(varchar, error_line());
	if error_procedure() is not null
		print '��� ���������: ' + error_procedure();
	return -1;
END CATCH;
GO

-- ��� ���� ����������� � ������
DECLARE @full INT;
EXEC @full = PRINT_REPORT null, null;
SELECT @full;

-- ��� ��������� ���������� � �������
DECLARE @faculty_pulp INT;
EXEC @faculty_pulp = PRINT_REPORT '����', '��';
SELECT @faculty_pulp;

-- ��� ������ ��� ��������� ����������
DECLARE @only_by_faculty INT;
EXEC @only_by_faculty = PRINT_REPORT '��', null;
SELECT @only_by_faculty;

-- ����������� ���������� �� �������
DECLARE @only_by_pulp INT;
EXEC @only_by_pulp = PRINT_REPORT null, '����';
SELECT @only_by_pulp;

-- ������ � ����������
DECLARE @error_param INT;
EXEC @error_param = PRINT_REPORT null, 'error';
SELECT @error_param;
