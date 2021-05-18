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
DECLARE SubjectCursor CURSOR LOCAL STATIC
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
