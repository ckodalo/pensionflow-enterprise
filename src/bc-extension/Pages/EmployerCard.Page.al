
page 50104 "PFE Employer Card"
{
    PageType = Card;
    SourceTable = "PFE Employer";
    Caption = 'Pension Employer';
    ApplicationArea = All;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = All;
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

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }

                field("Date Registered"; Rec."Date Registered")
                {
                    ApplicationArea = All;
                }
            }

            group(Contact)
            {
                field("Contact Person"; Rec."Contact Person")
                {
                    ApplicationArea = All;
                }

                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                }

                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }

                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }

                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
            }

            group(Integration)
            {
                field("BC Customer No."; Rec."BC Customer No.")
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
