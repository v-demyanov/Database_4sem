USE DVR_UNIVER;

-- 1. �� ������ ������ AUDITORIUM_TYPE � AUDITORIUM ������������ �������� ����� ��������� (������� AUDITORUM.AUDITORIUM)
-- � ��������������� �� ������������ ����� ��������� (������� AUDITORIUM_TYPE.AUDITORIUM_TYPENAME).
-- ����������: ������������ ���������� ������ INNER JOIN. 
SELECT AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME
FROM AUDITORIUM 
JOIN AUDITORIUM_TYPE ON AUDITORIUM_TYPE.AUDITORIUM_TYPE = AUDITORIUM.AUDITORIUM_TYPE;

-- 2. �� ������ ������ AUDITORIUM_TYPE � AUDITORIUM ������������ �������� ����� ��������� (������� AUDITORIUM.AUDITORIUM)
-- � ��������������� �� ������������ ����� ��������� (������� AUDITORIUM_TYPE.AUDITORIUM_TYPENAME). 
-- ��� ���� ������� ������� ������ �� ���������, � ������������ ������� ������������ ��������� ���������. 
-- ����������: ������������ ���������� ������ INNER JOIN � �������� LIKE. 
SELECT A.AUDITORIUM, AT.AUDITORIUM_TYPENAME
FROM AUDITORIUM AS A
JOIN AUDITORIUM_TYPE AS AT
ON AT.AUDITORIUM_TYPE = A.AUDITORIUM_TYPE AND AT.AUDITORIUM_TYPENAME LIKE '%���������%';

-- 3. �������� ��� SELECT-�������, ����������� �������������� ������ ����������� �������� �� ������� 1 � 2,
-- �� ��� ���������� INNER JOIN.
SELECT A.AUDITORIUM, AT.AUDITORIUM_TYPENAME
FROM AUDITORIUM AS A, AUDITORIUM_TYPE AS AT
WHERE AT.AUDITORIUM_TYPE = A.AUDITORIUM_TYPE AND AT.AUDITORIUM_TYPENAME LIKE '%���������%';

-- 4. �� ������ ������ PRORGESS, STUDENT, GROUPS, SUBJECT, PULPIT � FACULTY ������������ �������� ���������,
-- ���������� ��������������� ������ (������� PROGRESS.NOTE) �� 6 �� 8. 
-- �������������� ����� ������ ��������� �������: ���������, �������, �������������, ����������, ��� ��������, ������.
-- � ������� ������ ������ ���� �������� ��������������� ������ ��������: �����, ����, ������. 
-- �������������� ����� ������������� � ������� ����������� �� �������� FACULTY.FACULTY, PULPIT.PULPIT, PROFESSION.PROFESSION,
-- STUDENT.STUDENT_NAME � � ������� �������� �� ������� PROGRESS.NOTE.
-- ����������: ������������ ���������� INNER JOIN, �������� BETWEEN � ��������� CASE.
SELECT FACULTY.FACULTY AS '���������', 
	   PULPIT.PULPIT AS '�������',
	   PROFESSION.PROFESSION AS '�������������',
	   SUBJECT.SUBJECT AS '����������',
	   STUDENT.NAME AS '��� ��������',
CASE
	WHEN (PROGRESS.NOTE = 6) then '�����'
	WHEN (PROGRESS.NOTE = 7) then '����'
	WHEN (PROGRESS.NOTE = 8) then '������'
END '������'
FROM PROGRESS
JOIN STUDENT ON STUDENT.IDSTUDENT = PROGRESS.IDSTUDENT AND PROGRESS.NOTE BETWEEN 6 AND 8
JOIN SUBJECT ON SUBJECT.SUBJECT = PROGRESS.SUBJECT
JOIN PULPIT ON PULPIT.PULPIT = SUBJECT.PULPIT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
JOIN PROFESSION ON PROFESSION.PROFESSION = GROUPS.PROFESSION
ORDER BY FACULTY.FACULTY, PULPIT.PULPIT, PROFESSION.PROFESSION, STUDENT.NAME ASC, PROGRESS.NOTE DESC;

-- 5. ���������� ������, ����������� ������� 4 ����� �������, ����� � �������������� ������ ����������
-- �� ��������������� ������� ���� ���������: ������� ���������� ������ � ������� 7, ����� ������ � ������� 8
-- � ����� ������ � ������� 6. 
-- ����������: ������������ ��������� CASE � ������ ORDER BY.
SELECT FACULTY.FACULTY AS '���������', 
	   PULPIT.PULPIT AS '�������',
	   PROFESSION.PROFESSION AS '�������������',
	   SUBJECT.SUBJECT AS '����������',
	   STUDENT.NAME AS '��� ��������',
CASE
	WHEN (PROGRESS.NOTE = 6) then '�����'
	WHEN (PROGRESS.NOTE = 7) then '����'
	WHEN (PROGRESS.NOTE = 8) then '������'
END '������'
FROM PROGRESS
JOIN STUDENT ON STUDENT.IDSTUDENT = PROGRESS.IDSTUDENT AND PROGRESS.NOTE BETWEEN 6 AND 8
JOIN SUBJECT ON SUBJECT.SUBJECT = PROGRESS.SUBJECT
JOIN PULPIT ON PULPIT.PULPIT = SUBJECT.PULPIT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
JOIN PROFESSION ON PROFESSION.PROFESSION = GROUPS.PROFESSION
ORDER BY
CASE 
	WHEN (PROGRESS.NOTE = 7) then 1
	WHEN (PROGRESS.NOTE = 8) then 2
	else 3
END;

-- 6. �� ������ ������ PULPIT � TEACHER �������� ������ �������� ������ (������� PULPIT.PULPIT_NAME)
-- � �������������� (������� TEACHER.TEACHER_NAME) �� ���� ��������. �������������� ����� ������ ���������
-- ��� �������: ������� � �������������. ���� �� ������� ��� ��������������, �� � ������� �������������
-- ������ ���� �������� ������ ***. 
-- ����������: ������������ ���������� ������ LEFT OUTER JOIN � ������� isnull.
SELECT PULPIT.PULPIT_NAME[�������], isnull(TEACHER.TEACHER_NAME,'***')[�������������]
FROM PULPIT LEFT OUTER JOIN TEACHER
ON TEACHER.PULPIT = PULPIT.PULPIT;

-- 7. ��������� ������: ������ � ������� ������� �� ����� ���� �������� NULL
SELECT PULPIT.PULPIT_NAME[�������], isnull(TEACHER.TEACHER_NAME,'***')[�������������]
FROM TEACHER LEFT OUTER JOIN PULPIT 
ON TEACHER.PULPIT = PULPIT.PULPIT;

-- 7. �������� ����������� ��������� � ����� ����, ������ � ����������� RIGHT OUTER JOIN
SELECT PULPIT.PULPIT_NAME[�������], isnull(TEACHER.TEACHER_NAME,'***')[�������������]
FROM PULPIT RIGHT OUTER JOIN TEACHER 
ON TEACHER.PULPIT = PULPIT.PULPIT;

-- 9. ����������� SELECT-������ �� ������ CROSS JOIN-���������� ������ AUDITORIUM_TYPE � AUDITORIUM,
-- ������������ ���������, ����������� ����������, ����������� ��� ���������� ������� � ������� 1.
SELECT AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME
FROM AUDITORIUM CROSS JOIN AUDITORIUM_TYPE
WHERE AUDITORIUM_TYPE.AUDITORIUM_TYPE = AUDITORIUM.AUDITORIUM_TYPE;
