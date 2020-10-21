

/***Criação do usuario que rodará a SP e o evento para carregar***/
CREATE USER [serviceBrockerUser] FOR LOGIN [adminhomologacao] WITH DEFAULT_SCHEMA=[db_owner]
GO




ALTER QUEUE OrderQueue
WITH ACTIVATION
(
   -- Yes we want activation to start straight away.
   STATUS = ON,
   -- We want to target a local procedure delegate.
   PROCEDURE_NAME = orderMensageria,
   -- We want to process current requests, 20 is enough for this example.
   MAX_QUEUE_READERS = 20,
   -- Here I have simply created a SQL login with dbo privileges to execute the delegate sp.
   EXECUTE AS 'serviceBrockerUser'
);

GO 