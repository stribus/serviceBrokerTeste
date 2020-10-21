DECLARE @Handle UNIQUEIDENTIFIER ;
 DECLARE @MessageType SYSNAME ;
 DECLARE @Message XML
 DECLARE @OrderDate DATE
 DECLARE @OrderID INT 
 DECLARE @ProductCode VARCHAR(50)
 DECLARE @Quantity NUMERIC (9,2)
 DECLARE @UnitPrice NUMERIC (9,2)
 
WAITFOR( RECEIVE TOP (1)  
@Handle = conversation_handle,
@MessageType = message_type_name,
@Message = message_body FROM dbo.OrderQueue),TIMEOUT 1000
 
SET @OrderID   =   CAST(CAST(@Message.query('/Order/OrderID/text()') AS NVARCHAR(MAX)) AS INT)
SET @OrderDate   =   CAST(CAST(@Message.query('/Order/OrderDate/text()') AS NVARCHAR(MAX)) AS DATE)
SET @ProductCode =   CAST(CAST(@Message.query('/Order/ProductCode/text()') AS NVARCHAR(MAX)) AS VARCHAR(50))
SET @Quantity    =   CAST(CAST(@Message.query('/Order/Quantity/text()') AS NVARCHAR(MAX)) AS NUMERIC(9,2))
SET @UnitPrice   =   CAST(CAST(@Message.query('/Order/UnitPrice/text()') AS NVARCHAR(MAX)) AS NUMERIC(9,2))
 
PRINT @OrderID
PRINT @OrderDate
PRINT @ProductCode
PRINT @Quantity
PRINT @UnitPrice