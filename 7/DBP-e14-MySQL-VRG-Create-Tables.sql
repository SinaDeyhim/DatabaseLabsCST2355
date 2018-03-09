/********************************************************************************/
/*																		        */
/*	Kroenke and Auer - Database Processing (13th Edition) Chapter 10C         	*/
/*																		        */
/*	The View Ridge Gallery (VRG) - Create Tables							    */
/*																		        */
/*	These are the MySQL 5.6 SQL code solutions                              	*/
/*																		        */
/********************************************************************************/
DROP TABLE IF EXISTS CUSTOMER_ARTIST_INT;
DROP TABLE IF EXISTS TRANS;
DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS WORK;
DROP TABLE IF EXISTS ARTIST;

DROP VIEW IF EXISTS CustomerPhoneView;
DROP VIEW IF EXISTS CustomerInterestsView;

DROP FUNCTION IF EXISTS FirstNameFirst;

DROP PROCEDURE IF EXISTS InsertCustomerAndInterests;
DROP PROCEDURE IF EXISTS InsertCustomerWithTransaction;

CREATE TABLE ARTIST (
	ArtistID 		     Int 				NOT NULL,
	LastName		     Char(25)			NOT NULL,
	FirstName		     Char(25)			NOT NULL,
	Nationality      	 Char(30)			NULL,
	DateOfBirth      	 Numeric(4)			NULL,
	DateDeceased     	 Numeric(4)			NULL,
	CONSTRAINT 	ArtistPK				  PRIMARY KEY(ArtistID),
	CONSTRAINT 	ArtistAK1				  UNIQUE(LastName, FirstName),
	CONSTRAINT 	NationalityValues CHECK
					(Nationality IN ('Canadian', 'English', 'French',
					 'German', 'Mexican', 'Russian', 'Spanish',
					 'United States')),
	CONSTRAINT 	BirthValuesCheck  CHECK (DateOfBirth < DateDeceased),
	CONSTRAINT 	ValidBirthYear 	  CHECK
					(DateOfBirth LIKE '[1-2][0-9][0-9][0-9]'),
	CONSTRAINT 	ValidDeathYear 	  CHECK
					(DateDeceased LIKE '[1-2][0-9][0-9][0-9]')
	);

CREATE TABLE WORK (
	WorkID 			     Int 				NOT NULL,
	Title 				 Char(35) 		 	NOT NULL,
	Copy 				 Char(12)			NOT NULL,
	Medium 			     Char(35) 		 	NULL,
	Description			 Varchar(1000) 		NULL DEFAULT 'Unknown provenance',
	ArtistID 			   Int 				NOT NULL,
	CONSTRAINT 	WorkPK					 PRIMARY KEY(WorkID),
	CONSTRAINT 	WorkAK1				     UNIQUE(Title, Copy),
	CONSTRAINT 	ArtistFK				 FOREIGN KEY(ArtistID)
      						 REFERENCES ARTIST(ArtistID)
 							        ON UPDATE NO ACTION
							        ON DELETE NO ACTION
	);

CREATE TABLE CUSTOMER (
	CustomerID 			 Int 				NOT NULL,
	LastName 			 Char(25) 		 	NOT NULL,
	FirstName 			 Char(25) 			NOT NULL,
	Street 			     Char(30) 		 	NULL,
	City 				 Char(35)	 		NULL,
	State 			     Char(2) 			NULL,
	ZipPostalCode		 Char(9)			NULL,
	Country			     Char(50)			NULL,
	AreaCode 			 Char(3)			NULL,
	PhoneNumber 		 Char(8) 			NULL,
	Email				 Varchar(100)  		NULL,
  CONSTRAINT 	CustomerPK			   	PRIMARY KEY(CustomerID),
	CONSTRAINT 	EmailAK1				UNIQUE(Email)
	);

CREATE TABLE TRANS (
	TransactionID		 Int 				NOT NULL,
	DateAcquired 		 Datetime			NOT NULL,
	AcquisitionPrice 	 Numeric(8,2)	 	NOT NULL,
	DateSold			 Datetime			NULL,
	AskingPrice			 Numeric(8,2)	 	NULL,
	SalesPrice 			 Numeric(8,2)	 	NULL,
	CustomerID			 Int 				NULL,
	WorkID				 Int 				NOT NULL,
	CONSTRAINT 	TransPK				    PRIMARY KEY(TransactionID),
	CONSTRAINT 	TransWorkFK			   	FOREIGN KEY(WorkID)
						       REFERENCES WORK(WorkID)
 							        ON UPDATE NO ACTION
									ON DELETE NO ACTION,
	CONSTRAINT 	TransCustomerFK 	 	FOREIGN KEY(CustomerID)
						       REFERENCES CUSTOMER(CustomerID)
 							        ON UPDATE NO ACTION
							        ON DELETE NO ACTION,
	CONSTRAINT 	SalesPriceRange 	 	CHECK
					         ((SalesPrice > 0) AND (SalesPrice <=500000)),
	CONSTRAINT	ValidTransDate 		 	CHECK (DateAcquired <= DateSold)
	);

CREATE TABLE CUSTOMER_ARTIST_INT(
	ArtistID 			 Int 				NOT NULL,
	CustomerID 			 Int 				NOT NULL,
  CONSTRAINT 	CAIntPK				    PRIMARY KEY(ArtistID, CustomerID),
	CONSTRAINT 	CAInt_ArtistFK		 	FOREIGN KEY(ArtistID)
						       REFERENCES ARTIST(ArtistID)
									ON UPDATE NO ACTION
							        ON DELETE CASCADE,
	CONSTRAINT 	CAInt_CustomerFK   		FOREIGN KEY(CustomerID)
						       REFERENCES CUSTOMER(CustomerID)
							        ON UPDATE NO ACTION
							        ON DELETE CASCADE
	);

ALTER TABLE CUSTOMER
ADD INDEX ZipPostalCodeIndex
USING BTREE(ZipPostalCode);



CREATE VIEW CustomerInterestsView AS
    SELECT 
        C.LastName AS CustomerLastName,
        C.FirstName AS CustomerFirstName,
        A.LastName AS ArtistName
    FROM
        CUSTOMER AS C
            JOIN
        CUSTOMER_ARTIST_INT AS CAI ON C.CustomerID = CAI.CustomerID
            JOIN
        ARTIST AS A ON CAI.ArtistID = A.ArtistID;
        
CREATE VIEW CustomerPhoneView AS
SELECT LastName AS CustomerLastName,
FirstName AS CustomerFirstName,
CONCAT('(',AreaCode,') ',PhoneNumber) As CustomerPhone
FROM CUSTOMER;

DELIMITER //
CREATE FUNCTION FirstNameFirst
-- These are the input parameters
(
varFirstName Char(25),
varLastName Char(25)
)
RETURNS Varchar(60) DETERMINISTIC
BEGIN
-- This is the variable that will hold the value to be returned
DECLARE varFullName Varchar(60);
-- SQL statements to concatenate the names in the proper order
SET varFullName = CONCAT(varFirstName, ' ', varLastName);
-- Return the concatenated name
RETURN varFullName;
END
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE InsertCustomerAndInterests
(IN newLastName Char(25),
IN newFirstName Char(25),
IN newEmailAddress Varchar(100),
IN newAreaCode Char(3),
IN newPhoneNumber Char(8),
IN newNationality Char(30))
BEGIN
DECLARE varRowCount Int;
DECLARE varArtistID Int;
DECLARE varCustomerID Int;
DECLARE done Int DEFAULT 0;
DECLARE ArtistCursor CURSOR FOR
SELECT ArtistID
FROM ARTIST
WHERE Nationality=newNationality;
DECLARE continue HANDLER FOR NOT FOUND SET done = 1;
# Check to see if Customer already exists in database
SELECT COUNT(*) INTO varRowCount
FROM CUSTOMER
WHERE LastName = newLastName
AND FirstName = newFirstName
AND Email = newEmailAddress
AND AreaCode = newAreaCode
AND PhoneNumber = newPhoneNumber;
# IF (varRowCount > 0) THEN Customer already exists.
IF (varRowCount > 0) THEN
ROLLBACK;
SELECT 'Customer already exists';
END IF;
# IF (varRowCount = 0) THEN Customer does not exist.
# Insert new Customer data.
IF (varRowCount = 0) THEN
INSERT INTO CUSTOMER (LastName, FirstName, Email, AreaCode, PhoneNumber)
VALUES(newLastName, newFirstName, newEmailAddress, newAreaCode,
newPhoneNumber);
# Get new CustomerID surrogate key value.
SET varCustomerID = LAST_INSERT_ID();
# Create intersection record for each appropriate Artist.
OPEN ArtistCursor;
REPEAT
FETCH ArtistCursor INTO varArtistID;
IF NOT done THEN
INSERT INTO CUSTOMER_ARTIST_INT (ArtistID, CustomerID)
VALUES(varArtistID, varCustomerID);
END IF;
UNTIL done END REPEAT;
CLOSE ArtistCursor;
SELECT 'New customer and artist interest data added to database.'
AS InsertCustomerAndInterstsResults;
END IF;
END
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertCustomerWithTransaction
(IN newCustomerLastName Char(25),
IN newCustomerFirstName Char(25),
IN newCustomerEmailAddress Varchar(100),
IN newCustomerAreaCode Char(3),
IN newCustomerPhoneNumber Char(8),
IN transArtistLastName Char(25),
IN transWorkTitle Char(35),
IN transWorkCopy Char(12),
IN transTransSalesPrice Numeric(8,2))
spicwt:BEGIN
DECLARE varRowCount Int;
DECLARE varArtistID Int;
DECLARE varCustomerID Int;
DECLARE varWorkID Int;
DECLARE varTransactionID Int;
# Check to see if InsertCustomerWithTransactionCustomer already exists in database
SELECT COUNT(*) INTO varRowCount
FROM CUSTOMER
WHERE LastName = newCustomerLastName
AND FirstName = newCustomerFirstName
AND Email = newCustomerEmailAddress
AND AreaCode = newCustomerAreaCode
AND PhoneNumber = newCustomerPhoneNumber;
# IF (varRowCount > 0) THEN Customer already exists.
IF (varRowCount > 0)
THEN
SELECT 'Customer already exists';
ROLLBACK;
LEAVE spicwt;
END IF;
# IF varRowCount = 0 THEN Customer does not exist in database.
IF (varRowCount = 0) THEN
spicwtif:BEGIN
# Start transaction - Rollback everything if unable to complete it.
START TRANSACTION;
# Insert new Customer data.
INSERT INTO CUSTOMER (LastName, FirstName, AreaCode, PhoneNumber, Email)
VALUES(newCustomerLastName, newCustomerFirstName,
newCustomerAreaCode, newCustomerPhoneNumber, newCustomerEmailAddress);
# Get new CustomerID surrogate key value.
SET varCustomerID = LAST_INSERT_ID();
# Get ArtistID surrogate key value, check for validity.
SELECT ArtistID INTO varArtistID
FROM ARTIST
WHERE LastName = transArtistLastName;
IF (varArtistID IS NULL) THEN
SELECT 'Invalid ArtistID';
ROLLBACK;
LEAVE spicwtif;
END IF;
# Get WorkID surrogate key value, check for validity.
SELECT WorkID INTO varWorkID
FROM WORK
WHERE ArtistID = varArtistID
AND Title = transWorkTitle
AND Copy = transWorkCopy;
IF (varWorkID IS NULL) THEN
SELECT 'Invalid WorkID';
ROLLBACK;
LEAVE spicwtif;
END IF;
# Get TransID surrogate key value, check for validity.
SELECT TransactionID INTO varTransactionID
FROM TRANS
WHERE WorkID = varWorkID
AND SalesPrice IS NULL;
IF (varTransactionID IS NULL) THEN
SELECT 'Invalid TransactionID';
ROLLBACK;
LEAVE spicwtif;
END IF;
# All surrogate key values of OK, complete the transaction
# Update TRANS row
UPDATE TRANS
SET DateSold = CURRENT_DATE(),
SalesPrice = transTransSalesPrice,
CustomerID = varCustomerID
WHERE TransactionID = varTransactionID;
# Commit the Transaction
COMMIT;
# Create CUSTOMER_ARTIST_INT row
INSERT INTO CUSTOMER_ARTIST_INT (CustomerID, ArtistID)
VALUES(varCustomerID, varArtistID);
# The transaction is completed. Print message
SELECT 'The new customer and transaction are now in the database.'
AS InsertCustomerWithTransactionResults;
# END spicwtif
END spicwtif;
END IF;
# END spicwt
END spicwt
//
DELIMITER ;