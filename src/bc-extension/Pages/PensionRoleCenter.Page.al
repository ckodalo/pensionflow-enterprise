page 50102 "PFE Pension Role Center"
{
    PageType = RoleCenter;
    Caption = 'PensionFlow';
    RefreshOnActivate = true;

    layout
    {
        area(RoleCenter)
        {
            part(Activities; "PFE Activities")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(MemberManagement)
            {
                Caption = 'Member Management';

                action(Members)
                {
                    ApplicationArea = All;
                    Caption = 'Members';
                    RunObject = page "PFE Member List";
                    ToolTip = 'View and manage pension members.';
                }
                action(Enrollments)
                {
                    ApplicationArea = All;
                    Caption = 'Scheme Enrollments';
                    RunObject = page "PFE Enrollment List";
                    ToolTip = 'Manage employer-sponsored and individual pension enrollments.';
                }

            }
            group(SchemeManagement)
            {
                Caption = 'Schemes and Employers';
                action(SchemeEmployers)
                {
                    ApplicationArea = All;
                    Caption = 'Scheme Employers';
                    RunObject = page "PFE Scheme Employers";
                    ToolTip = 'Configure employer participation in Occupational and Umbrella schemes.';
                }

                action(PensionSchemes)
                {
                    ApplicationArea = All;
                    Caption = 'Pension Schemes';
                    RunObject = page "PFE Pension Scheme List";
                    ToolTip = 'View and manage pension schemes.';
                }

                action(Employers)
                {
                    ApplicationArea = All;
                    Caption = 'Employers';
                    RunObject = page "PFE Employer List";
                    ToolTip = 'View and manage pension employers.';
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                action(PensionFlowSetup)
                {
                    ApplicationArea = All;
                    Caption = 'PensionFlow Setup';
                    RunObject = page "PFE Setup";
                    AccessByPermission = tabledata "PFE Setup" = M;
                    ToolTip = 'Configure number series for employers, members, enrollments, and contribution batches.';
                }
            }
        }

        area(Embedding)
        {
            action(MemberList)
            {
                ApplicationArea = All;
                Caption = 'Members';
                RunObject = page "PFE Member List";
                ToolTip = 'View and manage pension members.';
            }
            action(EnrollmentList)
            {
                ApplicationArea = All;
                Caption = 'Scheme Enrollments';
                RunObject = page "PFE Enrollment List";
                ToolTip = 'Manage employer-sponsored and individual pension enrollments.';
            }
            action(PensionSchemeList)
            {
                ApplicationArea = All;
                Caption = 'Pension Schemes';
                RunObject = page "PFE Pension Scheme List";
                ToolTip = 'View and manage pension schemes.';
            }

            action(EmployerList)
            {
                ApplicationArea = All;
                Caption = 'Employers';
                RunObject = page "PFE Employer List";
                ToolTip = 'View and manage pension employers.';
            }
        }

        area(Creation)
        {
            action(NewMember)
            {
                ApplicationArea = All;
                Caption = 'Register Member';
                RunObject = page "PFE Member Card";
                RunPageMode = Create;
                Image = NewCustomer;
                ToolTip = 'Register a new pension member.';
            }
            action(NewEmployer)
            {
                ApplicationArea = All;
                Caption = 'New Employer';
                RunObject = page "PFE Employer Card";
                RunPageMode = Create;
                Image = NewCustomer;
                ToolTip = 'Register a new pension employer.';
            }
            action(NewEnrollment)
            {
                ApplicationArea = All;
                Caption = 'New Enrollment';
                RunObject = page "PFE Enrollment Card";
                RunPageMode = Create;
                Image = NewDocument;
                ToolTip = 'Enroll a member in an employer-sponsored or individual pension scheme.';
            }
        }
    }
}
