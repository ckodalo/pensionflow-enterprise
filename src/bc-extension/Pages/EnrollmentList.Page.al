page 50108 "PFE Enrollment List"
{
    PageType = List;
    SourceTable = "PFE Scheme Enrollment";
    Caption = 'Scheme Enrollments';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "PFE Enrollment Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Rows)
            {
                field("Enrollment No."; Rec."Enrollment No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the enrollment number. Leave blank to use the configured number series.';
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the member participating in this enrollment.';
                }
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employer participating in this enrollment.';
                }
                field("Scheme Code"; Rec."Scheme Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scheme. Selecting a different scheme defaults its contribution rates.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the enrollment status. Active enrollments require active linked records.';
                }
                field("Effective From"; Rec."Effective From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first date covered by this enrollment.';
                }
                field("Effective To"; Rec."Effective To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last date covered. Leave blank for an open-ended enrollment.';
                }
                field("Employee Rate"; Rec."Employee Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee contribution percentage for this enrollment.';
                }
                field("Employer Rate"; Rec."Employer Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employer contribution percentage for this enrollment.';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Member)
            {
                ApplicationArea = All;
                Caption = 'Member';
                RunObject = page "PFE Member Card";
                RunPageLink = "Member No." = field("Member No.");
                ToolTip = 'Open the linked member record.';
            }
            action(Employer)
            {
                ApplicationArea = All;
                Caption = 'Employer';
                RunObject = page "PFE Employer Card";
                RunPageLink = "Employer Code" = field("Employer Code");
                ToolTip = 'Open the linked employer record.';
            }
            action(Scheme)
            {
                ApplicationArea = All;
                Caption = 'Scheme';
                RunObject = page "PFE Pension Scheme Card";
                RunPageLink = "Scheme Code" = field("Scheme Code");
                ToolTip = 'Open the linked scheme record.';
            }
        }
    }
}
