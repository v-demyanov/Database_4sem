USE DVR_UNIVER;

-- 1. На основе таблиц AUDITORIUM_TYPE и AUDITORIUM сформировать перечень кодов аудиторий (столбец AUDITORUM.AUDITORIUM)
-- и соответствующих им наименований типов аудиторий (столбец AUDITORIUM_TYPE.AUDITORIUM_TYPENAME).
-- Примечание: использовать соединение таблиц INNER JOIN. 
SELECT AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME
FROM AUDITORIUM 
JOIN AUDITORIUM_TYPE ON AUDITORIUM_TYPE.AUDITORIUM_TYPE = AUDITORIUM.AUDITORIUM_TYPE;

-- 2. На основе таблиц AUDITORIUM_TYPE и AUDITORIUM сформировать перечень кодов аудиторий (столбец AUDITORIUM.AUDITORIUM)
-- и соответствующих им наименований типов аудиторий (столбец AUDITORIUM_TYPE.AUDITORIUM_TYPENAME). 
-- При этом следует выбрать только те аудитории, в наименовании которых присутствует подстрока компьютер. 
-- Примечание: использовать соединение таблиц INNER JOIN и предикат LIKE. 
SELECT A.AUDITORIUM, AT.AUDITORIUM_TYPENAME
FROM AUDITORIUM AS A
JOIN AUDITORIUM_TYPE AS AT
ON AT.AUDITORIUM_TYPE = A.AUDITORIUM_TYPE AND AT.AUDITORIUM_TYPENAME LIKE '%компьютер%';

-- 3. Написать два SELECT-запроса, формирующих результирующие наборы аналогичные запросам из заданий 1 и 2,
-- но без применения INNER JOIN.
SELECT A.AUDITORIUM, AT.AUDITORIUM_TYPENAME
FROM AUDITORIUM AS A, AUDITORIUM_TYPE AS AT
WHERE AT.AUDITORIUM_TYPE = A.AUDITORIUM_TYPE AND AT.AUDITORIUM_TYPENAME LIKE '%компьютер%';

-- 4. На основе таблиц PRORGESS, STUDENT, GROUPS, SUBJECT, PULPIT и FACULTY сформировать перечень студентов,
-- получивших экзаменационные оценки (столбец PROGRESS.NOTE) от 6 до 8. 
-- Результирующий набор должен содержать столбцы: Факультет, Кафедра, Специальность, Дисциплина, Имя Студента, Оценка.
-- В столбце Оценка должны быть записаны экзаменационные оценки прописью: шесть, семь, восемь. 
-- Результирующий набор отсортировать в порядке возрастания по столбцам FACULTY.FACULTY, PULPIT.PULPIT, PROFESSION.PROFESSION,
-- STUDENT.STUDENT_NAME и в порядке убывания по столбцу PROGRESS.NOTE.
-- Примечание: использовать соединение INNER JOIN, предикат BETWEEN и выражение CASE.
SELECT FACULTY.FACULTY AS 'Факультет', 
	   PULPIT.PULPIT AS 'Кафедра',
	   PROFESSION.PROFESSION AS 'Специальность',
	   SUBJECT.SUBJECT AS 'Дисциплина',
	   STUDENT.NAME AS 'Имя студента',
CASE
	WHEN (PROGRESS.NOTE = 6) then 'шесть'
	WHEN (PROGRESS.NOTE = 7) then 'семь'
	WHEN (PROGRESS.NOTE = 8) then 'восемь'
END 'Оценка'
FROM PROGRESS
JOIN STUDENT ON STUDENT.IDSTUDENT = PROGRESS.IDSTUDENT AND PROGRESS.NOTE BETWEEN 6 AND 8
JOIN SUBJECT ON SUBJECT.SUBJECT = PROGRESS.SUBJECT
JOIN PULPIT ON PULPIT.PULPIT = SUBJECT.PULPIT
JOIN GROUPS ON GROUPS.IDGROUP = STUDENT.IDGROUP
JOIN FACULTY ON FACULTY.FACULTY = GROUPS.FACULTY
JOIN PROFESSION ON PROFESSION.PROFESSION = GROUPS.PROFESSION
ORDER BY FACULTY.FACULTY, PULPIT.PULPIT, PROFESSION.PROFESSION, STUDENT.NAME ASC, PROGRESS.NOTE DESC;

-- 5. Переписать запрос, реализующий задание 4 таким образом, чтобы в результирующем наборе сортировка
-- по экзаменационным оценкам была следующей: сначала выводились строки с оценкой 7, затем строки с оценкой 8
-- и далее строки с оценкой 6. 
-- Примечание: использовать выражение CASE в секции ORDER BY.
SELECT FACULTY.FACULTY AS 'Факультет', 
	   PULPIT.PULPIT AS 'Кафедра',
	   PROFESSION.PROFESSION AS 'Специальность',
	   SUBJECT.SUBJECT AS 'Дисциплина',
	   STUDENT.NAME AS 'Имя студента',
CASE
	WHEN (PROGRESS.NOTE = 6) then 'шесть'
	WHEN (PROGRESS.NOTE = 7) then 'семь'
	WHEN (PROGRESS.NOTE = 8) then 'восемь'
END 'Оценка'
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

-- 6. На основе таблиц PULPIT и TEACHER получить полный перечень кафедр (столбец PULPIT.PULPIT_NAME)
-- и преподавателей (столбец TEACHER.TEACHER_NAME) на этих кафедрах. Результирующий набор должен содержать
-- два столбца: Кафедра и Преподаватель. Если на кафедре нет преподавателей, то в столбце Преподаватель
-- должна быть выведена строка ***. 
-- Примечание: использовать соединение таблиц LEFT OUTER JOIN и функцию isnull.
SELECT PULPIT.PULPIT_NAME[Кафедра], isnull(TEACHER.TEACHER_NAME,'***')[Преподаватель]
FROM PULPIT LEFT OUTER JOIN TEACHER
ON TEACHER.PULPIT = PULPIT.PULPIT;

-- 7. объяснить почему: почему в столбце Кафедра не может быть значения NULL
SELECT PULPIT.PULPIT_NAME[Кафедра], isnull(TEACHER.TEACHER_NAME,'***')[Преподаватель]
FROM TEACHER LEFT OUTER JOIN PULPIT 
ON TEACHER.PULPIT = PULPIT.PULPIT;

-- 7. получить аналогичный результат с кодом выше, только с применением RIGHT OUTER JOIN
SELECT PULPIT.PULPIT_NAME[Кафедра], isnull(TEACHER.TEACHER_NAME,'***')[Преподаватель]
FROM PULPIT RIGHT OUTER JOIN TEACHER 
ON TEACHER.PULPIT = PULPIT.PULPIT;

-- 9. Разработать SELECT-запрос на основе CROSS JOIN-соединения таблиц AUDITORIUM_TYPE и AUDITORIUM,
-- формирующего результат, аналогичный результату, полученному при выполнении запроса в задании 1.
SELECT AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME
FROM AUDITORIUM CROSS JOIN AUDITORIUM_TYPE
WHERE AUDITORIUM_TYPE.AUDITORIUM_TYPE = AUDITORIUM.AUDITORIUM_TYPE;
