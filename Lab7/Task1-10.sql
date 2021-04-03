USE DVR_UNIVER;


-- 1. �� ������ ������� AUDITORIUM ����������� SELECT-������,
-- ����������� ������������, ����������� � ������� ����������� ���������,
-- ��������� ����������� ���� ��������� � ����� ���������� ���������.
SELECT MAX(AUDITORIUM_CAPACITY)[������������ ����������� ���������],
	   MIN(AUDITORIUM_CAPACITY)[����������� ����������� ���������],
	   AVG(AUDITORIUM_CAPACITY)[������� ����������� ���������],
	   SUM(AUDITORIUM_CAPACITY)[��������� ����������� ���������],
	   COUNT(*)[����� ���������� ���������]
FROM AUDITORIUM;

-- 2. �� ������ ������ AUDITORIUM � AUDITORIUM_TYPE ����������� ������,
-- ����������� ��� ������� ���� ��������� ������������, �����������,
-- ������� ����������� ���������, ��������� ����������� ���� ���������
-- � ����� ���������� ��������� ������� ����. 
-- �������������� ����� ������ ��������� ������� � �������������
-- ���� ��������� (������� AUDITORIUM_TYPE.AUDITORIUM_TYPENAME)
-- � ������� � ������������ ����������.
SELECT AUDITORIUM_TYPE.AUDITORIUM_TYPENAME[��� ���������],
	   MAX(AUDITORIUM_CAPACITY)[������������ ����������� ���������],
	   MIN(AUDITORIUM_CAPACITY)[����������� ����������� ���������],
	   AVG(AUDITORIUM_CAPACITY)[������� ����������� ���������],
	   SUM(AUDITORIUM_CAPACITY)[��������� ����������� ���������],
	   COUNT(*)[����� ���������� ���������]
FROM AUDITORIUM 
JOIN AUDITORIUM_TYPE ON AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
GROUP BY AUDITORIUM_TYPENAME;

-- 3. ����������� ������ �� ������ ������� PROGRESS, ������� �������� ���������� ��������������� ������ � �������� ���������.
-- ��� ���� ������, ��� ���������� ����� ������ �������������� � �������, �������� �������� ������;
-- ����� �������� � ������� ���������� ������ ���� ����� ���������� ����� � ������� PROGRESS. 
SELECT *
FROM (select 
		case
		when NOTE between 4 and 5 then '4-5'
		when NOTE between 6 and 7 then '6-7'
		when NOTE between 8 and 9 then '8-9'
		else '10'
		end [������], count(*)[����������]
	  from PROGRESS group by case
		when NOTE between 4 and 5 then '4-5'
		when NOTE between 6 and 7 then '6-7'
		when NOTE between 8 and 9 then '8-9'
		else '10'
		end
	  ) AS T
ORDER BY CASE[������]
		 WHEN '4-5' THEN 5
		 WHEN '6-7' THEN 4
		 WHEN '8-9' THEN 3
		 WHEN '4-5' THEN 2
		 WHEN '10' THEN 1
		 ELSE 0
		 END;

-- 4. ����������� SELECT-������� �� ������ ������ FACULTY, GROUPS, STUDENT � PROGRESS, 
-- ������� �������� ������� ��������������� ������ ��� ������� ����� ������ �������������.
-- ������ ������������� � ������� �������� ������� ������.
-- ��� ���� ������� ������, ��� ������� ������ ������ �������������� � ��������� �� ���� ������ ����� �������. 
-- ������������ ���������� ���������� ������, ���������� ������� AVG � ���������� ������� CAST � ROUND.
SELECT FACULTY.FACULTY[���������],
	   GROUPS.PROFESSION[�������������],
	   GROUPS.YEAR_FIRST[����],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
GROUP BY FACULTY.FACULTY, GROUPS.PROFESSION, GROUPS.YEAR_FIRST
ORDER BY [������� ������] DESC;

-- ���������� SELECT-������, ������������� � ������� 4 ���, ����� � ������� �������� �������� ������ 
-- �������������� ������ ������ �� ����������� � ������ �� � ����. ��-���������� WHERE.
SELECT FACULTY.FACULTY[���������],
	   GROUPS.PROFESSION[�������������],
	   GROUPS.YEAR_FIRST[����],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
WHERE PROGRESS.SUBJECT = '����'
GROUP BY FACULTY.FACULTY, GROUPS.PROFESSION, GROUPS.YEAR_FIRST
ORDER BY [������� ������] DESC;

-- 5. �� ������ ������ FACULTY, GROUPS, STUDENT � PROGRESS ����������� SELECT-������,
-- � ������� ��������� �������������, ���������� � ������� ������ ��� ����� ��������� 
-- �� ���������� ���. ������������ ����������� �� ����� FACULTY, PROFESSION, SUBJECT.
SELECT GROUPS.FACULTY[���������],
	   GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
WHERE GROUPS.FACULTY = '����'
GROUP BY GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT; 

-- �������� � ������ ����������� ROLLUP � ���������������� ���������.
SELECT GROUPS.FACULTY[���������],
	   GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
WHERE GROUPS.FACULTY = '����'
GROUP BY ROLLUP (GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- 6. ��������� �������� SELECT-������ �.5 � �������������� CUBE-�����������. ���������������� ���������.
SELECT FACULTY.FACULTY[���������],
	   GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
WHERE GROUPS.FACULTY = '����'
GROUP BY CUBE (FACULTY.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- 7. �� ������ ������ GROUPS, STUDENT � PROGRESS ����������� SELECT-������,
-- � ������� ������������ ���������� ����� ���������.

-- !!!!!!!
-- � ������ ���������� ��������� �������: OR (GROUPS.FACULTY = '����' AND GROUPS.PROFESSION = '1-40 01 02')
-- ����� ������� ���������� ������ � ���� ��������

-- UNION
(SELECT GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = '����' OR (GROUPS.FACULTY = '����' AND GROUPS.PROFESSION = '1-40 01 02')
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT)
	UNION
(SELECT GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = '����'
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- UNION ALL
(SELECT GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = '����' OR (GROUPS.FACULTY = '����' AND GROUPS.PROFESSION = '1-40 01 02')
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT)
	UNION ALL
(SELECT GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = '����'
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- 8. �������� ����������� ���� �������� �����, ��������� � ���������� ���������� �������� ������ 8.
-- ��������� ���������. ������������ �������� INTERSECT.
(SELECT GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = '����' OR (GROUPS.FACULTY = '����' AND GROUPS.PROFESSION = '1-40 01 02')
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT)
	INTERSECT
(SELECT GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = '����'
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- 9. �������� ������� ����� ���������� �����, ��������� � ���������� �������� ������ 8. ��������� ���������. 
-- ������������ �������� EXCEPT.
(SELECT GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = '����' OR (GROUPS.FACULTY = '����' AND GROUPS.PROFESSION = '1-40 01 02')
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT)
	EXCEPT
(SELECT GROUPS.PROFESSION[�������������],
	   PROGRESS.SUBJECT[����������],
	   ROUND(AVG(CAST(PROGRESS.NOTE AS FLOAT(4))), 2)[������� ������]
FROM PROGRESS JOIN STUDENT ON PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
WHERE GROUPS.FACULTY = '����'
GROUP BY GROUPS.PROFESSION, PROGRESS.SUBJECT);

-- 10. �� ������ ������� PROGRESS ���������� ��� ������ ���������� ���������� ���������, ���������� ������ 8 � 9.
-- ������������ �����������, ������ HAVING, ����������.
SELECT p1.SUBJECT[����������], p1.NOTE,
(
	select count(*) from PROGRESS p2
	where p2.SUBJECT = p1.SUBJECT and p2.NOTE = p1.NOTE
)[���������� ���������]
FROM PROGRESS p1
GROUP BY p1.SUBJECT, p1.NOTE
HAVING p1.NOTE = 9 OR p1.NOTE = 8;

-- 12*. ���������� ���������� ��������� � ������ ������, �� ������ ���������� � ����� � ������������ ����� ��������.
-- ���������� ���������� ��������� �� ����� � ��������� ����������� � �������� � ����� ����� ��������.

-- ���������� ��������� � ������ ������
(SELECT GROUPS.IDGROUP,
(
	select count(*) from STUDENT
	where STUDENT.IDGROUP = GROUPS.IDGROUP
)[���������� ���������]
FROM GROUPS
GROUP BY GROUPS.IDGROUP)
	
-- ���������� ��������� �� ������ ����������
(SELECT f1.FACULTY,
(
	select count(*) from STUDENT
	join GROUPS on STUDENT.IDGROUP = GROUPS.IDGROUP
	join FACULTY f2 on GROUPS.FACULTY = f2.FACULTY
	where f2.FACULTY = f1.FACULTY
)[���������� ���������]
FROM FACULTY f1
GROUP BY f1.FACULTY)

-- ���������� ��������� � ������������
SELECT COUNT(*) AS '���������� ��������� � ������������' FROM STUDENT;


-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- ���������� ���������� ��������� �� ����� � ��������� ����������� � ��������
SELECT AUDITORIUM_TYPE.AUDITORIUM_TYPE,
(
	select count(*) from AUDITORIUM
	where AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
)[���������� ���������]
FROM AUDITORIUM_TYPE
GROUP BY AUDITORIUM_TYPE.AUDITORIUM_TYPE;

SELECT AUDITORIUM_TYPE.AUDITORIUM_TYPENAME[��� ���������],
	   SUM(AUDITORIUM_CAPACITY)[��������� ����������� ���������],
	   COUNT(*)[����� ���������� ���������]
FROM AUDITORIUM 
JOIN AUDITORIUM_TYPE ON AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
GROUP BY AUDITORIUM_TYPENAME;
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

