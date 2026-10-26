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
            group(Finance)
            {
                Caption = 'Finance';
                action(ContributionBatches) { ApplicationArea = All; Caption = 'Monthly Contribution Batches'; RunObject = page "PFE Contribution Batches"; }
                action(ContributionEntries) { ApplicationArea = All; Caption = 'Member Contribution History'; RunObject = page "PFE Contribution Entries"; }
                action(ContributionPaymentMatches) { ApplicationArea = All; Caption = 'Contribution Payment Matches'; RunObject = page "PFE Contribution Payments"; }
                group(GeneralLedger)
                {
                    Caption = 'General Ledger';
                    action(ChartOfAccounts) { ApplicationArea = All; Caption = 'Chart of Accounts'; RunObject = page "Chart of Accounts"; ToolTip = 'View contribution receivable and member balance control accounts alongside the company chart of accounts.'; }
                    action(GLEntries) { ApplicationArea = All; Caption = 'General Ledger Entries'; RunObject = page "General Ledger Entries"; }
                    action(GLRegisters) { ApplicationArea = All; Caption = 'G/L Registers'; RunObject = page "G/L Registers"; }
                    action(GeneralJournals) { ApplicationArea = All; Caption = 'General Journals'; RunObject = page "General Journal"; AccessByPermission = tabledata "Gen. Journal Line" = M; }
                }
                group(Receivables)
                {
                    Caption = 'Employer Receivables';
                    action(EmployerCustomers) { ApplicationArea = All; Caption = 'Employer Customer Accounts'; RunObject = page "Customer List"; ToolTip = 'Open BC customer accounts, including the pension customers linked from employer cards.'; }
                    action(CustomerLedger) { ApplicationArea = All; Caption = 'Customer Ledger Entries'; RunObject = page "Customer Ledger Entries"; ToolTip = 'Review employer contribution receivables and apply posted customer payments.'; }
                    action(CashReceipts) { ApplicationArea = All; Caption = 'Cash Receipt Journal'; RunObject = page "Cash Receipt Journal"; AccessByPermission = tabledata "Gen. Journal Line" = M; ToolTip = 'Record employer payments through the standard BC receipt process before matching them to contribution batches.'; }
                }
                group(Banking)
                {
                    Caption = 'Banking';
                    action(BankAccounts) { ApplicationArea = All; Caption = 'Bank Accounts'; RunObject = page "Bank Account List"; AccessByPermission = tabledata "Bank Account" = R; }
                    action(BankLedger) { ApplicationArea = All; Caption = 'Bank Account Ledger Entries'; RunObject = page "Bank Account Ledger Entries"; AccessByPermission = tabledata "Bank Account Ledger Entry" = R; }
                    action(BankReconciliation) { ApplicationArea = All; Caption = 'Bank Reconciliations'; RunObject = page "Bank Acc. Reconciliation List"; AccessByPermission = tabledata "Bank Acc. Reconciliation" = M; }
                }
                group(FinanceSetup)
                {
                    Caption = 'Financial Setup';
                    action(ContributionAccountingSetup) { ApplicationArea = All; Caption = 'Contribution Accounting Setup'; RunObject = page "PFE Setup"; AccessByPermission = tabledata "PFE Setup" = M; ToolTip = 'Configure contribution control accounts, posting journal and number series.'; }
                    action(Currencies) { ApplicationArea = All; Caption = 'Currencies and Exchange Rates'; RunObject = page Currencies; }
                    action(CustomerPostingGroups) { ApplicationArea = All; Caption = 'Customer Posting Groups'; RunObject = page "Customer Posting Groups"; AccessByPermission = tabledata "Customer Posting Group" = M; }
                    action(GeneralLedgerSetup) { ApplicationArea = All; Caption = 'General Ledger Setup'; RunObject = page "General Ledger Setup"; AccessByPermission = tabledata "General Ledger Setup" = M; }
                }
            }
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
                    ToolTip = 'Configure contribution control accounts, posting journals and number series.';
                }
            }
        }

        area(Embedding)
        {
            action(MonthlyContributions) { ApplicationArea = All; Caption = 'Contribution Batches'; RunObject = page "PFE Contribution Batches"; }
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
            action(NewContributionBatch) { ApplicationArea = All; Caption = 'New Contribution Batch'; RunObject = page "PFE Contribution Batch"; RunPageMode = Create; Image = NewDocument; }
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
