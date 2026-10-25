table 50102 "PFE Setup"
{
    Caption = 'PensionFlow Setup';
    DataClassification = CustomerContent;
    LookupPageId = "PFE Setup";
    DrillDownPageId = "PFE Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Employer Nos."; Code[20])
        {
            Caption = 'Employer Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Member Nos."; Code[20])
        {
            Caption = 'Member Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Enrollment Nos."; Code[20])
        {
            Caption = 'Enrollment Nos.';
            TableRelation = "No. Series";
        }
        field(5; "Contribution Batch Nos."; Code[20])
        {
            Caption = 'Contribution Batch Nos.';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        TestField("Primary Key", '');
    end;

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr);
    end;

    var
        RenameNotAllowedErr: Label 'The PensionFlow setup record cannot be renamed.';
}
