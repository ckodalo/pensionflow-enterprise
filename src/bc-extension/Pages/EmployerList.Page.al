
page 50103 "PFE Employer List"
{
    PageType = List;
    SourceTable = "PFE Employer";
    Caption = 'Pension Employers';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "PFE Employer Card";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Employers)
            {
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Leave blank to assign the next employer number when the record is saved. Enter a code only if the number series permits manual numbers.';
                }

                field("Employer Name"; Rec."Employer Name")
                {
                    ApplicationArea = All;
                }

                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                }

                field("Tax PIN"; Rec."Tax PIN")
                {
                    ApplicationArea = All;
                }

                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Enrollments)
            {
                ApplicationArea = All;
                Caption = 'Enrollments';
                Image = List;
                RunObject = page "PFE Enrollment List";
                RunPageLink = "Employer Code" = field("Employer Code");
                ToolTip = 'View scheme enrollments for this record.';
            }
        }
    }

}
