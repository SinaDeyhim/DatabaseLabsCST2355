SELECT LastName, FirstName, Phone, DateIn, DateOut
FROM  
(INVOICE INNER JOIN CUSTOMER ON CUSTOMER.CustomerID=INVOICE.CustomerNumber)
WHERE TotalAmount>100;
