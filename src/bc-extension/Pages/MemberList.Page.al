page 50106 "PFE Member List"
{
    PageType = List;
    SourceTable = "PFE Pension Member";
    Caption = 'Pension Members';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "PFE Member Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Rows)
            {
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the member number. Leave blank to use the configured number series.';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the pension member.';
                }
                field("Date Registered"; Rec."Date Registered")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the member registered.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the member is active.';
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the member email address.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the member phone number.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(RegisterMember)
            {
                ApplicationArea = All;
                Caption = 'Register Member';
                Image = NewCustomer;
                RunObject = page "PFE Member Card";
                RunPageMode = Create;
                ToolTip = 'Register a member independently. Select a scheme and any employer later through enrollment.';
            }
            action(ImportEmployerMembers)
            {
                ApplicationArea = All;
                Caption = 'Import Employer Members';
                Image = ImportExcel;
                ToolTip = 'Select an employer, participating scheme, and dates, then import or reuse members and create enrollments.';
                trigger OnAction()
                var
                    Importer: Codeunit "PFE Member Import";
                begin
                    Importer.UploadEnrolledMembers("PFE Member Import Mode"::Employer);
                    CurrPage.Update(false);
                end;
            }
            action(ImportIndividualMembers)
            {
                ApplicationArea = All;
                Caption = 'Import Individual Members';
                Image = ImportExcel;
                ToolTip = 'Import or reuse members and enroll them in an Individual scheme without an employer.';
                trigger OnAction()
                var
                    Importer: Codeunit "PFE Member Import";
                begin
                    Importer.UploadEnrolledMembers("PFE Member Import Mode"::Individual);
                    CurrPage.Update(false);
                end;
            }
            action(DownloadImportTemplate)
            {
                ApplicationArea = All;
                Caption = 'Download Member Template';
                Image = ExportToExcel;
                ToolTip = 'Download the Excel template for bulk member registration. Keep the Members worksheet and headers unchanged.';
                trigger OnAction()
                var
                    MemberImport: Codeunit "PFE Member Import";
                begin
                    MemberImport.DownloadTemplate();
                end;
            }
            action(ImportMembers)
            {
                ApplicationArea = All;
                Caption = 'Import Members Only';
                Image = ImportExcel;
                ToolTip = 'Upload completed member rows. All rows must pass validation before any members are created. Invalid rows are returned in an Excel error report.';
                trigger OnAction()
                var
                    MemberImport: Codeunit "PFE Member Import";
                begin
                    MemberImport.UploadMembers();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(Enrollments)
            {
                ApplicationArea = All;
                Caption = 'Enrollments';
                Image = List;
                RunObject = page "PFE Enrollment List";
                RunPageLink = "Member No." = field("Member No.");
                ToolTip = 'View enrollments for this member.';
            }
        }
    }
}
