USE DVR_UNIVER;

-- объяснить почему: почему в столбце Кафедра не может быть значения NULL
SELECT PULPIT.PULPIT_NAME[Кафедра], isnull(TEACHER.TEACHER_NAME,'***')[Преподаватель]
FROM TEACHER LEFT OUTER JOIN PULPIT 
ON TEACHER.PULPIT = PULPIT.PULPIT;

-- получить аналогичный результат с кодом выше, только с применением RIGHT OUTER JOIN
SELECT PULPIT.PULPIT_NAME[Кафедра], isnull(TEACHER.TEACHER_NAME,'***')[Преподаватель]
FROM PULPIT RIGHT OUTER JOIN TEACHER 
ON TEACHER.PULPIT = PULPIT.PULPIT;