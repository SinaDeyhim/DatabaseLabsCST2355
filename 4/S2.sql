SELECT LastName, FirstName, Phone
FROM CUSTOMER, INVOICE
WHERE
CUSTOMER.CustomerID=INVOICE.CustomerNumber
AND InvoiceNumber IN
(SELECT InvoiceNumber FROM INVOICE_ITEM
WHERE Item ='Dress Shirt')
ORDER BY LastName ASC, FirstName DESC; 
