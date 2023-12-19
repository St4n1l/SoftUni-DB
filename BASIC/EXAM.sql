CREATE DATABASE Boardgames
USE Boardgames

CREATE TABLE Categories
(
 Id INT PRIMARY KEY IDENTITY,
 [Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses
(
Id INT PRIMARY KEY IDENTITY,
StreetName NVARCHAR(100) NOT NULL,
StreetNumber INT NOT NULL,
Town VARCHAR(30) NOT NULL,
Country VARCHAR(50) NOT NULL,
ZIP INT NOT NULL
)

CREATE TABLE Publishers
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL UNIQUE,
AddressId INT FOREIGN KEY REFERENCES [Addresses](Id) NOT NULL,
Website NVARCHAR(40),
Phone NVARCHAR(20)
)

CREATE TABLE PlayersRanges
(
 Id INT PRIMARY KEY IDENTITY,
 PlayersMin INT NOT NULL,
 PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames
(
 Id INT PRIMARY KEY IDENTITY,
 [Name] NVARCHAR(30) NOT NULL,
 YearPublished INT NOT NULL,
 Rating Decimal(4,2) NOT NULL,
 CategoryId INT FOREIGN KEY REFERENCES [Categories](Id) NOT NULL,
 PublisherId INT FOREIGN KEY REFERENCES [Publishers](Id) NOT NULL,
 PlayersRangeId INT FOREIGN KEY REFERENCES [PlayersRanges](Id)
)

CREATE TABLE Creators
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames
(
CreatorId INT FOREIGN KEY REFERENCES [Creators](Id),
BoardgameId INT FOREIGN KEY REFERENCES [Boardgames](Id)
PRIMARY KEY(CreatorId,BoardgameId)
)


--02
INSERT INTO Boardgames VALUES
('Deep Blue',2019,5.67,1,15,7),
('Paris',2016,9.78,7,1,5),
('Catan: Starfarers',2021,9.87,7,13,6),
('Bleeding Kansas',2020,3.25,3,7,4),
('One Small Step',2019,	5.75,5,9,2)

INSERT INTO Publishers VALUES
('Agman Games',	5,'www.agmangames.com','+16546135542'),
('Amethyst Games',7,'www.amethystgames.com','+15558889992'),
('BattleBooks',	13 ,'www.battlebooks.com','+12345678907')


--03
SELECT * FROM [PlayersRanges]

UPDATE [PlayersRanges]
SET [PlayersMax] += 1
WHERE [PlayersMin] = 2 AND [PlayersMax] = 2


UPDATE [Boardgames]
SET [Name] = [Name] + 'V2'
WHERE [YearPublished] >= 2020

SELECT * FROM [Addresses]
SELECT * FROM [Publishers]
SELECT * FROM [Boardgames]
SELECT * FROM [CreatorsBoardgames]

DELETE FROM [CreatorsBoardgames] WHERE [BoardgameId] IN (1,16,31,47)
DELETE FROM [Boardgames] WHERE [PublisherId] = 1
DELETE FROM [Publishers] WHERE [AddressId] = 5
DELETE FROM [Addresses] WHERE LEFT(TOWN,1) = 'L'

--05
SELECT [Name], [Rating] FROM [Boardgames]
ORDER BY [YearPublished] ASC, [Name] DESC


--06
SELECT [b].[Id],[b].[Name],[b].[YearPublished],[c].[Name] AS [CategoryName] FROM [Boardgames] AS [b]
JOIN [Categories] AS [c]
ON [b].[CategoryId] = [c].[Id]
WHERE [c].[Name] = 'Strategy Games' OR [c].[Name] = 'Wargames'
ORDER BY [b].[YearPublished] DESC


SELECT * FROM [Categories]


--07
SELECT [c].[Id],
       CONCAT([c].[FirstName],' ', [c].[LastName]) AS [CreatorName],
	   [c].[Email]
FROM [CreatorsBoardgames] AS [cb]
RIGHT JOIN [Creators] AS [c]
ON [c].[Id] = [cb].CreatorId
WHERE [cb].[CreatorId] IS NULL


--08
SELECT TOP(5) [b].[Name],[Rating],[c].[Name] AS [CategoryName] FROM [Boardgames] AS [b]
JOIN [Categories] AS [c]
ON [c].[Id] = [b].[CategoryId]
JOIN [PlayersRanges] AS [pr]
ON [b].[PlayersRangeId] = [pr].[Id]
WHERE ([b].[Rating] > 7.00 AND CHARINDEX('a',[b].[Name])>0)
OR ([b].[Rating] > 7.50 AND [pr].PlayersMin = 2 AND [pr].[PlayersMax] = 5)
ORDER BY [b].[Name] ASC, [b].[Rating] DESC

--09
  SELECT CONCAT([FirstName],' ',[LastName]) AS [FullName],
         [Email],
   	     MAX([b].[Rating]) AS [Rating]
    FROM [Creators] AS [c]
         JOIN [CreatorsBoardgames] AS [cb]
      ON [c].[Id] = [cb].[CreatorId]
         JOIN [Boardgames] AS [b]
      ON [cb].[BoardgameId] = [b].[Id]
   WHERE RIGHT([c].[Email],4) = '.com'
GROUP BY [c].[FirstName],[c].[LastName],[c].[Email]
ORDER BY [FullName] ASC

SELECT * FROM CreatorsBoardgames

--10
  SELECT [c].[LastName],
	     CEILING(AVG([b].[Rating])) AS [AverageRating],
	     [p].[Name]
    FROM [Creators] AS [c]
    JOIN [CreatorsBoardgames]  AS [cb]
      ON [c].[Id] = [cb].[CreatorId]
    JOIN [Boardgames] AS [b]
      ON [cb].[BoardgameId] = [b].[Id]
    JOIN [Publishers] AS [p]
      ON [b].[PublisherId] = [p].[Id]
   WHERE [p].[Name] = 'Stonemaier Games'
GROUP BY [c].[FirstName],[c].[LastName],[p].[Name]
ORDER BY AVG([b].[Rating]) DESC

SELECT * FROM [Boardgames]


--11
CREATE FUNCTION udf_CreatorWithBoardgames(@name VARCHAR(30))
RETURNS INT
AS 
    BEGIN
	DECLARE @count INT
	SET @count = (
                          	SELECT COUNT(*) FROM [Creators] AS [c]
                          JOIN [CreatorsBoardgames] AS [cb] 
                          ON [c].[Id] = [cb].[CreatorId]
                          JOIN [Boardgames] AS [b]
                          ON [cb].[BoardgameId] = [b].[Id]
                          WHERE [c].[FirstName] = @name
				)
				RETURN @count
    END



--12
CREATE PROC usp_SearchByCategory(@category VARCHAR(50))
AS
  BEGIN
              SELECT [b].[Name], [b].[YearPublished], [b].[Rating], [c].[Name] AS [CategoryName],[p].[Name] AS [PublisherName], CONCAT([pr].[PlayersMin],' ', 'people') AS [MinPlayers],  CONCAT([pr].PlayersMax,' ', 'people') AS [MaxPlayers] FROM [Boardgames] AS [b]
           JOIN [Categories] AS [c]
           ON [b].[CategoryId] = [c].[Id]
           JOIN [PlayersRanges] AS [pr]
           ON [b].[PlayersRangeId] = [pr].[Id]
           JOIN [Publishers] AS [p]
           ON [b].[PublisherId] = [p].[Id]
           WHERE [c].[Name] = @category
           ORDER BY [p].[Name] ASC, [b].[YearPublished] DESC
  END


SELECT [b].[Name], [b].[YearPublished], [b].[Rating], [c].[Name] AS [CategoryName],[p].[Name] AS [PublisherName], CONCAT([pr].[PlayersMin],' ', 'people') AS [MinPlayers],  CONCAT([pr].PlayersMax,' ', 'people') AS [MaxPlayers] FROM [Boardgames] AS [b]
JOIN [Categories] AS [c]
ON [b].[CategoryId] = [c].[Id]
JOIN [PlayersRanges] AS [pr]
ON [b].[PlayersRangeId] = [pr].[Id]
JOIN [Publishers] AS [p]
ON [b].[PublisherId] = [p].[Id]
WHERE [c].[Name] = 'Wargames'
ORDER BY [p].[Name] ASC, [b].[YearPublished] DESC