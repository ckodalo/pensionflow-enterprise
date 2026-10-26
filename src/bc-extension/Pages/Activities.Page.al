page 50110 "PFE Activities"
{
    Caption = 'PensionFlow Overview';
    PageType = CardPart;
    SourceTable = "PFE Activities Cue";
    ApplicationArea = All;
    RefreshOnActivate = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            cuegroup(Overview)
            {
                Caption = 'PensionFlow Overview';
                field("Members"; Rec."Members")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of members in the current company. Select the cue to open the matching records.';
                    DrillDownPageId = "PFE Member List";
                }
                field("Employers"; Rec."Employers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of employers in the current company. Select the cue to open the matching records.';
                    DrillDownPageId = "PFE Employer List";
                }
                field("Schemes"; Rec."Schemes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of schemes in the current company. Select the cue to open the matching records.';
                    DrillDownPageId = "PFE Pension Scheme List";
                }
                field("Enrollments"; Rec."Enrollments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of enrollments in the current company. Select the cue to open the matching records.';
                    DrillDownPageId = "PFE Enrollment List";
                }
            }
            cuegroup(EnrollmentActivity)
            {
                Caption = 'Enrollment Activity';
                field("Active Enrollments"; Rec."Active Enrollments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of active enrollments in the current company. Select the cue to open the matching records.';
                    DrillDownPageId = "PFE Enrollment List";
                }
                field("Draft Enrollments"; Rec."Draft Enrollments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of draft enrollments in the current company. Select the cue to open the matching records.';
                    DrillDownPageId = "PFE Enrollment List";
                }
            }
            cuegroup(FinanceActivity)
            {
                Caption = 'Finance';
                field("Contributions to Review"; Rec."Contributions to Review") { ApplicationArea = All; DrillDownPageId = "PFE Contribution Batches"; ToolTip = 'Open contribution batches that are Open or Validated and awaiting review or approval.'; }
                field("Contributions to Post"; Rec."Contributions to Post") { ApplicationArea = All; DrillDownPageId = "PFE Contribution Batches"; ToolTip = 'Open approved payroll batches ready for general ledger and member contribution posting.'; }
                field("Posted Contribution Batches"; Rec."Posted Contribution Batches") { ApplicationArea = All; DrillDownPageId = "PFE Contribution Batches"; ToolTip = 'Open posted contribution batches and their linked member history, general ledger entries and payment matches.'; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Init();
        Rec.Insert();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields(Members, Employers, Schemes, Enrollments, "Active Enrollments", "Draft Enrollments",
            "Contributions to Review", "Contributions to Post", "Posted Contribution Batches");
    end;
}
