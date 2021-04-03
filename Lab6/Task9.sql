USE DVR_MyBase_Test;

SELECT *
FROM CURRICULUM
WHERE TEACHER IN(select TEACHER_KEY from TEACHER
				 where EXPERIENCE between 3 and 7);

SELECT TEACHER.TEACHER_LAST_NAME
FROM TEACHER
WHERE NOT EXISTS(select * from CURRICULUM
				 where TEACHER.TEACHER_KEY = CURRICULUM.TEACHER);

SELECT TOP 1
	(select max(HOURS_NUMBERS) from CURRICULUM where CLASS_TYPE like '������')[������],
	(select max(HOURS_NUMBERS) from CURRICULUM where CLASS_TYPE like '������������ ������')[����������� ������]
FROM CURRICULUM;

SELECT TEACHER_NAME
FROM TEACHER 
WHERE EXPERIENCE < ANY(select EXPERIENCE from TEACHER
						where TEACHER_NAME like '�%');


