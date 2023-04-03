USE master;

DROP PROCEDURE IF EXISTS CreateLogin;

GO
CREATE PROCEDURE CreateLogin @LoginName varchar(50), @LoginPassword varchar (50)
AS
BEGIN
DECLARE @sqlCommand nvarchar(1000)
IF not exists (SELECT NAME from sys.server_principals  WHERE TYPE = 'S' and NAME = @LoginName)
	SELECT @sqlCommand = 'CREATE LOGIN "' + @LoginName + '" WITH PASSWORD = ''' + @LoginPassword+ ''', CHECK_POLICY = OFF'
EXEC sp_executesql @sqlCommand
END;
GO

EXEC CreateLogin 'Nikita', 'Nikita';
EXEC CreateLogin 'NIkitaAdmin','NIkitaAdmin';

DROP DATABASE IF EXISTS ChildrenCamp;

CREATE DATABASE ChildrenCamp;

USE ChildrenCamp;

CREATE TABLE TransportTypes
(
	TypeCode INT PRIMARY KEY,
	TypeName NVARCHAR (255) NOT NULL
)

CREATE TABLE Transports
(
	TransportCode INT IDENTITY (1, 1) PRIMARY KEY,
	TransportType INT NOT NULL REFERENCES TransportTypes(TypeCode) ON DELETE CASCADE,
	Timetable NVARCHAR (255)
)

CREATE TABLE Squads
(
	SquadCode INT IDENTITY (1, 1) PRIMARY KEY,
	SquadName NVARCHAR (255) NOT NULL,
	SquadCharacter NVARCHAR (255)
)

CREATE TABLE Sections
(
	SectionCode INT IDENTITY (1, 1) PRIMARY KEY,
	Section_name NVARCHAR (255) NOT NULL,
	TimetableLink NVARCHAR (255) NOT NULL
)

CREATE TABLE SquadSections
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	SectionCode INT NOT NULL REFERENCES Sections(SectionCode) ON DELETE CASCADE,
	SquadCode INT NOT NULL REFERENCES Squads(SquadCode) ON DELETE CASCADE
)

CREATE TABLE Housings
(
	HousingCode INT IDENTITY (1, 1) PRIMARY KEY,
	HousingType NVARCHAR (255) NOT NULL,
	HousingName NVARCHAR (255) NOT NULL,
	NumberOfRoom INT NOT NULL,
	SquadCode INT REFERENCES Squads(SquadCode) ON DELETE CASCADE
)

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

CREATE TABLE Inventory
(
	InventoryCode INT IDENTITY (1, 1) PRIMARY KEY,
	InventoryType NVARCHAR (255) NOT NULL,	
	ShelfLife DATE 
)

CREATE TABLE HousingInventory
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	DateOfReceipt DATE NOT NULL,
	InventoryCode INT NOT NULL REFERENCES Inventory(InventoryCode) ON DELETE CASCADE,
	HousingCode INT NOT NULL REFERENCES Housings(HousingCode) ON DELETE CASCADE
)

CREATE TABLE CampEvents
(
	EventCode INT IDENTITY (1, 1) PRIMARY KEY,
	EventName NVARCHAR (255) NOT NULL,
	DateOfEvent DATE NOT NULL,
	PlaceOfEvent NVARCHAR (255) NOT NULL
)

CREATE TABLE EventInventory
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	EventCode INT NOT NULL REFERENCES CampEvents(EventCode) ON DELETE CASCADE,
	InventoryCode INT NOT NULL REFERENCES Inventory(InventoryCode) ON DELETE CASCADE
)

CREATE TABLE SectionEmployees
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	SectionCode INT NOT NULL REFERENCES Sections(SectionCode) ON DELETE CASCADE,
	CampEmployeeCode INT NOT NULL REFERENCES CampEmployees(CampEmployeeCode) ON DELETE CASCADE
)

CREATE TABLE Parents
(
	ParentCode INT IDENTITY (1, 1) PRIMARY KEY,
	ParentFullName NVARCHAR (255) NOT NULL,
	Passport NVARCHAR (255) NOT NULL,
	PhoneNumber NVARCHAR (25) NOT NULL
)

CREATE TABLE Trips
(
	TripCode INT IDENTITY (1, 1) PRIMARY KEY,
	DateOfStart DATE NOT NULL,
	DateOfEnd DATE NOT NULL,
	CampEmployeeCode INT NOT NULL REFERENCES CampEmployees(CampEmployeeCode) ON DELETE CASCADE,
	ParentCode INT NOT NULL REFERENCES Parents(ParentCode) ON DELETE CASCADE
)

CREATE TABLE Children
(
	ChildCode INT IDENTITY (1, 1) PRIMARY KEY,
	FullName NVARCHAR (255) NOT NULL, 
	DateOfBirthday DATE NOT NULL,
	SquadCode INT NOT NULL REFERENCES Squads(SquadCode),
	TripCode INT NOT NULL REFERENCES Trips(TripCode) ON DELETE CASCADE,
)

CREATE TABLE ChildrenParents
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	ChildCode INT NOT NULL REFERENCES Children(ChildCode),
	ParentCode INT NOT NULL REFERENCES Parents(ParentCode)
)

CREATE TABLE EventMembers 
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	EventCode INT NOT NULL REFERENCES CampEvents(EventCode) ON DELETE CASCADE,
	ChildCode INT NOT NULL REFERENCES Children(ChildCode) ON DELETE CASCADE,
	ChildActivity NVARCHAR (255)
)

CREATE TABLE EventEmployees
(
	ID INT IDENTITY (1, 1) PRIMARY KEY,
	CampEmployeeCode INT NOT NULL REFERENCES CampEmployees(CampEmployeeCode) ON DELETE CASCADE,
	EventCode INT NOT NULL REFERENCES CampEvents(EventCode) ON DELETE CASCADE,
	EmployeeActivity NVARCHAR (255)
)

CREATE USER YaNikita FOR LOGIN Nikita;
CREATE USER NIkitaAdmin FOR LOGIN NikitaAdmin;

CREATE ROLE OnlySelect;
GRANT SELECT ON TransportTypes TO OnlySelect;
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

DENY INSERT ON TransportTypes TO OnlySelect;
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

EXEC sp_addrolemember OnlySelect, YaNikita;
EXEC sp_addrolemember db_owner, NikitaAdmin;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP TRIGGER IF EXISTS CascadeDeleteOnDelete;

GO
CREATE TRIGGER CascadeDeleteOnDelete
   ON  dbo.ChildrenParents
   INSTEAD OF DELETE
AS  
BEGIN
	SET NOCOUNT ON;
	delete dbo.ChildrenParents from deleted
	where deleted.ChildCode = ChildrenParents.ChildCode or deleted.ParentCode = ChildrenParents.ParentCode;

	delete dbo.Parents from deleted
	where deleted.ParentCode = Parents.ParentCode

	delete dbo.Children from deleted
	where deleted.ChildCode = Children.ChildCode
END;

GO
CREATE TRIGGER CascadeUpdateOnUpdate
   ON  dbo.ChildrenParents
   AFTER UPDATE
AS  
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT ChildCode FROM Children where ChildCode = NULL)
		PRINT 'Empty input'
END;

GO
CREATE TRIGGER GeneratePrimaryKeyOnInsert
	ON dbo.TransportTypes
	INSTEAD OF INSERT
AS
BEGIN
	INSERT INTO TransportTypes
	IF EXISTS()
END;
