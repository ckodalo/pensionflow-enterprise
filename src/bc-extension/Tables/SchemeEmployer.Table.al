table 50107 "PFE Scheme Employer"
{
    Caption = 'Scheme Employer';
    DataClassification = CustomerContent;
    LookupPageId = "PFE Scheme Employers";
    DrillDownPageId = "PFE Scheme Employers";
    fields
    {
        field(1; "Scheme Code"; Code[20])
        {
            Caption = 'Scheme Code';
            TableRelation = "PFE Pension Scheme";
        }
        field(2; "Employer Code"; Code[20])
        {
            Caption = 'Employer Code';
            TableRelation = "PFE Employer";
        }
        field(3; Active; Boolean) { Caption = 'Active'; InitValue = true; }
        field(4; "Effective From"; Date) { Caption = 'Effective From'; }
        field(5; "Effective To"; Date) { Caption = 'Effective To'; }
    }
    keys
    {
        key(PK; "Scheme Code", "Employer Code") { Clustered = true; }
        key(Employer; "Employer Code", "Scheme Code") { }
    }
    trigger OnInsert()
    begin
        CheckParticipation();
    end;
    trigger OnModify()
    begin
        CheckParticipation();
        CheckExistingEnrollments();
    end;
    trigger OnDelete()
    begin
        CheckNoEnrollments();
    end;
    trigger OnRename()
    begin
        Error('Scheme employer participation keys cannot be renamed. Create a new participation instead.');
    end;

    local procedure CheckParticipation()
    var
        Scheme: Record "PFE Pension Scheme";
        Employer: Record "PFE Employer";
    begin
        TestField("Scheme Code");
        TestField("Employer Code");
        Scheme.LockTable();
        Scheme.Get("Scheme Code");
        Employer.LockTable();
        Employer.Get("Employer Code");
        if not (Scheme.Category in [Scheme.Category::Occupational, Scheme.Category::Umbrella]) then
            Error('Employer participation requires an Occupational or Umbrella scheme.');
        if ("Effective From" <> 0D) and ("Effective To" <> 0D) and ("Effective To" < "Effective From") then
            Error('Effective To cannot be before Effective From.');
    end;

    local procedure CheckExistingEnrollments()
    var
        Enrollment: Record "PFE Scheme Enrollment";
    begin
        Enrollment.SetRange("Scheme Code", "Scheme Code");
        Enrollment.SetRange("Employer Code", "Employer Code");
        Enrollment.SetFilter(Status, '<>%1', Enrollment.Status::Cancelled);
        if Enrollment.FindSet() then
            repeat
                if ("Effective From" <> 0D) and (Enrollment."Effective From" < "Effective From") then
                    Error('The participation period must cover existing enrollments.');
                if ("Effective To" <> 0D) and
                   ((Enrollment."Effective To" = 0D) or (Enrollment."Effective To" > "Effective To")) then
                    Error('Close or adjust existing enrollments before shortening the participation period.');
            until Enrollment.Next() = 0;
    end;

    local procedure CheckNoEnrollments()
    var
        Enrollment: Record "PFE Scheme Enrollment";
    begin
        Enrollment.SetRange("Scheme Code", "Scheme Code");
        Enrollment.SetRange("Employer Code", "Employer Code");
        if not Enrollment.IsEmpty() then
            Error('A scheme employer participation with enrollments cannot be deleted.');
    end;
}
