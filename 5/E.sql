SELECT ShipmentID, ShipperName, ShipperInvoiceNumber, ArrivalDate, DepartureDate
FROM SHIPMENT
WHERE DepartureDate LIKE '__12%' ;
