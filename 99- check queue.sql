
  DECLARE @Handle UNIQUEIDENTIFIER;
  --Sending the Message to the Queue
  BEGIN
    DIALOG CONVERSATION @Handle
    FROM SERVICE OrderService TO SERVICE 'OrderService' ON CONTRACT [postmessages]
    WITH ENCRYPTION = OFF;
 
    SEND ON CONVERSATION @Handle MESSAGE TYPE ReceivedOrders('noononoonno');






SELECT
	service_name
	, priority
	, queuing_order
	, service_contract_name
	, message_type_name
	, validation
	, message_body
	, message_enqueue_time
	, status
FROM
	dbo.OrderQueue