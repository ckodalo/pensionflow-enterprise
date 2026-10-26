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
        field(6; "Contribution Asset Account"; Code[20]) { Caption = 'Contributions Receivable Account'; TableRelation = "G/L Account" where("Account Type" = const(Posting), "Income/Balance" = const("Balance Sheet")); }
        field(7; "Member Balance Account"; Code[20]) { TableRelation = "G/L Account" where("Account Type" = const(Posting), "Income/Balance" = const("Balance Sheet")); }
        field(8; "Contribution Jnl. Template"; Code[10]) { TableRelation = "Gen. Journal Template" where(Type = const(General)); }
        field(9; "Contribution Jnl. Batch"; Code[10]) { TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Contribution Jnl. Template")); }
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
