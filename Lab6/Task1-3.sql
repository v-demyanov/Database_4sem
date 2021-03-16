USE DVR_UNIVER;

-- ������������ ������ ������������ ������,
-- ������� ��������� �� ���������� , �������������� ���������� �� �������������,
-- � ������������ �������� ���������� ����� ���������� ��� ����������
-- ����������: ������������ � ������ WHERE �������� IN c ����������������� �����������
SELECT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT, FACULTY
WHERE PULPIT.FACULTY = FACULTY.FACULTY
	  AND 
	  PULPIT.FACULTY IN(SELECT FACULTY FROM PROFESSION WHERE (PROFESSION_NAME LIKE '%����������%' OR PROFESSION_NAME LIKE '%����������%'));

-- ���������� ������ ������ 1 ����� ��-�����,
-- ����� ��� �� ��������� ��� ������� � ����������� INNER JOIN ������ FROM �������� �������
SELECT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT INNER JOIN FACULTY
ON PULPIT.FACULTY = FACULTY.FACULTY
WHERE PULPIT.FACULTY IN(SELECT FACULTY FROM PROFESSION WHERE (PROFESSION_NAME LIKE '%����������%' OR PROFESSION_NAME LIKE '%����������%'));

-- ���������� ������, ����������� 1 ����� ��� ������������� ����������.
-- ����������: ������������ ���������� INNER JOIN ���� ������. 
SELECT DISTINCT PULPIT.PULPIT_NAME, FACULTY.FACULTY_NAME
FROM PULPIT 
INNER JOIN FACULTY ON PULPIT.FACULTY = FACULTY.FACULTY
INNER JOIN PROFESSION ON PULPIT.FACULTY = PROFESSION.FACULTY  
	WHERE (PROFESSION_NAME LIKE '%����������%' OR PROFESSION_NAME LIKE '%����������%');