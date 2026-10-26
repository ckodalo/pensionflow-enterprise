page 50116 "PFE Contribution Lines"
{
    PageType = ListPart;
    SourceTable = "PFE Contribution Line";
    ApplicationArea = All;
    AutoSplitKey = true;
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                Editable = BatchEditable;
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Editable = false; }
                field("Member No."; Rec."Member No.") { ApplicationArea = All; }
                field("Import Reference"; Rec."Import Reference") { ApplicationArea = All; }
                field("Pensionable Salary"; Rec."Pensionable Salary") { ApplicationArea = All; }
                field("Payroll Amounts Supplied"; Rec."Payroll Amounts Supplied") { ApplicationArea = All; ToolTip = 'Select to use the employee and employer amounts supplied by payroll, including explicit zero amounts. Otherwise validation calculates both from salary.'; }
                field("Employee Contribution"; Rec."Employee Contribution") { ApplicationArea = All; }
                field("Employer Contribution"; Rec."Employer Contribution") { ApplicationArea = All; }
                field("Voluntary Contribution"; Rec."Voluntary Contribution") { ApplicationArea = All; }
                field("Enrollment No."; Rec."Enrollment No.") { ApplicationArea = All; }
                field("Employee Rate"; Rec."Employee Rate") { ApplicationArea = All; }
                field("Employer Rate"; Rec."Employer Rate") { ApplicationArea = All; }
                field("Expected Employee"; Rec."Expected Employee") { ApplicationArea = All; }
                field("Expected Employer"; Rec."Expected Employer") { ApplicationArea = All; }
                field("Employee Variance"; Rec."Employee Variance") { ApplicationArea = All; }
                field("Employer Variance"; Rec."Employer Variance") { ApplicationArea = All; }
                field("Has Variance"; Rec."Has Variance") { ApplicationArea = All; }
                field("Variance Reason"; Rec."Variance Reason") { ApplicationArea = All; ToolTip = 'Required before approval when either payroll contribution differs from the expected amount. Reopen a validated batch to enter a reason.'; }
                field("Total Due"; Rec."Total Due") { ApplicationArea = All; }
                field("Validation Error"; Rec."Validation Error") { ApplicationArea = All; Style = Unfavorable; }
            }
        }
    }
    procedure SetBatchEditable(Value: Boolean)
    begin
        BatchEditable := Value;
    end;
    var
        BatchEditable: Boolean;
}
