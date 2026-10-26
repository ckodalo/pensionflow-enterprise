page 50115 "PFE Contribution Batch"
{
    PageType = Card;
    SourceTable = "PFE Contribution Batch";
    Caption = 'Monthly Contribution Batch';
    ApplicationArea = All;
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; Editable = IsOpen; ToolTip = 'Leave blank to assign the next contribution batch number when saving.'; }
                field("Employer Code"; Rec."Employer Code") { ApplicationArea = All; Editable = IsOpen; }
                field("Scheme Code"; Rec."Scheme Code") { ApplicationArea = All; Editable = IsOpen; }
                field("Period Start"; Rec."Period Start") { ApplicationArea = All; Editable = IsOpen; ToolTip = 'Select any date in the contribution month. Eligibility and rates use the enrollment covering month-end; salary is not prorated automatically.'; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; Editable = IsOpen; ToolTip = 'Date used for general ledger and employer customer receivable posting. Foreign currencies require a standard BC exchange rate for this date.'; }
                field(Description; Rec.Description) { ApplicationArea = All; Editable = IsOpen; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; Editable = IsOpen; ToolTip = 'Select the currency for every amount in this batch, including KES. Blank uses the company currency shown below. Currency changes do not convert the uploaded amounts.'; }
                field(Currency; CurrencyLabel) { ApplicationArea = All; Caption = 'Company Currency (Blank Code)'; Editable = false; }
            }
            part(Lines; "PFE Contribution Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Batch No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Totals)
            {
                field("Line Count"; Rec."Line Count") { ApplicationArea = All; }
                field("Total Salary"; Rec."Total Salary") { ApplicationArea = All; }
                field("Expected Employee"; Rec."Expected Employee") { ApplicationArea = All; }
                field("Expected Employer"; Rec."Expected Employer") { ApplicationArea = All; }
                field("Total Employee"; Rec."Total Employee") { ApplicationArea = All; }
                field("Total Employer"; Rec."Total Employer") { ApplicationArea = All; }
                field("Total Voluntary"; Rec."Total Voluntary") { ApplicationArea = All; }
                field("Total Due"; Rec."Total Due") { ApplicationArea = All; ToolTip = 'Shows contributions due after validation, including voluntary amounts. This is separate from money received.'; }
                field("Variance Lines"; Rec."Variance Lines") { ApplicationArea = All; ToolTip = 'Shows lines with either an employee or employer payroll difference, including differences that cancel in the net total.'; }
                field("Total Variance"; Rec."Total Variance") { ApplicationArea = All; }
                field("Matched Payments"; Rec."Matched Payments") { ApplicationArea = All; Caption = 'Recorded Payment Matches'; }
                field(ValidPayments; ValidPayments) { ApplicationArea = All; Caption = 'Valid Matched Payments'; Editable = false; ToolTip = 'Excludes customer payments that have since been reversed. Review Payment Matches to remove reversed matches.'; }
                field(Outstanding; Outstanding) { ApplicationArea = All; Caption = 'Outstanding Amount'; Editable = false; }
            }
            group(Audit)
            {
                field("Approved By"; Rec."Approved By") { ApplicationArea = All; }
                field("Approved At"; Rec."Approved At") { ApplicationArea = All; }
                field("Posted By"; Rec."Posted By") { ApplicationArea = All; }
                field("Posted At"; Rec."Posted At") { ApplicationArea = All; }
                field("Asset Account"; Rec."Asset Account") { ApplicationArea = All; }
                field("Member Balance Account"; Rec."Member Balance Account") { ApplicationArea = All; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; }
                field("G/L Register No."; Rec."G/L Register No.") { ApplicationArea = All; }
                field("Receivable Entry No."; Rec."Receivable Entry No.") { ApplicationArea = All; }
                field("Total Due (LCY)"; Rec."Total Due (LCY)") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(DownloadTemplate)
            {
                ApplicationArea = All;
                Caption = 'Download Contribution Template';
                Image = Export;
                trigger OnAction()
                var
                    Importer: Codeunit "PFE Contribution Import";
                begin
                    CurrPage.SaveRecord();
                    Importer.DownloadTemplate(Rec."No.");
                end;
            }
            action(UploadContributions)
            {
                ApplicationArea = All;
                Caption = 'Upload Contributions';
                Image = Import;
                Enabled = IsOpen;
                trigger OnAction()
                var
                    Importer: Codeunit "PFE Contribution Import";
                begin
                    CurrPage.SaveRecord();
                    Importer.Upload(Rec."No.");
                    CurrPage.Update(false);
                end;
            }
            action(ValidateBatch)
            {
                ApplicationArea = All;
                Caption = 'Validate Contributions';
                Image = Check;
                Enabled = CanValidate;
                trigger OnAction()
                var
                    Management: Codeunit "PFE Contribution Management";
                begin
                    CurrPage.SaveRecord();
                    if Management.ValidateBatch(Rec."No.") then
                        Message('Validation completed. Review totals and variance reasons before approval.')
                    else
                        Message('Correct the Validation Error values on the lines and validate again.');
                    CurrPage.Update(false);
                end;
            }
            action(Approve)
            {
                ApplicationArea = All;
                Caption = 'Approve Batch';
                Image = Approve;
                Enabled = CanApprove;
                trigger OnAction()
                var
                    Management: Codeunit "PFE Contribution Management";
                begin
                    CurrPage.SaveRecord();
                    Management.Approve(Rec."No.");
                    CurrPage.Update(false);
                end;
            }
            action(Reopen)
            {
                ApplicationArea = All;
                Caption = 'Reopen Batch';
                Image = ReOpen;
                Enabled = CanReopen;
                trigger OnAction()
                var
                    Management: Codeunit "PFE Contribution Management";
                begin
                    Management.Reopen(Rec."No.");
                    CurrPage.Update(false);
                end;
            }
            action(PostBatch)
            {
                ApplicationArea = All;
                Caption = 'Post Contributions';
                Image = Post;
                Enabled = CanPost;
                ToolTip = 'Debits the employer contribution receivable, credits the member balance control account, and creates each member contribution entry in the same transaction. Upload and validation alone do not post.';
                trigger OnAction()
                var
                    Management: Codeunit "PFE Contribution Management";
                begin
                    if Confirm('Post the approved payroll to the general ledger, employer receivable and member contribution balances?', false) then begin
                        Management.Post(Rec."No.");
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(MatchPayment)
            {
                ApplicationArea = All;
                Caption = 'Match Customer Payment';
                Image = Payment;
                Enabled = IsPosted;
                trigger OnAction()
                var
                    MatchDialog: Page "PFE Match Contribution Payment";
                begin
                    MatchDialog.SetBatch(Rec."No.");
                    MatchDialog.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(GeneralLedgerEntries) { ApplicationArea = All; Caption = 'General Ledger Entries'; RunObject = page "General Ledger Entries"; RunPageLink = "Transaction No." = field("G/L Transaction No."); Enabled = IsPosted; }
            action(EmployerReceivable) { ApplicationArea = All; Caption = 'Employer Receivable'; RunObject = page "Customer Ledger Entries"; RunPageLink = "Entry No." = field("Receivable Entry No."); Enabled = IsPosted; }
            action(PostedEntries) { ApplicationArea = All; Caption = 'Posted Contributions'; RunObject = page "PFE Contribution Entries"; RunPageLink = "Batch No." = field("No."); }
            action(PaymentMatches) { ApplicationArea = All; Caption = 'Payment Matches'; RunObject = page "PFE Contribution Payments"; RunPageLink = "Batch No." = field("No."); }
        }
    }
    trigger OnOpenPage()
    var
        GLSetup: Record "General Ledger Setup";
        CurrencyManagement: Codeunit "PFE Contribution Currency";
    begin
        CurrencyManagement.EnsureKES();
        GLSetup.Get();
        CurrencyLabel := GLSetup."LCY Code";
        if CurrencyLabel = '' then
            CurrencyLabel := 'Local currency';
    end;

    trigger OnAfterGetCurrRecord()
    var
        Management: Codeunit "PFE Contribution Management";
    begin
        IsOpen := Rec.Status = Rec.Status::Open;
        CanValidate := Rec.Status in [Rec.Status::Open, Rec.Status::Validated];
        CanApprove := Rec.Status = Rec.Status::Validated;
        CanReopen := Rec.Status in [Rec.Status::Validated, Rec.Status::Approved];
        CanPost := Rec.Status = Rec.Status::Approved;
        IsPosted := Rec.Status = Rec.Status::Posted;
        Rec.CalcFields("Total Due", "Matched Payments");
        ValidPayments := Management.ValidMatchedAmount(Rec."No.");
        Outstanding := Rec."Total Due" - ValidPayments;
        CurrPage.Lines.Page.SetBatchEditable(IsOpen);
    end;

    var
        IsOpen: Boolean;
        CanValidate: Boolean;
        CanApprove: Boolean;
        CanReopen: Boolean;
        CanPost: Boolean;
        IsPosted: Boolean;
        Outstanding: Decimal;
        ValidPayments: Decimal;
        CurrencyLabel: Text[30];
}
