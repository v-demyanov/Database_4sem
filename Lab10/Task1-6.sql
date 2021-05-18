
-- 1.
USE DVR_UNIVER;

-- С помощью SSMS определить все индексы, которые имеются в БД UNIVER.
-- Определить, какие из них являются кластеризованными, а какие некластеризованными.
EXEC SP_HELPINDEX 'AUDITORIUM';
EXEC SP_HELPINDEX 'AUDITORIUM_TYPE';
EXEC SP_HELPINDEX 'FACULTY';
EXEC SP_HELPINDEX 'GROUPS';
EXEC SP_HELPINDEX 'PROFESSION';
EXEC SP_HELPINDEX 'PROGRESS';
EXEC SP_HELPINDEX 'PULPIT';
-- Создать временную локальную таблицу. Заполнить ее данными (не менее 1000 строк).
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

-- Разработать SELECT-запрос. Получить план запроса и определить его стоимость. 
-- Создать кластеризованный индекс, уменьшающий стоимость SELECT-запроса.
CHECKPOINT;  --фиксация БД
DBCC DROPCLEANBUFFERS;  --очистить буферный кэш
CREATE CLUSTERED INDEX #CL_INDEX_EX1 ON #EX1_EXAMPLE(COL1 ASC);

SELECT * FROM #EX1_EXAMPLE WHERE COL1 BETWEEN 1000 AND 3000 ORDER BY COL1;

DROP INDEX #CL_INDEX_EX1 ON #EX1_EXAMPLE;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

DROP TABLE #EX1_EXAMPLE;
DROP INDEX #CL_INDEX_EX1 ON #EX1_EXAMPLE;

-- 2. Создать временную локальную таблицу.
-- Заполнить ее данными (10000 строк или больше). 
-- Разработать SELECT-запрос. Получить план запроса и определить его стоимость. 
-- Создать некластеризованный неуникальный составной индекс. 
-- Оценить процедуры поиска информации.
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
SELECT * FROM #EX2_EXAMPLE WHERE TKEY = 354 AND COL1 > 5; -- применит индекс 

-- 3. Создать временную локальную таблицу.
-- Заполнить ее данными (не менее 10000 строк). 
-- Разработать SELECT-запрос. Получить план запроса и определить его стоимость. 
-- Создать некластеризованный индекс покрытия, уменьшающий стоимость SELECT-запроса. 
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

-- 4. Создать и заполнить временную локальную таблицу. 
-- Разработать SELECT-запрос, получить план запроса и определить его стоимость. 
-- Создать некластеризованный фильтруемый индекс, уменьшающий стоимость SELECT-запроса.
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

-- 5. Заполнить временную локальную таблицу. 
-- Создать некластеризованный индекс. Оценить уровень фрагментации индекса. 
-- Разработать сценарий на T-SQL, выполнение которого приводит к уровню
-- фрагментации индекса выше 90%. Оценить уровень фрагментации индекса. 
-- Выполнить процедуру реорганизации индекса, оценить уровень фрагментации. 
-- Выполнить процедуру перестройки индекса и оценить уровень фрагментации индекса.
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

SELECT name [Индекс], avg_fragmentation_in_percent [Фрагментация (%)]
        FROM sys.dm_db_index_physical_stats(DB_ID(N'tempdb'), 
        OBJECT_ID(N'#EX5_EXAMPLE'), NULL, NULL, NULL) ss
        JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id  
		WHERE name is not null;
		
ALTER INDEX #INDEX_EX5 ON #EX5_EXAMPLE REORGANIZE;

ALTER INDEX #INDEX_EX5 ON #EX5_EXAMPLE REBUILD WITH (ONLINE = OFF);

-- 6. Разработать пример, демонстрирующий применение параметра FILLFACTOR
-- при создании некластеризованного индекса.
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

SELECT name [Индекс], avg_fragmentation_in_percent [Фрагментация (%)]
        FROM sys.dm_db_index_physical_stats(DB_ID(N'tempdb'), 
        OBJECT_ID(N'#EX6_EXAMPLE'), NULL, NULL, NULL) ss
        JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id  
		WHERE name is not null;


