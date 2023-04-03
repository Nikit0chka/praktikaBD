USE ChildrenCamp;

DROP PROCEDURE IF EXISTS FirstProcedure;
DROP PROCEDURE IF EXISTS SecondProcedure;
DROP PROCEDURE IF EXISTS ThurdProcedure;
DROP PROCEDURE IF EXISTS FourthProcedure;
DROP PROCEDURE IF EXISTS FifthProcedure;
DROP PROCEDURE IF EXISTS SixthProcedure;
DROP PROCEDURE IF EXISTS SeventhProcedure;

GO
CREATE PROCEDURE FirstProcedure @inputValue INT AS
DECLARE @StartYear INT, @NumberOfLeapYears INT;
SET @StartYear = 1000;
SET @NumberOfLeapYears = 0;

BEGIN
	WHILE @StartYear < YEAR(CURRENT_TIMESTAMP) 
		BEGIN
			IF @StartYear % 4 = 0
				SET @NumberOfLeapYears += 1;
		SET @StartYear += 1;
		END;
	
	SELECT DATEDIFF(YEAR , '2000-1-1', CURRENT_TIMESTAMP) as 'Years from 2000';
	SELECT @NumberOfLeapYears as 'Number of leap years';
	SELECT * From Housings WHERE NumberOfRoom <= @inputValue;
END;

GO
CREATE PROCEDURE SecondProcedure @inputValue INT AS
DECLARE @FirstValue INT, @SecondValue INT, @ThurdValue INT, @FourthValue INT, @FifthValue INT, @StartYear INT, @NumberOfCenturies INT;
SET @FirstValue = 1;
SET @SecondValue = 2;
SET @ThurdValue = 3;
SET @FourthValue = 4;
SET @FifthValue = 6;
SET @StartYear = 1500;
SET @NumberOfCenturies = 0;

BEGIN	
	WHILE @StartYear <= YEAR(CURRENT_TIMESTAMP) 
		BEGIN
			SET @StartYear += 100;
			SET @NumberOfCenturies += 1;
		END;
	SELECT (@FirstValue + @SecondValue + @ThurdValue + @FourthValue + @FifthValue) / 5.0 as 'Average';
	SELECT @NumberOfCenturies as 'Number of centurieries from 1500';
	SELECT * From Housings WHERE NumberOfRoom <= @inputValue;
END;

GO 
CREATE PROCEDURE ThurdProcedure @InputValue1 INT, @InputValue2 INT, @InputDate Date AS
DECLARE @1 INT, @2 INT, @3 INT, @4 INT, @5 INT, @6 INT;
SET @1 = 1;
SET @2 = 2;
SET @3 = 3;
SET @4 = 4;
SET @5 = 5;
SET @6 = 6;

BEGIN
	IF MONTH(@InputDate) BETWEEN 3 and 5
		SELECT 'Its spring!' as 'Season';
	IF MONTH(@InputDate) BETWEEN 6 and 8
		SELECT 'Its summer!' as 'Season';
	IF MONTH(@InputDate) BETWEEN 9 and 11
		SELECT 'Its autumn!' as 'Season';
	IF MONTH(@InputDate) = 1 or MONTH(@InputDate) = 2 or MONTH(@InputDate) = 12 
		SELECT 'Its winter!' as 'Season';
	
	SELECT (@1 * @2 * @3 * @4 * @5 * @6) / 6.0 as 'Geometric mean';
	SELECT * FROM Housings WHERE NumberOfRoom  BETWEEN @InputValue1 and @InputValue2;
END;

GO 
CREATE PROCEDURE FourthProcedure @InputValue1 INT, @InputValue2 INT AS 
BEGIN
	SELECT 'Vorontsov Nikita 18 years' AS 'Name Surname Age';
	SELECT DATENAME(weekday, CURRENT_TIMESTAMP) AS 'Weekday';
	SELECT * FROM Housings WHERE NumberOfRoom  BETWEEN @InputValue1 and @InputValue2;
END;

GO
CREATE PROCEDURE FifthProcedure @InputValue1 INT, @InputValue2 INT, @InputValue3 INT AS
BEGIN
	IF @InputValue1 > @InputValue2 AND @InputValue1 > @InputValue3
		SELECT @InputValue1 AS 'Max';
	IF @InputValue2 > @InputValue1 AND @InputValue2 > @InputValue3
		SELECT @InputValue2 AS 'Max';	
	IF @InputValue3 > @InputValue1 AND @InputValue3 > @InputValue2
		SELECT @InputValue3 AS 'Max';
	IF @InputValue1 > @InputValue2 AND @InputValue1 < @InputValue3 OR @InputValue1 < @InputValue2 AND @InputValue1 > @InputValue3
		SELECT @InputValue1 AS 'Middle';
	IF @InputValue2 > @InputValue1 AND @InputValue2 < @InputValue3 OR @InputValue2 < @InputValue1 AND @InputValue2 > @InputValue3  
		SELECT @InputValue2 AS 'Middle';	
	IF @InputValue3 > @InputValue1 AND @InputValue3 < @InputValue2 OR @InputValue3 < @InputValue1 AND @InputValue3 > @InputValue2
		SELECT @InputValue3 AS 'Middle';
	IF @InputValue1 < @InputValue2 AND @InputValue1 < @InputValue3
		SELECT @InputValue1 AS 'Min';
	IF @InputValue2 < @InputValue1 AND @InputValue2 < @InputValue3
		SELECT @InputValue2 AS 'Min';	
	IF @InputValue3 < @InputValue1 AND @InputValue3 < @InputValue2
		SELECT @InputValue3 AS 'Min';
	
	SELECT @InputValue1 * 4 - 6 * @InputValue2 + 7 * @InputValue3 as 'Expression';
	SELECT * FROM Housings WHERE NumberOfRoom > @Inputvalue1 and NumberOfRoom > @InputValue2 and NumberOfRoom > @InputValue3;
END;

GO
CREATE PROCEDURE SixthProcedure @InputValue1 NVARCHAR(100), @InputValue2 NVARCHAR(100), @InputValue3 NVARCHAR(100), @InputValue4 INT, @InputValue5 INT, @InputValue6 INT AS
BEGIN
	IF LEN(@InputValue1) > LEN(@InputValue2) AND LEN(@InputValue1) > LEN(@InputValue3)
		SELECT @InputValue1 AS 'Max';
	IF LEN(@InputValue2) > LEN(@InputValue1) AND LEN(@InputValue2) > LEN(@InputValue3)
		SELECT @InputValue2 AS 'Max';	
	IF LEN(@InputValue3) > LEN(@InputValue1) AND LEN(@InputValue3) > LEN(@InputValue2)
		SELECT @InputValue3 AS 'Max';
		
	SELECT 2 * @InputValue4 - 5 * @InputValue5 + 2 * @InputValue6 as 'Expression';
	SELECT * FROM Housings WHERE NumberOfRoom > @Inputvalue4 and NumberOfRoom > @InputValue5 and NumberOfRoom > @InputValue6;
END;

GO
CREATE PROCEDURE SeventhProcedure @InputValue1 NVARCHAR(100), @InputValue2 NVARCHAR(100), @InputValue3 NVARCHAR(100), @InputValue4 INT, @InputValue5 INT, @InputValue6 INT AS
BEGIN
	IF LEN(@InputValue1) < LEN(@InputValue2) AND LEN(@InputValue1) < LEN(@InputValue3)
		SELECT @InputValue1 AS 'Min';
	IF LEN(@InputValue2) < LEN(@InputValue1) AND LEN(@InputValue2) < LEN(@InputValue3)
		SELECT @InputValue2 AS 'Min';	
	IF LEN(@InputValue3) < LEN(@InputValue1) AND LEN(@InputValue3) < LEN(@InputValue2)
		SELECT @InputValue3 AS 'Min';
		
	SELECT 5 * @InputValue5 - 4 * @InputValue4 * @InputValue5 - 3 * @InputValue6 - 12 * @InputValue5 as 'Expression';
	SELECT * FROM Housings WHERE NumberOfRoom BETWEEN @InputValue5 and @InputValue6;
END;

GO
FirstProcedure 1;
GO
SecondProcedure 1000;
GO
ThurdProcedure 100, 200, '1900-01-01';
GO 
FourthProcedure 100, 200;
GO 
FifthProcedure 300, 200, 300;
GO
SixthProcedure '123', '1234', '12345', 300, 200, 300;
GO 
SeventhProcedure '123', '1234', '12345', 1, 1, 1;
