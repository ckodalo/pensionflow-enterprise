
page 50101 "PFE Pension Scheme Card"
{
    PageType = Card;
    SourceTable = "PFE Pension Scheme";
    Caption = 'Pension Scheme';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
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
            }

            group(Contributions)
            {
                field("Employee Rate"; Rec."Employee Rate")
                {
                    ApplicationArea = All;
                }

                field("Employer Rate"; Rec."Employer Rate")
                {
                    ApplicationArea = All;
                }

                field("Effective Date"; Rec."Effective Date")
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
                RunPageLink = "Scheme Code" = field("Scheme Code");
                ToolTip = 'View scheme enrollments for this record.';
            }
        }
    }

}
