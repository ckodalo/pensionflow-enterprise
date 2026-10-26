page 50118 "PFE Contribution Payments"
{
    Caption = 'Contribution Payment Matches';
    PageType = List;
    SourceTable = "PFE Contribution Payment";
    ApplicationArea = All;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Payments)
            {
                field("Batch No."; Rec."Batch No.") { ApplicationArea = All; }
                field("Payment Entry No."; Rec."Payment Entry No.") { ApplicationArea = All; }
                field("Document No."; Rec."Document No.") { ApplicationArea = All; }
                field("Payment Date"; Rec."Payment Date") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field(Reversed; PaymentReversed) { ApplicationArea = All; Caption = 'Payment Reversed'; ToolTip = 'Shows whether the linked customer payment has since been reversed. Remove this match if it is no longer valid.'; }
                field("Matched By"; Rec."Matched By") { ApplicationArea = All; }
                field("Matched At"; Rec."Matched At") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(RemoveMatch)
            {
                ApplicationArea = All;
                Caption = 'Remove Payment Match';
                Image = UnApply;
                trigger OnAction()
                var
                    Management: Codeunit "PFE Contribution Management";
                begin
                    if Confirm('Remove this contribution payment match? The posted customer payment will remain unchanged.', false) then begin
                        Management.RemovePayment(Rec."Batch No.", Rec."Payment Entry No.");
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        Ledger: Record "Cust. Ledger Entry";
    begin
        PaymentReversed := false;
        if Ledger.Get(Rec."Payment Entry No.") then
            PaymentReversed := Ledger.Reversed;
    end;
    var
        PaymentReversed: Boolean;
}
