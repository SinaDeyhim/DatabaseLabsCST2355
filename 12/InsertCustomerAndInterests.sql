CREATE PROCEDURE InsertCustomerAndInterests
@NewLastName Char(25),
@NewFirstName Char(25),
@NewEmailAddress Varchar(100),
@NewAreaCode Char(3),
@NewPhoneNumber Char(8),
@Nationality Char(30)
AS
BEGIN
DECLARE @RowCount AS Int
DECLARE @ArtistID AS Int
DECLARE @CustomerID AS Int
-- Check to see if Customer already exist in database
SELECT @RowCount = COUNT(*)
FROM dbo.CUSTOMER
WHERE LastName = @NewLastName
AND FirstName = @NewFirstName
AND Email = @NewEmailAddress
AND AreaCode = @NewAreaCode
AND PhoneNumber = @NewPhoneNumber;
-- IF @RowCount > 0 THEN Customer already exists.
IF (@RowCount > 0)
BEGIN
PRINT '******************************************************'
PRINT ''
PRINT ' The Customer is already in the database. '
PRINT ''
PRINT ' Customer Last Name = '+@NewLastName
PRINT ' Customer First Name = '+@NewFirstName
PRINT ''
PRINT '******************************************************'
RETURN
END
-- IF @RowCount = 0 THEN Customer does not exist in database.
ELSE
BEGIN
-- Insert new Customer data.
INSERT INTO dbo.CUSTOMER
(LastName, FirstName, Email, AreaCode, PhoneNumber)
VALUES(
@NewLastName, @NewFirstName, @NewEmailAddress, @NewAreaCode,
@NewPhoneNumber);
-- Get new CustomerID surrogate key value.
SELECT @CustomerID = CustomerID
FROM dbo.CUSTOMER
WHERE LastName = @NewLastName
AND FirstName = @NewFirstName
AND Email = @NewEmailAddress
AND AreaCode = @NewAreaCode
AND PhoneNumber = @NewPhoneNumber;
PRINT '******************************************************'
PRINT ''
PRINT ' The new Customer is now in the database. '
PRINT ''
PRINT ' Customer Last Name = '+@NewLastName
PRINT ' Customer First Name = '+@NewFirstName
PRINT ''
PRINT '******************************************************'
-- Create intersection record for each appropriate Artist.
DECLARE ArtistCursor CURSOR FOR
SELECT ArtistID
FROM dbo.ARTIST
WHERE Nationality=@Nationality
--Process each appropriate Artist
OPEN ArtistCursor
FETCH NEXT FROM ArtistCursor INTO @ArtistID
WHILE @@FETCH_STATUS = 0
BEGIN
INSERT INTO dbo.CUSTOMER_ARTIST_INT
(ArtistID, CustomerID)
VALUES(@ArtistID, @CustomerID);
PRINT '*************************************************'
PRINT ''
PRINT ' New CUSTOMER_ARTIST_INT row added. '
PRINT ''
PRINT ' ArtistID = '+CONVERT(Char(6), @ArtistID)
PRINT ' CustomerID = '+CONVERT(Char(6), @CustomerID)
PRINT ''
PRINT '*************************************************'
FETCH NEXT FROM ArtistCursor INTO @ArtistID
END
CLOSE ArtistCursor
DEALLOCATE ArtistCursor
END
END