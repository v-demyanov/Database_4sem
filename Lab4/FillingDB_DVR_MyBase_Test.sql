use DVR_MyBase_Test;

/*drop table SPECIALTY;
drop table GROUPS;
drop table CLASS_TYPE;
drop table SUBJECT;
drop table TEACHER;
drop table CURRICULUM;*/

------Создание и заполнение таблицы SPECIALTY
	create table SPECIALTY
	(	SPECIALTY nvarchar(50) constraint SPECIALTY_PK primary key
	) on G1;

	insert into SPECIALTY(SPECIALTY)
		values ('ПОИТ'),
			   ('ПОиБМС'),
			   ('ДЭиВИ'),
			   ('ИСиТ');

------Создание и заполнение таблицы GROUPS
	create table GROUPS
	(	GROUP_NUMBER int constraint GROUP_NUMBER_PK primary key NOT NULL,
		SPECIALTY nvarchar(50) constraint SPECIALTY_FK foreign key
								references SPECIALTY(SPECIALTY) NOT NULL,
		DEPARTMENT nvarchar(50) NOT NULL,
		STUDENT_NUMBERS int NOT NULL
	) on G1;

	insert into GROUPS(GROUP_NUMBER, SPECIALTY, DEPARTMENT, STUDENT_NUMBERS)
		values (5, 'ПОИТ', 'Дневное', 31),
			   (4, 'ИСиТ', 'Очное', 29),
			   (3, 'ПОИТ', 'Дневное', 25),
			   (2, 'ДЭиВИ', 'Вечернее', 31),
			   (1, 'ПОиБМС', 'Дневное', 28);

------Создание и заполнение таблицы CLASS_TYPE
	create table CLASS_TYPE
	(	CLASS_TYPE nvarchar(50) constraint CLASS_TYPE_PK primary key NOT NULL
	);

	insert into CLASS_TYPE(CLASS_TYPE)
		values ('Лекция'),
			   ('Практическое занятие'),
			   ('Лабораторная работа');

------Создание и заполнение таблицы SUBJECT
	create table SUBJECT
	(	SUBJECT nvarchar(50) constraint SUBJECT_PK primary key NOT NULL
	);

	insert into SUBJECT(SUBJECT)
		values ('Математика'),
			   ('Английский'),
			   ('ООП'),
			   ('БД');
		
------Создание и заполнение таблицы TEACHER
	create table TEACHER
	(	TEACHER_KEY nvarchar(10) constraint TEACHER_KEY_PK primary key NOT NULL,
		TEACHER_NAME nvarchar(50) NOT NULL,
		TEACHER_LAST_NAME nvarchar(50) NOT NULL,
		TEACHER_MIDDLE_NAME nvarchar(50) NOT NULL,
		PHONE_NUMBER varchar(20) NOT NULL,
		EXPERIENCE int
	) on G2;

	insert into TEACHER(TEACHER_KEY, TEACHER_NAME, TEACHER_LAST_NAME, TEACHER_MIDDLE_NAME, PHONE_NUMBER, EXPERIENCE)
		values ('t1', 'Иван', 'Иванов', 'Иванович', '36(38)744-39-94', 2),
			   ('t2', 'Алексей', 'Алексеев', 'Алексеевич', '70(552)204-07-37', 3),
			   ('t3', 'Владимир', 'Сергеев', 'Владимрович', '7(44)720-57-48', 7),
			   ('t4', 'Илья', 'Ильин', 'Русланович', '422(36)881-19-61', 10);

------Создание и заполнение таблицы CURRICULUM
	create table CURRICULUM
	(	CURRICULUM_KEY nvarchar(10) constraint CURRICULUM_KEY_PK primary key NOT NULL,
		TEACHER nvarchar(10) constraint TEACHER_FK foreign key
								references TEACHER(TEACHER_KEY) NOT NULL,
		GROUP_NUMBER int constraint GROUP_NUMBER_FK foreign key
								references GROUPS(GROUP_NUMBER) NOT NULL,
		CLASS_TYPE nvarchar(50) constraint CLASS_TYPE_FK foreign key
								references CLASS_TYPE(CLASS_TYPE) NOT NULL,
		HOURS_NUMBERS int,
		PAYMENT real,
		SUBJECT nvarchar(50) constraint SUBJECT_FK foreign key
								references SUBJECT(SUBJECT) NOT NULL
	);

	insert into CURRICULUM(CURRICULUM_KEY, TEACHER, GROUP_NUMBER, CLASS_TYPE, HOURS_NUMBERS, PAYMENT, SUBJECT)
		values ('2k', 't1', 2, 'Практическое занятие', 100, 2000, 'Математика'),
			   ('3k', 't2', 2, 'Лекция', 200, 3000, 'Английский'),
			   ('4k', 't3', 2, 'Лабораторная работа', 50, 500, 'ООП');