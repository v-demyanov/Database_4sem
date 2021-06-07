USE DVR_MyBase_Test;

-- скалярная функция
go
CREATE FUNCTION COUNT_GROUPS(@spec VARCHAR(20) = NULL) RETURNS INT AS
BEGIN
	declare @rc int = 0;
	set @rc = (select count(*) from GROUPS
			   where SPECIALTY = @spec);
	return @rc;
END;
go

DECLARE @spec VARCHAR(20) = 'ПОИТ';
DECLARE @groups_count INT = dbo.COUNT_GROUPS(@spec);
PRINT 'Количество групп со специальностью ' + @spec + ': ' + CAST(@groups_count AS VARCHAR(4));

-- табличная функция
go
CREATE FUNCTION FGROUPS() returns table AS
	return select * FROM GROUPS;
go

SELECT * FROM dbo.FGROUPS();
