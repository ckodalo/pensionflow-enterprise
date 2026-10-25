codeunit 50100 "PFE Setup Management"
{
    procedure CreateDefaultNumberSeries(var Setup: Record "PFE Setup")
    begin
        Setup.LockTable();
        Setup.Get();
        if Setup."Employer Nos." = '' then
            Setup.Validate("Employer Nos.", CreateSeries('PFE-EMP', 'PensionFlow employers', 'EMP000001', 'EMP999999'));
        if Setup."Member Nos." = '' then
            Setup.Validate("Member Nos.", CreateSeries('PFE-MEM', 'PensionFlow members', 'MEM000001', 'MEM999999'));
        if Setup."Enrollment Nos." = '' then
            Setup.Validate("Enrollment Nos.", CreateSeries('PFE-ENR', 'PensionFlow enrollments', 'ENR000001', 'ENR999999'));
        if Setup."Contribution Batch Nos." = '' then
            Setup.Validate("Contribution Batch Nos.", CreateSeries('PFE-CB', 'PensionFlow contribution batches', 'CB000001', 'CB999999'));
        Setup.Modify(true);
    end;

    local procedure CreateSeries(SeriesCode: Code[20]; Description: Text[100]; StartingNo: Code[20]; EndingNo: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // A conflicting code must be reviewed rather than silently reused or overwritten.
        NoSeries.Init();
        NoSeries.Validate(Code, SeriesCode);
        NoSeries.Validate(Description, Description);
        NoSeries.Validate("Default Nos.", true);
        NoSeries.Validate("Manual Nos.", false);
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine.Validate("Series Code", SeriesCode);
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
        NoSeriesLine.Validate("Increment-by No.", 1);
        NoSeriesLine.Insert(true);
        exit(SeriesCode);
    end;
}
