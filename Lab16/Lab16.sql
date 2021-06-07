USE DVR_UNIVER;

-- 1. создание xml-док в режиме PATH
go
SELECT TEACHER.TEACHER[TeacherShortName], TEACHER.TEACHER_NAME[TeacherName], 
    TEACHER.GENDER[Gender], TEACHER.PULPIT[Pulpit]
FROM TEACHER WHERE TEACHER.PULPIT = 'ИСиТ'
FOR XML PATH('Teacher'), ROOT('Teachers');

-- 2. создание xml-док в режиме AUTO
go
SELECT AUDITORIUM.AUDITORIUM_NAME [AuditoriumName],
	   AUDITORIUM_TYPE.AUDITORIUM_TYPENAME [AuditoriumTypeName],
	   AUDITORIUM.AUDITORIUM_CAPACITY [AuditoriumCapacity]
FROM AUDITORIUM 
JOIN AUDITORIUM_TYPE ON AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
WHERE AUDITORIUM_TYPE.AUDITORIUM_TYPE = 'ЛК'
FOR XML AUTO, ROOT('AuditoriumCollection');

-- 3. Заполнить таблицу из XML-doc
go
DECLARE @h INT = 0,
		@x VARCHAR(2000) = ' <?xml version="1.0" encoding="windows-1251" ?>
       <SUBJECTS> 
       <SUBJECT SUBJECT="SubjL16_1" SUBJECT_NAME="Subj_Lab16_1" PULPIT="ИСиТ" />
	   <SUBJECT SUBJECT="SubjL16_2" SUBJECT_NAME="Subj_Lab16_2" PULPIT="ИСиТ" />
	   <SUBJECT SUBJECT="SubjL16_3" SUBJECT_NAME="Subj_Lab16_3" PULPIT="ИСиТ" />
       </SUBJECTS>';

EXEC sp_xml_preparedocument @h OUTPUT, @x;  -- подготовка документа 
INSERT INTO SUBJECT SELECT * FROM OPENXML(@h, '/SUBJECTS/SUBJECT', 0)
WITH([SUBJECT] CHAR(10), [SUBJECT_NAME] VARCHAR(100), [PULPIT] CHAR(20))       
EXEC sp_xml_removedocument @h;              -- удаление документа

DELETE SUBJECT WHERE SUBJECT LIKE '%SubjL16%';
SELECT * FROM SUBJECT;

-- 4. insert добавляющий в таблицу xml-структуру
SELECT * FROM STUDENT;

INSERT INTO STUDENT(IDGROUP, NAME, BDAY, INFO)
	VALUES(5, 'Демьянов Владислав Русланович', '2002-02-18',
	'<студент>
		<паспорт серия="MP" номер="3245761" дата="11.03.2015" />
		<адрес>
			<страна>Беларусь</страна>
			<город>Минск</город>
			<улица>Игуменский тракт</улица>
			<дом>34</дом>
			<квартира>48</квартира>
		</адрес>
	</студент>');
--<телефон>+375291076745</телефон>
SELECT * FROM STUDENT WHERE NAME = 'Демьянов Владислав Русланович';

UPDATE STUDENT SET INFO =
	'<студент>
		<паспорт серия="MP" номер="1234567" дата="21.07.2021" />
		<телефон>+375291076745</телефон>
		<адрес>
			<страна>Беларусь</страна>
			<город>Минск</город>
			<улица>Игуменский тракт</улица>
			<дом>34</дом>
			<квартира>48</квартира>
		</адрес>
	</студент>'
WHERE NAME = 'Демьянов Владислав Русланович';

SELECT NAME, INFO.value('(студент/паспорт/@серия)[1]', 'char(2)')[серия паспорта],
	INFO.value('(студент/паспорт/@номер)[1]', 'varchar(20)')[номер паспорта],
	INFO.query('/студент/адрес')[адрес]
FROM STUDENT
WHERE NAME = 'Демьянов Владислав Русланович';

DELETE STUDENT WHERE NAME = 'Демьянов Владислав Русланович';

-- 5. XML SCHEMACOLLECTION 
go
create xml schema collection Student as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" 
           elementFormDefault="qualified"
           xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="студент">  
  <xs:complexType>
  <xs:sequence>
       <xs:element name="паспорт" maxOccurs="1" minOccurs="1">
			<xs:complexType>
				<xs:attribute name="серия" type="xs:string" use="required" />
				<xs:attribute name="номер" type="xs:unsignedInt" use="required"/>
				<xs:attribute name="дата" use="required" >  
					<xs:simpleType>  
						<xs:restriction base="xs:string">
							<xs:pattern value="[0-9]{2}.[0-9]{2}.[0-9]{4}"/>
						</xs:restriction> 	
					</xs:simpleType>
				</xs:attribute>
			</xs:complexType> 
		</xs:element>
		<xs:element name="адрес">   
			<xs:complexType>
				<xs:sequence>
					<xs:element name="страна" type="xs:string" />
					<xs:element name="город" type="xs:string" />
					<xs:element name="улица" type="xs:string" />
					<xs:element name="дом" type="xs:string" />
					<xs:element name="квартира" type="xs:string" />
				</xs:sequence>
			</xs:complexType>
		</xs:element>
   </xs:sequence>
   </xs:complexType>
   </xs:element>
</xs:schema>';
--<xs:element maxOccurs="3" name="телефон" type="xs:unsignedInt"/>
ALTER TABLE STUDENT ALTER COLUMN INFO XML(Student);
DROP XML SCHEMA COLLECTION Student;
SELECT * FROM STUDENT WHERE NAME = 'Демьянов Владислав Русланович';


INSERT INTO STUDENT(IDGROUP, NAME, BDAY, INFO)
	VALUES(5, 'Демьянов Владислав Русланович', '2002-02-18',
	'<студент>
		<паспорт серия="MP" номер="1234567" дата="11.03.2015" />
		<телефон телефон="+375291076745" />
		<адрес>
			<страна>Беларусь</страна>
			<город>Минск</город>
			<улица>Игуменский тракт</улица>
			<дом>34</дом>
			<квартира>48</квартира>
		</адрес>
	</студент>');

-- 7.
 
SELECT f.FACULTY as "@код",
	   (select COUNT(*) from PULPIT as P where P.FACULTY = f.FACULTY) as "количество_кафедр",
	   (select p.PULPIT as "@код",
			   (select t.TEACHER as "преподаватель/@код",
					   t.TEACHER_NAME as "преподаватель"
				from TEACHER as t where t.PULPIT = p.PULPIT
				for xml path(''), type, root('преподаватели'))
		from PULPIT as p where p.FACULTY = f.FACULTY 
		for xml path('кафедра'), type, root('кафедры')) 
FROM FACULTY as f
FOR XML PATH('факультет'), TYPE, ROOT('университет');