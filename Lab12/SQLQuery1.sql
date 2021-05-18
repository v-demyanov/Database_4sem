
-- 1. Разработать сценарий, демон-стрирующий работу в режиме неявной транзакции.
-- Проанализировать пример, приведенный справа, в котором создается таблица Х,
-- и создать сценарий для другой таблицы.
SET NOCOUNT ON 

IF EXISTS (select * from SYS.OBJECTS
			where OBJECT_ID = object_id(N'DBO.NUMBERS'))
DROP TABLE NUMBERS;

DECLARE @min_num INT,
		@i INT = 0,
		@flag CHAR = 'c';

SET IMPLICIT_TRANSACTIONS ON
CREATE TABLE NUMBERS(NUM INT);
	while @i < 10
	begin
		insert NUMBERS values(floor(100*rand()));
		set @i = @i + 1;
	end;

	SET @min_num = (select min(num) from NUMBERS);
	print 'минимальный элемент в таблице NUMBERS: ' + cast(@min_num as varchar(2));

	if @flag = 'c' commit;
	else rollback;
SET IMPLICIT_TRANSACTIONS OFF;

SELECT * FROM NUMBERS;

IF EXISTS (select * from SYS.OBJECTS
			where OBJECT_ID = object_id(N'DBO.NUMBERS'))
PRINT 'таблица NUMBERS есть';
ELSE PRINT 'таблицы NUMBERS нет';

-- 2. Разработать сценарий, демонстрирующий свойство атомарности явной транзакции на примере базы данных X_UNIVER. 
-- В блоке CATCH предусмотреть выдачу соответствующих сообщений об ошибках. 
-- Опробовать работу сценария при использовании различных операторов модификации таблиц.

USE DVR_UNIVER;

BEGIN TRY
	begin tran
	delete STUDENT where NAME = 'lab12_ex2'; 
	insert STUDENT (IDGROUP, NAME, BDAY)
		values (2, 'lab12_ex2', GETDATE());
	update STUDENT set NAME = 'lab12_ex2_updated'
			where NAME = 10; -- ошибка
	commit tran;
END TRY
BEGIN CATCH
	print 'ошибка: неизвестная ошибка ' + cast(error_number() as varchar(5)) + error_message();
	if @@trancount > 0 rollback tran;
END CATCH;

SELECT * FROM STUDENT;

-- 3. Разработать сценарий, демонстрирующий применение оператора SAVE TRAN
-- на примере базы данных X_UNIVER. 
-- В блоке CATCH предусмотреть выдачу соответствующих сообщений об ошибках. 
-- Опробовать работу сценария при использовании различных контрольных точек
-- и различных операторов модификации таблиц.

DECLARE @point VARCHAR(32);
BEGIN TRY
	begin tran
	delete STUDENT where NAME = 'lab12_ex3'; 
	set @point = 'p1'; save tran @point;
	insert STUDENT (IDGROUP, NAME, BDAY)
		values (2, 'lab12_ex3', GETDATE());
	set @point = 'p2'; save tran @point;
	delete STUDENT where NAME = 'lab12_ex3_1'; 
	insert STUDENT (IDGROUP, NAME, BDAY)
		values (2, 'lab12_ex3_1', GETDATE());
	update STUDENT set NAME = 'lab12_ex2_updated'
			where NAME = 10; -- ошибка
	commit tran;
END TRY
BEGIN CATCH
	print 'ошибка: неизвестная ошибка ' + cast(error_number() as varchar(5)) + ' ' + error_message();
	if @@trancount > 0 
		begin
		  print 'контрольная точка: ' + @point;
		  rollback tran @point;
		  commit tran;
		end;
END CATCH;

-- 4. Разработать два сценария A и B на примере базы данных X_UNIVER. 
-- Сценарий A представляет собой явную транзакцию с уровнем
-- изолированности READ UNCOMMITED, сценарий B – явную транзакцию 
-- с уровнем изолированности READ COM-MITED (по умолчанию). 
-- Сценарий A должен демон-стрировать, что уровень READ UNCOMMITED
-- допускает не-подтвержденное, неповторяю-щееся и фантомное чтение. 

-- для демонстрации
INSERT PULPIT VALUES ('L12_EX4', 'L12_EX4', 'ИДиП');

DELETE PULPIT WHERE PULPIT = 'L12_EX4';
DELETE FACULTY WHERE FACULTY = 'L12_EX4';

--------------------------------------------------------------
------A---------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION
-----t1---------
SELECT @@SPID, 'insert FACULTY' 'Тест', *
	FROM FACULTY WHERE FACULTY = 'ИТ';
SELECT @@SPID, 'update PULPIT' 'Тест', *
	FROM PULPIT WHERE FACULTY = 'ИТ';
COMMIT;

-----t2---------
-----B----------

BEGIN TRANSACTION
SELECT @@SPID 
INSERT FACULTY VALUES ('L12_EX4','L12_EX4');
UPDATE PULPIT SET FACULTY = 'ИТ' WHERE PULPIT = 'L12_EX4'

-----t1----------
-----t2----------

ROLLBACK;
SELECT * FROM FACULTY;
SELECT * FROM PULPIT;

-- 5. Разработать два сценария A и B на примере базы данных X_UNIVER. 
-- Сценарии A и В представля-ют собой явные транзакции с уровнем изолированности READ COMMITED. 
-- Сценарий A должен демон-стрировать, что уровень READ COMMITED не допускает не-подтвержденного
-- чтения, но при этом возможно неповторя-ющееся и фантомное чтение.

-- для демонстрации
INSERT PULPIT VALUES ('L12_EX5', 'L12_EX5', 'ИДиП');

DELETE PULPIT WHERE PULPIT = 'L12_EX5';

-----A--------
SELECT * FROM PULPIT;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
SELECT count(*) FROM PULPIT
WHERE FACULTY = 'ИТ';

-----t1-------
-----t2-------

SELECT 'update PULPIT' 'результат', count(*) 
FROM PULPIT WHERE FACULTY = 'ИТ';
COMMIT;
------B----

BEGIN TRANSACTION

------t1-----

UPDATE PULPIT SET FACULTY = 'ИТ' WHERE PULPIT = 'L12_EX5';
COMMIT;

-- 6. Разработать два сценария A и B на примере базы данных X_UNIVER. 
-- Сценарий A представляет со-бой явную транзакцию с уров-нем изолированности RE-PEATABLE READ.
-- Сценарий B – явную транзакцию с уровнем изолированности READ COM-MITED. 
-- Сценарий A должен демон-стрировать, что уровень REAPETABLE READ не допус-кает
-- неподтвержденного чтения и неповторяющегося чтения, но при этом возможно фантомное чтение. 

-- для демонстрации
DELETE PULPIT WHERE PULPIT = 'L12_EX6';

-- A ---
set transaction isolation level  REPEATABLE READ 
begin transaction 
select PULPIT from PULPIT where FACULTY = 'ИДиП';
-------------------------- t1 ------------------ 
-------------------------- t2 -----------------
select  case
when PULPIT = 'ИДиП' then 'insert  PULPIT'  else ' ' 
end 'результат', PULPIT from PULPIT  where FACULTY = 'ИДиП';
commit; 

--- B ---	
begin transaction 	  
-------------------------- t1 --------------------
insert PULPIT values ('L12_EX6', 'L12_EX6', 'ИДиП');
commit; 


-- 7. Разработать два сценария A и B на примере базы данных X_UNIVER. 
-- Сценарий A представляет собой явную транзакцию с уров-нем изолированности SERIALIZABLE. 
-- Сценарий B – явную транзакцию с уровнем изолированно-сти READ COMMITED.
-- Сценарий A должен демонстрировать отсутствие фантомного, неподтвержденного и неповторяющегося чтения.

-- для демонстрации
INSERT FACULTY VALUES ('L12_EX7', 'L12_EX7');
INSERT PULPIT VALUES ('L12_EX7', 'L12_EX7', 'L12_EX7');

SELECT * FROM FACULTY;
SELECT * FROM PULPIT;

-- A --
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION
DELETE PULPIT WHERE FACULTY = 'L12_EX7';
INSERT PULPIT VALUES ('L12_EX7', 'L12_EX7', 'L12_EX7');
UPDATE PULPIT SET FACULTY = 'L12_EX7' WHERE PULPIT_NAME = 'L12_EX7';
SELECT FACULTY FROM PULPIT WHERE PULPIT_NAME = 'L12_EX7';
---------------t1---------------
SELECT FACULTY FROM PULPIT WHERE PULPIT_NAME = 'L12_EX7';
---------------t2---------------
COMMIT;

--- B ---
BEGIN TRANSACTION
DELETE PULPIT WHERE FACULTY = 'L12_EX7';
INSERT PULPIT VALUES ('L12_EX7', 'L12_EX7', 'L12_EX7');
UPDATE PULPIT SET FACULTY = 'L12_EX7' WHERE PULPIT_NAME = 'L12_EX7';
SELECT FACULTY FROM PULPIT WHERE PULPIT_NAME = 'L12_EX7';
---------------t1---------------
COMMIT;
SELECT FACULTY FROM PULPIT WHERE PULPIT_NAME = 'L12_EX7';
---------------t2---------------


-- 8. Разработать сценарий, демонстрирующий свойства вложенных транзакций,
-- на примере базы данных X_UNIVER. 

-- для демонстрации
INSERT PULPIT VALUES ('LAB12_EX8', 'LAB12_EX8', 'ИТ');

BEGIN TRAN
INSERT FACULTY VALUES ('LAB12_EX8', 'LAB12_EX8');
	BEGIN TRAN
	UPDATE PULPIT SET FACULTY = 'LAB12_EX8' WHERE PULPIT = 'LAB12_EX8';
	COMMIT;
IF @@TRANCOUNT > 0 ROLLBACK; -- ?

SELECT * FROM FACULTY;
SELECT * FROM PULPIT;

DELETE PULPIT WHERE PULPIT = 'LAB12_EX8';
DELETE FACULTY WHERE FACULTY = 'LAB12_EX8';
