/**
 * Switch on Service Broker
SQL server is locked down when you get it out of the box. 
So remove that bubble wrap and enable service broker on the database you’ll use for this lab.
 * */
ALTER DATABASE desenv
 SET enable_broker

/**
 * Message Types
You will need two message types. 
You could consider your message types to be two people conversing at a counter like a landlord & 
patron or a hardware shop keeper & a customer. They both have their own dialect in the conversation so 
we need to define a message type for each of them. For this example I’m simply specifying that I want the messages to be xml types.
 You can explore the additional options at http://msdn.microsoft.com/en-us/library/ms187744.aspx

In the SQL service broker, there can be four types of validations,
 such as NONE, EMPTY, WELL_FORMED_XML, and VALID_XML WITH SCHEMA COLLECTION. 
 In the NONE option, no validations are made, and typically NONE is used as validation left to the consumption.
 * 
 */
CREATE MESSAGE TYPE ReceivedOrders
AUTHORIZATION dbo
VALIDATION = None;;

/**
The next service broker object that we create is the CONTRACT. 
The contract will create a logical grouping of one or more message types. 
This means that there is a one-to-many relationship between the CONTRACT and the MESSAGE TYPE.
*/

CREATE CONTRACT postmessages
(ReceivedOrders SENT BY ANY);;
go
/*
Next, we will be creating an important object called QUEUE that will hold the messages that you are sending.
When the status is set to OFF, you cannot send or receive messages from the queue.
 Another important configuration is that the RETENTION option.
 If the RETENTION is set to OFF, messages will be deleted from the queue.
 If you want to keep the messages for auditing purposes, you can set this to ON.
 However, setting the RETENTION to ON will impact the performance of the system.
 Therefore, it is recommended to set the RETENTION to OFF.
*/
CREATE QUEUE OrderQueue
WITH STATUS = ON, RETENTION = OFF

CREATE SERVICE OrderService
AUTHORIZATION dbo 
ON QUEUE OrderQueue
(postmessages)


CREATE TABLE [dbo].[Orders](
  [OrderID] [int] NOT NULL,
  [OrderDate] [date] NULL,
  [ProductCode] [varchar](50) NOT NULL,
  [Quantity] [numeric](9, 2) NULL,
  [UnitPrice] [numeric](9, 2) NULL,
 CONSTRAINT [PK__Orders] PRIMARY KEY CLUSTERED 
(
  [OrderID] ASC,
  [ProductCode] ASC
)
ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Orders2](
  [OrderID] [int] NOT NULL,
  [OrderDate] [date] NULL,
  [ProductCode] [varchar](50) NOT NULL,
  [Quantity] [numeric](9, 2) NULL,
  [UnitPrice] [numeric](9, 2) NULL,
 CONSTRAINT [PK__Orders2] PRIMARY KEY CLUSTERED 
(
  [OrderID] ASC,
  [ProductCode] ASC
)
ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE PROCEDURE usp_CreateOrders (
  @OrderID INT
  ,@ProductCode VARCHAR(50)
  ,@Quantity NUMERIC(9, 2)
  ,@UnitPrice NUMERIC(9, 2)
  )
AS
BEGIN
  DECLARE @OrderDate AS SMALLDATETIME
  SET @OrderDate = GETDATE()
  DECLARE @XMLMessage XML
 
  CREATE TABLE #Message (
    OrderID INT PRIMARY KEY
    ,OrderDate DATE
    ,ProductCode VARCHAR(50)
    ,Quantity NUMERIC(9, 2)
    ,UnitPrice NUMERIC(9, 2)
    )
 
  INSERT INTO #Message (
    OrderID
    ,OrderDate
    ,ProductCode
    ,Quantity
    ,UnitPrice
    )
  VALUES (
    @OrderID
    ,@OrderDate
    ,@ProductCode
    ,@Quantity
    ,@UnitPrice
    )
 
  --Insert to Orders Table
  INSERT INTO Orders (
    OrderID
    ,OrderDate
    ,ProductCode
    ,Quantity
    ,UnitPrice
    )
  VALUES (
    @OrderID
    ,@OrderDate
    ,@ProductCode
    ,@Quantity
    ,@UnitPrice
    )
     --Creating the XML Message
  SELECT @XMLMessage = (
      SELECT *
      FROM #Message
      FOR XML PATH('Order')
        ,TYPE
      );
 
  DECLARE @Handle UNIQUEIDENTIFIER;
  --Sending the Message to the Queue
  BEGIN
    DIALOG CONVERSATION @Handle
    FROM SERVICE OrderService TO SERVICE 'OrderService' ON CONTRACT [postmessages]
    WITH ENCRYPTION = OFF;
 
    SEND ON CONVERSATION @Handle MESSAGE TYPE ReceivedOrders(@XMLMessage);
  END 
  GO