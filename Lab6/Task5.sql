USE DVR_UNIVER;

SELECT FACULTY_NAME
FROM FACULTY
WHERE NOT EXISTS (SELECT * FROM PULPIT WHERE PULPIT.FACULTY = FACULTY.FACULTY);