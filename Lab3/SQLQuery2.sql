use DemyanovUNIVER
CREATE table STUDENT
(
	[Номер зачётки] nvarchar(10) primary key not null,
	[Фамилия студента] nvarchar(50) not null,
	[Номер группы] int not null,
	[Дата рождения] date not null,
);

ALTER table STUDENT ADD [Дата поступления] date;	
ALTER table STUDENT ADD POL nchar(1) default 'м' check (POL in ('м', 'ж'));
--ALTER table STUDENT DROP Column [Дата поступления];
ALTER table STUDENT ADD check ([Номер группы] > 0 AND [Номер группы] <= 12);

INSERT into STUDENT ([Номер зачётки], [Фамилия студента], [Номер группы], [Дата рождения], [Дата поступления], POL)
	Values 
	('245kl321', 'Иванов', 4, '2-2-2000', '2-2-2009', 'м'),
	('p231l333', 'Демьянов', 5, '2-2-2000', '2-2-2009', 'м'),
	('kk233ll4', 'Петров', 4, '2-2-2000', '2-2-2009', 'м'),
	('2l222344', 'Алексеева', 7, '2-2-2000', '2-2-2020', 'ж'),
	('2l222345', 'Морозова', 7, '2-2-2000', '2-2-2009', 'ж'),
	('2l222346', 'Денисова', 7, '2-2-1998', '2-2-2025', 'ж'),
	('2l222347', 'Семёнова', 7, '2-2-2000', '2-2-2009', 'ж');
