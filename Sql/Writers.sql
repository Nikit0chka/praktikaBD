DROP DATABASE IF EXISTS b_library;
CREATE DATABASE b_library;
USE b_library;

CREATE TABLE tAuthors (
AuthorId             INT              IDENTITY (1, 1) NOT NULL,
AuthorFirstName      NVARCHAR (20)    NOT NULL,
AuthorLastName       NVARCHAR (20)    NOT NULL,
AuthorAge            INT               NOT NULL 
);

INSERT tAuthors VALUES
('Александр', 'Пушкин', '37'),
('Сергей', 'Есенин', '30'),
('Джек', 'Лондон', '40'),
('Шота', 'Руставели', '44'),
('Рабиндранат', 'Тагор', '80');

SELECT * FROM tAuthors;

SELECT * FROM tAuthors
ORDER BY AuthorAge ASC

SELECT AuthorFirstName, AuthorAge FROM tAuthors
ORDER BY AuthorAge DESC

SELECT AuthorFirstName, AuthorLastName FROM tAuthors
ORDER BY AuthorFirstName ASC

SELECT AuthorFirstName, AuthorLastName FROM tAuthors
ORDER BY AuthorLastName ASC

SELECT * FROM tAuthors
WHERE AuthorAge < 50
ORDER BY AuthorAge ASC