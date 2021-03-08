USE DVR_MyBase_Test;

-- �������� ���������������
-- ����������� LEFT JOIN and RIGHT JOIN
-- ��������� INNER JOIN
SELECT *
FROM TEACHER FULL OUTER JOIN CURRICULUM
ON CURRICULUM.TEACHER = TEACHER.TEACHER_KEY;

SELECT *
FROM  CURRICULUM FULL OUTER JOIN TEACHER
ON CURRICULUM.TEACHER = TEACHER.TEACHER_KEY;

-- ������, ��������� �������� �������� ������ ����� (� �������� FULL OUTER JOIN) ������� 
-- � �� �������� ������ ������
SELECT *
FROM  TEACHER FULL OUTER JOIN CURRICULUM 
ON CURRICULUM.TEACHER = TEACHER.TEACHER_KEY
WHERE CURRICULUM.CURRICULUM_KEY IS NULL;

-- ������, ��������� �������� �������� ������ ������ ������� � �� ���������� ������ ��-���
SELECT *
FROM  CURRICULUM FULL OUTER JOIN TEACHER 
ON CURRICULUM.TEACHER = TEACHER.TEACHER_KEY
WHERE CURRICULUM.CURRICULUM_KEY IS NULL;

-- ������, ��������� �������� �������� ������ ������ ������� � ����� ������
SELECT *
FROM  CURRICULUM FULL OUTER JOIN TEACHER -- ����� ���� ������������ INNER JOIN ��� WHERE � �����
ON CURRICULUM.TEACHER = TEACHER.TEACHER_KEY
WHERE CURRICULUM.TEACHER IS NOT NULL AND TEACHER.TEACHER_KEY IS NOT NULL;