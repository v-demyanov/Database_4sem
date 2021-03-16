USE DVR_UNIVER;

-- найти все аудитории, вместимость которых меньше чем у любой аудитории типа ЛК-К
SELECT *
FROM AUDITORIUM 
WHERE AUDITORIUM_CAPACITY < ALL(SELECT AUDITORIUM_CAPACITY FROM AUDITORIUM WHERE AUDITORIUM_TYPE = 'ЛК-К');

-- найти все аудитории, вместимость которых меньше чем у хотя бы одной аудитории типа ЛК-К
SELECT *
FROM AUDITORIUM 
WHERE AUDITORIUM_CAPACITY < ANY(SELECT AUDITORIUM_CAPACITY FROM AUDITORIUM WHERE AUDITORIUM_TYPE = 'ЛК-К');