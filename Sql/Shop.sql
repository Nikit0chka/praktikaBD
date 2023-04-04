USE master;

go
DROP DATABASE IF EXISTS Supermarket;
go
CREATE DATABASE Supermarket;
go
USE Supermarket;

CREATE TABLE Departments
(
	DepartmentID INT IDENTITY(1, 1) PRIMARY KEY,
	DepartmentName NVARCHAR(100) NOT NULL,
	NumberOfCounters INT NOT NULL,
	NumberOfSellers INT NOT NULL,
	FloorNumber INT NOT NULL
);

CREATE TABLE Posts
(
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	Tittle NVARCHAR(100) NOT NULL,
	Salary DECIMAL NOT NULL, 
);

CREATE TABLE Employees
(
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	EmplName NVARCHAR(100) NOT NULL,
	Surname NVARCHAR(100) NOT NULL,
	Patronomyc NVARCHAR(100),
	DateOfBirthday DATE NOT NULL,
	DateOfEntry DATE NOT NULL,
	MonthlyExperiense INT NOT NULL,
	Position INT NOT NULL REFERENCES Posts(ID),
	Gender Nvarchar(10) NOT NULL, 
	EmplAddress Nvarchar(150) NOT NULL,
	City Nvarchar(50) NOT NULL,
	PhoneNumber Nvarchar(20) NOT NULL,
);

CREATE TABLE Products
(
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	ProdName NVARCHAR(50) NOT NULL,
	Department INT NOT NULL REFERENCES Departments(DepartmentID),
	CountryOfOrigin NVARCHAR(50) NOT NULL,
	StorageConditions NVARCHAR(50) NOT NULL,
	ShelfLife DATE NOT NULL
);

CREATE TABLE ProductSales
(
	ID INT IDENTITY(1, 1) PRIMARY KEY,
	Seller INT NOT NULL REFERENCES Employees(ID),
	SelDate DATE NOT NULL,
	SelTime TIME NOT NULL,
	Quantity INT NOT NULL,
	Price DECIMAL NOT NULL,
	SelSum DECIMAL NOT NULL
);

INSERT Departments
VALUES
('Название1', 1, 1, 1),
('Название2', 2, 2, 2),
('Название3', 3, 3, 3);

INSERT Posts
VALUES
('Хозяин', 112.121),
('Дед', 112.121),
('Бабушка', 112.121);

INSERT Products
VALUES
('a', 1, 'a', 'a', CURRENT_TIMESTAMP),
('a', 2, 'a', 'a', CURRENT_TIMESTAMP),
('a', 3, 'a', 'a', CURRENT_TIMESTAMP);

INSERT Employees
VALUES
('a', 'a', 'a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1, 'а','a','a','a'),
('a', 'a', 'a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 2, 'а','a','a','a'),
('a', 'a', 'a', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 3, 'а','a','a','a');

INSERT ProductSales
VALUES
(1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1.1, 1.1),
(2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1.1, 1.1);

CREATE USER YaNikita FOR LOGIN Nikita;
GRANT SELECT, INSERT ON Departments TO YaNikita;

CREATE USER NIkitaAdmin FOR LOGIN NikitaAdmin;
CREATE ROLE OnlySelect;
GRANT SELECT ON Departments TO OnlySelect;
GRANT SELECT ON Posts TO OnlySelect;
GRANT SELECT ON Products TO OnlySelect;
GRANT SELECT ON ProductSales TO OnlySelect;

DENY INSERT ON Departments TO OnlySelect;
DENY INSERT ON Posts TO OnlySelect;
DENY INSERT ON Products TO OnlySelect;
DENY INSERT ON ProductSales TO OnlySelect;

EXEC sp_addrolemember OnlySelect, YaNikita;
EXEC sp_addrolemember db_owner, NikitaAdmin;


DROP TRIGGER IF EXISTS CascadeDeleteTrig1;
DROP TRIGGER IF EXISTS CascadeDeleteTrig2;
DROP TRIGGER IF EXISTS CascadeDeleteTrig3;
DROP TRIGGER IF EXISTS InsertCurrentTime;

GO
CREATE TRIGGER CascadeDeleteTrig1 ON Departments
INSTEAD OF DELETE AS
BEGIN
	DELETE FROM Products WHERE Department IN (SELECT DepartmentID FROM DELETED);
	DELETE FROM Departments WHERE DepartmentID IN (SELECT DepartmentID FROM DELETED);
END;


GO
CREATE TRIGGER CascadeDeleteTrig2 ON Posts
INSTEAD OF DELETE AS
BEGIN
	DELETE FROM Employees WHERE Position IN (SELECT ID FROM DELETED);
	DELETE FROM Posts WHERE ID IN (SELECT ID FROM DELETED);
END;

GO
CREATE TRIGGER CascadeDeleteTrig3 ON Employees
INSTEAD OF DELETE AS
BEGIN
	DELETE FROM ProductSales WHERE Seller IN (SELECT ID FROM DELETED);
	DELETE FROM Employees WHERE ID IN (SELECT ID FROM DELETED);
END;

GO 
CREATE TRIGGER InsertCurrentTime ON ProductSales
INSTEAD OF INSERT AS
BEGIN
	INSERT INTO ProductSales(Seller, SelDate, SelTime, Quantity, Price, SelSum) 
	VALUES ((SELECT Seller FROM inserted), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, (SELECT Quantity FROM inserted),
			(SELECT Price FROM inserted), (SELECT SelSum FROM inserted));
END;

GO
SELECT * FROM Departments;
SELECT * FROM Posts;
SELECT * FROM Products;
SELECT * FROM Employees;
SELECT * FROM ProductSales;

DELETE FROM Departments WHERE DepartmentID = 1;
DELETE FROM Posts WHERE ID = 1;
DELETE FROM Employees WHERE ID = 1;

INSERT ProductSales
VALUES
(3, '2020-02-02', '01:04:06.4733333', 1, 2, 1);

GO
SELECT * FROM Departments;
SELECT * FROM Posts;
SELECT * FROM Products;
SELECT * FROM Employees;
SELECT * FROM ProductSales;

SELECT NAME AS trigger_name, parent_id AS table_id, 
OBJECT_NAME(parent_id) AS table_name, 
CASE is_disabled WHEN 0 THEN 'Enable' ELSE 'Disable' END AS status FROM sys.triggers
WHERE is_ms_shipped = 0
ORDER BY parent_id