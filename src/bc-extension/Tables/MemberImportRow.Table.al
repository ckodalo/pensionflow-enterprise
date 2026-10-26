table 50105 "PFE Member Import Row"
{
    Caption = 'Member Import Row';
    TableType = Temporary;
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Row No."; Integer) { Caption = 'Row No.'; }
        field(2; "Import Reference"; Code[50]) { Caption = 'Import Reference'; }
        field(3; "Member No."; Code[20]) { Caption = 'Member No.'; }
        field(4; "Member Name"; Text[100]) { Caption = 'Member Name'; }
        field(5; "Date of Birth"; Date) { Caption = 'Date of Birth'; }
        field(6; "Email Address"; Text[100]) { Caption = 'Email Address'; }
        field(7; "Phone No."; Text[30]) { Caption = 'Phone No.'; }
        field(8; "Address"; Text[100]) { Caption = 'Address'; }
        field(9; "City"; Text[50]) { Caption = 'City'; }
        field(10; "Date Registered"; Date) { Caption = 'Date Registered'; }
        field(11; "Status"; Enum "PFE Member Status") { Caption = 'Status'; }
        field(12; "Existing Member No."; Code[20]) { Caption = 'Existing Member No.'; }
    }
    keys
    {
        key(PK; "Row No.") { Clustered = true; }
        key(ImportReference; "Import Reference") { }
        key(MemberNo; "Member No.") { }
    }
}
