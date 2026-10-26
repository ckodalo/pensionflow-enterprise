table 50108 "PFE Contribution Batch"
{
    Caption = 'Contribution Batch';
    DataClassification = CustomerContent;
    LookupPageId = "PFE Contribution Batches";
    DrillDownPageId = "PFE Contribution Batches";
    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Batch No.';
            trigger OnValidate()
            var
                Setup: Record "PFE Setup";
                NoSeries: Codeunit "No. Series";
            begin
                if "No." <> xRec."No." then begin
                    Setup.Get();
                    Setup.TestField("Contribution Batch Nos.");
                    NoSeries.TestManual(Setup."Contribution Batch Nos.");
                end;
            end;
        }
        field(2; "Employer Code"; Code[20]) { TableRelation = "PFE Employer"; }
        field(3; "Scheme Code"; Code[20]) { TableRelation = "PFE Pension Scheme"; }
        field(4; "Period Start"; Date)
        {
            Caption = 'Contribution Month';
            trigger OnValidate()
            begin
                if "Period Start" <> 0D then
                    "Period Start" := DMY2Date(1, Date2DMY("Period Start", 2), Date2DMY("Period Start", 3));
            end;
        }
        field(5; Description; Text[100]) { }
        field(6; Status; Enum "PFE Contribution Status") { Editable = false; }
        field(7; "Approved By"; Code[50]) { Editable = false; }
        field(8; "Approved At"; DateTime) { Editable = false; }
        field(9; "Posted By"; Code[50]) { Editable = false; }
        field(10; "Posted At"; DateTime) { Editable = false; }
        field(11; "Total Due"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("PFE Contribution Line"."Total Due" where("Batch No." = field("No.")));
            Editable = false;
        }
        field(12; "Matched Payments"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("PFE Contribution Payment".Amount where("Batch No." = field("No.")));
            Editable = false;
        }
        field(13; "Line Count"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("PFE Contribution Line" where("Batch No." = field("No.")));
            Editable = false;
        }
        field(14; "Total Variance"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("PFE Contribution Line".Variance where("Batch No." = field("No.")));
            Editable = false;
        }
        field(15; "Variance Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("PFE Contribution Line" where("Batch No." = field("No."), "Has Variance" = const(true)));
            Editable = false;
        }
        field(16; "Total Salary"; Decimal) { FieldClass = FlowField; CalcFormula = sum("PFE Contribution Line"."Pensionable Salary" where("Batch No." = field("No."))); Editable = false; }
        field(17; "Total Employee"; Decimal) { FieldClass = FlowField; CalcFormula = sum("PFE Contribution Line"."Employee Contribution" where("Batch No." = field("No."))); Editable = false; }
        field(18; "Total Employer"; Decimal) { FieldClass = FlowField; CalcFormula = sum("PFE Contribution Line"."Employer Contribution" where("Batch No." = field("No."))); Editable = false; }
        field(19; "Total Voluntary"; Decimal) { FieldClass = FlowField; CalcFormula = sum("PFE Contribution Line"."Voluntary Contribution" where("Batch No." = field("No."))); Editable = false; }
        field(20; "Expected Employee"; Decimal) { FieldClass = FlowField; CalcFormula = sum("PFE Contribution Line"."Expected Employee" where("Batch No." = field("No."))); Editable = false; }
        field(21; "Expected Employer"; Decimal) { FieldClass = FlowField; CalcFormula = sum("PFE Contribution Line"."Expected Employer" where("Batch No." = field("No."))); Editable = false; }
        field(22; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(23; "Posting Date"; Date) { }
        field(24; "Asset Account"; Code[20]) { Caption = 'Approved Receivable Account'; Editable = false; TableRelation = "G/L Account"; }
        field(25; "Member Balance Account"; Code[20]) { Caption = 'Approved Member Balance Account'; Editable = false; TableRelation = "G/L Account"; }
        field(26; "Customer No."; Code[20]) { Caption = 'Approved Employer Customer'; Editable = false; TableRelation = Customer; }
        field(27; "G/L Register No."; Integer) { Editable = false; TableRelation = "G/L Register"; }
        field(28; "G/L Transaction No."; Integer) { Editable = false; }
        field(29; "Receivable Entry No."; Integer) { Editable = false; TableRelation = "Cust. Ledger Entry"; }
        field(30; "Total Due (LCY)"; Decimal) { Editable = false; }
    }
    keys { key(PK; "No.") { Clustered = true; } }
    trigger OnInsert()
    var
        Setup: Record "PFE Setup";
        NoSeries: Codeunit "No. Series";
    begin
        TestField(Status, Status::Open);
        Setup.Get();
        Setup.TestField("Contribution Batch Nos.");
        if "No." = '' then
            "No." := NoSeries.GetNextNo(Setup."Contribution Batch Nos.", WorkDate())
        else
            NoSeries.TestManual(Setup."Contribution Batch Nos.");
        TestField("No.");
        if "Posting Date" = 0D then
            "Posting Date" := WorkDate();
    end;
    trigger OnModify()
    var
        Previous: Record "PFE Contribution Batch";
    begin
        Previous.Get("No.");
        if Previous.Status = Previous.Status::Posted then
            Error('Posted contribution batches cannot be changed.');
        if (Previous.Status <> Previous.Status::Open) and
           (("Employer Code" <> Previous."Employer Code") or ("Scheme Code" <> Previous."Scheme Code") or
            ("Period Start" <> Previous."Period Start") or ("Currency Code" <> Previous."Currency Code") or
            ("Posting Date" <> Previous."Posting Date") or (Description <> Previous.Description)) then
            Error('Reopen the batch before changing its details.');
    end;
    trigger OnDelete()
    var
        Line: Record "PFE Contribution Line";
    begin
        TestField(Status, Status::Open);
        Line.SetRange("Batch No.", "No.");
        Line.DeleteAll(true);
    end;
    trigger OnRename()
    begin
        Error('Contribution batch numbers cannot be renamed.');
    end;
}
