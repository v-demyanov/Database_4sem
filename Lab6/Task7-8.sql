USE DVR_UNIVER;

-- ����� ��� ���������, ����������� ������� ������ ��� � ����� ��������� ���� ��-�
SELECT *
FROM AUDITORIUM 
WHERE AUDITORIUM_CAPACITY < ALL(SELECT AUDITORIUM_CAPACITY FROM AUDITORIUM WHERE AUDITORIUM_TYPE = '��-�');

-- ����� ��� ���������, ����������� ������� ������ ��� � ���� �� ����� ��������� ���� ��-�
SELECT *
FROM AUDITORIUM 
WHERE AUDITORIUM_CAPACITY < ANY(SELECT AUDITORIUM_CAPACITY FROM AUDITORIUM WHERE AUDITORIUM_TYPE = '��-�');