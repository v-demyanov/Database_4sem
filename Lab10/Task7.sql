USE DVR_MyBase_Test;

-- 1
EXEC SP_HELPINDEX 'CLASS_TYPE'
EXEC SP_HELPINDEX 'CURRICULUM';
EXEC SP_HELPINDEX 'GROUPS';
EXEC SP_HELPINDEX 'SPECIALTY';
EXEC SP_HELPINDEX 'SUBJECT';
EXEC SP_HELPINDEX 'TEACHER';

-- 2
CHECKPOINT;  --�������� ��
DBCC DROPCLEANBUFFERS;  --�������� �������� ���

SELECT * FROM CLASS_TYPE;

-- 3
CREATE INDEX #NON_CL_INDEX_CURRICULUM ON TEACHER(EXPERIENCE,TEACHER_NAME);

SELECT * FROM TEACHER WHERE EXPERIENCE BETWEEN 3 AND 8
SELECT * FROM TEACHER ORDER BY EXPERIENCE,TEACHER_NAME;
SELECT * FROM TEACHER WHERE EXPERIENCE = 3 AND TEACHER_NAME LIKE '�%'; -- �������� ������ 

DROP INDEX #NON_CL_INDEX_CURRICULUM ON TEACHER;

-- 4
CREATE INDEX #NON_CL_INDEX_CURRICULUM ON CURRICULUM(HOURS_NUMBERS) INCLUDE (PAYMENT);

SELECT PAYMENT FROM CURRICULUM WHERE HOURS_NUMBERS > 50;

-- 5
CREATE INDEX #INDEX_WHERE_GROUPS ON GROUPS(STUDENT_NUMBERS) WHERE STUDENT_NUMBERS >= 20 AND STUDENT_NUMBERS < 30;

SELECT STUDENT_NUMBERS FROM GROUPS
WHERE STUDENT_NUMBERS >= 20 AND STUDENT_NUMBERS < 30;

SELECT STUDENT_NUMBERS FROM GROUPS
WHERE STUDENT_NUMBERS BETWEEN 0 AND 10;

SELECT STUDENT_NUMBERS FROM GROUPS
WHERE STUDENT_NUMBERS >= 30;