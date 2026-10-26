table 50110 "PFE Contribution Entry"
{
    Caption = 'Posted Contribution Entry';
    DataClassification = CustomerContent;
    LookupPageId = "PFE Contribution Entries";
    DrillDownPageId = "PFE Contribution Entries";
    fields
    {
        field(1; "Batch No."; Code[20]) { }
        field(2; "Line No."; Integer) { }
        field(3; "Member No."; Code[20]) { TableRelation = "PFE Pension Member"; }
        field(4; "Employer Code"; Code[20]) { TableRelation = "PFE Employer"; }
        field(5; "Scheme Code"; Code[20]) { TableRelation = "PFE Pension Scheme"; }
        field(6; "Period Start"; Date) { }
        field(7; "Enrollment No."; Code[20]) { }
        field(8; "Pensionable Salary"; Decimal) { }
        field(9; "Employee Rate"; Decimal) { DecimalPlaces = 0 : 5; }
        field(10; "Employer Rate"; Decimal) { DecimalPlaces = 0 : 5; }
        field(11; "Employee Contribution"; Decimal) { }
        field(12; "Employer Contribution"; Decimal) { }
        field(13; "Voluntary Contribution"; Decimal) { }
        field(14; "Expected Employee"; Decimal) { }
        field(15; "Expected Employer"; Decimal) { }
        field(16; "Variance Reason"; Text[250]) { }
        field(17; "Total Due"; Decimal) { }
        field(18; "Posted By"; Code[50]) { }
        field(19; "Posted At"; DateTime) { }
        field(20; "Currency Code"; Code[10]) { TableRelation = Currency; }
        field(21; "Posting Date"; Date) { }
        field(22; "G/L Transaction No."; Integer) { }
        field(23; "Total Due (LCY)"; Decimal) { }
    }
    keys
    {
        key(PK; "Batch No.", "Line No.") { Clustered = true; }
        key(MemberMonth; "Scheme Code", "Member No.", "Period Start") { Unique = true; }
        key(MemberHistory; "Member No.", "Posting Date", "Batch No.", "Line No.") { }
    }
    trigger OnModify()
    begin
        Error('Posted contribution entries cannot be changed.');
    end;
    trigger OnDelete()
    begin
        Error('Posted contribution entries cannot be deleted.');
    end;
    trigger OnRename()
    begin
        Error('Posted contribution entries cannot be renamed.');
    end;
}
