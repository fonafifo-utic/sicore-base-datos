use []
go

IF EXISTS(SELECT * FROM sysobjects WHERE id = object_id(N'[].[]') and objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE [].[]
GO

CREATE PROCEDURE [].[] (@parametro as nvarchar(max))
AS
BEGIN TRY
	BEGIN TRANSACTION
	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH