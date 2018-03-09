SELECT LastName, FirstName, Phone
FROM (CUSTOMER JOIN INVOICE
ON
CUSTOMER.CustomerID=INVOICE.CustomerNumber)
JOIN INVOICE_ITEM 
ON
INVOICE.InvoiceNumber=INVOICE_ITEM.InvoiceNumber
WHERE Item='Dress Shirt'
ORDER BY LastName ASC, FirstName DESC; 
