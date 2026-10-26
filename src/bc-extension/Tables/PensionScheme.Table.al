
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
            Caption = 'Benefit Design';
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
        field(8; Category; Enum "PFE Scheme Category")
        {
            Caption = 'Scheme Category';
        }
    }

    keys
    {
        key(PK; "Scheme Code")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        CheckCategory();
    end;

    trigger OnModify()
    begin
        CheckCategory();
    end;

    local procedure CheckCategory()
    var
        Enrollment: Record "PFE Scheme Enrollment";
        Participation: Record "PFE Scheme Employer";
    begin
        if Category = Category::Individual then begin
            TestField("Employer Rate", 0);
            Participation.SetRange("Scheme Code", "Scheme Code");
            if not Participation.IsEmpty() then
                Error('A scheme with participating employers cannot become an Individual scheme.');
        end;
        Enrollment.SetRange("Scheme Code", "Scheme Code");
        if Enrollment.FindSet() then
            repeat
                if Category = Category::Unspecified then
                    Error('A scheme with enrollments must have a category.');
                if (Category = Category::Individual) and (Enrollment."Employer Code" <> '') then
                    Error('Existing employer enrollments are incompatible with an Individual scheme.');
                if (Category <> Category::Individual) and (Enrollment."Employer Code" = '') then
                    Error('Existing individual enrollments require an Individual scheme.');
            until Enrollment.Next() = 0;
    end;

    trigger OnDelete()
    var
        Enrollment: Record "PFE Scheme Enrollment";
        Participation: Record "PFE Scheme Employer";
    begin
        Enrollment.SetRange("Scheme Code", "Scheme Code");
        if not Enrollment.IsEmpty() then
            Error('A scheme with enrollments cannot be deleted.');
        Participation.SetRange("Scheme Code", "Scheme Code");
        if not Participation.IsEmpty() then
            Error('A scheme with participating employers cannot be deleted.');
    end;

    trigger OnRename()
    var
        Enrollment: Record "PFE Scheme Enrollment";
        Participation: Record "PFE Scheme Employer";
    begin
        Enrollment.SetRange("Scheme Code", xRec."Scheme Code");
        if not Enrollment.IsEmpty() then
            Error('A scheme with enrollments cannot be renamed.');
        Participation.SetRange("Scheme Code", xRec."Scheme Code");
        if not Participation.IsEmpty() then
            Error('A scheme with participating employers cannot be renamed.');
    end;

}
