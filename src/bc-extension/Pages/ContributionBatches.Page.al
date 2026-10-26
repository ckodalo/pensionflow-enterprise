page 50114 "PFE Contribution Batches"
{
    PageType = List;
    SourceTable = "PFE Contribution Batch";
    Caption = 'Monthly Contribution Batches';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "PFE Contribution Batch";
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Batches)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Employer Code"; Rec."Employer Code") { ApplicationArea = All; }
                field("Scheme Code"; Rec."Scheme Code") { ApplicationArea = All; }
                field("Period Start"; Rec."Period Start") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Line Count"; Rec."Line Count") { ApplicationArea = All; }
                field("Total Due"; Rec."Total Due") { ApplicationArea = All; }
                field("Matched Payments"; ValidPayments) { ApplicationArea = All; Caption = 'Valid Matched Payments'; }
                field(Outstanding; Outstanding) { ApplicationArea = All; Caption = 'Outstanding Amount'; }
                field("Variance Lines"; Rec."Variance Lines") { ApplicationArea = All; }
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        Management: Codeunit "PFE Contribution Management";
    begin
        Rec.CalcFields("Total Due");
        ValidPayments := Management.ValidMatchedAmount(Rec."No.");
        Outstanding := Rec."Total Due" - ValidPayments;
    end;
    var
        ValidPayments: Decimal;
        Outstanding: Decimal;
}
