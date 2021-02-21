use master
go
create database DVR_UNIVER
on primary
(name=N'DVR_UNIVER_mdf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_UNIVER\DVR_UNIVER.mdf',
 size=5120Kb, maxsize=10240Kb, filegrowth=1024Kb),
(name=N'DVR_UNIVER_ndf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_UNIVER\DVR_UNIVER.ndf',
 size=5120Kb, maxsize=10240Kb, filegrowth=10%),

filegroup G1
(name=N'DVR_UNIVER11_ndf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_UNIVER\DVR_UNIVER11.ndf',
 size=10240Kb, maxsize=15360Kb, filegrowth=1024Kb),
(name=N'DVR_UNIVER12_ndf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_UNIVER\DVR_UNIVER12.ndf',
 size=2048Kb, maxsize=5120Kb, filegrowth=1024Kb),

 filegroup G2
(name=N'DVR_UNIVER21_ndf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_UNIVER\DVR_UNIVER21.ndf',
 size=5120Kb, maxsize=10240Kb, filegrowth=1024Kb),
(name=N'DVR_UNIVER22_ndf', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_UNIVER\DVR_UNIVER22.ndf',
 size=2048Kb, maxsize=5120Kb, filegrowth=1024Kb)

 log on
(name=N'DVR_UNIVER_log', filename=N'D:\Study\FourthSem\Database\Labs\Database\DVR_UNIVER\DVR_UNIVER.ldf',
 size=5120Kb, maxsize=UNLIMITED, filegrowth=1024Kb)
go