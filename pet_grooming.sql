/*
    Pet Grooming business scenario
    Run this script in the target SQL Server database.
*/

-- Removes the former table name as well when upgrading a prior version of this script.
DROP TABLE IF EXISTS dbo.PetGroomingCustomers;
DROP TABLE IF EXISTS dbo.Customer;
GO

CREATE TABLE dbo.Customer
(
    CustomerId int IDENTITY(1, 1) NOT NULL
        CONSTRAINT PK_Customer PRIMARY KEY
        CONSTRAINT CK_Customer_Id_NotNegative CHECK (CustomerId >= 0),
    OwnerName nvarchar(100) NOT NULL
        CONSTRAINT CK_Customer_OwnerName_NotBlank CHECK (LEN(LTRIM(RTRIM(OwnerName))) > 0),
    OwnerAddress nvarchar(200) NOT NULL
        CONSTRAINT CK_Customer_OwnerAddress_NotBlank CHECK (LEN(LTRIM(RTRIM(OwnerAddress))) > 0),
    PetType varchar(20) NOT NULL
        CONSTRAINT CK_Customer_PetType CHECK (PetType IN ('dog', 'cat', 'rabbit', 'guinea pig')),
    PetName nvarchar(100) NOT NULL
        CONSTRAINT CK_Customer_PetName_NotBlank CHECK (LEN(LTRIM(RTRIM(PetName))) > 0),
    GroomingPrice decimal(10, 2) NOT NULL
        CONSTRAINT CK_Customer_GroomingPrice CHECK (GroomingPrice >= 0),
    ServiceFrequency varchar(10) NOT NULL
        CONSTRAINT CK_Customer_ServiceFrequency CHECK (ServiceFrequency IN ('weekly', 'biweekly')),
    PickUpDate date NOT NULL
        CONSTRAINT CK_Customer_PickUpDate_Year CHECK (YEAR(PickUpDate) >= 2019),
    CustomerEndDate date NULL,

    CONSTRAINT CK_Customer_CustomerEndDate
        CHECK (CustomerEndDate IS NULL OR CustomerEndDate >= PickUpDate)
);
GO

INSERT INTO dbo.Customer
    (OwnerName, OwnerAddress, PetType, PetName, GroomingPrice, ServiceFrequency, PickUpDate, CustomerEndDate)
VALUES
    (N'Bry-Ann Yates', N'326 34th St. S', 'rabbit', N'Longears', 30.00, 'weekly',   '20190821', NULL),
    (N'Meg Ross', N'1719 Beach Dr SE', 'dog', N'Trooper', 55.00, 'biweekly', '20200119', NULL),
    (N'Brayanna Mille', N'2255 22 Ave N', 'rabbit', N'Hunny Bunny', 40.00, 'biweekly', '20191105', NULL),
    (N'Brayanna Mille', N'2255 22 Ave N', 'rabbit', N'Hazel', 40.00, 'biweekly', '20191105', NULL),
    (N'Marianne Griffin', N'312 Sand Pine Ln', 'dog', N'Mr. Stich', 60.00, 'biweekly', '20210620', NULL),
    (N'Mike Smith', N'145 Menhaden St', 'guinea pig', N'Pippin', 30.00, 'biweekly', '20220430', NULL),
    (N'Bethany Singer', N'1818 Bay St', 'cat', N'Dingus', 40.00, 'biweekly', '20220607', NULL),
    (N'Bobbi Welker', N'324 Wilcox St', 'dog', N'Moose', 45.00, 'weekly', '20210314', NULL),
    (N'Bobbi Welker', N'324 Wilcox St', 'dog', N'Piper', 60.00, 'weekly', '20210314', NULL),
    (N'Bobbi Welker', N'324 Wilcox St', 'dog', N'Kipper', 65.00, 'weekly', '20210314', NULL),
    (N'Mark Doppler', N'5329 53rd St', 'guinea pig', N'Ginger', 35.00, 'biweekly', '20191029', NULL),
    (N'Tara Hamid', N'210 Sunrise Dr.', 'rabbit', N'Holly', 50.00, 'biweekly', '20211212', NULL),
    (N'Leni Baker', N'3210 Gandy Blvd.', 'cat', N'Pussy Willow', 55.00, 'weekly', '20190924', NULL),
    (N'Leni Baker', N'3210 Gandy Blvd.', 'cat', N'Kitty Cat', 60.00, 'weekly', '20190924', NULL),
    (N'Heather Rieder', N'937 MLK St.', 'rabbit', N'Hopper', 45.00, 'weekly', '20220202', NULL),
    (N'Lee Kleshinski', N'4903 49th Ave', 'dog', N'Phillip', 60.00, 'weekly', '20210708', NULL),
    (N'Tracy Price', N'9027 Juniper St', 'rabbit', N'Dopey', 55.00, 'biweekly', '20190930', NULL),
    (N'Tracy Price', N'9027 Juniper St', 'guinea pig', N'Spicy', 40.00, 'biweekly', '20190930', NULL);
GO

-- 1. Number of current pets by type.
SELECT
    PetType,
    COUNT(*) AS CurrentPetCount
FROM dbo.Customer
WHERE CustomerEndDate IS NULL
GROUP BY PetType
ORDER BY PetType;
GO

-- 2. Current owners with more than one pet.
SELECT
    OwnerName,
    OwnerAddress,
    COUNT(*) AS PetCount
FROM dbo.Customer
WHERE CustomerEndDate IS NULL
GROUP BY OwnerName, OwnerAddress
HAVING COUNT(*) > 1
ORDER BY PetCount DESC, OwnerName;
GO

-- 3. Current customer(s) who pay the most annually, based on service frequency.
WITH CustomerCharges AS
(
    SELECT
        OwnerName,
        OwnerAddress,
        SUM(GroomingPrice * CASE ServiceFrequency
            WHEN 'weekly' THEN 52
            WHEN 'biweekly' THEN 26
        END) AS AnnualGroomingCharge
    FROM dbo.Customer
    WHERE CustomerEndDate IS NULL
    GROUP BY OwnerName, OwnerAddress
)
SELECT TOP (1) WITH TIES
    OwnerName,
    OwnerAddress,
    AnnualGroomingCharge
FROM CustomerCharges
ORDER BY AnnualGroomingCharge DESC;
GO

-- 4. Average grooming charge per current animal type.
SELECT
    PetType,
    CAST(AVG(GroomingPrice) AS decimal(10, 2)) AS AverageGroomingCharge
FROM dbo.Customer
WHERE CustomerEndDate IS NULL
GROUP BY PetType
ORDER BY PetType;
GO
