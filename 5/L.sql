SELECT City, Store, COUNT(ItemID) AS Number_of_Purchases_Combo
FROM ITEM 
GROUP BY City, Store;