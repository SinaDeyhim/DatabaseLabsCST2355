USE [VRG]
GO
/****** Object:  Trigger [dbo].[CIV_ChangeCustomerName]    Script Date: 2018-03-09 9:57:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[CIV_ChangeCustomerName]
ON [dbo].[CustomerInterestsView]
INSTEAD OF UPDATE
 
AS
BEGIN
        Set NOCOUNT ON;
 
        DECLARE			
						@OldCustomerFirstName   AS Char(25),
                        @OldCustomerLastName    AS Char(25),
                        @NewCustomerFirstName   AS Char(25),
						@NewCustomerLastName    AS Char(25),
						@CustomerID             AS Int
 
        -- Get values of old and new names
		Select @NewCustomerLastName = CustomerLastName
        From inserted;

		Select @NewCustomerFirstName = CustomerFirstName
        From inserted;
 
        Select @OldCustomerLastName = CustomerLastName
        from deleted;
 
        Select @oldCustomerFirstName = CustomerFirstName
        from deleted;
		
		-- count the number of synonyms in customer
        Select *
        from dbo.CUSTOMER AS C1
        where C1.LastName = @OldCustomerLastName
		AND C1.FirstName  = @oldCustomerFirstName
        AND EXISTS
                (Select *
                from dbo.CUSTOMER as C2
                where C1.LastName = C2.LastName
				AND C1.FirstName=C2.FirstName
                AND C1.CustomerID <> C2.CustomerID);
 
        IF(@@rowCount = 0)
                BEGIN
                        SELECT @CustomerID = CustomerID
						FROM dbo.CUSTOMER AS C
						WHERE C.LastName = @OldCustomerLastName
						AND C.FirstName= @OldCustomerFirstName
						
						UPDATE dbo.CUSTOMER
                        SET LastName = @NewCustomerLastName
                        Where CustomerID = @CustomerID

						UPDATE dbo.CUSTOMER
                        SET FirstName = @NewCustomerFirstName
                        Where CustomerID = @CustomerID

                        PRINT '*********************************'
                        PRINT ''
                        PRINT ' The Customer Name has been changed'
                        PRINT ''
						PRINT ' Customer ID Number         = '+CONVERT (Char(6), @CustomerID)
                        PRINT ''
                        PRINT ' Former Customer Last Name  = '+@OldCustomerLastName
                        PRINT ' Former Customer First Name = '+@OldCustomerFirstName
                        PRINT ''
                        PRINT ' Updated Customer Last Name = '+@NewCustomerLastName
						PRINT ' Updated Customer First Name = '+@NewCustomerFirstName
                        PRINT ''
                        PRINT '*******************************************'
                        END
 
                        ELSE
                                BEGIN
                                PRINT '*********************************'
                                PRINT ''
                                PRINT ' Transaction cancelled'
                                PRINT ''
                                PRINT ' Customer Last Name  = '+@OldCustomerLastName
								PRINT ' Customer First Name = '+@OldCustomerFirstName
                                PRINT ''
                                PRINT ''
                                PRINT ' The Customer name is not unique'
                                PRINT '*******************************************'
                                END

           END