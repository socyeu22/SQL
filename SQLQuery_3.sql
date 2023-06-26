-- Tạo database
create database NTB_DB_test
use NTB_DB_test
go
-- Tạo bảng Location
create table Locationn(
    LocationID char(6) not null primary key,
    L_Name nvarchar(50) not null,
    L_Description nvarchar(200)
)
-- Tạo bảng Land
create table Land (
    LandID int identity(1, 1) not null primary key,
    Title nvarchar(100) not null,
    LocationID char(6) not null,
    Detail nvarchar(1000),
    StartDate datetime not null,
    EndDate datetime not null,
	FOREIGN KEY (LocationID) REFERENCES Locationn (LocationID) ON DELETE CASCADE ON UPDATE CASCADE,
)
-- Tạo bảng Building
create table Building(
    BuildingID int not null identity(1, 1) primary key,
    LandID int not null,
    BuildingType nvarchar(50),
    Area int DEFAULT 50,
    Floors int default 1,
    Rooms int default 1,
	FOREIGN KEY (LandID) REFERENCES Land (LandID) ON DELETE CASCADE ON UPDATE CASCADE
)
-- Thêm dử liệu vào bảng 
insert into Locationn (LocationID, L_Name, L_Description) VALUES ('100000', 'Ha Noi', 'Thu do nghin nam van hien')
insert into Locationn (LocationID, L_Name, L_Description) VALUES ('20000', 'Ha Nam', 'Thanh pho ven thu do')
insert into Locationn (LocationID, L_Name, L_Description) VALUES ('30000', 'Ninh Binh', 'Co do Hoa Lu')

insert into Locationn values ('880000','An Giang','An Giang province'),
                              ('260000','Bac Lieu','Bac Lieu proince'),
							  ('960000','Bac Kan','Bac Kan province')

insert into Land (Title, LocationID, Detail, StartDate, EndDate) VALUES ('Chau Doc','880000',null,'2023-01-23 00:00:00','2023-09-23 00:00:00')
insert into Land (Title, LocationID, Detail, StartDate, EndDate) VALUES ('Tp Bac Lieu','260000',null,'2023-02-23 00:00:00','2023-10-23 00:00:00')
insert into Land (Title, LocationID, Detail, StartDate, EndDate) VALUES ('Ba Be','960000',null,'2023-03-23 00:00:00','2023-11-23 00:00:00')
ALTER TABLE Building
add Cost Money
insert into Building values (1,'office',100,3,6,1000)
insert into Building values (2,'home',50,3,3,400)
insert into Building values (3,'villa',120,3,7,1500)

--List all the buildings with a floor area of 100m2 or more.
SELECT *
FROM Building
WHERE Area >= 100;

--List the construction land will be completed before January 2013.
SELECT *
FROM Land
WHERE EndDate < '2013-01-01';

--List all buildings to be built in the land of title "My Dinh”
SELECT Building.*
FROM Building
INNER JOIN Land ON Building.LandID = Land.LandID
WHERE Land.Title = 'My Dinh';

--Create a view v_Buildings contains the following information (BuildingID, Title, Name,
--BuildingType, Area, Floors) from table Building, Land and Location.
CREATE VIEW v_Buildings AS
SELECT B.BuildingID, L.Title, LN.L_Name, B.BuildingType, B.Area, B.Floors
FROM Building B
JOIN Land L ON B.LandID = L.LandID
JOIN Locationn LN ON L.LocationID = LN.LocationID;

--Create a view v_TopBuildings about 5 buildings with the most expensive price per m2.
CREATE VIEW v_TopBuildings AS
SELECT TOP 5 B.BuildingID, B.Title, L.L_Name, B.BuildingType, B.Area, B.Price
FROM (
    SELECT B.*, B.Price / B.Area AS PricePerM2
    FROM Building B
) AS B
JOIN Land L ON B.LandID = L.LandID
ORDER BY B.PricePerM2 DESC;

-- Create a store called sp_SearchLandByLocation with input parameter is the area code
-- and retrieve planned land for this area.
CREATE PROCEDURE sp_SearchLandByLocation
    @AreaCode char(6)
AS
BEGIN
    SELECT L.*
    FROM Land L
    INNER JOIN Locationn LN ON L.LocationID = LN.LocationID
    WHERE LN.LocationID = @AreaCode;
END

-- Create a store called sp_SearchBuidingByLand procedure input parameter is the land
-- code and retrieve the buildings built on that land.
CREATE PROCEDURE sp_SearchBuildingByLand
    @LandCode int
AS
BEGIN
    SELECT B.*
    FROM Building B
    INNER JOIN Land L ON B.LandID = L.LandID
    WHERE L.LandID = @LandCode;
END

-- Create a trigger tg_RemoveLand allows to delete only lands which have not any
-- buildings built on it.
CREATE TRIGGER tg_RemoveLand
ON Land
INSTEAD OF DELETE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM deleted d JOIN Building b ON d.LandID = b.LandID)
    BEGIN
        DELETE FROM Land
        FROM Land l
        JOIN deleted d ON l.LandID = d.LandID;
    END
    ELSE
    BEGIN
        RAISERROR ('Cannot delete land with buildings built on it.', 16, 1);
        ROLLBACK;
    END
END



