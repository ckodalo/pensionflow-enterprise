
page 50100 "PFE Pension Scheme List"
{
    PageType = List;
    SourceTable = "PFE Pension Scheme";
    Caption = 'Pension Schemes';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "PFE Pension Scheme Card";

    layout
    {
        area(Content)
        {
            repeater(Schemes)
            {
                field("Scheme Code"; Rec."Scheme Code")
                {
                    ApplicationArea = All;
                }

                field("Scheme Name"; Rec."Scheme Name")
                {
                    ApplicationArea = All;
                }

                field("Scheme Type"; Rec."Scheme Type")
                {
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scheme participation category.';
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
                RunPageLink = "Scheme Code" = field("Scheme Code");
                ToolTip = 'View scheme enrollments for this record.';
            }
        }
    }

}
