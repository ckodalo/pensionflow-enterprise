table 50111 "PFE Contribution Payment"
{
    Caption = 'Contribution Payment Match';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Batch No."; Code[20]) { TableRelation = "PFE Contribution Batch"; }
        field(2; "Payment Entry No."; Integer) { TableRelation = "Cust. Ledger Entry"."Entry No."; }
        field(3; Amount; Decimal) { MinValue = 0; }
        field(4; "Document No."; Code[20]) { }
        field(5; "Payment Date"; Date) { }
        field(6; "Matched By"; Code[50]) { }
        field(7; "Matched At"; DateTime) { }
        field(8; "Currency Code"; Code[10]) { TableRelation = Currency; }
    }
    keys { key(PK; "Batch No.", "Payment Entry No.") { Clustered = true; } }
    trigger OnModify()
    begin
        Error('Remove the payment match and create it again to correct it.');
    end;
    trigger OnRename()
    begin
        Error('Payment matches cannot be renamed.');
    end;
}
