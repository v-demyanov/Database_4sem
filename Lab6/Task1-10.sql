USE DVR_UNIVER;

-- 1. ������������ ������ ������������ ������,
-- ������� ��������� �� ���������� , �������������� ���������� �� �������������,
-- � ������������ �������� ���������� ����� ���������� ��� ����������
-- ����������: ������������ � ������ WHERE �������� IN c ����������������� �����������
SELECT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT, FACULTY
WHERE PULPIT.FACULTY = FACULTY.FACULTY
	  AND 
	  PULPIT.FACULTY IN(SELECT FACULTY FROM PROFESSION WHERE (PROFESSION_NAME LIKE '%����������%' OR PROFESSION_NAME LIKE '%����������%'));

-- 2. ���������� ������ ������ 1 ����� �������,
-- ����� ��� �� ��������� ��� ������� � ����������� INNER JOIN ������ FROM �������� �������
SELECT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT INNER JOIN FACULTY
ON PULPIT.FACULTY = FACULTY.FACULTY
WHERE PULPIT.FACULTY IN(SELECT FACULTY FROM PROFESSION WHERE (PROFESSION_NAME LIKE '%����������%' OR PROFESSION_NAME LIKE '%����������%'));

-- 3. ���������� ������, ����������� 1 ����� ��� ������������� ����������.
-- ����������: ������������ ���������� INNER JOIN ���� ������. 
SELECT DISTINCT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT 
INNER JOIN FACULTY ON PULPIT.FACULTY = FACULTY.FACULTY
INNER JOIN PROFESSION ON PULPIT.FACULTY = PROFESSION.FACULTY  
	WHERE (PROFESSION_NAME LIKE '%����������%' OR PROFESSION_NAME LIKE '%����������%');

-- 4. �� ������ ������� AUDITORIUM ������������ ������ ��������� ����� ������� ������������ (������� AUDITORIUM_CAPACITY)
-- ��� ������� ���� ��������� (AUDITORIUM_TYPE). ��� ���� ��������� ������� ������������� � ������� �������� �����������. 
-- ����������: ������������ ������������� ��������� c �������� TOP � ORDER BY. 
SELECT AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY
FROM AUDITORIUM a
WHERE AUDITORIUM_CAPACITY = (SELECT TOP(1) AUDITORIUM_CAPACITY FROM AUDITORIUM aa
							WHERE aa.AUDITORIUM_TYPE = a.AUDITORIUM_TYPE
							ORDER BY AUDITORIUM_CAPACITY DESC);

-- 5. �� ������ ������ FACULTY � PULPIT ������������ ������ ������������ ����������� (������� FACULTY_NAME)
-- �� ������� ��� �� ����� ������� (������� PULPIT).
-- ����������: ������������ �������� EXISTS � ���-������������ ���������. 
SELECT FACULTY_NAME
FROM FACULTY
WHERE NOT EXISTS (SELECT * FROM PULPIT WHERE PULPIT.FACULTY = FACULTY.FACULTY);

-- 6. �� ������ ������� PROGRESS ������������ ������, ���������� ������� �������� ������ (������� NOTE) 
-- �� �����������, ������� ��������� ����: ����, �� � ����. ����������: ������������ ���
-- ����������������� ���������� � ������ SELECT; � ����������� ��������� ���������� ������� AVG.
SELECT TOP(1)
	(SELECT AVG(NOTE) FROM PROGRESS WHERE SUBJECT LIKE '����')[����],
	(SELECT AVG(NOTE) FROM PROGRESS WHERE SUBJECT LIKE '��')[��],
	(SELECT AVG(NOTE) FROM PROGRESS WHERE SUBJECT LIKE '����')[����]
FROM PROGRESS;

-- 7. ����� ��� ���������, ����������� ������� ������ ��� � ����� ��������� ���� ��-�
SELECT *
FROM AUDITORIUM 
WHERE AUDITORIUM_CAPACITY < ALL(SELECT AUDITORIUM_CAPACITY FROM AUDITORIUM WHERE AUDITORIUM_TYPE = '��-�');

-- 8. ����� ��� ���������, ����������� ������� ������ ��� � ���� �� ����� ��������� ���� ��-�
SELECT *
FROM AUDITORIUM 
WHERE AUDITORIUM_CAPACITY < ANY(SELECT AUDITORIUM_CAPACITY FROM AUDITORIUM WHERE AUDITORIUM_TYPE = '��-�');

-- 10*. ����� � ������� STUDENT ���������, � ������� ���� �������� � ���� ����. ��������� �������.
SELECT *, (SELECT DISTINCT DAY(BDAY) FROM STUDENT s2 WHERE DAY(s2.BDAY) = DAY(s1.BDAY)) AS [Day]
FROM STUDENT s1
ORDER BY Day;