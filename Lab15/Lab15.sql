USE DVR_UNIVER;


-- 1. AFTER-триггер реагирующий на событие insert
DELETE FROM TEACHER WHERE TEACHER='T1_l15'; -- перед выполнением
DROP TABLE TR_AUDIT;

CREATE TABLE TR_AUDIT
(
	ID INT IDENTITY,
	STMT VARCHAR(20)
	CHECK (STMT in ('INS', 'DEL', 'UPD')),
	TRNAME VARCHAR(50),
	CC VARCHAR(300)
);

go
CREATE TRIGGER TR_TEACHER_INS ON TEACHER AFTER INSERT AS
BEGIN
	declare @a1 char(10), @a2 varchar(100), @a3 char(1), @a4 char(20), @in varchar(300);
    print 'Операция вставки';
	set @a1 = (select TEACHER from INSERTED);
	set @a2 = (select TEACHER_NAME from INSERTED);
	set @a3 = (select GENDER from INSERTED);
	set @a4 = (select PULPIT from INSERTED);
	set @in = @a1 + ' ' + @a2 + ' ' + @a3 + ' ' + @a4;
	insert into TR_AUDIT(STMT, TRNAME, CC)  
		values('INS', 'TR_TEACHER_INS', @in);	         
    return;
END
go

INSERT INTO TEACHER VALUES('T1_l15', 'Task1_lab15', 'м', 'ИСиТ');

SELECT * FROM TEACHER;
SELECT * FROM TR_AUDIT;

-- 2. AFTER-триггер реагирующий на событие delete
go
CREATE TRIGGER TR_TEACHER_DEL ON TEACHER AFTER DELETE AS
BEGIN
	declare @a1 char(10), @a2 varchar(100), @a3 char(1), @a4 char(20), @in varchar(300);
	print 'Операция удаления';
	set @a1 = (select TEACHER from DELETED);
	set @a2 = (select TEACHER_NAME from DELETED);
	set @a3 = (select GENDER from DELETED);
    set @a4 = (select PULPIT from DELETED);
    set @in = @a1 + ' ' + @a2 + ' ' + @a3 + ' ' + @a4;
	insert into TR_AUDIT(STMT, TRNAME, CC)  
		values('DEL', 'TR_TEACHER_DEL', @in);	         
	return;  
END;
go 

-- строка, которая вставлялась в задании №1
DELETE TEACHER WHERE TEACHER = 'T1_l15';

SELECT * FROM TEACHER;
SELECT * FROM TR_AUDIT;

-- 3. AFTER-триггер реагирующий на событие update
DELETE FROM TR_AUDIT WHERE STMT = 'UPD';
DELETE FROM TEACHER WHERE TEACHER = 'T3_l15';

go
CREATE TRIGGER TR_TEACHER_UPD ON TEACHER AFTER UPDATE AS
BEGIN
	declare @a1 char(10), @a2 varchar(100), @a3 char(1), @a4 char(20), @in varchar(300);
	print 'Операция обновления';
	-- до
	set @a1 = (select TEACHER from DELETED);
	set @a2 = (select TEACHER_NAME from DELETED);
	set @a3 = (select GENDER from DELETED);
    set @a4 = (select PULPIT from DELETED);
    set @in = 'До: ' + @a1 + ' ' + @a2 + ' ' + @a3 + ' ' + @a4;
	insert into TR_AUDIT(STMT, TRNAME, CC)  
		values('UPD', 'TR_TEACHER_UPD', @in);	
	-- после
	set @a1 = (select TEACHER from INSERTED);
	set @a2 = (select TEACHER_NAME from INSERTED);
	set @a3 = (select GENDER from INSERTED);
    set @a4 = (select PULPIT from INSERTED);
    set @in = 'После: ' + @a1 + ' ' + @a2 + ' ' + @a3 + ' ' + @a4;
	insert into TR_AUDIT(STMT, TRNAME, CC)
		values('UPD', 'TR_TEACHER_UPD', @in);
	return;  
END;
go

INSERT INTO TEACHER VALUES('T3_l15', 'Task3_lab15', 'м', 'ИСиТ');

UPDATE TEACHER SET GENDER = 'ж' WHERE TEACHER='T3_l15';

SELECT * FROM TEACHER;
SELECT * FROM TR_AUDIT;

-- 4. AFTER-триггер реагирующий на INSERT, DELETE, UPDATE
DISABLE TRIGGER TR_TEACHER_INS ON TEACHER;
DISABLE TRIGGER TR_TEACHER_DEL ON TEACHER;
DISABLE TRIGGER TR_TEACHER_UPD ON TEACHER;
DROP TABLE TR_AUDIT;

go
CREATE TRIGGER TR_TEACHER ON TEACHER AFTER INSERT, DELETE, UPDATE AS
declare @a1 char(10), @a2 varchar(100), @a3 char(1), @a4 char(20), @in varchar(300);
declare @ins int = (select count(*) from inserted),
        @del int = (select count(*) from deleted); 
IF @ins > 0 AND @del = 0
BEGIN
	print 'Событие: INSERT';
	set @a1 = (select TEACHER from INSERTED);
	set @a2 = (select TEACHER_NAME from INSERTED);
	set @a3 = (select GENDER from INSERTED);
	set @a4 = (select PULPIT from INSERTED);
	set @in = @a1 + ' ' + @a2 + ' ' + @a3 + ' ' + @a4;
	insert into TR_AUDIT(STMT, TRNAME, CC)  
		values('INS', 'TR_TEACHER', @in);	
END;
ELSE
IF @ins = 0 AND  @del > 0
BEGIN
	print 'Событие: DELETE';
	set @a1 = (select TEACHER from DELETED);
	set @a2 = (select TEACHER_NAME from DELETED);
	set @a3 = (select GENDER from DELETED);
	set @a4 = (select PULPIT from DELETED);
	set @in = @a1 + ' ' + @a2 + ' ' + @a3 + ' ' + @a4;
	insert into TR_AUDIT(STMT, TRNAME, CC)  
		values('DEL', 'TR_TEACHER', @in);
END;
ELSE	  
IF @ins > 0 AND @del > 0
BEGIN
	print 'Событие: UPDATE'; 
	-- до
	set @a1 = (select TEACHER from DELETED);
	set @a2 = (select TEACHER_NAME from DELETED);
	set @a3 = (select GENDER from DELETED);
    set @a4 = (select PULPIT from DELETED);
    set @in = 'До: ' + @a1 + ' ' + @a2 + ' ' + @a3 + ' ' + @a4;
	insert into TR_AUDIT(STMT, TRNAME, CC)  
		values('UPD', 'TR_TEACHER', @in);	
	-- после
	set @a1 = (select TEACHER from INSERTED);
	set @a2 = (select TEACHER_NAME from INSERTED);
	set @a3 = (select GENDER from INSERTED);
    set @a4 = (select PULPIT from INSERTED);
    set @in = 'После: ' + @a1 + ' ' + @a2 + ' ' + @a3 + ' ' + @a4;
	insert into TR_AUDIT(STMT, TRNAME, CC)
		values('UPD', 'TR_TEACHER', @in);
END;
RETURN;  

INSERT INTO TEACHER VALUES('T4_l15', 'Task4_lab15', 'м', 'ИСиТ');
UPDATE TEACHER SET GENDER = 'ж' WHERE TEACHER='T4_l15';
DELETE TEACHER WHERE TEACHER = 'T4_l15';

SELECT * FROM TEACHER;
SELECT * FROM TR_AUDIT;

-- 5. продемонстрировать, что проверка ограничения целостности выполняется 
-- до срабатывания AFTER-триггера
DELETE TEACHER WHERE TEACHER = 'T5_l15';
--
INSERT INTO TEACHER VALUES('T5_l15', 'Task5_lab15', 'м', 'ИСиТ');
--
UPDATE TEACHER SET GENDER = 'T' WHERE TEACHER='T5_l15';
--
SELECT * FROM TR_AUDIT;

-- 6. Упорядочить выполнение триггеров
go   
CREATE TRIGGER TR_TEACHER_DEL1 ON TEACHER AFTER DELETE AS
	print 'TR_TEACHER_DEL1';
	return;  
go 
CREATE TRIGGER TR_TEACHER_DEL2 ON TEACHER AFTER DELETE AS
	print 'TR_TEACHER_DEL2';
	return;  
go  
CREATE TRIGGER TR_TEACHER_DEL3 ON TEACHER AFTER DELETE AS 
	print 'TR_TEACHER_DEL3';
	return;  
go  

-- проверка выполения порядка триггеров
select t.name, e.type_desc 
  from sys.triggers t join sys.trigger_events e on t.object_id = e.object_id  
  where OBJECT_NAME(t.parent_id)='TEACHER' and e.type_desc = 'DELETE';  

-- изменение порядка выполнения триггеров
exec SP_SETTRIGGERORDER @triggername = 'TR_TEACHER_DEL3', 
	                    @order='First', @stmttype = 'DELETE';
exec SP_SETTRIGGERORDER @triggername = 'TR_TEACHER_DEL2', 
	                    @order='Last', @stmttype = 'DELETE';

-- проверка выполения порядка триггеров
select t.name, e.type_desc 
  from sys.triggers t join sys.trigger_events e on t.object_id = e.object_id  
  where OBJECT_NAME(t.parent_id)='TEACHER' and e.type_desc = 'DELETE';

-- 7. показать, что AFTER-триггер является частью транзакции с операцией
go
CREATE TRIGGER TR_AUDIT_CAPAC ON AUDITORIUM AFTER INSERT, DELETE, UPDATE AS
declare @c int = (select sum(AUDITORIUM_CAPACITY) from AUDITORIUM);
IF (@c > 10000)
BEGIN
	raiserror('Общая вместимость аудиторий не может превышать 10000', 10, 1);
	rollback;
END;
RETURN;

INSERT INTO AUDITORIUM VALUES('T7_l15', 'T7_l15', 100000, 'T7_l15');

SELECT * FROM AUDITORIUM;
SELECT * FROM TR_AUDIT;

-- 8. 
go
CREATE TRIGGER TR_FAC_INSTEAD_OF ON FACULTY INSTEAD OF DELETE AS
	raiserror('Удаление запрещено', 10, 1);
RETURN;

DELETE FACULTY WHERE FACULTY = 'ИДиП';

SELECT * FROM FACULTY;

USE DVR_UNIVER;

DROP TRIGGER TR_TEACHER_INS;
DROP TRIGGER TR_TEACHER_DEL;
DROP TRIGGER TR_TEACHER_UPD;
DROP TRIGGER TR_TEACHER;
DROP TRIGGER TR_TEACHER_DEL1;
DROP TRIGGER TR_TEACHER_DEL2;
DROP TRIGGER TR_TEACHER_DEL3;
DROP TRIGGER TR_AUDIT_CAPAC;
DROP TRIGGER TR_FAC_INSTEAD_OF;

-- 9. триггер реагирующий на все DDL-события в БД
USE CR;

go
CREATE TRIGGER TR_DDL_BLOCK ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS AS
declare @t varchar(50) =  EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)');
declare @t1 varchar(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(50)');
declare @t2 varchar(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(50)'); 
if (@t1 = 'Table2' or @t1 = 'Table3' or @t1 = 'Table4')
BEGIN
	print 'Тип события: '+@t;
	print 'Имя объекта: '+@t1;
	print 'Тип объекта: '+@t2;
	raiserror( N'DDL операции с БД запрещены', 16, 1);  
	rollback;    
END;
go
 
DROP TABLE Table2;
ALTER TABLE Table2 DROP COLUMN t2; 

-- 11. Создать таблицу WEATHER (город, начальная дата, конечная дата, температура). 
-- Создать триггер, проверяющий коррект-ность ввода и изменения данных. 
-- Например, если в таблице есть строка (Минск, 01.01.2017 00:00, 01.01.2017 23:59, -6),
-- то в нее не может быть вставлена строка (Минск, 01.01.2017 00:00, 01.01.2017 23:59, -2). Временные периоды могут быть различными.
CREATE TABLE WEATHER 
(
	CITY NVARCHAR(50),
	START_DATE SMALLDATETIME,
	END_DATE SMALLDATETIME,
	TEMPERATURE FLOAT
);

go 
CREATE TRIGGER TR_WEATHER ON WEATHER FOR INSERT, UPDATE AS
DECLARE @a1 NVARCHAR(50), @a2 SMALLDATETIME, @a3 SMALLDATETIME, @a4 FLOAT, @count INT, @in NVARCHAR(300)
BEGIN
	print 'Событие: INSERT'; 
	set @a1 = (select CITY from INSERTED);
    set @a2= (select START_DATE from INSERTED);
    set @a3= (select END_DATE from INSERTED);
	set @a4 = (select TEMPERATURE from INSERTED);
	set @in = @a1 + ' ' + cast(@a2 as nvarchar(20)) + ' ' + cast(@a3 as nvarchar(20)) + ' ' + cast(@a4 as nvarchar(20));
	set @count = (select count(*) from WEATHER where CITY = @a1 and (START_DATE >= @a2 or END_DATE <= @a3)) 
	if @count > 1
	begin
		raiserror(@in, 11, 1);  
		rollback;
	end
	return;
END;
go

INSERT INTO WEATHER VALUES ('Минск','01.01.2017 00:00','01.01.2017 23:59', -6);
INSERT INTO WEATHER VALUES ('Минск','01.01.2017 00:00','01.01.2017 23:59', -2);

DELETE WEATHER WHERE CITY = 'Минск';
