page 50107 "PFE Member Card"
{
    PageType = Card;
    SourceTable = "PFE Pension Member";
    Caption = 'Pension Member';
    ApplicationArea = All;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the member number. Leave blank to use the configured number series.';
                }
                field("Import Reference"; Rec."Import Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an optional stable external identity. Once saved, it cannot be changed. Imports use it to recognize the same member.';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the pension member.';
                }
                field("Date of Birth"; Rec."Date of Birth")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the member date of birth.';
                }
                field("Date Registered"; Rec."Date Registered")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the member registered.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the member is active.';
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the member email address.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the member phone number.';
                }
                field("Address"; Rec."Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the member address.';
                }
                field("City"; Rec."City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the member city.';
                }
            }
            group(ContributionBalances)
            {
                Caption = 'Contribution Balances';
                field(BalanceCurrency; BalanceCurrency)
                {
                    ApplicationArea = All;
                    Caption = 'Balance Currency Code';
                    TableRelation = Currency;
                    ToolTip = 'Select one currency for the contribution totals. Blank means company local currency. Different currencies are never added together.';
                    trigger OnValidate()
                    begin
                        SetContributionFilters();
                        CurrPage.Update(false);
                    end;
                }
                field(BalanceScheme; BalanceScheme)
                {
                    ApplicationArea = All;
                    Caption = 'Balance Scheme';
                    TableRelation = "PFE Pension Scheme";
                    ToolTip = 'Select a scheme, or leave blank for all schemes in the selected currency.';
                    trigger OnValidate()
                    begin
                        SetContributionFilters();
                        CurrPage.Update(false);
                    end;
                }
                field("Employee Contributions"; Rec."Employee Contributions") { ApplicationArea = All; }
                field("Employer Contributions"; Rec."Employer Contributions") { ApplicationArea = All; }
                field("Voluntary Contributions"; Rec."Voluntary Contributions") { ApplicationArea = All; }
                field("Contribution Balance"; Rec."Contribution Balance") { ApplicationArea = All; ToolTip = 'Shows contributions credited to this member and posted to the general ledger, including amounts still receivable. This is not a cash-received or investment account balance.'; }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(PostedContributions)
            {
                ApplicationArea = All;
                Caption = 'Contribution History';
                RunObject = page "PFE Contribution Entries";
                RunPageLink = "Member No." = field("Member No.");
            }
            action(Enrollments)
            {
                ApplicationArea = All;
                Caption = 'Enrollments';
                Image = List;
                RunObject = page "PFE Enrollment List";
                RunPageLink = "Member No." = field("Member No.");
                ToolTip = 'View enrollments for this member.';
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetContributionFilters();
    end;
    local procedure SetContributionFilters()
    begin
        Rec.SetRange("Contribution Currency Filter", BalanceCurrency);
        if BalanceScheme = '' then
            Rec.SetRange("Contribution Scheme Filter")
        else
            Rec.SetRange("Contribution Scheme Filter", BalanceScheme);
        Rec.CalcFields("Employee Contributions", "Employer Contributions", "Voluntary Contributions", "Contribution Balance");
    end;
    var
        BalanceCurrency: Code[10];
        BalanceScheme: Code[20];
}
