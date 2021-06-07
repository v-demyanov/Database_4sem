USE DVR_UNIVER;

-- 1. �������� xml-��� � ������ PATH
go
SELECT TEACHER.TEACHER[TeacherShortName], TEACHER.TEACHER_NAME[TeacherName], 
    TEACHER.GENDER[Gender], TEACHER.PULPIT[Pulpit]
FROM TEACHER WHERE TEACHER.PULPIT = '����'
FOR XML PATH('Teacher'), ROOT('Teachers');

-- 2. �������� xml-��� � ������ AUTO
go
SELECT AUDITORIUM.AUDITORIUM_NAME [AuditoriumName],
	   AUDITORIUM_TYPE.AUDITORIUM_TYPENAME [AuditoriumTypeName],
	   AUDITORIUM.AUDITORIUM_CAPACITY [AuditoriumCapacity]
FROM AUDITORIUM 
JOIN AUDITORIUM_TYPE ON AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
WHERE AUDITORIUM_TYPE.AUDITORIUM_TYPE = '��'
FOR XML AUTO, ROOT('AuditoriumCollection');

-- 3. ��������� ������� �� XML-doc
go
DECLARE @h INT = 0,
		@x VARCHAR(2000) = ' <?xml version="1.0" encoding="windows-1251" ?>
       <SUBJECTS> 
       <SUBJECT SUBJECT="SubjL16_1" SUBJECT_NAME="Subj_Lab16_1" PULPIT="����" />
	   <SUBJECT SUBJECT="SubjL16_2" SUBJECT_NAME="Subj_Lab16_2" PULPIT="����" />
	   <SUBJECT SUBJECT="SubjL16_3" SUBJECT_NAME="Subj_Lab16_3" PULPIT="����" />
       </SUBJECTS>';

EXEC sp_xml_preparedocument @h OUTPUT, @x;  -- ���������� ��������� 
INSERT INTO SUBJECT SELECT * FROM OPENXML(@h, '/SUBJECTS/SUBJECT', 0)
WITH([SUBJECT] CHAR(10), [SUBJECT_NAME] VARCHAR(100), [PULPIT] CHAR(20))       
EXEC sp_xml_removedocument @h;              -- �������� ���������

DELETE SUBJECT WHERE SUBJECT LIKE '%SubjL16%';
SELECT * FROM SUBJECT;

-- 4. insert ����������� � ������� xml-���������
SELECT * FROM STUDENT;

INSERT INTO STUDENT(IDGROUP, NAME, BDAY, INFO)
	VALUES(5, '�������� ��������� ����������', '2002-02-18',
	'<�������>
		<������� �����="MP" �����="3245761" ����="11.03.2015" />
		<�����>
			<������>��������</������>
			<�����>�����</�����>
			<�����>���������� �����</�����>
			<���>34</���>
			<��������>48</��������>
		</�����>
	</�������>');
--<�������>+375291076745</�������>
SELECT * FROM STUDENT WHERE NAME = '�������� ��������� ����������';

UPDATE STUDENT SET INFO =
	'<�������>
		<������� �����="MP" �����="1234567" ����="21.07.2021" />
		<�������>+375291076745</�������>
		<�����>
			<������>��������</������>
			<�����>�����</�����>
			<�����>���������� �����</�����>
			<���>34</���>
			<��������>48</��������>
		</�����>
	</�������>'
WHERE NAME = '�������� ��������� ����������';

SELECT NAME, INFO.value('(�������/�������/@�����)[1]', 'char(2)')[����� ��������],
	INFO.value('(�������/�������/@�����)[1]', 'varchar(20)')[����� ��������],
	INFO.query('/�������/�����')[�����]
FROM STUDENT
WHERE NAME = '�������� ��������� ����������';

DELETE STUDENT WHERE NAME = '�������� ��������� ����������';

-- 5. XML SCHEMACOLLECTION 
go
create xml schema collection Student as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" 
           elementFormDefault="qualified"
           xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="�������">  
  <xs:complexType>
  <xs:sequence>
       <xs:element name="�������" maxOccurs="1" minOccurs="1">
			<xs:complexType>
				<xs:attribute name="�����" type="xs:string" use="required" />
				<xs:attribute name="�����" type="xs:unsignedInt" use="required"/>
				<xs:attribute name="����" use="required" >  
					<xs:simpleType>  
						<xs:restriction base="xs:string">
							<xs:pattern value="[0-9]{2}.[0-9]{2}.[0-9]{4}"/>
						</xs:restriction> 	
					</xs:simpleType>
				</xs:attribute>
			</xs:complexType> 
		</xs:element>
		<xs:element name="�����">   
			<xs:complexType>
				<xs:sequence>
					<xs:element name="������" type="xs:string" />
					<xs:element name="�����" type="xs:string" />
					<xs:element name="�����" type="xs:string" />
					<xs:element name="���" type="xs:string" />
					<xs:element name="��������" type="xs:string" />
				</xs:sequence>
			</xs:complexType>
		</xs:element>
   </xs:sequence>
   </xs:complexType>
   </xs:element>
</xs:schema>';
--<xs:element maxOccurs="3" name="�������" type="xs:unsignedInt"/>
ALTER TABLE STUDENT ALTER COLUMN INFO XML(Student);
DROP XML SCHEMA COLLECTION Student;
SELECT * FROM STUDENT WHERE NAME = '�������� ��������� ����������';


INSERT INTO STUDENT(IDGROUP, NAME, BDAY, INFO)
	VALUES(5, '�������� ��������� ����������', '2002-02-18',
	'<�������>
		<������� �����="MP" �����="1234567" ����="11.03.2015" />
		<������� �������="+375291076745" />
		<�����>
			<������>��������</������>
			<�����>�����</�����>
			<�����>���������� �����</�����>
			<���>34</���>
			<��������>48</��������>
		</�����>
	</�������>');

-- 7.
 
SELECT f.FACULTY as "@���",
	   (select COUNT(*) from PULPIT as P where P.FACULTY = f.FACULTY) as "����������_������",
	   (select p.PULPIT as "@���",
			   (select t.TEACHER as "�������������/@���",
					   t.TEACHER_NAME as "�������������"
				from TEACHER as t where t.PULPIT = p.PULPIT
				for xml path(''), type, root('�������������'))
		from PULPIT as p where p.FACULTY = f.FACULTY 
		for xml path('�������'), type, root('�������')) 
FROM FACULTY as f
FOR XML PATH('���������'), TYPE, ROOT('�����������');