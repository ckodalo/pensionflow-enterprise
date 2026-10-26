-- Fictional samples for the local BC270_PF demo company only.
-- Direct SQL inserts do not execute Business Central AL triggers.
USE [Demo Database BC (27-0)];
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

INSERT INTO [dbo].[CRONUS International Ltd_$PFE Pension Scheme$41b2d20b-1f4f-404a-bec2-2064832d3c1c]
    ([Scheme Code], [Scheme Name], [Scheme Type], [Employee Rate], [Employer Rate], [Effective Date], [Status], [Category], [$systemCreatedAt], [$systemModifiedAt])
SELECT s.Code, s.Name, s.SchemeType, s.EmployeeRate, s.EmployerRate, CONVERT(datetime, '20260101', 112), s.Status, 2, GETUTCDATE(), GETUTCDATE()
FROM (VALUES
    (N'DEMO-DC', N'Demo Growth Pension Scheme', 0, 5.0, 10.0, 1),
    (N'DEMO-DB', N'Demo Secure Pension Scheme', 1, 6.0, 12.0, 1),
    (N'DEMO-DRAFT', N'Demo Future Pension Scheme', 0, 4.0, 8.0, 0)
) s(Code, Name, SchemeType, EmployeeRate, EmployerRate, Status)
WHERE NOT EXISTS (
    SELECT 1 FROM [dbo].[CRONUS International Ltd_$PFE Pension Scheme$41b2d20b-1f4f-404a-bec2-2064832d3c1c] t WITH (UPDLOCK, HOLDLOCK)
    WHERE t.[Scheme Code] = s.Code
);
SELECT @@ROWCOUNT AS SchemesInserted;

INSERT INTO [dbo].[CRONUS International Ltd_$PFE Employer$41b2d20b-1f4f-404a-bec2-2064832d3c1c]
    ([Employer Code], [Employer Name], [Registration No_], [Tax PIN], [Contact Person], [Email Address], [Phone No_], [Address], [City], [Status], [Date Registered], [BC Customer No_], [No_ Series], [$systemCreatedAt], [$systemModifiedAt])
SELECT e.Code, e.Name, N'', N'', N'', e.Email, N'', N'', N'', e.Status, CONVERT(datetime, '20260101', 112), N'', N'', GETUTCDATE(), GETUTCDATE()
FROM (VALUES
    (N'DEMO-EMP001', N'Demo Acacia Manufacturing Ltd.', N'acacia@example.com', 1),
    (N'DEMO-EMP002', N'Demo Horizon Services Ltd.', N'horizon@example.com', 1),
    (N'DEMO-EMP003', N'Demo Summit Trading Ltd.', N'summit@example.com', 0)
) e(Code, Name, Email, Status)
WHERE NOT EXISTS (
    SELECT 1 FROM [dbo].[CRONUS International Ltd_$PFE Employer$41b2d20b-1f4f-404a-bec2-2064832d3c1c] t WITH (UPDLOCK, HOLDLOCK)
    WHERE t.[Employer Code] = e.Code
);
SELECT @@ROWCOUNT AS EmployersInserted;

COMMIT TRANSACTION;

SELECT [Scheme Code], [Scheme Name], [Status]
FROM [dbo].[CRONUS International Ltd_$PFE Pension Scheme$41b2d20b-1f4f-404a-bec2-2064832d3c1c]
WHERE [Scheme Code] IN (N'DEMO-DC', N'DEMO-DB', N'DEMO-DRAFT');

SELECT [Employer Code], [Employer Name], [Status]
FROM [dbo].[CRONUS International Ltd_$PFE Employer$41b2d20b-1f4f-404a-bec2-2064832d3c1c]
WHERE [Employer Code] IN (N'DEMO-EMP001', N'DEMO-EMP002', N'DEMO-EMP003');
