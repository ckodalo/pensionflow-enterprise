table 50109 "PFE Contribution Line"
{
    Caption = 'Contribution Line';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Batch No."; Code[20]) { TableRelation = "PFE Contribution Batch"; }
        field(2; "Line No."; Integer) { }
        field(3; "Member No."; Code[20]) { TableRelation = "PFE Pension Member"; }
        field(4; "Import Reference"; Code[50]) { }
        field(5; "Pensionable Salary"; Decimal) { MinValue = 0; DecimalPlaces = 2 : 5; }
        field(6; "Payroll Amounts Supplied"; Boolean) { }
        field(7; "Employee Contribution"; Decimal) { MinValue = 0; DecimalPlaces = 2 : 5; }
        field(8; "Employer Contribution"; Decimal) { MinValue = 0; DecimalPlaces = 2 : 5; }
        field(9; "Voluntary Contribution"; Decimal) { MinValue = 0; DecimalPlaces = 2 : 5; }
        field(10; "Enrollment No."; Code[20]) { Editable = false; }
        field(11; "Employee Rate"; Decimal) { Editable = false; DecimalPlaces = 0 : 5; }
        field(12; "Employer Rate"; Decimal) { Editable = false; DecimalPlaces = 0 : 5; }
        field(13; "Expected Employee"; Decimal) { Editable = false; }
        field(14; "Expected Employer"; Decimal) { Editable = false; }
        field(15; "Employee Variance"; Decimal) { Editable = false; }
        field(16; "Employer Variance"; Decimal) { Editable = false; }
        field(17; Variance; Decimal) { Editable = false; }
        field(18; "Total Due"; Decimal) { Editable = false; }
        field(19; "Variance Reason"; Text[250]) { }
        field(20; "Validation Error"; Text[250]) { Editable = false; }
        field(21; "Has Variance"; Boolean) { Editable = false; }
    }
    keys
    {
        key(PK; "Batch No.", "Line No.") { Clustered = true; }
        key(Member; "Batch No.", "Member No.") { }
    }
    trigger OnInsert()
    begin
        CheckEditable();
        ClearResults();
    end;
    trigger OnModify()
    begin
        CheckEditable();
        ClearResults();
    end;
    trigger OnDelete()
    begin
        CheckEditable();
    end;
    trigger OnRename()
    begin
        Error('Contribution line keys cannot be renamed.');
    end;
    procedure CheckEditable()
    var
        Batch: Record "PFE Contribution Batch";
    begin
        Batch.LockTable();
        Batch.Get("Batch No.");
        Batch.TestField(Status, Batch.Status::Open);
    end;
    procedure ClearResults()
    begin
        if not "Payroll Amounts Supplied" then begin
            "Employee Contribution" := 0;
            "Employer Contribution" := 0;
        end;
        "Enrollment No." := '';
        "Employee Rate" := 0;
        "Employer Rate" := 0;
        "Expected Employee" := 0;
        "Expected Employer" := 0;
        "Employee Variance" := 0;
        "Employer Variance" := 0;
        Variance := 0;
        "Total Due" := 0;
        "Validation Error" := '';
        "Has Variance" := false;
    end;
}
