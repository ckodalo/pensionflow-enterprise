page 50119 "PFE Match Contribution Payment"
{
    Caption = 'Match Customer Payment';
    PageType = StandardDialog;
    ApplicationArea = All;
    layout
    {
        area(Content)
        {
            group(Payment)
            {
                field(Batch; BatchNo) { ApplicationArea = All; Caption = 'Contribution Batch'; Editable = false; }
                field(Customer; CustomerNo) { ApplicationArea = All; Caption = 'Employer Customer No.'; Editable = false; }
                field(Currency; CurrencyCode) { ApplicationArea = All; Caption = 'Currency Code'; Editable = false; ToolTip = 'Payment and contribution batch must use the same currency. Blank means company currency.'; }
                field(PaymentEntry; PaymentEntryNo)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Payment Entry No.';
                    ToolTip = 'Choose an existing posted payment in the batch currency for this employer customer. Matching does not post or apply general ledger transactions.';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Ledger: Record "Cust. Ledger Entry";
                        PaymentLookup: Page "Customer Ledger Entries";
                    begin
                        Ledger.SetRange("Customer No.", CustomerNo);
                        Ledger.SetRange("Document Type", Ledger."Document Type"::Payment);
                        Ledger.SetRange("Currency Code", CurrencyCode);
                        Ledger.SetRange(Reversed, false);
                        PaymentLookup.SetTableView(Ledger);
                        PaymentLookup.LookupMode(true);
                        if PaymentLookup.RunModal() = Action::LookupOK then begin
                            PaymentLookup.GetRecord(Ledger);
                            PaymentEntryNo := Ledger."Entry No.";
                        end;
                        exit(true);
                    end;
                }
                field(Amount; MatchAmount) { ApplicationArea = All; Caption = 'Amount to Match'; DecimalPlaces = 2 : 5; }
            }
        }
    }
    procedure SetBatch(Value: Code[20])
    var
        Batch: Record "PFE Contribution Batch";
        Employer: Record "PFE Employer";
        Management: Codeunit "PFE Contribution Management";
    begin
        BatchNo := Value;
        Batch.Get(BatchNo);
        Batch.TestField(Status, Batch.Status::Posted);
        Employer.Get(Batch."Employer Code");
        Employer.TestField("BC Customer No.");
        CustomerNo := Employer."BC Customer No.";
        CurrencyCode := Batch."Currency Code";
        Batch.CalcFields("Total Due", "Matched Payments");
        MatchAmount := Batch."Total Due" - Management.ValidMatchedAmount(BatchNo);
    end;
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Management: Codeunit "PFE Contribution Management";
    begin
        if CloseAction = Action::OK then
            Management.MatchPayment(BatchNo, PaymentEntryNo, MatchAmount);
        exit(true);
    end;
    var
        BatchNo: Code[20];
        CustomerNo: Code[20];
        CurrencyCode: Code[10];
        PaymentEntryNo: Integer;
        MatchAmount: Decimal;
}
