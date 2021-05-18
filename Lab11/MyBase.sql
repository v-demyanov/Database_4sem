USE DVR_MyBase_Test;

-- 1.
DECLARE @subj nchar(20), @result nchar(300) = '';
DECLARE SubjName CURSOR FOR SELECT SUBJECT FROM SUBJECT;

OPEN SubjName;
FETCH SubjName INTO @subj;

PRINT 'Краткие названия предметов';
WHILE @@FETCH_STATUS = 0
	BEGIN
	 set @result = rtrim(@subj) + ',' + @result;
	 FETCH SubjName INTO @subj;
	END;
PRINT @result;
CLOSE SubjName;

-- 2. LOCAL
DECLARE GroupsCursor CURSOR LOCAL
		FOR SELECT GROUP_NUMBER, STUDENT_NUMBERS FROM GROUPS;
DECLARE @group NVARCHAR(20), @capac INT;

OPEN GroupsCursor;
FETCH GroupsCursor INTO @group, @capac;
PRINT 'Группа №' + @group + ' количество человек в группе ' + cast(@capac as VARCHAR(8));
GO

DECLARE @group NVARCHAR(20), @capac INT;
FETCH GroupsCursor INTO @group, @capac;
PRINT 'Группа №' + @group + ' количество человек в группе ' + cast(@capac as VARCHAR(8));
GO

-- 3. GLOBAL
DECLARE GroupsCursor CURSOR GLOBAL
		FOR SELECT GROUP_NUMBER, STUDENT_NUMBERS FROM GROUPS;
DECLARE @group NVARCHAR(20), @capac INT;

OPEN GroupsCursor;
FETCH GroupsCursor INTO @group, @capac;
PRINT 'Группа №' + @group + ' количество человек в группе ' + cast(@capac as VARCHAR(8));
GO

DECLARE @group NVARCHAR(20), @capac INT;
FETCH GroupsCursor INTO @group, @capac;
PRINT 'Группа №' + @group + ' количество человек в группе ' + cast(@capac as VARCHAR(8));
GO

-- 4. STATIC DYNAMIC

GO

DECLARE @subj NVARCHAR(20), @pulp NVARCHAR(20);
DECLARE SubjectCursor CURSOR LOCAL DYNAMIC
		FOR SELECT SUBJECT FROM dbo.SUBJECT;

OPEN SubjectCursor;
PRINT 'Количество строк: ' + CAST(@@CURSOR_ROWS AS VARCHAR(6));

INSERT SUBJECT (SUBJECT)
	VALUES('STAT_DYNAM');

FETCH SubjectCursor INTO @subj;
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @subj;
	FETCH SubjectCursor INTO @subj;
END;
CLOSE SubjectCursor;

DELETE SUBJECT WHERE SUBJECT = 'STAT_DYNAM';

GO

