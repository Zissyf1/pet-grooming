/*
    Pet Grooming business scenario
    Run this script in the target SQL Server database.
*/

DROP TABLE IF EXISTS dbo.PetGroomingCustomers;
GO

CREATE TABLE dbo.PetGroomingCustomers
(
    PetGroomingCustomerId int IDENTITY(1, 1) NOT NULL
        CONSTRAINT PK_PetGroomingCustomers PRIMARY KEY,
    OwnerName nvarchar(100) NOT NULL,
    OwnerAddress nvarchar(200) NOT NULL,
    PetType varchar(20) NOT NULL,
    PetName nvarchar(100) NOT NULL,
    GroomingPrice decimal(10, 2) NOT NULL,
    ServiceFrequency varchar(10) NOT NULL,
    PickupDate date NOT NULL,
    CustomerEndDate date NULL,

    CONSTRAINT CK_PetGroomingCustomers_PetType
        CHECK (PetType IN ('dog', 'cat', 'rabbit', 'guinea pig')),
    CONSTRAINT CK_PetGroomingCustomers_GroomingPrice
        CHECK (GroomingPrice >= 0),
    CONSTRAINT CK_PetGroomingCustomers_ServiceFrequency
        CHECK (ServiceFrequency IN ('weekly', 'biweekly')),
    CONSTRAINT CK_PetGroomingCustomers_CustomerEndDate
        CHECK (CustomerEndDate IS NULL OR CustomerEndDate >= PickupDate)
);
GO

INSERT INTO dbo.PetGroomingCustomers
    (OwnerName, OwnerAddress, PetType, PetName, GroomingPrice, ServiceFrequency, PickupDate, CustomerEndDate)
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
FROM dbo.PetGroomingCustomers
WHERE CustomerEndDate IS NULL
GROUP BY PetType
ORDER BY PetType;
GO

-- 2. Current owners with more than one pet.
SELECT
    OwnerName,
    OwnerAddress,
    COUNT(*) AS PetCount
FROM dbo.PetGroomingCustomers
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
    FROM dbo.PetGroomingCustomers
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
FROM dbo.PetGroomingCustomers
WHERE CustomerEndDate IS NULL
GROUP BY PetType
ORDER BY PetType;
GO
