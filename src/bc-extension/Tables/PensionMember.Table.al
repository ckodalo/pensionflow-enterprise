table 50103 "PFE Pension Member"
{
    Caption = 'Pension Member';
    DataClassification = CustomerContent;
    LookupPageId = "PFE Member List";
    DrillDownPageId = "PFE Member List";

    fields
    {
        field(1; "Member No."; Code[20])
        {
            Caption = 'Member No.';
            // Allow a blank key on new pages; OnInsert assigns the next number.
            trigger OnValidate()
            var
                Setup: Record "PFE Setup";
                NoSeries: Codeunit "No. Series";
            begin
                if "Member No." <> xRec."Member No." then begin
                    Setup.Get();
                    Setup.TestField("Member Nos.");
                    NoSeries.TestManual(Setup."Member Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Member Name"; Text[100])
        {
            Caption = 'Member Name';
        }
        field(3; "Date of Birth"; Date)
        {
            Caption = 'Date of Birth';
            trigger OnValidate()
            begin
                CheckDates();
            end;
        }
        field(4; "Email Address"; Text[100])
        {
            Caption = 'Email Address';
            ExtendedDatatype = EMail;
        }
        field(5; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(6; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(7; City; Text[50])
        {
            Caption = 'City';
        }
        field(8; "Date Registered"; Date)
        {
            Caption = 'Date Registered';
            trigger OnValidate()
            begin
                CheckDates();
            end;
        }
        field(9; Status; Enum "PFE Member Status")
        {
            Caption = 'Status';
        }
        field(10; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            Editable = false;
        }
        field(11; "Import Reference"; Code[50])
        {
            Caption = 'Import Reference';
        }
        field(20; "Contribution Currency Filter"; Code[10]) { FieldClass = FlowFilter; TableRelation = Currency; }
        field(21; "Contribution Scheme Filter"; Code[20]) { FieldClass = FlowFilter; TableRelation = "PFE Pension Scheme"; }
        field(22; "Employee Contributions"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("PFE Contribution Entry"."Employee Contribution" where("Member No." = field("Member No."), "Currency Code" = field("Contribution Currency Filter"), "Scheme Code" = field("Contribution Scheme Filter"), "G/L Transaction No." = filter(> 0)));
            Editable = false;
        }
        field(23; "Employer Contributions"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("PFE Contribution Entry"."Employer Contribution" where("Member No." = field("Member No."), "Currency Code" = field("Contribution Currency Filter"), "Scheme Code" = field("Contribution Scheme Filter"), "G/L Transaction No." = filter(> 0)));
            Editable = false;
        }
        field(24; "Voluntary Contributions"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("PFE Contribution Entry"."Voluntary Contribution" where("Member No." = field("Member No."), "Currency Code" = field("Contribution Currency Filter"), "Scheme Code" = field("Contribution Scheme Filter"), "G/L Transaction No." = filter(> 0)));
            Editable = false;
        }
        field(25; "Contribution Balance"; Decimal)
        {
            Caption = 'Posted Contribution Balance';
            FieldClass = FlowField;
            CalcFormula = sum("PFE Contribution Entry"."Total Due" where("Member No." = field("Member No."), "Currency Code" = field("Contribution Currency Filter"), "Scheme Code" = field("Contribution Scheme Filter"), "G/L Transaction No." = filter(> 0)));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Member No.") { Clustered = true; }
        key(MemberName; "Member Name") { }
        key(ImportReference; "Import Reference") { }
    }

    trigger OnInsert()
    var
        Setup: Record "PFE Setup";
        NoSeries: Codeunit "No. Series";
    begin
        TestField("Member Name");
        if "Date Registered" = 0D then
            "Date Registered" := WorkDate();
        CheckDates();
        CheckImportReference();
        Setup.Get();
        Setup.TestField("Member Nos.");
        if "Member No." = '' then begin
            "No. Series" := Setup."Member Nos.";
            "Member No." := NoSeries.GetNextNo("No. Series", WorkDate());
        end else begin
            NoSeries.TestManual(Setup."Member Nos.");
            "No. Series" := '';
        end;
    end;

    trigger OnModify()
    begin
        if (xRec."Import Reference" <> '') and ("Import Reference" <> xRec."Import Reference") then
            Error('The import reference cannot be changed after the member is created.');
        if "Import Reference" <> xRec."Import Reference" then
            CheckImportReference();
        TestField("Member Name");
        CheckDates();
    end;

    trigger OnDelete()
    begin
        CheckNoEnrollments();
    end;

    trigger OnRename()
    begin
        Error(RenameErr);
    end;

    local procedure CheckImportReference()
    var
        Setup: Record "PFE Setup";
        Member: Record "PFE Pension Member";
    begin
        if "Import Reference" = '' then
            exit;
        // Serialize imported references through the company setup record.
        Setup.LockTable();
        Setup.Get();
        Member.SetRange("Import Reference", "Import Reference");
        Member.SetFilter("Member No.", '<>%1', "Member No.");
        if not Member.IsEmpty() then
            Error('A member already exists with import reference %1.', "Import Reference");
    end;

    local procedure CheckDates()
    begin
        if ("Date of Birth" <> 0D) and ("Date of Birth" > WorkDate()) then
            Error(BirthDateErr);
        if ("Date of Birth" <> 0D) and ("Date Registered" <> 0D) and ("Date Registered" < "Date of Birth") then
            Error(RegistrationDateErr);
    end;

    local procedure CheckNoEnrollments()
    var
        Enrollment: Record "PFE Scheme Enrollment";
        Contribution: Record "PFE Contribution Line";
    begin
        Contribution.SetRange("Member No.", "Member No.");
        if not Contribution.IsEmpty() then
            Error('A member with contribution lines cannot be deleted.');
        Enrollment.SetRange("Member No.", "Member No.");
        if not Enrollment.IsEmpty() then
            Error(EnrollmentExistsErr);
    end;

    var
        BirthDateErr: Label 'Date of birth cannot be after the work date.';
        RegistrationDateErr: Label 'Registration date cannot be before date of birth.';
        EnrollmentExistsErr: Label 'A member with enrollments cannot be deleted.';
        RenameErr: Label 'Member numbers cannot be renamed.';
}
