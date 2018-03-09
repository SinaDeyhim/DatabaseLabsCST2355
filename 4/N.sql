SELECT LastName, FirstName, Phone
FROM CUSTOMER, INVOICE
WHERE CUSTOMER.CustomerID=INVOICE.CustomerNumber
AND TotalAmount>100
ORDER BY LastName ASC, FirstName DESC; 
