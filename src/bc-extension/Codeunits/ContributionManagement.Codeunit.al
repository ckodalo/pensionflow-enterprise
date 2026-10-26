codeunit 50104 "PFE Contribution Management"
{
    Permissions = tabledata "PFE Contribution Entry" = I,
                  tabledata "PFE Contribution Payment" = ID;

    procedure ValidateBatch(BatchNo: Code[20]): Boolean
    var
        Batch: Record "PFE Contribution Batch";
        Line: Record "PFE Contribution Line";
        Seen: Record "PFE Contribution Line" temporary;
        Valid: Boolean;
    begin
        Batch.LockTable();
        Batch.Get(BatchNo);
        if Batch.Status in [Batch.Status::Approved, Batch.Status::Posted] then
            Error('Reopen an approved batch before validating it. Posted batches cannot be changed.');
        CheckHeader(Batch);
        Line.SetRange("Batch No.", BatchNo);
        if Line.IsEmpty() then
            Error('Add contribution lines before validating.');
        Valid := true;
        if Line.FindSet(true) then
            repeat
                Line.ClearResults();
                ClearLastError();
                if not CalculateLine(Batch, Line) then begin
                    Line.ClearResults();
                    Line."Validation Error" := CopyStr(GetLastErrorText(), 1, 250);
                    Valid := false;
                end else begin
                    Seen.SetRange("Member No.", Line."Member No.");
                    if not Seen.IsEmpty() then begin
                        Line."Validation Error" := 'Member is repeated in this batch.';
                        Valid := false;
                    end;
                    Seen.Reset();
                    Seen := Line;
                    Seen.Insert();
                end;
                // Calculated results are written only by this workflow, not the editing trigger.
                Line.Modify(false);
            until Line.Next() = 0;
        if Valid then
            Batch.Status := Batch.Status::Validated
        else
            Batch.Status := Batch.Status::Open;
        Batch.Modify(true);
        exit(Valid);
    end;

    procedure Approve(BatchNo: Code[20])
    var
        Batch: Record "PFE Contribution Batch";
        Line: Record "PFE Contribution Line";
        Accounting: Codeunit "PFE Contribution Accounting";
    begin
        Batch.LockTable();
        Batch.Get(BatchNo);
        Batch.TestField(Status, Batch.Status::Validated);
        if not ValidateBatch(BatchNo) then
            Error('Correct validation errors before approving.');
        Batch.Get(BatchNo);
        Batch.CalcFields("Total Due");
        if Batch."Total Due" <= 0 then
            Error('A contribution batch must have a positive total due.');
        Line.SetRange("Batch No.", BatchNo);
        Line.SetRange("Has Variance", true);
        if Line.FindSet() then
            repeat
                if DelChr(Line."Variance Reason", '=', ' ') = '' then
                    Error('Line %1 has a payroll difference. Reopen the batch and enter a variance reason.', Line."Line No.");
            until Line.Next() = 0;
        Accounting.SnapshotSetup(Batch);
        Batch.Status := Batch.Status::Approved;
        Batch."Approved By" := CopyStr(UserId(), 1, 50);
        Batch."Approved At" := CurrentDateTime();
        Batch.Modify(true);
    end;

    procedure Reopen(BatchNo: Code[20])
    var
        Batch: Record "PFE Contribution Batch";
        Line: Record "PFE Contribution Line";
    begin
        Batch.LockTable();
        Batch.Get(BatchNo);
        if Batch.Status = Batch.Status::Posted then
            Error('Posted batches cannot be reopened.');
        Batch.Status := Batch.Status::Open;
        Batch."Approved By" := '';
        Batch."Approved At" := 0DT;
        Batch."Asset Account" := '';
        Batch."Member Balance Account" := '';
        Batch."Customer No." := '';
        Batch.Modify(true);
        Line.SetRange("Batch No.", BatchNo);
        if Line.FindSet(true) then
            repeat
                Line.ClearResults();
                Line.Modify(false);
            until Line.Next() = 0;
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Post(BatchNo: Code[20])
    var
        Batch: Record "PFE Contribution Batch";
        Line: Record "PFE Contribution Line";
        Calculated: Record "PFE Contribution Line";
        Entry: Record "PFE Contribution Entry";
        PostedAt: DateTime;
        Accounting: Codeunit "PFE Contribution Accounting";
        RunningAmount: Decimal;
        AllocatedLCY: Decimal;
    begin
        Batch.LockTable();
        Batch.Get(BatchNo);
        Batch.TestField(Status, Batch.Status::Approved);
        CheckHeader(Batch);
        Entry.LockTable();
        Line.SetRange("Batch No.", BatchNo);
        if not Line.FindSet() then
            Error('The batch contains no contribution lines.');
        PostedAt := CurrentDateTime();
        repeat
            Calculated := Line;
            ClearLastError();
            if not CalculateLine(Batch, Calculated) then
                Error('Line %1: %2', Line."Line No.", GetLastErrorText());
            if (Calculated."Member No." <> Line."Member No.") or
               (Calculated."Enrollment No." <> Line."Enrollment No.") or
               (Calculated."Employee Rate" <> Line."Employee Rate") or
               (Calculated."Employer Rate" <> Line."Employer Rate") or
               (Calculated."Expected Employee" <> Line."Expected Employee") or
               (Calculated."Expected Employer" <> Line."Expected Employer") or
               (Calculated."Total Due" <> Line."Total Due") then
                Error('Line %1 changed since approval. Reopen, validate and approve again.', Line."Line No.");
        until Line.Next() = 0;
        // Standard BC posting and the member subledger share one transaction.
        Accounting.PostToGL(Batch);
        Line.FindSet();
        repeat
            Entry.Init();
            Entry."Batch No." := BatchNo;
            Entry."Line No." := Line."Line No.";
            Entry."Member No." := Line."Member No.";
            Entry."Employer Code" := Batch."Employer Code";
            Entry."Scheme Code" := Batch."Scheme Code";
            Entry."Period Start" := Batch."Period Start";
            Entry."Currency Code" := Batch."Currency Code";
            Entry."Posting Date" := Batch."Posting Date";
            Entry."G/L Transaction No." := Batch."G/L Transaction No.";
            Entry."Enrollment No." := Line."Enrollment No.";
            Entry."Pensionable Salary" := Line."Pensionable Salary";
            Entry."Employee Rate" := Line."Employee Rate";
            Entry."Employer Rate" := Line."Employer Rate";
            Entry."Employee Contribution" := Line."Employee Contribution";
            Entry."Employer Contribution" := Line."Employer Contribution";
            Entry."Voluntary Contribution" := Line."Voluntary Contribution";
            Entry."Expected Employee" := Line."Expected Employee";
            Entry."Expected Employer" := Line."Expected Employer";
            Entry."Variance Reason" := Line."Variance Reason";
            Entry."Total Due" := Line."Total Due";
            RunningAmount += Line."Total Due";
            Entry."Total Due (LCY)" := Round(Batch."Total Due (LCY)" * RunningAmount / Batch."Total Due", AmountPrecision()) - AllocatedLCY;
            AllocatedLCY += Entry."Total Due (LCY)";
            Entry."Posted By" := CopyStr(UserId(), 1, 50);
            Entry."Posted At" := PostedAt;
            Entry.Insert(true);
        until Line.Next() = 0;
        Batch.Status := Batch.Status::Posted;
        Batch."Posted By" := CopyStr(UserId(), 1, 50);
        Batch."Posted At" := PostedAt;
        Batch.Modify(true);
    end;

    procedure CheckHeader(Batch: Record "PFE Contribution Batch")
    var
        Eligibility: Codeunit "PFE Enrollment Management";
        CurrencyManagement: Codeunit "PFE Contribution Currency";
        Precision: Decimal;
    begin
        Batch.TestField("Employer Code");
        Batch.TestField("Scheme Code");
        Batch.TestField("Period Start");
        Precision := CurrencyManagement.Precision(Batch."Currency Code");
        if Date2DMY(Batch."Period Start", 1) <> 1 then
            Error('Contribution Month must be the first day of the month.');
        Eligibility.CheckEligibility(Batch."Scheme Code", Batch."Employer Code", MonthEnd(Batch."Period Start"), MonthEnd(Batch."Period Start"), true);
    end;

    [TryFunction]
    procedure CalculateLine(Batch: Record "PFE Contribution Batch"; var Line: Record "PFE Contribution Line")
    var
        Member: Record "PFE Pension Member";
        ByReference: Record "PFE Pension Member";
        Enrollment: Record "PFE Scheme Enrollment";
        Entry: Record "PFE Contribution Entry";
        Precision: Decimal;
        CurrencyManagement: Codeunit "PFE Contribution Currency";
    begin
        if (Line."Member No." = '') and (Line."Import Reference" = '') then
            Error('Enter Member No. or Import Reference.');
        if Line."Import Reference" <> '' then begin
            ByReference.SetRange("Import Reference", Line."Import Reference");
            if ByReference.Count() <> 1 then
                Error('Import Reference must identify exactly one existing member.');
            ByReference.FindFirst();
            if (Line."Member No." <> '') and (Line."Member No." <> ByReference."Member No.") then
                Error('Member No. and Import Reference identify different members.');
            Line."Member No." := ByReference."Member No.";
        end;
        Member.Get(Line."Member No.");
        Member.TestField(Status, Member.Status::Active);
        if (Line."Pensionable Salary" < 0) or (Line."Employee Contribution" < 0) or
           (Line."Employer Contribution" < 0) or (Line."Voluntary Contribution" < 0) then
            Error('Salary and contribution amounts cannot be negative.');
        Precision := CurrencyManagement.Precision(Batch."Currency Code");
        if (Round(Line."Pensionable Salary", Precision) <> Line."Pensionable Salary") or
           (Round(Line."Voluntary Contribution", Precision) <> Line."Voluntary Contribution") then
            Error('Salary and voluntary amounts must use the selected currency amount rounding precision.');
        Enrollment.SetRange("Member No.", Line."Member No.");
        Enrollment.SetRange("Employer Code", Batch."Employer Code");
        Enrollment.SetRange("Scheme Code", Batch."Scheme Code");
        Enrollment.SetFilter(Status, '%1|%2', Enrollment.Status::Active, Enrollment.Status::Closed);
        Enrollment.SetFilter("Effective From", '<=%1', MonthEnd(Batch."Period Start"));
        Enrollment.SetFilter("Effective To", '%1|>=%2', 0D, MonthEnd(Batch."Period Start"));
        if Enrollment.Count() <> 1 then
            Error('Member must have exactly one eligible enrollment covering the last day of the contribution month.');
        Enrollment.FindFirst();
        if (Enrollment."Employee Rate" < 0) or (Enrollment."Employee Rate" > 100) or
           (Enrollment."Employer Rate" < 0) or (Enrollment."Employer Rate" > 100) then
            Error('Enrollment contribution rates must be between 0 and 100.');
        Line."Enrollment No." := Enrollment."Enrollment No.";
        Line."Employee Rate" := Enrollment."Employee Rate";
        Line."Employer Rate" := Enrollment."Employer Rate";
        Line."Expected Employee" := Round(Line."Pensionable Salary" * Line."Employee Rate" / 100, Precision);
        Line."Expected Employer" := Round(Line."Pensionable Salary" * Line."Employer Rate" / 100, Precision);
        if Line."Payroll Amounts Supplied" then begin
            if (Round(Line."Employee Contribution", Precision) <> Line."Employee Contribution") or
               (Round(Line."Employer Contribution", Precision) <> Line."Employer Contribution") then
                Error('Payroll amounts must use the selected currency amount rounding precision.');
        end else begin
            Line."Employee Contribution" := Line."Expected Employee";
            Line."Employer Contribution" := Line."Expected Employer";
        end;
        Line."Employee Variance" := Line."Employee Contribution" - Line."Expected Employee";
        Line."Employer Variance" := Line."Employer Contribution" - Line."Expected Employer";
        Line.Variance := Line."Employee Variance" + Line."Employer Variance";
        Line."Has Variance" := (Line."Employee Variance" <> 0) or (Line."Employer Variance" <> 0);
        Line."Total Due" := Line."Employee Contribution" + Line."Employer Contribution" + Line."Voluntary Contribution";
        Entry.SetRange("Scheme Code", Batch."Scheme Code");
        Entry.SetRange("Member No.", Line."Member No.");
        Entry.SetRange("Period Start", Batch."Period Start");
        if not Entry.IsEmpty() then
            Error('This member already has a posted contribution for this scheme and month.');
    end;

    procedure MatchPayment(BatchNo: Code[20]; PaymentEntryNo: Integer; Amount: Decimal)
    var
        Batch: Record "PFE Contribution Batch";
        Employer: Record "PFE Employer";
        Ledger: Record "Cust. Ledger Entry";
        Match: Record "PFE Contribution Payment";
        Existing: Record "PFE Contribution Payment";
        Allocated: Decimal;
        CurrencyManagement: Codeunit "PFE Contribution Currency";
    begin
        Batch.LockTable();
        Batch.Get(BatchNo);
        Batch.TestField(Status, Batch.Status::Posted);
        Employer.Get(Batch."Employer Code");
        Employer.TestField("BC Customer No.");
        Ledger.LockTable();
        Ledger.Get(PaymentEntryNo);
        Ledger.TestField("Customer No.", Employer."BC Customer No.");
        Ledger.TestField("Document Type", Ledger."Document Type"::Payment);
        Ledger.TestField("Currency Code", Batch."Currency Code");
        Ledger.TestField(Reversed, false);
        Ledger.CalcFields("Original Amount");
        if (Amount <= 0) or (Round(Amount, CurrencyManagement.Precision(Batch."Currency Code")) <> Amount) then
            Error('Enter a positive payment amount using the selected currency amount rounding precision.');
        Existing.LockTable();
        Existing.SetRange("Payment Entry No.", PaymentEntryNo);
        if Existing.FindSet() then
            repeat
                Allocated += Existing.Amount;
            until Existing.Next() = 0;
        if Allocated + Amount > -Ledger."Original Amount" then
            Error('The amount exceeds the unallocated value of this customer payment.');
        Batch.CalcFields("Total Due", "Matched Payments");
        if ValidMatchedAmount(BatchNo) + Amount > Batch."Total Due" then
            Error('The amount exceeds the outstanding contribution balance.');
        Match.Init();
        Match."Batch No." := BatchNo;
        Match."Payment Entry No." := PaymentEntryNo;
        Match.Amount := Amount;
        Match."Currency Code" := Batch."Currency Code";
        Match."Document No." := Ledger."Document No.";
        Match."Payment Date" := Ledger."Posting Date";
        Match."Matched By" := CopyStr(UserId(), 1, 50);
        Match."Matched At" := CurrentDateTime();
        Match.Insert(true);
    end;

    procedure RemovePayment(BatchNo: Code[20]; PaymentEntryNo: Integer)
    var
        Batch: Record "PFE Contribution Batch";
        Match: Record "PFE Contribution Payment";
    begin
        Batch.LockTable();
        Batch.Get(BatchNo);
        Match.Get(BatchNo, PaymentEntryNo);
        Match.Delete(true);
    end;

    procedure ValidMatchedAmount(BatchNo: Code[20]): Decimal
    var
        Match: Record "PFE Contribution Payment";
        Ledger: Record "Cust. Ledger Entry";
        Amount: Decimal;
    begin
        Match.SetRange("Batch No.", BatchNo);
        if Match.FindSet() then
            repeat
                if Ledger.Get(Match."Payment Entry No.") then
                    if not Ledger.Reversed then
                        Amount += Match.Amount;
            until Match.Next() = 0;
        exit(Amount);
    end;

    procedure AmountPrecision(): Decimal
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        GLSetup.TestField("Amount Rounding Precision");
        exit(GLSetup."Amount Rounding Precision");
    end;

    procedure MonthEnd(PeriodStart: Date): Date
    begin
        exit(CalcDate('<CM>', PeriodStart));
    end;
}
