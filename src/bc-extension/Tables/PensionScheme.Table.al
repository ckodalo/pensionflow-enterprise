
table 50100 "PFE Pension Scheme"
{
    Caption = 'Pension Scheme';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Scheme Code"; Code[20])
        {
            Caption = 'Scheme Code';
            NotBlank = true;
        }

        field(2; "Scheme Name"; Text[100])
        {
            Caption = 'Scheme Name';
        }

        field(3; "Scheme Type"; Enum "PFE Scheme Type")
        {
            Caption = 'Scheme Type';
        }

        field(4; "Employee Rate"; Decimal)
        {
            Caption = 'Employee Contribution Rate';
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 5;
        }

        field(5; "Employer Rate"; Decimal)
        {
            Caption = 'Employer Contribution Rate';
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 5;
        }

        field(6; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
        }

        field(7; Status; Enum "PFE Scheme Status")
        {
            Caption = 'Status';
        }
    }

    keys
    {
        key(PK; "Scheme Code")
        {
            Clustered = true;
        }
    }
}
