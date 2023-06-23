USE ChildrenCamp;

CREATE TABLE FakeParents
(
	ID INT IDENTITY(1, 1),
	FIO NVARCHAR(255)
)

DECLARE @w INT, @l INT
SET @w = ascii('ÿ') - ascii('À');
SET @l = ascii('À');

DECLARE @n INT = 0;
DECLARE @inFIO NVARCHAR(255) = 'Àñ';

WHILE (@n < 100000)
BEGIN
  INSERT INTO FakeParents (FIO)
  VALUES (@inFIO);

  IF (LEN(@inFIO) > 20) 
	SET @inFIO = CHAR(ROUND(RAND() * @w, 0) + @l) 
  ELSE 
	SET @inFIO = @inFIO + CHAR(ROUND(RAND() * @w, 0) + @l)

  SET @n = @n + 1
END;

CREATE CLUSTERED INDEX ReaderClust
ON FakeParents(ID)


SELECT *
  FROM FakeParents
 WHERE ID BETWEEN 33000 AND 33050
 USE master;