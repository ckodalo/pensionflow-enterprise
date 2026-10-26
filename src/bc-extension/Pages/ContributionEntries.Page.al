page 50117 "PFE Contribution Entries"
{
    Caption = 'Posted Pension Contributions';
    PageType = List;
    SourceTable = "PFE Contribution Entry";
    SourceTableView = sorting("Member No.", "Posting Date", "Batch No.", "Line No.");
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Batch No."; Rec."Batch No.") { ApplicationArea = All; }
                field("Member No."; Rec."Member No.") { ApplicationArea = All; }
                field("Employer Code"; Rec."Employer Code") { ApplicationArea = All; }
                field("Scheme Code"; Rec."Scheme Code") { ApplicationArea = All; }
                field("Period Start"; Rec."Period Start") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field("G/L Transaction No."; Rec."G/L Transaction No.") { ApplicationArea = All; }
                field("Total Due (LCY)"; Rec."Total Due (LCY)") { ApplicationArea = All; }
                field("Enrollment No."; Rec."Enrollment No.") { ApplicationArea = All; }
                field("Pensionable Salary"; Rec."Pensionable Salary") { ApplicationArea = All; }
                field("Employee Rate"; Rec."Employee Rate") { ApplicationArea = All; }
                field("Employer Rate"; Rec."Employer Rate") { ApplicationArea = All; }
                field("Employee Contribution"; Rec."Employee Contribution") { ApplicationArea = All; }
                field("Employer Contribution"; Rec."Employer Contribution") { ApplicationArea = All; }
                field("Voluntary Contribution"; Rec."Voluntary Contribution") { ApplicationArea = All; }
                field("Expected Employee"; Rec."Expected Employee") { ApplicationArea = All; }
                field("Expected Employer"; Rec."Expected Employer") { ApplicationArea = All; }
                field("Variance Reason"; Rec."Variance Reason") { ApplicationArea = All; }
                field("Total Due"; Rec."Total Due") { ApplicationArea = All; }
                field("Posted By"; Rec."Posted By") { ApplicationArea = All; }
                field("Posted At"; Rec."Posted At") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(GeneralLedgerEntries)
            {
                ApplicationArea = All;
                Caption = 'General Ledger Entries';
                RunObject = page "General Ledger Entries";
                RunPageLink = "Transaction No." = field("G/L Transaction No.");
                Enabled = Rec."G/L Transaction No." <> 0;
            }
            action(ContributionBatch)
            {
                ApplicationArea = All;
                Caption = 'Contribution Batch';
                RunObject = page "PFE Contribution Batch";
                RunPageLink = "No." = field("Batch No.");
            }
        }
    }
}
