table 50106 "PFE Activities Cue"
{
    Caption = 'PensionFlow Activities Cue';
    TableType = Temporary;
    DataClassification = SystemMetadata;
    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key'; }
        field(2; "Members"; Integer)
        {
            Caption = 'Pension Members';
            FieldClass = FlowField;
            CalcFormula = count("PFE Pension Member");
            Editable = false;
        }
        field(3; "Employers"; Integer)
        {
            Caption = 'Employers';
            FieldClass = FlowField;
            CalcFormula = count("PFE Employer");
            Editable = false;
        }
        field(4; "Schemes"; Integer)
        {
            Caption = 'Pension Schemes';
            FieldClass = FlowField;
            CalcFormula = count("PFE Pension Scheme");
            Editable = false;
        }
        field(5; "Enrollments"; Integer)
        {
            Caption = 'Scheme Enrollments';
            FieldClass = FlowField;
            CalcFormula = count("PFE Scheme Enrollment");
            Editable = false;
        }
        field(6; "Active Enrollments"; Integer)
        {
            Caption = 'Active Enrollments';
            FieldClass = FlowField;
            CalcFormula = count("PFE Scheme Enrollment" where(Status = const(Active)));
            Editable = false;
        }
        field(7; "Draft Enrollments"; Integer)
        {
            Caption = 'Draft Enrollments';
            FieldClass = FlowField;
            CalcFormula = count("PFE Scheme Enrollment" where(Status = const(Draft)));
            Editable = false;
        }
        field(8; "Contributions to Review"; Integer)
        {
            Caption = 'Contribution Batches to Review';
            FieldClass = FlowField;
            CalcFormula = count("PFE Contribution Batch" where(Status = filter(Open | Validated)));
            Editable = false;
        }
        field(9; "Contributions to Post"; Integer)
        {
            Caption = 'Approved Batches to Post';
            FieldClass = FlowField;
            CalcFormula = count("PFE Contribution Batch" where(Status = const(Approved)));
            Editable = false;
        }
        field(10; "Posted Contribution Batches"; Integer)
        {
            Caption = 'Posted Contribution Batches';
            FieldClass = FlowField;
            CalcFormula = count("PFE Contribution Batch" where(Status = const(Posted)));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
