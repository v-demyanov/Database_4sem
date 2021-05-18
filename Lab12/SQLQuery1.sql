
-- 1. ����������� ��������, �����-���������� ������ � ������ ������� ����������.
-- ���������������� ������, ����������� ������, � ������� ��������� ������� �,
-- � ������� �������� ��� ������ �������.
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
	print '����������� ������� � ������� NUMBERS: ' + cast(@min_num as varchar(2));

	if @flag = 'c' commit;
	else rollback;
SET IMPLICIT_TRANSACTIONS OFF;

SELECT * FROM NUMBERS;

IF EXISTS (select * from SYS.OBJECTS
			where OBJECT_ID = object_id(N'DBO.NUMBERS'))
PRINT '������� NUMBERS ����';
ELSE PRINT '������� NUMBERS ���';

-- 2. ����������� ��������, ��������������� �������� ����������� ����� ���������� �� ������� ���� ������ X_UNIVER. 
-- � ����� CATCH ������������� ������ ��������������� ��������� �� �������. 
-- ���������� ������ �������� ��� ������������� ��������� ���������� ����������� ������.

USE DVR_UNIVER;

BEGIN TRY
	begin tran
	delete STUDENT where NAME = 'lab12_ex2'; 
	insert STUDENT (IDGROUP, NAME, BDAY)
		values (2, 'lab12_ex2', GETDATE());
	update STUDENT set NAME = 'lab12_ex2_updated'
			where NAME = 10; -- ������
	commit tran;
END TRY
BEGIN CATCH
	print '������: ����������� ������ ' + cast(error_number() as varchar(5)) + error_message();
	if @@trancount > 0 rollback tran;
END CATCH;

SELECT * FROM STUDENT;

-- 3. ����������� ��������, ��������������� ���������� ��������� SAVE TRAN
-- �� ������� ���� ������ X_UNIVER. 
-- � ����� CATCH ������������� ������ ��������������� ��������� �� �������. 
-- ���������� ������ �������� ��� ������������� ��������� ����������� �����
-- � ��������� ���������� ����������� ������.

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
			where NAME = 10; -- ������
	commit tran;
END TRY
BEGIN CATCH
	print '������: ����������� ������ ' + cast(error_number() as varchar(5)) + ' ' + error_message();
	if @@trancount > 0 
		begin
		  print '����������� �����: ' + @point;
		  rollback tran @point;
		  commit tran;
		end;
END CATCH;

-- 4. ����������� ��� �������� A � B �� ������� ���� ������ X_UNIVER. 
-- �������� A ������������ ����� ����� ���������� � �������
-- ��������������� READ UNCOMMITED, �������� B � ����� ���������� 
-- � ������� ��������������� READ COM-MITED (�� ���������). 
-- �������� A ������ �����-����������, ��� ������� READ UNCOMMITED
-- ��������� ��-��������������, ����������-����� � ��������� ������. 

-- ��� ������������
INSERT PULPIT VALUES ('L12_EX4', 'L12_EX4', '����');

DELETE PULPIT WHERE PULPIT = 'L12_EX4';
DELETE FACULTY WHERE FACULTY = 'L12_EX4';

--------------------------------------------------------------
------A---------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION
-----t1---------
SELECT @@SPID, 'insert FACULTY' '����', *
	FROM FACULTY WHERE FACULTY = '��';
SELECT @@SPID, 'update PULPIT' '����', *
	FROM PULPIT WHERE FACULTY = '��';
COMMIT;

-----t2---------
-----B----------

BEGIN TRANSACTION
SELECT @@SPID 
INSERT FACULTY VALUES ('L12_EX4','L12_EX4');
UPDATE PULPIT SET FACULTY = '��' WHERE PULPIT = 'L12_EX4'

-----t1----------
-----t2----------

ROLLBACK;
SELECT * FROM FACULTY;
SELECT * FROM PULPIT;

-- 5. ����������� ��� �������� A � B �� ������� ���� ������ X_UNIVER. 
-- �������� A � � ����������-�� ����� ����� ���������� � ������� ��������������� READ COMMITED. 
-- �������� A ������ �����-����������, ��� ������� READ COMMITED �� ��������� ��-���������������
-- ������, �� ��� ���� �������� ���������-������ � ��������� ������.

-- ��� ������������
INSERT PULPIT VALUES ('L12_EX5', 'L12_EX5', '����');

DELETE PULPIT WHERE PULPIT = 'L12_EX5';

-----A--------
SELECT * FROM PULPIT;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
SELECT count(*) FROM PULPIT
WHERE FACULTY = '��';

-----t1-------
-----t2-------

SELECT 'update PULPIT' '���������', count(*) 
FROM PULPIT WHERE FACULTY = '��';
COMMIT;
------B----

BEGIN TRANSACTION

------t1-----

UPDATE PULPIT SET FACULTY = '��' WHERE PULPIT = 'L12_EX5';
COMMIT;

-- 6. ����������� ��� �������� A � B �� ������� ���� ������ X_UNIVER. 
-- �������� A ������������ ��-��� ����� ���������� � ����-��� ��������������� RE-PEATABLE READ.
-- �������� B � ����� ���������� � ������� ��������������� READ COM-MITED. 
-- �������� A ������ �����-����������, ��� ������� REAPETABLE READ �� �����-����
-- ����������������� ������ � ���������������� ������, �� ��� ���� �������� ��������� ������. 

-- ��� ������������
DELETE PULPIT WHERE PULPIT = 'L12_EX6';

-- A ---
set transaction isolation level  REPEATABLE READ 
begin transaction 
select PULPIT from PULPIT where FACULTY = '����';
-------------------------- t1 ------------------ 
-------------------------- t2 -----------------
select  case
when PULPIT = '����' then 'insert  PULPIT'  else ' ' 
end '���������', PULPIT from PULPIT  where FACULTY = '����';
commit; 

--- B ---	
begin transaction 	  
-------------------------- t1 --------------------
insert PULPIT values ('L12_EX6', 'L12_EX6', '����');
commit; 


-- 7. ����������� ��� �������� A � B �� ������� ���� ������ X_UNIVER. 
-- �������� A ������������ ����� ����� ���������� � ����-��� ��������������� SERIALIZABLE. 
-- �������� B � ����� ���������� � ������� ������������-��� READ COMMITED.
-- �������� A ������ ��������������� ���������� ����������, ����������������� � ���������������� ������.

-- ��� ������������
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


-- 8. ����������� ��������, ��������������� �������� ��������� ����������,
-- �� ������� ���� ������ X_UNIVER. 

-- ��� ������������
INSERT PULPIT VALUES ('LAB12_EX8', 'LAB12_EX8', '��');

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
