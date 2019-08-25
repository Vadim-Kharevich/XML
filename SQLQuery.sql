GO
CREATE TABLE Clients (
    ClientId int IDENTITY PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Address NVARCHAR(255) 
);

CREATE TABLE Accounts (
    AccountId int IDENTITY PRIMARY KEY,
    Number NVARCHAR(50) NOT NULL,
    Сurrency NVARCHAR(50) NOT NULL,
	Opening_date date NOT NULL,
	Closing_date date,
	Balance money,
	ClientId int FOREIGN KEY REFERENCES Clients(ClientId)
);

CREATE TABLE History (
    HistoryId int IDENTITY PRIMARY KEY,
	Id int NOT NULL,
    Operation NVARCHAR(300) NOT NULL,
	Value_Before NVARCHAR(700) ,
	Value_After NVARCHAR(700) ,
    Date_Time DATETIME NOT NULL DEFAULT GETDATE()
);

GO
INSERT INTO Clients VALUES(N'ОАО "Газпром"',N'Россия'),(N'ОАО "БелАЗ"',N'Беларусь'), (N'ЗАО "МЗКТ"',NULL);
GO
INSERT INTO Accounts VALUES('1234 234H 43D5 4351 9246','BYN','2017.09.20','2021.09.20',2076.32,3),
('2341 234H 43D5 4351 9246','RYB','2017.09.20',NULL,NULL,3),
('3412 234H 43D5 4351 9246','USD','2017.09.20',NULL,NULL,1),
('4123 234H 43D5 4351 9246','EUR','2015.09.20','2017.09.20',23,2);


--запись изменений таблицы Accounts
GO
CREATE TRIGGER InsertInAccounts
ON Accounts
AFTER INSERT
AS
INSERT INTO History (Id, Operation,Value_Before,Value_After)
SELECT AccountId, 
N'Добавление счета ' + Number, 
'-',  
'Number: '+  Number +', Currency: '+Сurrency+', Opening_date: '+ CONVERT(NVARCHAR(700), Opening_date) +
', Closing_date: '+ISNULL(CONVERT(NVARCHAR(700), Closing_date),'-')+', Balance: '+CONVERT(NVARCHAR(700), ISNULL(Balance, '-') )+', ClientId: '+CONVERT(NVARCHAR(700), ClientId)
FROM INSERTED

GO
CREATE TRIGGER DeleteInAccounts
ON Accounts
AFTER DELETE
AS
INSERT INTO History (Id, Operation,Value_Before,Value_After)
SELECT AccountId, 
N'Удаление счета ' + Number,  
'Number: '+  Number +', Currency: '+Сurrency+', Opening_date: '+ CONVERT(NVARCHAR(700), Opening_date) +
', Closing_date: '+ISNULL(CONVERT(NVARCHAR(700), Closing_date),'-')+', Balance: '+CONVERT(NVARCHAR(700), ISNULL(Balance, '-'))+', ClientId: '+CONVERT(NVARCHAR(700), ClientId),
'-'
FROM DELETED

GO
CREATE TRIGGER UpdateInAccounts
ON Accounts
AFTER UPDATE
AS
INSERT INTO History (Id, Operation,Value_Before,Value_After)
SELECT DELETED.AccountId, 
N'Редактирование счета ' + DELETED.Number,  
'Number: '+  DELETED.Number +', Currency: '+DELETED.Сurrency+', Opening_date: '+ CONVERT(NVARCHAR(700), DELETED.Opening_date) +
', Closing_date: '+ISNULL(CONVERT(NVARCHAR(700), DELETED.Closing_date),'-')+', Balance: '+CONVERT(NVARCHAR(700), ISNULL(DELETED.Balance, '-'))+', ClientId: '+CONVERT(NVARCHAR(700), DELETED.ClientId),
'Number: '+  INSERTED.Number +', Currency: '+INSERTED.Сurrency+', Opening_date: '+ CONVERT(NVARCHAR(700), INSERTED.Opening_date) +
', Closing_date: '+ISNULL(CONVERT(NVARCHAR(700), INSERTED.Closing_date),'-')+', Balance: '+CONVERT(NVARCHAR(700), ISNULL(INSERTED.Balance, '-'))+', ClientId: '+CONVERT(NVARCHAR(700), INSERTED.ClientId)
FROM DELETED,INSERTED


--запись изменений таблицы Clients
GO
CREATE TRIGGER InsertInClients
ON Clients
AFTER INSERT
AS
INSERT INTO History (Id, Operation,Value_Before,Value_After)
SELECT ClientId, 
N'Добавление клиента ' + Name, 
'-',  
'Name: '+  Name +', Address: '+ ISNULL(Address, '-')
FROM INSERTED

GO
CREATE TRIGGER DeleteInClients
ON Clients
AFTER DELETE
AS
INSERT INTO History (Id, Operation,Value_Before,Value_After)
SELECT ClientId, 
N'Удаление клиента ' + Name,  
'Name: '+  Name +', Address: '+ISNULL(Address, '-'),
'-'
FROM INSERTED

GO
CREATE TRIGGER UpdateInClients
ON Clients
AFTER UPDATE
AS
INSERT INTO History (Id, Operation,Value_Before,Value_After)
SELECT DELETED.ClientId, 
N'Редактирование клиента ' + DELETED.Name,  
'Name: '+  DELETED.Name +', Address: '+ ISNULL(DELETED.Address, '-'),
'Name: '+  INSERTED.Name +', Address: '+ ISNULL(INSERTED.Address, '-')
FROM DELETED,INSERTED

GO
--Необходимо написать запрос, который возвращает список клиентов, у которых есть счета и количество этих счетов.
SELECT Name,COUNT(Accounts.AccountId) FROM Clients JOIN Accounts ON Clients.ClientId=Accounts.ClientId GROUP BY Clients.Name;

GO
--Необходимо написать запрос, который возвращает список клиентов, у которых все счета закрыты.
SELECT Name FROM Clients JOIN Accounts ON Clients.ClientId=Accounts.ClientId AND Accounts.ClientId != ALL(SELECT ClientId FROM Accounts INTERSECT SELECT ClientId FROM Accounts WHERE Closing_date>GETDATE() OR Closing_date IS NULL) GROUP BY Clients.Name;

GO
--Необходимо написать запрос, который возвращает список счетов клиентов, у которых в наименование есть ОАО.
SELECT Number FROM Accounts JOIN Clients ON Clients.ClientId=Accounts.ClientId AND Clients.Name LIKE N'%ОАО%';

GO
--Необходимо написать запрос, который для клиентов с наименованиями, определяемыми в условии, проставляет текущий остаток счета равным 0, если он был неизвестен.
UPDATE Accounts SET Balance=ISNULL(Balance,'0') FROM 
(SELECT * FROM Clients WHERE Name=N'ОАО "Газпром"') AS Selected
WHERE Accounts.ClientId = Selected.ClientId;

GO
--Необходимо написать запрос, который возвращает список незакрытых счетов вместе с наименованием клиента, которому принадлежит счет.
SELECT Accounts.Number,Clients.Name FROM Accounts JOIN Clients ON Clients.ClientId=Accounts.ClientId AND (Accounts.Closing_date>GETDATE() OR Accounts.Closing_date IS NULL);
