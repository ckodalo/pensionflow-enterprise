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
            group(ContributionAccounting)
            {
                Caption = 'Contribution Accounting';
                field("Contribution Asset Account"; Rec."Contribution Asset Account") { ApplicationArea = All; ToolTip = 'Default balance-sheet asset control account for employer contributions receivable. Employers can select a different receivable account.'; }
                field("Member Balance Account"; Rec."Member Balance Account") { ApplicationArea = All; ToolTip = 'Default liability control account credited for member contributions. Schemes can select their own member balance control account.'; }
                field("Contribution Jnl. Template"; Rec."Contribution Jnl. Template") { ApplicationArea = All; }
                field("Contribution Jnl. Batch"; Rec."Contribution Jnl. Batch") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateContributionAccounts)
            {
                ApplicationArea = All;
                Caption = 'Create Contribution Accounts';
                Image = Setup;
                ToolTip = 'Creates PFE-1300 Contributions Receivable and PFE-2300 Member Balances Control plus a contribution journal. Existing configured accounts are preserved; conflicting account numbers are rejected.';
                trigger OnAction()
                var
                    Accounting: Codeunit "PFE Contribution Accounting";
                begin
                    CurrPage.SaveRecord();
                    Accounting.CreateDefaultAccounts();
                    CurrPage.Update(false);
                    Message('Contribution accounts and journal are ready. Use Set Up Contribution Accounting on each employer card to link its receivable customer.');
                end;
            }
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
