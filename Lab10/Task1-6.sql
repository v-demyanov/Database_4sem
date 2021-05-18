
-- 1.
USE DVR_UNIVER;

-- � ������� SSMS ���������� ��� �������, ������� ������� � �� UNIVER.
-- ����������, ����� �� ��� �������� �����������������, � ����� �������������������.
EXEC SP_HELPINDEX 'AUDITORIUM';
EXEC SP_HELPINDEX 'AUDITORIUM_TYPE';
EXEC SP_HELPINDEX 'FACULTY';
EXEC SP_HELPINDEX 'GROUPS';
EXEC SP_HELPINDEX 'PROFESSION';
EXEC SP_HELPINDEX 'PROGRESS';
EXEC SP_HELPINDEX 'PULPIT';
-- ������� ��������� ��������� �������. ��������� �� ������� (�� ����� 1000 �����).
USE tempdb;

CREATE TABLE #EX1_EXAMPLE
(
	COL1 INT IDENTITY(1,1),
	COL2 NVARCHAR(50)
);

DECLARE @i INT = 0;
WHILE @i < 100000
BEGIN
	INSERT #EX1_EXAMPLE(COL2)
		VALUES(CONCAT('example str #', CAST(@i AS VARCHAR(10))));
	SET @i = @i + 1;
END;

-- ����������� SELECT-������. �������� ���� ������� � ���������� ��� ���������. 
-- ������� ���������������� ������, ����������� ��������� SELECT-�������.
CHECKPOINT;  --�������� ��
DBCC DROPCLEANBUFFERS;  --�������� �������� ���
CREATE CLUSTERED INDEX #CL_INDEX_EX1 ON #EX1_EXAMPLE(COL1 ASC);

SELECT * FROM #EX1_EXAMPLE WHERE COL1 BETWEEN 1000 AND 3000 ORDER BY COL1;

DROP INDEX #CL_INDEX_EX1 ON #EX1_EXAMPLE;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

DROP TABLE #EX1_EXAMPLE;
DROP INDEX #CL_INDEX_EX1 ON #EX1_EXAMPLE;

-- 2. ������� ��������� ��������� �������.
-- ��������� �� ������� (10000 ����� ��� ������). 
-- ����������� SELECT-������. �������� ���� ������� � ���������� ��� ���������. 
-- ������� ������������������ ������������ ��������� ������. 
-- ������� ��������� ������ ����������.
CREATE TABLE #EX2_EXAMPLE
(
	TKEY INT,
	COL1 INT IDENTITY(1,1),
	COL2 NVARCHAR(50)
);

DECLARE @i INT = 0;
WHILE @i < 10000
BEGIN
	INSERT #EX2_EXAMPLE(TKEY, COL2)
		VALUES(FLOOR(30000*RAND()), CONCAT('example str #', CAST(@i AS VARCHAR(10))));
	SET @i = @i + 1;
END;

CREATE INDEX #NON_CL_INDEX_EX2 ON #EX2_EXAMPLE(TKEY, COL1);

SELECT * FROM #EX2_EXAMPLE WHERE (TKEY BETWEEN 2000 AND 6000) AND COL1 > 1000;
SELECT * FROM #EX2_EXAMPLE ORDER BY TKEY,COL1;
SELECT * FROM #EX2_EXAMPLE WHERE TKEY = 354 AND COL1 > 5; -- �������� ������ 

-- 3. ������� ��������� ��������� �������.
-- ��������� �� ������� (�� ����� 10000 �����). 
-- ����������� SELECT-������. �������� ���� ������� � ���������� ��� ���������. 
-- ������� ������������������ ������ ��������, ����������� ��������� SELECT-�������. 
CREATE TABLE #EX3_EXAMPLE
(
	TKEY INT,
	COL1 INT IDENTITY(1,1),
	COL2 NVARCHAR(50)
);

DECLARE @i INT = 0;
WHILE @i < 10000
BEGIN
	INSERT #EX3_EXAMPLE(TKEY, COL2)
		VALUES(FLOOR(30000*RAND()), CONCAT('example str #', CAST(@i AS VARCHAR(10))));
	SET @i = @i + 1;
END;

CREATE INDEX #NON_CL_INDEX_EX3 ON #EX3_EXAMPLE(TKEY) INCLUDE (COL1);

SELECT COL1 FROM #EX3_EXAMPLE WHERE TKEY > 3000;

-- 4. ������� � ��������� ��������� ��������� �������. 
-- ����������� SELECT-������, �������� ���� ������� � ���������� ��� ���������. 
-- ������� ������������������ ����������� ������, ����������� ��������� SELECT-�������.
CREATE TABLE #EX4_EXAMPLE
(
	TKEY INT,
	COL1 INT IDENTITY(1,1),
	COL2 NVARCHAR(50)
);

DECLARE @i INT = 0;
WHILE @i < 10000
BEGIN
	INSERT #EX4_EXAMPLE(TKEY, COL2)
		VALUES(FLOOR(30000*RAND()), CONCAT('example str #', CAST(@i AS VARCHAR(10))));
	SET @i = @i + 1;
END;


CREATE INDEX #INDEX_WHERE_EX4 ON #EX4_EXAMPLE(TKEY) WHERE TKEY >= 1500 AND TKEY < 5000;

SELECT TKEY FROM #EX4_EXAMPLE
WHERE TKEY >= 1500 AND TKEY < 5000;

SELECT TKEY FROM #EX4_EXAMPLE
WHERE TKEY BETWEEN 0 AND 1300;

SELECT TKEY FROM #EX4_EXAMPLE
WHERE TKEY >= 1600;

-- 5. ��������� ��������� ��������� �������. 
-- ������� ������������������ ������. ������� ������� ������������ �������. 
-- ����������� �������� �� T-SQL, ���������� �������� �������� � ������
-- ������������ ������� ���� 90%. ������� ������� ������������ �������. 
-- ��������� ��������� ������������� �������, ������� ������� ������������. 
-- ��������� ��������� ����������� ������� � ������� ������� ������������ �������.
CREATE TABLE #EX5_EXAMPLE
(
	TKEY INT,
	COL1 INT IDENTITY(1,1),
	COL2 NVARCHAR(50)
);

DECLARE @i INT = 0;
WHILE @i < 10000
BEGIN
	INSERT #EX5_EXAMPLE(TKEY, COL2)
		VALUES(FLOOR(30000*RAND()), CONCAT('example str #', CAST(@i AS VARCHAR(10))));
	SET @i = @i + 1;
END;

CREATE INDEX #INDEX_EX5 ON #EX5_EXAMPLE(TKEY);

INSERT top(1000000) #EX5_EXAMPLE(TKEY) select TKEY from #EX5_EXAMPLE;

SELECT name [������], avg_fragmentation_in_percent [������������ (%)]
        FROM sys.dm_db_index_physical_stats(DB_ID(N'tempdb'), 
        OBJECT_ID(N'#EX5_EXAMPLE'), NULL, NULL, NULL) ss
        JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id  
		WHERE name is not null;
		
ALTER INDEX #INDEX_EX5 ON #EX5_EXAMPLE REORGANIZE;

ALTER INDEX #INDEX_EX5 ON #EX5_EXAMPLE REBUILD WITH (ONLINE = OFF);

-- 6. ����������� ������, ��������������� ���������� ��������� FILLFACTOR
-- ��� �������� ������������������� �������.
CREATE TABLE #EX6_EXAMPLE
(
	TKEY INT,
	COL1 INT IDENTITY(1,1),
	COL2 NVARCHAR(50)
);

DECLARE @i INT = 0;
WHILE @i < 10000
BEGIN
	INSERT #EX6_EXAMPLE(TKEY, COL2)
		VALUES(FLOOR(30000*RAND()), CONCAT('example str #', CAST(@i AS VARCHAR(10))));
	SET @i = @i + 1;
END;

INSERT top(50)percent INTO #EX6_EXAMPLE(TKEY,COL2) select TKEY, COL2 from #EX6_EXAMPLE;

CREATE INDEX #INDEX_WITH_FILLF_EX6 ON #EX6_EXAMPLE(TKEY) WITH (FILLFACTOR = 65);

SELECT name [������], avg_fragmentation_in_percent [������������ (%)]
        FROM sys.dm_db_index_physical_stats(DB_ID(N'tempdb'), 
        OBJECT_ID(N'#EX6_EXAMPLE'), NULL, NULL, NULL) ss
        JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id  
		WHERE name is not null;


