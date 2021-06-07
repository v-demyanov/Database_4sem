USE DVR_MyBase_Test;

-- хранимая процедура без параметров
go
CREATE PROCEDURE PSUBJECT AS
BEGIN
	DECLARE @n INT = (SELECT COUNT(*) FROM TEACHER);
	SELECT * FROM SUBJECT;
	RETURN @n;
END;
go

DECLARE @str_count INT;
EXEC @str_count = PSUBJECT;
PRINT 'Количество строк выведенных в результирующий набор: ' + CAST(@str_count AS nvarchar(4));

-- хранимая процедура с входными и выходными параметрами
go
CREATE PROCEDURE PGROUP @spec VARCHAR(20) = NULL, @c INT OUTPUT AS
BEGIN
	DECLARE @groups_count INT = (SELECT COUNT(*) FROM SUBJECT);
	SELECT *
	FROM GROUPS WHERE SPECIALTY = @spec;
	SET @c = @@ROWCOUNT;
	RETURN @groups_count;
END;
go

DECLARE @groups_count_all INT = 0,
		@spec_key VARCHAR(20) = 'ПОИТ',
		@row_count INT = 0;
EXEC @groups_count_all = PGROUP @spec_key, @c = @row_count OUTPUT;
PRINT 'Кол-во групп всего: ' + cast(@groups_count_all AS VARCHAR(4));
PRINT 'Кол-во групп со специальностью ' + @spec_key + ': ' + CAST(@row_count AS VARCHAR(4));

-- хранимая процедура как источник для insert
go
ALTER PROCEDURE PGROUP @spec VARCHAR(20) = NULL AS
BEGIN
	DECLARE @groups_count INT = (SELECT COUNT(*) FROM SUBJECT);
	SELECT *
	FROM GROUPS WHERE SPECIALTY = @spec;
	RETURN @groups_count;
END;
go

CREATE TABLE #GROUPS
(
	GROUP_NUMBER INT,
	SPECIALTY NVARCHAR(50),
	DEPARTMENT NVARCHAR(50),
	STUDENT_NUMBERS INT
);

INSERT #GROUPS EXEC PGROUP @spec = 'ПОИТ';
SELECT * FROM #GROUPS;
