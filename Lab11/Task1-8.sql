USE DVR_UNIVER;

-- 1. ����������� ��������, �������-���� ������ ��������� �� ������� ����.
-- � ����� ������ ���� �������� ������� �������� (���� SUBJECT) 
-- �� ������� SUBJECT � ���� ������ ����� �������. 
-- ������������ ���������� ������� RTRIM.
DECLARE @subj nchar(20), @result nchar(300) = '';
DECLARE ShortSubjName CURSOR 
					FOR SELECT SUBJECT FROM SUBJECT;

OPEN ShortSubjName;
FETCH ShortSubjName INTO @subj;

PRINT '������� �������� ���������';
WHILE @@FETCH_STATUS = 0
	BEGIN
	 set @result = rtrim(@subj) + ',' + @result;
	 FETCH ShortSubjName INTO @subj;
	END;
PRINT @result;
CLOSE ShortSubjName;

-- 2. ����������� ��������, ��������������� ������� ����������� �������
-- �� ���������� �� ������� ���� ������ X_UNIVER.

-- CURSOR LOCAL
DECLARE Auditorium CURSOR LOCAL
		FOR SELECT AUDITORIUM, AUDITORIUM_CAPACITY FROM AUDITORIUM;
DECLARE @audit NVARCHAR(20), @capac INT;

OPEN Auditorium;
FETCH Auditorium INTO @audit, @capac;
PRINT '��������� �' + @audit + ' � ������������ ' + cast(@capac as VARCHAR(8));
GO

DECLARE @audit NVARCHAR(20), @capac INT;
FETCH Auditorium INTO @audit, @capac;
PRINT '��������� �' + @audit + ' � ������������ ' + cast(@capac as VARCHAR(8));
GO

-- CURSOR GLOBAL
DECLARE Auditorium CURSOR GLOBAL
		FOR SELECT AUDITORIUM, AUDITORIUM_CAPACITY FROM AUDITORIUM;
DECLARE @audit NVARCHAR(20), @capac INT;

OPEN Auditorium;
FETCH Auditorium INTO @audit, @capac;
PRINT '��������� �' + @audit + ' � ������������ ' + cast(@capac as VARCHAR(8));
GO

DECLARE @audit NVARCHAR(20), @capac INT;
FETCH Auditorium INTO @audit, @capac;
PRINT '��������� �' + @audit + ' � ������������ ' + cast(@capac as VARCHAR(8));
GO

-- 3. ����������� ��������, ��������������� ������� ����������� ��������
-- �� ������������ �� ������� ���� ������ X_UNIVER.

-- ��� ������������ �������� static �� dynamic
GO

DECLARE @subj NVARCHAR(20), @pulp NVARCHAR(20);
DECLARE SubjectCursor CURSOR LOCAL static
		FOR SELECT SUBJECT, PULPIT FROM dbo.SUBJECT WHERE PULPIT = '��';

OPEN SubjectCursor;
PRINT '���������� �����: ' + CAST(@@CURSOR_ROWS AS VARCHAR(6));

INSERT SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT)
	VALUES('SUBJ_LAB11', 'SUBJECT_LAB11', '��');

FETCH SubjectCursor INTO @subj, @pulp;
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @subj + '' + @pulp;
	FETCH SubjectCursor INTO @subj, @pulp;
END;
CLOSE SubjectCursor;

DELETE SUBJECT WHERE SUBJECT = 'SUBJ_LAB11';

GO

-- 4. ����������� ��������, ��������������� �������� ��������� 
-- � �������������� ������ ������� � ��������� SCROLL �� ������� ���� ������ X_UNIVER.
-- ������������ ��� ��������� �������� ����� � ��������� FETCH.
GO

DECLARE @subj NVARCHAR(20), @pulp NVARCHAR(20);
DECLARE SubjectCursor CURSOR LOCAL DYNAMIC SCROLL
		FOR SELECT SUBJECT, PULPIT
			FROM dbo.SUBJECT WHERE PULPIT = '����';

OPEN SubjectCursor;
FETCH LAST FROM SubjectCursor INTO @subj, @pulp;
PRINT '��������� ������: ' + @subj + '' + @pulp;
FETCH FIRST FROM SubjectCursor INTO @subj, @pulp;
PRINT '������ ������: ' + @subj + '' + @pulp;
FETCH NEXT FROM SubjectCursor INTO @subj, @pulp;
PRINT '��������� ����� ������ ������: ' + @subj + '' + @pulp;
FETCH RELATIVE 2 FROM SubjectCursor INTO @subj, @pulp;
PRINT '������ ������ �� �������: ' + @subj + '' + @pulp;
CLOSE SubjectCursor;

GO

-- 5. ������� ������, ��������������� ���������� ����������� CURRENT OF
-- � ������ WHERE � �������������� ���������� UPDATE � DELETE.
GO

INSERT PULPIT (PULPIT, PULPIT_NAME, FACULTY)
	VALUES('L11_EX5', 'L11_EX5', '����');

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
UPDATE dbo.SUBJECT SET PULPIT = '��' WHERE CURRENT OF SubjectCursor;
CLOSE SubjectCursor;


GO

-- 6. ����������� SELECT-������, � ������� �������� �� ������� PROGRESS
-- ��������� ������, ���������� ���������� � ���������, ���������� ������ ���� 4
-- (������������ ����������� ������ PROGRESS, STUDENT, GROUPS). 

INSERT PROGRESS (SUBJECT, IDSTUDENT,NOTE)
	VALUES ('��', 1000, 3),
		   ('��', 1001, 3),
		   ('��', 1002, 3),
		   ('��', 1003, 3),
		   ('��', 1004, 3),
		   ('��', 1005, 3),
		   ('��', 1006, 3);

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

-- ����������� SELECT-������, � ��-����� �������� � ������� PROGRESS
-- ��� �������� � ���������� ������� IDSTUDENT �������������� ������ 
-- (������������� �� �������).

INSERT PROGRESS (SUBJECT, IDSTUDENT,NOTE)
	VALUES ('��', 1007, 6);

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
DECLARE @temp_fac CHAR(10), @temp_pul CHAR(10), @list VARCHAR(100), @DISCIPLINES CHAR(12) = '����������: ', @DISCIPLINES_NONE CHAR(16) = '����������: ���.';

OPEN Ex8Cursor;
FETCH Ex8Cursor INTO @faculty, @pulpit, @subject, @cnt_teacher;
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT '��������� ' + (@faculty) + ': ';
	SET @temp_fac = @faculty;
	-- ���� �� �������� ����� ���������
	WHILE (@faculty = @temp_fac)
	BEGIN
		PRINT CHAR(9) + '������� ' + RTRIM(@pulpit) + ': ';
		PRINT CHAR(9) + CHAR(9) + '���������� ��������������: ' + RTRIM(@cnt_teacher) + '.';
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
		-- ���� �� �������� ����� �������
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