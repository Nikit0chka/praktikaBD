USE master;

--Запарился и создал процедуру создающую логин на уровне сервака
DROP PROCEDURE IF EXISTS CreateLogin;

GO
CREATE PROCEDURE CreateLogin @LoginName varchar(50), @LoginPassword varchar (50)
AS
BEGIN
DECLARE @sqlCommand nvarchar(1000)
IF NOT EXISTS (SELECT NAME from sys.server_principals  WHERE TYPE = 'S' and NAME = @LoginName)
	SELECT @sqlCommand = 'CREATE LOGIN "' + @LoginName + '" WITH PASSWORD = ''' + @LoginPassword+ ''', CHECK_POLICY = OFF'
EXEC sp_executesql @sqlCommand
END;
GO

EXEC CreateLogin 'NikitaReadOnly', 'NikitaReadOnly';
EXEC CreateLogin 'NIkitaAdmin','NIkitaAdmin';
EXEC CreateLogin 'NikitaWriteOnly', 'NikitaWriteOnly';

--Удаление базы данных, если она уже была создана
DROP DATABASE IF EXISTS ChildrenCamp;

--Создание базы данных
CREATE DATABASE ChildrenCamp;

--Переключение на созданную базу данных
USE ChildrenCamp;

--Создание таблицы Транспорт
CREATE TABLE Transports
(
	TransportCode INT IDENTITY (1, 1) PRIMARY KEY,
	TransportType CHAR (255) NOT NULL,
	Timetable NVARCHAR (255)
)

--Создание таблицы Отряды
CREATE TABLE Squads
(
	SquadCode INT IDENTITY (1, 1) PRIMARY KEY,
	SquadName NVARCHAR (255) NOT NULL,
	SquadCharacter NVARCHAR (255)
)

--Создание таблицы Секции
CREATE TABLE Sections
(
	SectionCode INT IDENTITY (1, 1) PRIMARY KEY,
	SectionName NVARCHAR (255) NOT NULL,
	TimetableLink NVARCHAR (255) NOT NULL
)

--Создание таблицы Дополнительной таблицы Отряды секций
CREATE TABLE SquadSections
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	SectionCode INT NOT NULL REFERENCES Sections(SectionCode) ON DELETE CASCADE,
	SquadCode INT NOT NULL REFERENCES Squads(SquadCode) ON DELETE CASCADE
)

--Создание таблицы Корпуса
CREATE TABLE Housings
(
	HousingCode INT IDENTITY (1, 1) PRIMARY KEY,
	HousingType NVARCHAR (255) NOT NULL,
	HousingName NVARCHAR (255) NOT NULL,
	NumberOfRoom INT NOT NULL,
	SquadCode INT REFERENCES Squads(SquadCode) ON DELETE CASCADE
)

--Создание таблицы Сотрудники лагеря
CREATE TABLE CampEmployees
(
	CampEmployeeCode INT IDENTITY (1, 1) PRIMARY KEY,
	FullName NVARCHAR (255) NOT NULL,
	Portfolio NVARCHAR (255) NOT NULL,
	Post NVARCHAR (255) NOT NULL,
	SquadLeaderCode INT REFERENCES Squads(SquadCode) ON DELETE SET NULL,
	DriverTransportCode INT REFERENCES Transports(TransportCode) ON DELETE CASCADE,
	CampEmployeerHousingCode INT NOT NULL REFERENCES Housings(HousingCode) ON DELETE NO ACTION
)

--Создание таблицы Инвентарь
CREATE TABLE Inventory
(
	InventoryCode INT IDENTITY (1, 1) PRIMARY KEY,
	InventoryType NVARCHAR (255) NOT NULL,	
	ShelfLife DATE 
)

--Создание дополнительной таблицы Иневентарь корпуса
CREATE TABLE HousingInventory
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	DateOfReceipt DATE NOT NULL,
	InventoryCode INT NOT NULL REFERENCES Inventory(InventoryCode) ON DELETE CASCADE,
	HousingCode INT NOT NULL REFERENCES Housings(HousingCode) ON DELETE CASCADE
)

--Создание таблицы Мероприятия
CREATE TABLE CampEvents
(
	EventCode INT IDENTITY (1, 1) PRIMARY KEY,
	EventName NVARCHAR (255) NOT NULL,
	DateOfEvent DATE NOT NULL,
	PlaceOfEvent NVARCHAR (255) NOT NULL
)

--Создание дополнительной таблицы Инвентарь мероприятия
CREATE TABLE EventInventory
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	EventCode INT NOT NULL REFERENCES CampEvents(EventCode) ON DELETE CASCADE,
	InventoryCode INT NOT NULL REFERENCES Inventory(InventoryCode) ON DELETE CASCADE
)

--Создание дополнительной таблицы Сотрудники секций
CREATE TABLE SectionEmployees
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	SectionCode INT NOT NULL REFERENCES Sections(SectionCode) ON DELETE CASCADE,
	CampEmployeeCode INT NOT NULL REFERENCES CampEmployees(CampEmployeeCode) ON DELETE CASCADE
)

--Создание таблицы Родители
CREATE TABLE Parents
(
	ParentCode INT IDENTITY (1, 1) PRIMARY KEY,
	ParentFullName NVARCHAR (255) NOT NULL,
	Passport NVARCHAR (255) NOT NULL,
	PhoneNumber NVARCHAR (25) NOT NULL
)

--Создание таблицы Путевки
CREATE TABLE Trips
(
	TripCode INT IDENTITY (1, 1) PRIMARY KEY,
	DateOfStart DATE NOT NULL,
	DateOfEnd DATE NOT NULL,
	CampEmployeeCode INT NOT NULL REFERENCES CampEmployees(CampEmployeeCode) ON DELETE CASCADE,
	ParentCode INT NOT NULL REFERENCES Parents(ParentCode) ON DELETE CASCADE
)

--Создание таблицы Дети
CREATE TABLE Children
(
	ChildCode INT IDENTITY (1, 1) PRIMARY KEY,
	FullName NVARCHAR (255) NOT NULL, 
	DateOfBirthday DATE NOT NULL,
	SquadCode INT NOT NULL REFERENCES Squads(SquadCode) ON DELETE NO ACTION,
	TripCode INT NOT NULL REFERENCES Trips(TripCode) ON DELETE CASCADE,
)

--Создание дополнительной таблицы дети родителей
CREATE TABLE ChildrenParents
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	ChildCode INT NOT NULL REFERENCES Children(ChildCode),
	ParentCode INT NOT NULL REFERENCES Parents(ParentCode)
)

--Создание дополнительной таблицы Участники мероприятия
CREATE TABLE EventMembers 
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	EventCode INT NOT NULL REFERENCES CampEvents(EventCode) ON DELETE CASCADE,
	ChildCode INT NOT NULL REFERENCES Children(ChildCode) ON DELETE CASCADE,
	ChildActivity NVARCHAR (255)
)

--Создание дополнительной таблицы Сотрудники мероприятия
CREATE TABLE EventEmployees
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	CampEmployeeCode INT NOT NULL REFERENCES CampEmployees(CampEmployeeCode) ON DELETE CASCADE,
	EventCode INT NOT NULL REFERENCES CampEvents(EventCode) ON DELETE CASCADE,
	EmployeeActivity NVARCHAR (255)
)

--Создание тригера каскадное удаление для таблицы дети родителей
GO
CREATE TRIGGER CascdeDeleteOnDelete
   ON  dbo.ChildrenParents
   INSTEAD OF DELETE
AS  
BEGIN
	SET NOCOUNT ON;
	DELETE dbo.ChildrenParents FROM deleted
	WHERE deleted.ID = ChildrenParents.ID;

	DELETE dbo.Parents FROM deleted
	WHERE deleted.ParentCode = Parents.ParentCode

	DELETE dbo.Children FROM deleted
	WHERE deleted.ChildCode = Children.ChildCode
END;

--Создание тригера уведомляющего о просроченном продукте при его добавлении
GO
CREATE TRIGGER CheckShelfLifeOnInsert
   ON  dbo.Inventory
   AFTER INSERT
AS  
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT * FROM inserted WHERE ShelfLife < CURRENT_TIMESTAMP)
		PRINT 'You have added an item whose expiration date has expired!'
END;

--Создание процедуры которая меняет отряд вожатого и возвращает строкой результат изменения
GO
CREATE PROCEDURE ChangeSquadLeaderSquadCode @SquadLeaderCode INT, @SquadCode INT, @OutputString NVARCHAR(70) OUTPUT AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT * FROM CampEmployees WHERE CampEmployeeCode = @SquadLeaderCode)
	BEGIN
		IF EXISTS(SELECT * FROM Squads WHERE SquadCode = @SquadCode)
		BEGIN
			UPDATE CampEmployees SET SquadLeaderCode = @SquadCode WHERE CampEmployeeCode = @SquadLeaderCode;
			SET @OutputString ='Squad code changed succsessfull!'
		END;
		ELSE
			SET @OutputString ='There are no squad with this code!'
	END
	ELSE 
		SET @OutputString ='There are no squad leader with this code!'
	RETURN;
END;

--Создание процедуры которая выводит вожатых и список его детей
GO 
CREATE PROCEDURE ShowSquadMembersAndSquadLeaders AS
BEGIN
	SET NOCOUNT ON;
	SELECT * 
	FROM Children
	JOIN CampEmployees ON Children.SquadCode = CampEmployees.SquadLeaderCode
END;

--Создание процедуры которая выводит ФИО ребенка и его полный возраст с использованием курсора и цикла while 
GO
CREATE PROCEDURE GetChildrenFullNameFullAge
AS
BEGIN
	DECLARE @ChildFullName VARCHAR(50)
	DECLARE @DateOfBirthday DATE
	DECLARE ChildCursor CURSOR FOR SELECT FullName, DateOfBirthday FROM children

OPEN ChildCursor
	
	FETCH NEXT FROM ChildCursor INTO @ChildFullName, @DateOfBirthday

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Child name: ' + @ChildFullName + ', Full age: ' + CAST(YEAR(CURRENT_TIMESTAMP) - YEAR(@DateOfBirthday) AS VARCHAR(10))
	FETCH NEXT FROM ChildCursor INTO @ChildFullName, @DateOfBirthday
	END

CLOSE ChildCursor
DEALLOCATE ChildCursor
END;

--Создание представления которое выводит ребенка и его дом
GO 
CREATE VIEW ChildrensHousing AS
	SELECT Children.FullName, Housings.HousingName
	FROM Children
	JOIN Squads ON Children.SquadCode = Squads.SquadCode
	JOIN Housings ON Housings.SquadCode = Squads.SquadCode;

--Запарился и создал процедуру для добавления строк из файла
GO
CREATE PROCEDURE InsertRowsFromFile @FilePath NVARCHAR(1000), @TableName NVARCHAR(100)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    SET @sql = 'BULK INSERT ' + @TableName + ' FROM ''' + @FilePath + ''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')'
    EXEC sp_executesql @sql
END;

GO
--Создание юзеров
CREATE USER NikitaReadOnly FOR LOGIN NikitaReadOnly;
CREATE USER NIkitaAdmin FOR LOGIN NikitaAdmin;
CREATE USER NikitaWriteOnly FOR LOGIN NikitaWriteOnly;
CREATE USER UserWithoutLogin WITHOUT LOGIN; 

--Создание роли и выдача ей прав
CREATE ROLE OnlySelect;
CREATE ROLE OnlyInsert;

GRANT SELECT ON Transports TO OnlySelect;
GRANT SELECT ON Squads TO OnlySelect;
GRANT SELECT ON Sections TO OnlySelect;
GRANT SELECT ON SquadSections TO OnlySelect;
GRANT SELECT ON Housings TO OnlySelect;
GRANT SELECT ON CampEmployees TO OnlySelect;
GRANT SELECT ON Inventory TO OnlySelect;
GRANT SELECT ON HousingInventory TO OnlySelect;
GRANT SELECT ON CampEvents TO OnlySelect;
GRANT SELECT ON EventInventory TO OnlySelect;
GRANT SELECT ON SectionEmployees TO OnlySelect;
GRANT SELECT ON Parents TO OnlySelect;
GRANT SELECT ON Trips TO OnlySelect;
GRANT SELECT ON Children TO OnlySelect;
GRANT SELECT ON ChildrenParents TO OnlySelect;
GRANT SELECT ON EventMembers TO OnlySelect;
GRANT SELECT ON EventEmployees TO OnlySelect;

DENY INSERT ON Transports TO OnlySelect;
DENY INSERT ON Squads TO OnlySelect;
DENY INSERT ON Sections TO OnlySelect;
DENY INSERT ON SquadSections TO OnlySelect;
DENY INSERT ON Housings TO OnlySelect;
DENY INSERT ON CampEmployees TO OnlySelect;
DENY INSERT ON Inventory TO OnlySelect;
DENY INSERT ON HousingInventory TO OnlySelect;
DENY INSERT ON CampEvents TO OnlySelect;
DENY INSERT ON EventInventory TO OnlySelect;
DENY INSERT ON SectionEmployees TO OnlySelect;
DENY INSERT ON Parents TO OnlySelect;
DENY INSERT ON Trips TO OnlySelect;
DENY INSERT ON Children TO OnlySelect;
DENY INSERT ON ChildrenParents TO OnlySelect;
DENY INSERT ON EventMembers TO OnlySelect;
DENY INSERT ON EventEmployees TO OnlySelect;

GRANT SELECT ON Transports TO OnlyInsert;
GRANT SELECT ON Squads TO OnlyInsert;
GRANT SELECT ON Sections TO OnlyInsert;
GRANT SELECT ON SquadSections TO OnlyInsert;
GRANT SELECT ON Housings TO OnlyInsert;
GRANT SELECT ON CampEmployees TO OnlyInsert;
GRANT SELECT ON Inventory TO OnlyInsert;
GRANT SELECT ON HousingInventory TO OnlyInsert;
GRANT SELECT ON CampEvents TO OnlyInsert;
GRANT SELECT ON EventInventory TO OnlyInsert;
GRANT SELECT ON SectionEmployees TO OnlyInsert;
GRANT SELECT ON Parents TO OnlyInsert;
GRANT SELECT ON Trips TO OnlyInsert;
GRANT SELECT ON Children TO OnlyInsert;
GRANT SELECT ON ChildrenParents TO OnlyInsert;
GRANT SELECT ON EventMembers TO OnlyInsert;
GRANT SELECT ON EventEmployees TO OnlyInsert;

DENY INSERT ON Transports TO OnlyInsert;
DENY INSERT ON Squads TO OnlyInsert;
DENY INSERT ON Sections TO OnlyInsert;
DENY INSERT ON SquadSections TO OnlyInsert;
DENY INSERT ON Housings TO OnlyInsert;
DENY INSERT ON CampEmployees TO OnlyInsert;
DENY INSERT ON Inventory TO OnlyInsert;
DENY INSERT ON HousingInventory TO OnlyInsert;
DENY INSERT ON CampEvents TO OnlyInsert;
DENY INSERT ON EventInventory TO OnlyInsert;
DENY INSERT ON SectionEmployees TO OnlyInsert;
DENY INSERT ON Parents TO OnlyInsert;
DENY INSERT ON Trips TO OnlyInsert;
DENY INSERT ON Children TO OnlyInsert;
DENY INSERT ON ChildrenParents TO OnlyInsert;
DENY INSERT ON EventMembers TO OnlyInsert;
DENY INSERT ON EventEmployees TO OnlyInsert;

--распределение ролей между юзерами
EXEC sp_addrolemember OnlySelect, NikitaReadOnly;
EXEC sp_addrolemember OnlyInsert, UserWithoutLogin;
EXEC sp_addrolemember db_owner, NikitaAdmin;
EXEC sp_addrolemember db_datawriter, NikitaWriteOnly;

USE master;