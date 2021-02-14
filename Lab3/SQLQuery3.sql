use DemyanovUNIVER;
-- вывод всей информации
SELECT * From STUDENT;
-- выбор содержимого двух столбцов
SELECT [Номер зачётки], [Фамилия студента] From STUDENT;
-- подсчёт количества строк в таблице
SELECT count(*) From STUDENT;
-- Where, Distinct, Top
SELECT [Номер зачётки], [Фамилия студента] From STUDENT
	Where POL = 'ж'
SELECT Distinct Top(5) [Фамилия студента] From STUDENT
-- UPDATE 
UPDATE STUDENT set [Номер группы] = 5;
-- DELETE
DELETE from STUDENT Where [Номер зачётки] = '245kl321';
-- BETWEEN
SELECT [Номер зачётки], [Фамилия студента] From STUDENT WHERE [Фамилия студента] Between 'Д%' And 'Р%';
-- Like
SELECT [Фамилия студента] From STUDENT WHERE [Фамилия студента] Like 'А%';
-- In
SELECT [Номер зачётки], [Фамилия студента] From STUDENT WHERE [Фамилия студента] In ('Демьянов', 'Иванов');
-- Удаление таблицы
DROP table STUDENT;