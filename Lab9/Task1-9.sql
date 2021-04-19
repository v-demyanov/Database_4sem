USE DVR_UNIVER;


-- 1. ����������� T-SQL-������, � �������: 
-- 1) �������� ���������� ���� char, varchar, datetime,
-- time, int, smallint, tinint, numeric(12, 5); 
-- 2) ������ ��� ���������� ������������������� � ��������� ����������;
-- 3) ��������� ������������ �������� ��������� ���� ���������� � ������� ��������� SET,
-- ����� �� ���� ���������� ��������� ��������, ���������� � ���������� ������� SELECT; 
-- 4) ���� �� ���������� �������� ��� ������������� � �� ����������� �� ��������,
-- ���������� ���������� ��������� ��������� �������� � ������� ��������� SELECT; 
-- 5) �������� ����� �������� ���������� ������� � ������� ��������� SELECT,
-- �������� ������ �������� ���������� ����������� � ������� ��������� PRINT.

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

PRINT '������� ����� ' + CAST(@tvar AS VARCHAR(10));
PRINT '���������� ���������: ' + cast(@ivar as varchar(10));
PRINT '���� �������� �������� ��������: ' + cast(@dtvar as varchar(10));
SELECT @tivar AS '��������� � ��� ������������';

-- 2. ����������� ������, � ������� ������������ ����� ����������� ���������.
-- ����� ����� ����������� ��������� 200, �� ������� ���������� ���������,
-- ������� ����������� ���������, ���������� ���������, ����������� ������� ������ �������,
-- � ������� ����� ���������. ����� ����� ����������� ��������� ������ 200, �� �������
-- ��������� � ������� ����� �����������.

DECLARE @y1 INT = (select sum(AUDITORIUM_CAPACITY) from AUDITORIUM),
@y2 int, @y3 numeric(8,3), @y4 int, @y5 numeric(8,3)
IF @y1 > 200
BEGIN
	select @y2 = (select count(*) from AUDITORIUM),
		   @y3 = (select cast(avg(AUDITORIUM_CAPACITY) as numeric(8,3)) from AUDITORIUM)
	set @y4 = (select count(*) from AUDITORIUM where AUDITORIUM_CAPACITY < @y3)
	set @y5 = (@y4 * 100) / @y2
	select @y1 '������ ���������������', @y2 '���������� ���������',
		   @y3 '������� ���������������', @y4 '���-�� � ������������ ������ �������',
		   @y5 '������� ���������, ����������� ������� ������ �������'
END
ELSE IF @y1 < 200 PRINT '����� ���������������: ' + CAST(@y1 AS VARCHAR(10));
ELSE PRINT '����� ��������������� ����� 200';

SELECT * FROM AUDITORIUM;

-- 3.	����������� T-SQL-������, ������� ������� �� ������ ���������� ����������:
PRINT '@@ROWCOUNT (����� ������������ �����): ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
PRINT '@@VERSION (������ SQL Server): ' + CAST(@@VERSION AS NVARCHAR(300));
PRINT '@@SPID (���������� ��������� ������������� ��������,' +
		'����������� �������� �������� �����������): ' + CAST(@@SPID AS NVARCHAR(300));
PRINT '@@ERROR (��� ��������� ������): ' + CAST(@@ERROR AS NVARCHAR(300));
PRINT '@@SERVERNAME (��� �������): ' + CAST(@@SERVERNAME AS NVARCHAR(300));
PRINT '@@TRANCOUNT (���������� ������� ����������� ����������): ' + CAST(@@TRANCOUNT AS NVARCHAR(300));
PRINT '@@FETCH_STATUS (�������� ���������� ���������� ����� ��������������� ������): ' + CAST(@@FETCH_STATUS AS NVARCHAR(300));
PRINT '@@NESTLEVEL (������� ����������� ������� ���������): ' + CAST(@@NESTLEVEL AS NVARCHAR(300));

-- 4.

--	   | sin^2(t), t > x
-- z = | 4 * (t + x), t < x
--	   | 1 - e^(x-2), t = x

DECLARE @t int = 1, @z float, @x int = 5;
IF (@t > @x) SET @z = POWER(SIN(@t), 2)
ELSE IF (@t < @x) SET @z = 4 * (@t + @x)
ELSE SET @z = 1 - EXP(@x - 2);

PRINT 'z= ' + CAST(@z AS VARCHAR(10));
 
-- �������������� ������� ��� �������� � �����������
-- (��������, �������� ������� ���������� � �������� �. �.)

DECLARE @data4b NVARCHAR(50);
DECLARE @result4b NVARCHAR(50);
SET @data4b = '�������� ��������� ����������';

PRINT '������ ���: ' + @data4b;

SET @result4b = SUBSTRING(@data4b, 1, CHARINDEX(' ', @data4b)) +
				SUBSTRING(@data4b, CHARINDEX(' ', @data4b) + 1, 1) + '.' +
				SUBSTRING(@data4b, CHARINDEX(' ', @data4b, CHARINDEX(' ', @data4b) + 1) + 1, 1) + '.';

PRINT '����������� ���: ' + @result4b;

-- ����� ���������, � ������� ���� �������� � ��������� ������, � ����������� �� ��������
DECLARE @month NCHAR(2) = MONTH(DATEADD(MONTH, 1, GETDATE()));

SELECT IDSTUDENT, IDGROUP, NAME, BDAY, DATEDIFF(YEAR, BDAY, GETDATE()) AS AGE
FROM STUDENT WHERE MONTH(BDAY) = @month;

-- ����� ��� ������, � ������� �������� ��������� ������ ������� ������� �� ����
DECLARE @group_number INT = 4;

SELECT TOP(1) DATENAME(WEEKDAY, PDATE) AS "WEEKDAY"
FROM PROGRESS
JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON STUDENT.IDGROUP = GROUPS.IDGROUP
WHERE GROUPS.IDGROUP =  @group_number;

-- 5. ������������������ ����������� IF� ELSE �� ������� ������� ������ ������ ���� ������ �_UNIVER
USE DVR_MyBase_Test;

DECLARE @x1 INT = (select sum(HOURS_NUMBERS) from CURRICULUM),
@x2 int, @x3 numeric(8,3), @x4 int, @x5 numeric(8,3)
IF @x1 < 0 PRINT '������: ���������� ����� �� ����� ���� �������������' + '(' + CAST(@x1 AS VARCHAR(10)) + ')'
ELSE IF @x1 < 450
BEGIN
	select @x2 = (select count(*) from CURRICULUM),
		   @x3 = (select cast(avg(HOURS_NUMBERS) as numeric(8,3)) from CURRICULUM)
	select @x1 '����� ���������� �����', @x2 '���������� ������',
		   @x3 '������� ���������� �����'
END
ELSE PRINT '����� ���������� �����: ' + CAST(@x1 AS VARCHAR(10));

-- 6. ����������� ��������, � ������� � ������� CASE ������������� ������,
-- ���������� ���������� ���������� ���������� ��� ����� ���������.
USE DVR_UNIVER;

DECLARE @faculty_name NVARCHAR(10) = '����';

SELECT CASE
	   when NOTE BETWEEN 1 AND 3 then '�� ����'
	   when NOTE BETWEEN 3 AND 6 then '�����������������'
	   when NOTE BETWEEN 6 AND 8 THEN '������'
	   when NOTE BETWEEN 8 AND 10 THEN '�������'
	   else '������'
	   end ������, count(*) [���������� ���������]
FROM PROGRESS
JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON STUDENT.IDGROUP = GROUPS.IDGROUP
WHERE FACULTY = @faculty_name
GROUP BY CASE
	   when NOTE BETWEEN 1 AND 3 then '�� ����'
	   when NOTE BETWEEN 3 AND 6 then '�����������������'
	   when NOTE BETWEEN 6 AND 8 THEN '������'
	   when NOTE BETWEEN 8 AND 10 THEN '�������'
	   else '������'
	   end;

-- 7. ������� ��������� ��������� ������� �� ���� �������� � 10 �����,
-- ��������� �� � ������� ����������. ������������ �������� WHILE.

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

-- 8. ����������� ������, ��������������� ������������� ��������� RETURN.
DECLARE @y INT = 0;

WHILE @y < 10
BEGIN
	if @y = 5 return;
	else begin
		print @y;
		set @y = @y + 1;
	end
END;

-- 9. ����������� �������� � ��������, � ������� ������������ ��� ��������� ������ ����� TRY � CATCH.
-- ��������� ������� ERROR_NUMBER (��� ��������� ������), ERROR_ES-SAGE (��������� �� ������),
-- ERROR_LINE (��� ��������� ������), ERROR_PROCEDURE (��� ��������� ��� NULL),
-- ERROR_SEVERITY (������� ����������� ������), ERROR_ STATE (����� ������).
-- ���������������� ���������.

BEGIN TRY
	DECLARE @a INT = 3;
	DECLARE @b NVARCHAR = 'TEST';
	DECLARE @result INT;
	SET @result = @a / @b;
END TRY
BEGIN CATCH 
	print '��� ��������� ������: ' + CAST(ERROR_NUMBER() AS VARCHAR(50))
	print '��������� �� ������: ' + CAST(ERROR_MESSAGE() AS VARCHAR(50))
	print '����� ������ ��������� ������: ' + CAST(ERROR_LINE() AS VARCHAR(50))
	print '��� ��������� ��� NULL: ' + CAST(ERROR_PROCEDURE() AS VARCHAR(50))
	print '������� ����������� ������: ' + CAST(ERROR_SEVERITY() AS VARCHAR(50))
	print '����� ������: ' + CAST(ERROR_STATE() AS VARCHAR(50))
END CATCH;

