SELECT DISTINCT ShipperName, SHIPMENT.ShipmentID, DepartureDate
FROM SHIPMENT, SHIPMENT_ITEM, ITEM 
WHERE SHIPMENT.ShipmentID=SHIPMENT_ITEM.ShipmentID
AND
SHIPMENT_ITEM.ItemID=ITEM.ItemID
AND
ITEM.City='Singapore'
ORDER BY ShipperName, DepartureDate DESC;
