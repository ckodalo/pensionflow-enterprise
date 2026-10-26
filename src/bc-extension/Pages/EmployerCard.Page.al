
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
                field("Contribution Asset Account"; Rec."Contribution Asset Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Balance-sheet asset account for this employer contributions receivable. Blank uses PensionFlow Setup. The linked customer posting group must point to the same account.';
                }
                field("BC Customer No."; Rec."BC Customer No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SetUpContributionAccounting)
            {
                ApplicationArea = All;
                Caption = 'Set Up Contribution Accounting';
                Image = Setup;
                AccessByPermission = tabledata "PFE Setup" = M;
                trigger OnAction()
                var
                    Accounting: Codeunit "PFE Contribution Accounting";
                begin
                    CurrPage.SaveRecord();
                    Accounting.SetUpEmployer(Rec."Employer Code");
                    CurrPage.Update(false);
                    Message('The employer receivable account and customer link are ready. Existing linked customers must use the selected receivable account.');
                end;
            }
        }
        area(Navigation)
        {
            action(ContributionBatches)
            {
                ApplicationArea = All;
                Caption = 'Contribution Batches';
                RunObject = page "PFE Contribution Batches";
                RunPageLink = "Employer Code" = field("Employer Code");
            }
            action(ParticipatingSchemes)
            {
                ApplicationArea = All;
                Caption = 'Participating Schemes';
                RunObject = page "PFE Scheme Employers";
                RunPageLink = "Employer Code" = field("Employer Code");
                ToolTip = 'Manage the schemes this employer participates in.';
            }
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
