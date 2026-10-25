table 50104 "PFE Scheme Enrollment"
{
    Caption = 'Scheme Enrollment';
    DataClassification = CustomerContent;
    LookupPageId = "PFE Enrollment List";
    DrillDownPageId = "PFE Enrollment List";

    fields
    {
        field(1; "Enrollment No."; Code[20])
        {
            Caption = 'Enrollment No.';
            NotBlank = true;
            trigger OnValidate()
            var
                Setup: Record "PFE Setup";
                NoSeries: Codeunit "No. Series";
            begin
                if "Enrollment No." <> xRec."Enrollment No." then begin
                    Setup.Get();
                    Setup.TestField("Enrollment Nos.");
                    NoSeries.TestManual(Setup."Enrollment Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Member No."; Code[20])
        {
            Caption = 'Member No.';
            TableRelation = "PFE Pension Member";
        }
        field(3; "Employer Code"; Code[20])
        {
            Caption = 'Employer Code';
            TableRelation = "PFE Employer";
        }
        field(4; "Scheme Code"; Code[20])
        {
            Caption = 'Scheme Code';
            TableRelation = "PFE Pension Scheme";
            trigger OnValidate()
            var
                Scheme: Record "PFE Pension Scheme";
            begin
                if "Scheme Code" = xRec."Scheme Code" then
                    exit;
                if "Scheme Code" = '' then begin
                    "Employee Rate" := 0;
                    "Employer Rate" := 0;
                    exit;
                end;
                Scheme.Get("Scheme Code");
                Validate("Employee Rate", Scheme."Employee Rate");
                Validate("Employer Rate", Scheme."Employer Rate");
            end;
        }
        field(5; "Employee Rate"; Decimal)
        {
            Caption = 'Employee Contribution Rate (%)';
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 5;
        }
        field(6; "Employer Rate"; Decimal)
        {
            Caption = 'Employer Contribution Rate (%)';
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 5;
        }
        field(7; "Effective From"; Date)
        {
            Caption = 'Effective From';
            trigger OnValidate()
            begin
                CheckDates();
            end;
        }
        field(8; "Effective To"; Date)
        {
            Caption = 'Effective To';
            trigger OnValidate()
            begin
                CheckDates();
            end;
        }
        field(9; Status; Enum "PFE Enrollment Status")
        {
            Caption = 'Status';
        }
        field(10; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Enrollment No.") { Clustered = true; }
        key(MemberEmployerScheme; "Member No.", "Employer Code", "Scheme Code", "Effective From") { }
        key(EmployerScheme; "Employer Code", "Scheme Code") { }
        key(SchemeEmployer; "Scheme Code", "Employer Code") { }
    }

    trigger OnInsert()
    var
        Setup: Record "PFE Setup";
        NoSeries: Codeunit "No. Series";
    begin
        CheckEnrollment();
        Setup.Get();
        Setup.TestField("Enrollment Nos.");
        if "Enrollment No." = '' then begin
            "No. Series" := Setup."Enrollment Nos.";
            "Enrollment No." := NoSeries.GetNextNo("No. Series", WorkDate());
        end else begin
            NoSeries.TestManual(Setup."Enrollment Nos.");
            "No. Series" := '';
        end;
    end;

    trigger OnModify()
    begin
        CheckEnrollment();
    end;

    trigger OnRename()
    begin
        Error(RenameErr);
    end;

    local procedure CheckDates()
    begin
        if ("Effective From" <> 0D) and ("Effective To" <> 0D) and ("Effective To" < "Effective From") then
            Error(DateRangeErr);
    end;

    local procedure CheckEnrollment()
    var
        Member: Record "PFE Pension Member";
        Employer: Record "PFE Employer";
        Scheme: Record "PFE Pension Scheme";
        OtherEnrollment: Record "PFE Scheme Enrollment";
    begin
        TestField("Member No.");
        TestField("Employer Code");
        TestField("Scheme Code");
        TestField("Effective From");
        // Lock a stable parent row so simultaneous first enrollments for the
        // same member cannot both pass an empty overlap check.
        Member.LockTable();
        Member.Get("Member No.");
        Employer.LockTable();
        Employer.Get("Employer Code");
        Scheme.LockTable();
        Scheme.Get("Scheme Code");
        CheckDates();
        if ("Employee Rate" < 0) or ("Employee Rate" > 100) or
           ("Employer Rate" < 0) or ("Employer Rate" > 100) then
            Error(RateErr);
        if Status = Status::Active then begin
            Member.TestField(Status, Member.Status::Active);
            Employer.TestField(Status, Employer.Status::Active);
            Scheme.TestField(Status, Scheme.Status::Active);
            if (Scheme."Effective Date" <> 0D) and ("Effective From" < Scheme."Effective Date") then
                Error(SchemeDateErr);
        end;
        if Status = Status::Closed then
            TestField("Effective To");
        if Status = Status::Cancelled then
            exit;

        OtherEnrollment.LockTable();
        OtherEnrollment.SetCurrentKey("Member No.", "Employer Code", "Scheme Code", "Effective From");
        OtherEnrollment.SetRange("Member No.", "Member No.");
        OtherEnrollment.SetRange("Employer Code", "Employer Code");
        OtherEnrollment.SetRange("Scheme Code", "Scheme Code");
        OtherEnrollment.SetFilter("Enrollment No.", '<>%1', "Enrollment No.");
        OtherEnrollment.SetFilter(Status, '<>%1', Status::Cancelled);
        if "Effective To" <> 0D then
            OtherEnrollment.SetFilter("Effective From", '<=%1', "Effective To");
        OtherEnrollment.SetFilter("Effective To", '%1|>=%2', 0D, "Effective From");
        if not OtherEnrollment.IsEmpty() then
            Error(OverlapErr);
    end;

    var
        DateRangeErr: Label 'Effective To cannot be before Effective From.';
        RateErr: Label 'Contribution rates must be between 0 and 100.';
        SchemeDateErr: Label 'An active enrollment cannot begin before the scheme effective date.';
        OverlapErr: Label 'The member already has an overlapping enrollment for this employer and scheme.';
        RenameErr: Label 'Enrollment numbers cannot be renamed.';
}
