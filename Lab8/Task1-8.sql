USE DVR_UNIVER;

-- 1. ����������� ������������� � ������ �������������. ������������� ������ ���� ��������� �� ������ SELECT-�������
-- � ������� TEACHER � ��������� ��������� �������: ��� (TEACHER), ��� ������������� (TEACHER_NAME), ��� (GENDER), ��� ������� (PULPIT). 
CREATE VIEW [�������������]
	AS SELECT TEACHER.TEACHER[���],
		      TEACHER.TEACHER_NAME[��� �������������],
			  TEACHER.GENDER[���],
			  TEACHER.PULPIT[��� �������] FROM TEACHER;

SELECT * FROM [�������������];

-- 2. ����������� � ������� ������������� � ������ ���������� ������.
-- ������������� ������ ���� ��������� �� ������ SELECT-������� � �������� FACULTY � PULPIT.
-- ������������� ������ ��������� ��������� �������: ��������� (FACULTY.FACULTY_ NAME), ���������� ������ (����������� �� ������ ����� ������� PULPIT). 
-- �
CREATE VIEW [���������� ������]
	AS SELECT FACULTY.FACULTY_NAME[���������],
			  (select count(*)
			  from PULPIT where PULPIT.FACULTY = FACULTY.FACULTY)[���������� ������]
	FROM FACULTY;
-- �
CREATE VIEW [���������� ������]
	AS SELECT DISTINCT(FACULTY.FACULTY_NAME)[���������],
				COUNT(PULPIT.FACULTY)[���������� ������]
	FROM dbo.FACULTY JOIN dbo.PULPIT
	ON PULPIT.FACULTY = FACULTY.FACULTY
	GROUP BY FACULTY.FACULTY_NAME;

-- 3. ����������� � ������� ������������� � ������ ���������. ������������� ������ ���� ��������� �� ������
-- ������� AUDITORIUM � ��������� �������: ��� (AUDITORIUM), ������������ ��������� (AUDITORIUM_NAME). 
-- ������������� ������ ���������� ������ ���������� ��������� (� ������� AUDITORIUM_ TYPE ������, ������������ � ������� ��)
-- � ��������� ���������� ��������� INSERT, UPDATE � DELETE.
CREATE VIEW [���������]
	AS SELECT AUDITORIUM.AUDITORIUM[���],
			  AUDITORIUM.AUDITORIUM_NAME[������������ ���������]
	FROM AUDITORIUM WHERE AUDITORIUM.AUDITORIUM_TYPE LIKE '��%';

INSERT  [���������]
	VALUES('339-6', '333-1');

SELECT * FROM AUDITORIUM;

-- 4. ����������� � ������� ������������� � ������ ����������_���������.
-- ������������� ������ ���� ��������� �� ������ SELECT-������� � ������� AUDITORIUM � ��������� ��������� �������:
-- ��� (AUDITORIUM), ������������ ��������� (AUDITORIUM_NAME). ������������� ������ ���������� ������
-- ���������� ��������� (� ������� AUDITORIUM_TYPE ������, ������������ � �������� ��). 
-- ���������� INSERT � UPDATE �����������, �� � ������ �����������, ����������� ������ WITH CHECK OPTION.
CREATE VIEW ����������_���������
	AS SELECT AUDITORIUM.AUDITORIUM[���],
			  AUDITORIUM.AUDITORIUM_NAME[������������ ���������],
			  AUDITORIUM.AUDITORIUM_TYPE[��� ���������]
	FROM AUDITORIUM WHERE AUDITORIUM.AUDITORIUM_TYPE LIKE '��%'
	WITH CHECK OPTION; 

INSERT ����������_���������
	VALUES('233-1', '233-1', '��-�');

SELECT * FROM ����������_���������;

-- 5. ����������� � ������� ������������� � ������ ����������. ������������� ������ ���� ��������� 
-- �� ������ SELECT-������� � ������� SUBJECT, ���������� ��� ���������� � ���������� ������� 
-- � ��������� ��������� �������: ��� (SUBJECT), ������������ ���������� (SUBJECT_NAME) � ��� ������� (PULPIT). 
-- ������������ ������ TOP � ORDER BY.
CREATE VIEW ����������
	AS SELECT TOP 150 SUBJECT.SUBJECT[���],
			  SUBJECT.SUBJECT_NAME[������������ ����������],
			  SUBJECT.PULPIT
	FROM SUBJECT ORDER BY SUBJECT.SUBJECT_NAME;

SELECT * FROM ����������;

-- 6. �������� ������������� ����������_������, ��������� � ������� 2 ���, ����� ��� ���� ��������� � ������� ��������.
-- ������������������ �������� ������������� ������������� � ������� ��������. ����������: ������������ ����� SCHEMABINDING. 
ALTER VIEW [���������� ������] WITH SCHEMABINDING 
	AS SELECT FACULTY.FACULTY_NAME[���������],
			  (select count(*)
			  from dbo.PULPIT where PULPIT.FACULTY = FACULTY.FACULTY)[���������� ������]
	FROM dbo.FACULTY;

-- 8*. ����������� ������������� ��� ������� TIMETABLE (������������ ������ 6) � ���� ����������.
-- ������� �������� PIVOT � ������������ ���.
/*CREATE VIEW ����������
	AS SELECT CLASS_NUMBER, [��] = '��', [��] = '��', [��] = '��', [��] = '��', [��] = '��', [��] = '��', [��] = '��'
	FROM TIMETABLE
	PIVOT( SUM(IDGROUP, TIMETABLE.TEACHER) FOR TIMETABLE.WEEKDAY IN([��], [��], [��], [��], [��], [��], [��])) AS test;

SELECT * FROM ����������;

SELECT * FROM TIMETABLE;

--CONCAT(TIMETABLE.AUDITORIUM, TIMETABLE.SUBJECT, TIMETABLE.TEACHER, TIMETABLE.IDGROUP)*/





