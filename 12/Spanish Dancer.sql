-- INSERT new work into WORK
/* *** SQL-INSERT-CH10A-01 *** */
INSERT INTO WORK VALUES(
'Spanish Dancer', '635/750', 'High Quality Limited Print',
'American Realist style - From work in Spain', 11);
-- Obtain the new WorkID form WORK
/* *** SQL-Query-CH10A-07 *** */
SELECT WorkID
FROM dbo.WORK
WHERE ArtistID = 11
AND Title = 'Spanish Dancer'
AND Copy = '635/750';

INSERT INTO TRANS (DateAcquired, AcquisitionPrice, WorkID)
VALUES ('06/8/2014', 200.00, 597);

