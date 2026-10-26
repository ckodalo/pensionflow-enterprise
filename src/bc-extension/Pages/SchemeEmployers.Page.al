page 50111 "PFE Scheme Employers"
{
    PageType = List;
    SourceTable = "PFE Scheme Employer";
    Caption = 'Scheme Employers';
    ApplicationArea = All;
    UsageCategory = Lists;
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            repeater(Participations)
            {
                field("Scheme Code"; Rec."Scheme Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Occupational or Umbrella scheme.';
                }
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the participating employer.';
                }
                field("Active"; Rec."Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether new active enrollments are allowed.';
                }
                field("Effective From"; Rec."Effective From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first permitted enrollment date. Blank means unrestricted.';
                }
                field("Effective To"; Rec."Effective To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last permitted enrollment date. Blank means unrestricted.';
                }
            }
        }
    }
}
