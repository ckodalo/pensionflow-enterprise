-- Local BC270_PF / CRONUS company only. User-authorized direct SQL account setup.
-- Direct SQL bypasses AL triggers. This script creates empty master accounts only,
-- including the companion extension rows; it never creates ledger entries.
-- Preview: sqlcmd -S lpc:localhost -E -b -i scripts/create-contribution-accounts.sql -v Apply=0
-- Apply:   sqlcmd -S lpc:localhost -E -b -i scripts/create-contribution-accounts.sql -v Apply=1
USE [Demo Database BC (27-0)];
SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @Apply bit = $(Apply);
DECLARE @Now datetime = GETUTCDATE();
DECLARE @ExternalActor uniqueidentifier = '00000000-0000-0000-0000-000000000000';
DECLARE @Created table (AccountNo nvarchar(20));
DECLARE @Accounts table (AccountNo nvarchar(20) PRIMARY KEY, AccountName nvarchar(100), Category int, DirectPosting tinyint);
INSERT INTO @Accounts VALUES
    (N'PFE-1300', N'Pension contributions receivable', 1, 0),
    (N'PFE-2300', N'Pension member balances control', 2, 1);

BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (
        SELECT 1 FROM [dbo].[CRONUS International Ltd_$PFE Employer$41b2d20b-1f4f-404a-bec2-2064832d3c1c]
        WHERE [Employer Code] = N'PFEMP001' AND [Employer Name] = N'Wizz Solutions'
    ) THROW 51000, 'Expected Wizz Solutions employer was not found. Verify the target company.', 1;

    IF EXISTS (
        SELECT 1
        FROM [dbo].[CRONUS International Ltd_$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972] a WITH (UPDLOCK, HOLDLOCK)
        JOIN @Accounts s ON s.AccountNo = a.[No_]
        WHERE a.Name <> s.AccountName OR a.[Account Type] <> 0 OR a.[Income_Balance] <> 1
          OR a.[Account Category] <> s.Category OR a.[Direct Posting] <> s.DirectPosting OR a.Blocked <> 0
    ) THROW 51001, 'A requested account number already exists with conflicting settings. Nothing was changed.', 1;

    IF EXISTS (
        SELECT 1 FROM [dbo].[CRONUS International Ltd_$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972$ext] e
        JOIN @Accounts s ON e.[No_] = s.AccountNo
        WHERE NOT EXISTS (SELECT 1 FROM [dbo].[CRONUS International Ltd_$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972] a WHERE a.[No_] = e.[No_])
    ) THROW 51002, 'An orphan companion account row exists. Review before continuing.', 1;

    INSERT INTO [dbo].[CRONUS International Ltd_$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972]
        ([No_], Name, [Search Name], [Account Type], [API Account Type], [Income_Balance],
         [Account Category], [Direct Posting], Blocked, [Last Modified Date Time], [Last Date Modified],
         [$systemCreatedAt], [$systemModifiedAt], [$systemCreatedBy], [$systemModifiedBy])
    OUTPUT inserted.[No_] INTO @Created
    SELECT s.AccountNo, s.AccountName, UPPER(s.AccountName), 0, 0, 1,
           s.Category, s.DirectPosting, 0, @Now, CONVERT(datetime, CONVERT(date, @Now)),
           @Now, @Now, @ExternalActor, @ExternalActor
    FROM @Accounts s
    WHERE NOT EXISTS (
        SELECT 1 FROM [dbo].[CRONUS International Ltd_$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972] a WITH (UPDLOCK, HOLDLOCK)
        WHERE a.[No_] = s.AccountNo
    );

    INSERT INTO [dbo].[CRONUS International Ltd_$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972$ext] ([No_])
    SELECT s.AccountNo FROM @Accounts s
    WHERE NOT EXISTS (
        SELECT 1 FROM [dbo].[CRONUS International Ltd_$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972$ext] e WITH (UPDLOCK, HOLDLOCK)
        WHERE e.[No_] = s.AccountNo
    );

    SELECT a.[No_] AS AccountNo, a.Name, a.[Account Type], a.[Income_Balance], a.[Account Category],
           a.[Direct Posting], a.Blocked, a.[$systemId],
           CASE WHEN c.AccountNo IS NULL THEN 'Already present' ELSE 'Created' END AS Result
    FROM [dbo].[CRONUS International Ltd_$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972] a
    JOIN @Accounts s ON s.AccountNo = a.[No_]
    LEFT JOIN @Created c ON c.AccountNo = a.[No_];

    IF @Apply = 1 BEGIN
        COMMIT TRANSACTION;
        SELECT 'Committed' AS TransactionResult, ORIGINAL_LOGIN() AS SqlLogin;
    END ELSE BEGIN
        ROLLBACK TRANSACTION;
        SELECT 'Preview only - rolled back' AS TransactionResult, ORIGINAL_LOGIN() AS SqlLogin;
    END;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
