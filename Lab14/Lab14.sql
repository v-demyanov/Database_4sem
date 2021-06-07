USE DVR_UNIVER;

-- 1. ����������� ��������� ������� � ������ COUNT_STUDENTS,
-- ������� ��������� ���������� ���-������ �� ����������,
-- ��� �������� �������� ���������� ���� VARCHAR(20) � ������ @faculty. 
go
CREATE FUNCTION COUNT_STUDENTS(@faculty VARCHAR(20) = NULL) RETURNS INT AS
BEGIN
	declare @rc int = 0;
	set @rc = (select count(IDSTUDENT) from STUDENT
			   join GROUPS on STUDENT.IDGROUP = GROUPS.IDGROUP
			   join FACULTY on GROUPS.FACULTY = FACULTY.FACULTY
			   where FACULTY.FACULTY = @faculty);
	return @rc;
END;
go

DECLARE @faculty VARCHAR(20) = '����';
DECLARE @students_count INT = dbo.COUNT_STUDENTS(@faculty);
PRINT '���������� ��������� �� ���������� ' + @faculty + ': ' + CAST(@students_count AS VARCHAR(4));

DROP FUNCTION COUNT_STUDENTS;

-- ������ ��������� � ����� ������� � ������� ��������� ALTER � ���, 
-- ����� ������� ��������� ������ �������� @prof ���� VARCHAR(20),
-- ������������ ������������� ���������.
go
ALTER FUNCTION COUNT_STUDENTS(@faculty VARCHAR(20) = NULL, @prof VARCHAR(20) = NULL) RETURNS INT AS
BEGIN
	declare @rc int = 0;
	set @rc = (select count(IDSTUDENT) from STUDENT
			   join GROUPS on STUDENT.IDGROUP = GROUPS.IDGROUP
			   join FACULTY on GROUPS.FACULTY = FACULTY.FACULTY
			   where FACULTY.FACULTY = @faculty and GROUPS.PROFESSION = @prof);
	return @rc;
END;
go

DECLARE @faculty VARCHAR(20) = '����';
DECLARE @prof VARCHAR(20) = '1-47 01 01';
DECLARE @students_count INT = dbo.COUNT_STUDENTS(@faculty, @prof);
PRINT '���������� ��������� �� ���������� ' + @faculty + ' �� �������������� ' + @prof + ': ' + CAST(@students_count AS VARCHAR(4));


-- 2. ����������� ��������� ������� � ������ FSUBJECTS, ����������� �������� @p
-- ���� VARCHAR(20), �������� �������� ������ ��� ������� (������� SUBJECT.PULPIT). 
-- ������� ������ ���������� ������ ���� VARCHAR(300) � �������� ��������� � ������. 

go
CREATE FUNCTION FSUBJECTS(@p VARCHAR(20)) RETURNS VARCHAR(300) AS
BEGIN
	declare @subj varchar(10), @result varchar(100) = '';
	declare subj_cursor cursor local static for
				select SUBJECT from SUBJECT 
				where PULPIT = @p;
	open subj_cursor;
	fetch subj_cursor into @subj;
	while @@FETCH_STATUS = 0
	begin
		set @result = @result + RTRIM(@subj) + ', ';
		fetch subj_cursor into @subj;
	end;
	return @result
END;
go

SELECT PULPIT[�������], dbo.FSUBJECTS(PULPIT) [����������] FROM PULPIT;

-- 3.
go
CREATE FUNCTION FFACPUL(@faculty varchar(20) = NULL, @pulp varchar(20) = NULL) returns table AS
	return select FACULTY.FACULTY, PULPIT.PULPIT from FACULTY 
	left outer join PULPIT on FACULTY.FACULTY = PULPIT.FACULTY
    where FACULTY.FACULTY = isnull(@faculty, FACULTY.FACULTY) and
    PULPIT.PULPIT = isnull(@pulp, PULPIT.PULPIT);
go

SELECT * FROM dbo.FFACPUL(null, null);
SELECT * FROM dbo.FFACPUL('����', null);
SELECT * FROM dbo.FFACPUL(null, '��');
SELECT * FROM dbo.FFACPUL('����', '��');

-- 4. �� ������� ���� ������� ��������, ��������������� ��-����
-- ��������� ������� FCTEACHER. ������� �������-�� ���� ��������,
-- �������� ��� �������. ������� ������-���� ���������� ��������������
-- �� �������� ���������� �������. ���� �������� ����� NULL, �� ������������
-- ��-��� ���������� ��������������. 
go
CREATE FUNCTION FCTEACHER(@pulp varchar(20) = NULL) returns INT AS
BEGIN
	declare @rc int = 0;
	set @rc = (select count(TEACHER) from TEACHER
			  where PULPIT = isnull(@pulp, PULPIT));
    return @rc;
END;
go

SELECT PULPIT[�������], dbo.FCTEACHER(PULPIT)[���������� ��������������]
FROM PULPIT;

SELECT dbo.FCTEACHER(NULL)[����� ��������������];

-- 6. ==========================================================================

-- ����������� ������ �� ����������
go
CREATE FUNCTION COUNT_PULPITS(@faculty VARCHAR(20) = NULL) RETURNS INT AS
BEGIN
	declare @rc int = 0;
	set @rc = (select count(PULPIT) from PULPIT where FACULTY = @faculty);
	return @rc;
END;
go

-- ���������� ����� �� ����������
go
CREATE FUNCTION COUNT_GROUPS(@faculty VARCHAR(20) = NULL) RETURNS INT AS
BEGIN
	declare @rc int = 0;
	set @rc = (select count(IDGROUP) from GROUPS where FACULTY = @faculty);
	return @rc;
END;
go

-- ���������� �������������� �� ����������
go
CREATE FUNCTION COUNT_PROFESSIONS(@faculty VARCHAR(20) = NULL) RETURNS INT AS
BEGIN
	declare @rc int = 0;
	set @rc = (select count(PROFESSION) from PROFESSION where FACULTY = @faculty);
	return @rc;
END;
go

go
create function FACULTY_REPORT(@c int) returns @fr table
	            ([���������] varchar(50), [���������� ������] int, [���������� �����] int, 
				[���������� ���������] int, [���������� ��������������] int) as
begin 
	declare cc CURSOR static for 
		select FACULTY from FACULTY 
		where dbo.COUNT_STUDENTS(FACULTY, default) > @c; 
	declare @f varchar(30);
	open cc;  
	fetch cc into @f;
	while @@fetch_status = 0
	begin
		insert @fr values(@f, dbo.COUNT_PULPITS(@f), dbo.COUNT_GROUPS(@f),
						 dbo.COUNT_STUDENTS(@f, default), dbo.COUNT_PROFESSIONS(@f)); 
		fetch cc into @f;  
	end;   
	return;
end;
go

SELECT * FROM dbo.FACULTY_REPORT(0);

DROP FUNCTION FACULTY_REPORT;

-- 7. ====================================================================================
DROP PROCEDURE PRINT_REPORTX;

select distinct facpul_table.FACULTY, facpul_table.PULPIT [�������],
	   dbo.FSUBJECTS(facpul_table.PULPIT) [����������],
	   dbo.FCTEACHER(facpul_table.PULPIT) [���-�� ��������������]
	   from dbo.FFACPUL('����', null) facpul_table
	   order by FACULTY;


GO
CREATE PROCEDURE PRINT_REPORTX @f CHAR(10) = null, @p CHAR(10) = null AS
declare @faculty char(50), @pulpit char(10), @subject char(10), @cnt_teacher int;
declare @temp_fac char(50), @temp_pul char(10), @list varchar(100), 
		@DISCIPLINES char(12) = '����������: ', @DISCIPLINES_NONE char(16) = '����������: ���.';
BEGIN TRY
	if (@p is not null and not exists (select FACULTY from PULPIT where PULPIT = @p))
		raiserror('������ � ����������', 11, 1);
	declare @count int = 0;
	declare EX8 cursor local static 
			for select distinct facpul_table.FACULTY, facpul_table.PULPIT [�������],
				dbo.FSUBJECTS(facpul_table.PULPIT) [����������],
				dbo.FCTEACHER(facpul_table.PULPIT) [���-�� ��������������]
				from dbo.FFACPUL(@f, @p) facpul_table
				order by FACULTY;
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

			if(@subject is not null)
				set @list = @DISCIPLINES + @subject;
			if (@subject is null) set @list = @DISCIPLINES_NONE;

			set @temp_pul = @pulpit;
			fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
			while (@pulpit = @temp_pul)
			begin
				if(@subject is not null)
					set @list = @DISCIPLINES + @subject;
				fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
				if(@@FETCH_STATUS != 0) break;
			end;
			
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
EXEC @full = PRINT_REPORTX null, null;
SELECT @full;

-- ��� ��������� ���������� � �������
DECLARE @faculty_pulp INT;
EXEC @faculty_pulp = PRINT_REPORTX '����', '��';
SELECT @faculty_pulp;

-- ��� ������ ��� ��������� ����������
DECLARE @only_by_faculty INT;
EXEC @only_by_faculty = PRINT_REPORTX '��', null;
SELECT @only_by_faculty;

-- ����������� ���������� �� �������
DECLARE @only_by_pulp INT;
EXEC @only_by_pulp = PRINT_REPORTX null, '����';
SELECT @only_by_pulp;

-- ������ � ����������
DECLARE @error_param INT;
EXEC @error_param = PRINT_REPORTX null, 'error';
SELECT @error_param;

