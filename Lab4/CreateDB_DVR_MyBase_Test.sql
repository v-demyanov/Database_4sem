use master
go
create database DVR_MyBase_Test
on primary
(name=N'DVR_MyBase_Test_mdf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_MyBase_Test\DVR_MyBase_Test.mdf',
 size=5120Kb, maxsize=10240Kb, filegrowth=1024Kb),
(name=N'DVR_MyBase_Test_ndf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_MyBase_Test\DVR_MyBase_Test.ndf',
 size=5120Kb, maxsize=10240Kb, filegrowth=10%),

filegroup G1
(name=N'DVR_MyBase_Test11_ndf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_MyBase_Test\DVR_MyBase_Test11.ndf',
 size=10240Kb, maxsize=15360Kb, filegrowth=1024Kb),
(name=N'DVR_MyBase_Test12_ndf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_MyBase_Test\DVR_MyBase_Test12.ndf',
 size=2048Kb, maxsize=5120Kb, filegrowth=1024Kb),

 filegroup G2
(name=N'DVR_MyBase_Test21_ndf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_MyBase_Test\DVR_MyBase_Test21.ndf',
 size=5120Kb, maxsize=10240Kb, filegrowth=1024Kb),
(name=N'DVR_MyBase_Test22_ndf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_MyBase_Test\DVR_MyBase_Test22.ndf',
 size=2048Kb, maxsize=5120Kb, filegrowth=1024Kb)

 log on
(name=N'DVR_MyBase_Test_log', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_MyBase_Test\DVR_MyBase_Test.ldf',
 size=5120Kb, maxsize=UNLIMITED, filegrowth=1024Kb)
go