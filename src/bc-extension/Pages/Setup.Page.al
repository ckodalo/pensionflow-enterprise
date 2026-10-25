page 50105 "PFE Setup"
{
    PageType = Card;
    SourceTable = "PFE Setup";
    Caption = 'PensionFlow Setup';
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Employer Nos."; Rec."Employer Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series used to assign employer codes. Enable Manual Nos. on the series to allow manually entered codes.';
                }
                field("Member Nos."; Rec."Member Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series reserved for member numbers.';
                }
                field("Enrollment Nos."; Rec."Enrollment Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series reserved for enrollment numbers.';
                }
                field("Contribution Batch Nos."; Rec."Contribution Batch Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series reserved for contribution batch numbers.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateDefaultNumberSeries)
            {
                ApplicationArea = All;
                Caption = 'Create Default Number Series';
                Image = NumberSetup;
                ToolTip = 'Create default number series for empty setup fields. Existing setup assignments and number sequences are preserved.';

                trigger OnAction()
                var
                    SetupManagement: Codeunit "PFE Setup Management";
                begin
                    CurrPage.SaveRecord();
                    SetupManagement.CreateDefaultNumberSeries(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}
