USE DVR_UNIVER;

SET NOCOUNT ON

-- 1. режим неявной транзакции
DECLARE @len INT,
		@i INT = 0,
		@flag CHAR = 'c';

SET IMPLICIT_TRANSACTIONS ON
	while @i < 10
	begin
		set @len = (select count(*) from AUDITORIUM_TYPE);
		insert AUDITORIUM_TYPE values(concat('lb_12_', @len + 1), 'l12');
		set @i = @i + 1;
	end;

	if @flag = 'c' commit;
	else rollback;
SET IMPLICIT_TRANSACTIONS OFF;

SELECT * FROM AUDITORIUM_TYPE;

-- 2. явная транзакция
BEGIN TRY
	begin tran
	delete SUBJECT where SUBJECT = 'lab12_myBase'; 
	insert SUBJECT values ('lab12_myBase');
	update SUBJECT set SUBJECT = 'lab12_myBase_updated'
			where SUBJECT = 10; -- ошибка
	commit tran;
END TRY
BEGIN CATCH
	print 'ошибка: неизвестная ошибка ' + cast(error_number() as varchar(5)) + error_message();
	if @@trancount > 0 rollback tran;
END CATCH;

-- 3. save tran
DECLARE @point VARCHAR(32);
BEGIN TRY
	begin tran
	delete SUBJECT where SUBJECT = 'lab12_MyBase3'; 
	set @point = 'p1'; save tran @point;
	insert SUBJECT values ('lab12_MyBase3');
	set @point = 'p2'; save tran @point;
	delete SUBJECT where SUBJECT = 'lab12_MyBase3'; 
	insert SUBJECT values ('lab12_MyBase31');
	update SUBJECT set SUBJECT = 'lab12_MyBase31_updated'
			where SUBJECT = 10; -- ошибка
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