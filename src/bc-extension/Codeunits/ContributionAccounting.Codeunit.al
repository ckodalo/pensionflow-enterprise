codeunit 50107 "PFE Contribution Accounting"
{
    Permissions = tabledata "G/L Account" = I,
                  tabledata "Customer Posting Group" = I,
                  tabledata Customer = I,
                  tabledata "Gen. Journal Template" = I,
                  tabledata "Gen. Journal Batch" = I,
                  tabledata "Source Code" = I;

    trigger OnRun()
    begin
        CreateDefaultAccounts();
    end;

    procedure CreateDefaultAccounts()
    var
        Setup: Record "PFE Setup";
        Template: Record "Gen. Journal Template";
        JnlBatch: Record "Gen. Journal Batch";
        Source: Record "Source Code";
    begin
        Setup.LockTable();
        Setup.Get();
        if Setup."Contribution Asset Account" = '' then begin
            CreateAccount('PFE-1300', 'Pension contributions receivable', true);
            Setup.Validate("Contribution Asset Account", 'PFE-1300');
        end;
        if Setup."Member Balance Account" = '' then begin
            CreateAccount('PFE-2300', 'Pension member balances control', false);
            Setup.Validate("Member Balance Account", 'PFE-2300');
        end;
        if not Source.Get('PFE-CONT') then begin
            Source.Init();
            Source.Code := 'PFE-CONT';
            Source.Description := 'Pension contribution payroll';
            Source.Insert(true);
        end;
        if Setup."Contribution Jnl. Template" = '' then begin
            if not Template.Get('PFE-CONTR') then begin
                Template.Init();
                Template.Validate(Name, 'PFE-CONTR');
                Template.Description := 'Pension contribution payroll';
                Template.Validate(Type, Template.Type::General);
                Template."Source Code" := 'PFE-CONT';
                Template.Insert(true);
            end else begin
                Template.TestField(Type, Template.Type::General);
                Template.TestField("Source Code", 'PFE-CONT');
            end;
            Setup.Validate("Contribution Jnl. Template", Template.Name);
        end;
        if Setup."Contribution Jnl. Batch" = '' then begin
            if not JnlBatch.Get(Setup."Contribution Jnl. Template", 'PAYROLL') then begin
                JnlBatch.Init();
                JnlBatch.Validate("Journal Template Name", Setup."Contribution Jnl. Template");
                JnlBatch.Validate(Name, 'PAYROLL');
                JnlBatch.Description := 'Monthly pension contributions';
                JnlBatch.Insert(true);
            end;
            Setup.Validate("Contribution Jnl. Batch", JnlBatch.Name);
        end;
        Setup.Modify(true);
        CheckAccount(Setup."Contribution Asset Account", true);
        CheckAccount(Setup."Member Balance Account", false);
    end;

    procedure SetUpEmployer(EmployerCode: Code[20])
    var
        Setup: Record "PFE Setup";
        Employer: Record "PFE Employer";
        Customer: Record Customer;
        PostingGroup: Record "Customer Posting Group";
        AssetAccount: Code[20];
        GroupCode: Code[20];
    begin
        Setup.Get();
        Employer.LockTable();
        Employer.Get(EmployerCode);
        Employer.TestField("Employer Name");
        AssetAccount := Employer."Contribution Asset Account";
        if AssetAccount = '' then
            AssetAccount := Setup."Contribution Asset Account";
        CheckAccount(AssetAccount, true);
        if Employer."BC Customer No." <> '' then begin
            Customer.Get(Employer."BC Customer No.");
            PostingGroup.Get(Customer."Customer Posting Group");
            PostingGroup.TestField("Receivables Account", AssetAccount);
        end else begin
            GroupCode := CopyStr('PFE-' + AssetAccount, 1, 20);
            if not PostingGroup.Get(GroupCode) then begin
                PostingGroup.Init();
                PostingGroup.Code := GroupCode;
                PostingGroup.Description := 'Pension employer contributions';
                PostingGroup.Validate("Receivables Account", AssetAccount);
                PostingGroup.Insert(true);
            end else
                PostingGroup.TestField("Receivables Account", AssetAccount);
            Customer.Init();
            Customer.Validate(Name, Employer."Employer Name");
            Customer.Validate("Customer Posting Group", PostingGroup.Code);
            Customer.Insert(true);
            Employer.Validate("BC Customer No.", Customer."No.");
        end;
        if Employer."Contribution Asset Account" = '' then
            Employer.Validate("Contribution Asset Account", AssetAccount);
        Employer.Modify(true);
    end;

    procedure SnapshotSetup(var Batch: Record "PFE Contribution Batch")
    var
        AssetAccount: Code[20];
        BalanceAccount: Code[20];
        CustomerNo: Code[20];
    begin
        Batch.TestField("Posting Date");
        ResolveSetup(Batch, AssetAccount, BalanceAccount, CustomerNo);
        Batch."Asset Account" := AssetAccount;
        Batch."Member Balance Account" := BalanceAccount;
        Batch."Customer No." := CustomerNo;
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure PostToGL(var Batch: Record "PFE Contribution Batch")
    var
        Setup: Record "PFE Setup";
        Template: Record "Gen. Journal Template";
        JnlBatch: Record "Gen. Journal Batch";
        Journal: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        Register: Record "G/L Register";
        Receivable: Record "Cust. Ledger Entry";
        Posting: Codeunit "Gen. Jnl.-Post Line";
        AssetAccount: Code[20];
        BalanceAccount: Code[20];
        CustomerNo: Code[20];
        LastEntryNo: Integer;
    begin
        Batch.TestField("G/L Register No.", 0);
        Batch.TestField("Posting Date");
        ResolveSetup(Batch, AssetAccount, BalanceAccount, CustomerNo);
        if (Batch."Asset Account" <> AssetAccount) or (Batch."Member Balance Account" <> BalanceAccount) or
           (Batch."Customer No." <> CustomerNo) then
            Error('Accounting setup changed since approval. Reopen, validate and approve again.');
        Setup.Get();
        Setup.TestField("Contribution Jnl. Template");
        Setup.TestField("Contribution Jnl. Batch");
        Template.Get(Setup."Contribution Jnl. Template");
        Template.TestField(Type, Template.Type::General);
        Template.TestField("Source Code");
        JnlBatch.Get(Template.Name, Setup."Contribution Jnl. Batch");
        Batch.CalcFields("Total Due");
        if Batch."Total Due" <= 0 then
            Error('The contribution amount must be positive.');
        Journal.Init();
        Journal."Journal Template Name" := Template.Name;
        Journal."Journal Batch Name" := JnlBatch.Name;
        Journal."Line No." := 10000;
        Journal.Validate("Posting Date", Batch."Posting Date");
        Journal.Validate("Document Type", Journal."Document Type"::Invoice);
        Journal.Validate("Document No.", Batch."No.");
        Journal.Validate("Account Type", Journal."Account Type"::Customer);
        Journal.Validate("Account No.", CustomerNo);
        Journal.Validate("Currency Code", Batch."Currency Code");
        Journal.Validate(Amount, Batch."Total Due");
        Journal.Validate("Bal. Account Type", Journal."Bal. Account Type"::"G/L Account");
        Journal.Validate("Bal. Account No.", BalanceAccount);
        Journal.Description := CopyStr('Pension ' + Batch."Scheme Code" + ' ' + Format(Batch."Period Start", 0, '<Year4>-<Month,2>'), 1, 100);
        Journal."Source Code" := Template."Source Code";
        Journal."System-Created Entry" := true;
        LastEntryNo := Posting.RunWithCheck(Journal);
        Posting.GetGLReg(Register);
        GLEntry.Get(LastEntryNo);
        Batch."G/L Register No." := Register."No.";
        Batch."G/L Transaction No." := GLEntry."Transaction No.";
        Receivable.SetRange("Transaction No.", GLEntry."Transaction No.");
        Receivable.SetRange("Customer No.", CustomerNo);
        Receivable.SetRange("Document No.", Batch."No.");
        Receivable.FindFirst();
        Batch."Receivable Entry No." := Receivable."Entry No.";
        Receivable.CalcFields("Original Amt. (LCY)");
        Batch."Total Due (LCY)" := Receivable."Original Amt. (LCY)";
    end;

    procedure ResolveSetup(Batch: Record "PFE Contribution Batch"; var AssetAccount: Code[20]; var BalanceAccount: Code[20]; var CustomerNo: Code[20])
    var
        Setup: Record "PFE Setup";
        Employer: Record "PFE Employer";
        Scheme: Record "PFE Pension Scheme";
        Customer: Record Customer;
        PostingGroup: Record "Customer Posting Group";
    begin
        Setup.Get();
        Employer.Get(Batch."Employer Code");
        Scheme.Get(Batch."Scheme Code");
        AssetAccount := Employer."Contribution Asset Account";
        if AssetAccount = '' then
            AssetAccount := Setup."Contribution Asset Account";
        BalanceAccount := Scheme."Member Balance Account";
        if BalanceAccount = '' then
            BalanceAccount := Setup."Member Balance Account";
        if AssetAccount = BalanceAccount then
            Error('Receivable and member balance accounts must be different.');
        CheckAccount(AssetAccount, true);
        CheckAccount(BalanceAccount, false);
        Employer.TestField("BC Customer No.");
        Customer.Get(Employer."BC Customer No.");
        Customer.TestField(Blocked, Customer.Blocked::" ");
        CustomerNo := Customer."No.";
        PostingGroup.Get(Customer."Customer Posting Group");
        PostingGroup.TestField("Receivables Account", AssetAccount);
    end;

    procedure CheckAccount(AccountNo: Code[20]; Asset: Boolean)
    var
        Account: Record "G/L Account";
    begin
        if AccountNo = '' then
            Error('Set up contribution accounts in PensionFlow Setup and employer accounting before approval.');
        Account.Get(AccountNo);
        Account.TestField("Account Type", Account."Account Type"::Posting);
        Account.TestField("Income/Balance", Account."Income/Balance"::"Balance Sheet");
        Account.TestField(Blocked, false);
        if Asset then
            Account.TestField("Account Category", Account."Account Category"::Assets)
        else begin
            Account.TestField("Account Category", Account."Account Category"::Liabilities);
            Account.TestField("Direct Posting", true);
        end;
    end;

    local procedure CreateAccount(AccountNo: Code[20]; AccountName: Text[100]; Asset: Boolean)
    var
        Account: Record "G/L Account";
    begin
        Account.LockTable();
        if Account.Get(AccountNo) then begin
            Account.TestField(Name, AccountName);
            CheckAccount(AccountNo, Asset);
            exit;
        end;
        Account.Init();
        Account.Validate("No.", AccountNo);
        Account.Validate(Name, AccountName);
        Account.Validate("Account Type", Account."Account Type"::Posting);
        Account.Validate("Income/Balance", Account."Income/Balance"::"Balance Sheet");
        if Asset then
            Account.Validate("Account Category", Account."Account Category"::Assets)
        else
            Account.Validate("Account Category", Account."Account Category"::Liabilities);
        Account.Validate("Direct Posting", not Asset);
        Account.Insert(true);
    end;
}
