
table 50101 "PFE Employer"
{
    Caption = 'Pension Employer';
    DataClassification = CustomerContent;
    LookupPageId = "PFE Employer List";
    DrillDownPageId = "PFE Employer List";

    fields
    {
        field(1; "Employer Code"; Code[20])
        {
            Caption = 'Employer Code';
            // Allow a blank key on new pages; OnInsert assigns the next number.

            trigger OnValidate()
            var
                Setup: Record "PFE Setup";
                NoSeries: Codeunit "No. Series";
            begin
                if "Employer Code" <> xRec."Employer Code" then begin
                    Setup.Get();
                    Setup.TestField("Employer Nos.");
                    NoSeries.TestManual(Setup."Employer Nos.");
                    "No. Series" := '';
                end;
            end;
        }

        field(2; "Employer Name"; Text[100])
        {
            Caption = 'Employer Name';
        }

        field(3; "Registration No."; Code[30])
        {
            Caption = 'Registration Number';
        }

        field(4; "Tax PIN"; Code[20])
        {
            Caption = 'Tax PIN';
        }

        field(5; "Contact Person"; Text[100])
        {
            Caption = 'Contact Person';
        }

        field(6; "Email Address"; Text[100])
        {
            Caption = 'Email Address';
            ExtendedDatatype = EMail;
        }

        field(7; "Phone No."; Text[30])
        {
            Caption = 'Phone Number';
            ExtendedDatatype = PhoneNo;
        }

        field(8; Address; Text[100])
        {
            Caption = 'Address';
        }

        field(9; City; Text[50])
        {
            Caption = 'City';
        }

        field(10; Status; Enum "PFE Employer Status")
        {
            Caption = 'Status';
        }

        field(11; "Date Registered"; Date)
        {
            Caption = 'Date Registered';
        }

        field(12; "BC Customer No."; Code[20])
        {
            Caption = 'Business Central Customer No.';
            TableRelation = Customer."No.";
        }

        field(13; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            Editable = false;
        }
        field(14; "Contribution Asset Account"; Code[20])
        {
            Caption = 'Contributions Receivable Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), "Income/Balance" = const("Balance Sheet"));
        }
    }

    keys
    {
        key(PK; "Employer Code")
        {
            Clustered = true;
        }

        key(EmployerName; "Employer Name")
        {
        }
    }

    trigger OnInsert()
    var
        Setup: Record "PFE Setup";
        NoSeries: Codeunit "No. Series";
    begin
        Setup.Get();
        Setup.TestField("Employer Nos.");
        if "Employer Code" = '' then begin
            "No. Series" := Setup."Employer Nos.";
            "Employer Code" := NoSeries.GetNextNo("No. Series", WorkDate());
        end else begin
            NoSeries.TestManual(Setup."Employer Nos.");
            "No. Series" := '';
        end;
    end;
    trigger OnDelete()
    var
        Enrollment: Record "PFE Scheme Enrollment";
        Participation: Record "PFE Scheme Employer";
        Contribution: Record "PFE Contribution Batch";
    begin
        Contribution.SetRange("Employer Code", "Employer Code");
        if not Contribution.IsEmpty() then
            Error('An employer with contribution batches cannot be deleted.');
        Enrollment.SetRange("Employer Code", "Employer Code");
        if not Enrollment.IsEmpty() then
            Error('An employer with enrollments cannot be deleted.');
        Participation.SetRange("Employer Code", "Employer Code");
        if not Participation.IsEmpty() then
            Error('An employer participating in schemes cannot be deleted.');
    end;

    trigger OnRename()
    var
        Enrollment: Record "PFE Scheme Enrollment";
        Participation: Record "PFE Scheme Employer";
    begin
        Enrollment.SetRange("Employer Code", xRec."Employer Code");
        if not Enrollment.IsEmpty() then
            Error('An employer with enrollments cannot be renamed.');
        Participation.SetRange("Employer Code", xRec."Employer Code");
        if not Participation.IsEmpty() then
            Error('An employer participating in schemes cannot be renamed.');
    end;

}
