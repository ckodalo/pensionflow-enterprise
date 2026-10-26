codeunit 50105 "PFE Contribution Import"
{
    procedure DownloadTemplate(BatchNo: Code[20])
    var
        Batch: Record "PFE Contribution Batch";
        Enrollment: Record "PFE Scheme Enrollment";
        Member: Record "PFE Pension Member";
        Excel: Record "Excel Buffer" temporary;
        Management: Codeunit "PFE Contribution Management";
        ColumnNo: Integer;
    begin
        Batch.Get(BatchNo);
        Management.CheckHeader(Batch);
        Excel.NewRow();
        for ColumnNo := 1 to 6 do
            Excel.AddColumn(GetHeader(ColumnNo), false,
                'Use Member No. or Import Reference. Salary is required. Leave both payroll contribution columns blank for calculation, or fill both (zero is allowed). Voluntary is optional. Use numeric values without currency symbols; no formulas.',
                true, false, false, '@', Excel."Cell Type"::Text);
        Enrollment.SetRange("Employer Code", Batch."Employer Code");
        Enrollment.SetRange("Scheme Code", Batch."Scheme Code");
        Enrollment.SetFilter(Status, '%1|%2', Enrollment.Status::Active, Enrollment.Status::Closed);
        Enrollment.SetFilter("Effective From", '<=%1', Management.MonthEnd(Batch."Period Start"));
        Enrollment.SetFilter("Effective To", '%1|>=%2', 0D, Management.MonthEnd(Batch."Period Start"));
        if Enrollment.FindSet() then
            repeat
                Member.Get(Enrollment."Member No.");
                if Member.Status = Member.Status::Active then begin
                    Excel.NewRow();
                    Excel.AddColumn(Member."Member No.", false, '', false, false, false, '@', Excel."Cell Type"::Text);
                    Excel.AddColumn(Member."Import Reference", false, '', false, false, false, '@', Excel."Cell Type"::Text);
                    for ColumnNo := 3 to 6 do
                        Excel.AddColumn('', false, '', false, false, false, '0.00', Excel."Cell Type"::Number);
                end;
            until Enrollment.Next() = 0;
        ExportExcel(Excel, 'PensionFlow-Contributions-' + BatchNo + '.xlsx');
    end;

    procedure Upload(BatchNo: Code[20])
    var
        Batch: Record "PFE Contribution Batch";
        Existing: Record "PFE Contribution Line";
        Excel: Record "Excel Buffer" temporary;
        Input: InStream;
        FileName: Text;
        OpenError: Text;
        Valid: Boolean;
    begin
        Batch.Get(BatchNo);
        Batch.TestField(Status, Batch.Status::Open);
        Existing.SetRange("Batch No.", BatchNo);
        if not Existing.IsEmpty() then
            if not Confirm('Replace all existing lines in this open batch with the uploaded spreadsheet?', false) then
                exit;
        if not UploadIntoStream('Upload Monthly Contributions', '', 'Excel workbooks (*.xlsx)|*.xlsx', FileName, Input) then
            exit;
        OpenError := Excel.OpenBookStream(Input, 'Contributions');
        if OpenError <> '' then
            Error(OpenError);
        Excel.ReadSheet();
        Excel.CloseBook();
        Valid := ProcessWorksheet(BatchNo, Excel);
        if Valid then
            Message('Contributions uploaded and validated. Review totals and payroll differences, then approve and post the batch.')
        else
            Message('Contributions uploaded with validation errors. Review Validation Error on the lines, correct the data and validate again. Nothing has been posted.');
    end;

    procedure ProcessWorksheet(BatchNo: Code[20]; var Excel: Record "Excel Buffer" temporary): Boolean
    var
        Batch: Record "PFE Contribution Batch";
        Staged: Record "PFE Contribution Line" temporary;
        Line: Record "PFE Contribution Line";
        Management: Codeunit "PFE Contribution Management";
        RowNo: Integer;
        LastRow: Integer;
        ColumnNo: Integer;
        EmployeeText: Text;
        EmployerText: Text;
    begin
        Batch.LockTable();
        Batch.Get(BatchNo);
        Batch.TestField(Status, Batch.Status::Open);
        Management.CheckHeader(Batch);
        Excel.Reset();
        for ColumnNo := 1 to 6 do begin
            CheckCell(Excel, 1, ColumnNo);
            if GetCell(Excel, 1, ColumnNo) <> GetHeader(ColumnNo) then
                Error('Column %1 must have the header "%2".', ColumnNo, GetHeader(ColumnNo));
        end;
        Excel.SetFilter("Column No.", '>6');
        if not Excel.IsEmpty() then
            Error('The Contributions worksheet must contain exactly six columns.');
        Excel.Reset();
        Excel.SetCurrentKey("Row No.", "Column No.");
        Excel.FindLast();
        LastRow := Excel."Row No.";
        if LastRow > 10001 then
            Error('Upload a maximum of 10000 contribution rows.');
        for RowNo := 2 to LastRow do
            if not BlankRow(Excel, RowNo) then begin
                for ColumnNo := 1 to 6 do
                    CheckCell(Excel, RowNo, ColumnNo);
                Staged.Init();
                Staged."Batch No." := BatchNo;
                Staged."Line No." := RowNo;
                if StrLen(GetCell(Excel, RowNo, 1)) > 20 then
                    Error('Excel row %1: Member No. exceeds 20 characters.', RowNo);
                if StrLen(GetCell(Excel, RowNo, 2)) > 50 then
                    Error('Excel row %1: Import Reference exceeds 50 characters.', RowNo);
                Staged."Member No." := GetCell(Excel, RowNo, 1);
                Staged."Import Reference" := GetCell(Excel, RowNo, 2);
                Staged."Pensionable Salary" := ReadAmount(GetCell(Excel, RowNo, 3), RowNo, true);
                EmployeeText := GetCell(Excel, RowNo, 4);
                EmployerText := GetCell(Excel, RowNo, 5);
                if (EmployeeText = '') <> (EmployerText = '') then
                    Error('Excel row %1: fill both payroll contribution amounts or leave both blank.', RowNo);
                Staged."Payroll Amounts Supplied" := EmployeeText <> '';
                Staged."Employee Contribution" := ReadAmount(EmployeeText, RowNo, false);
                Staged."Employer Contribution" := ReadAmount(EmployerText, RowNo, false);
                Staged."Voluntary Contribution" := ReadAmount(GetCell(Excel, RowNo, 6), RowNo, false);
                Staged.Insert();
            end;
        if Staged.IsEmpty() then
            Error('The workbook contains no contribution rows.');
        // Parse every row before replacing any existing draft data. No commits here.
        Line.SetRange("Batch No.", BatchNo);
        Line.DeleteAll(true);
        if Staged.FindSet() then
            repeat
                Line := Staged;
                Line.Insert(true);
            until Staged.Next() = 0;
        exit(Management.ValidateBatch(BatchNo));
    end;

    procedure GetHeader(ColumnNo: Integer): Text
    begin
        case ColumnNo of
            1: exit('Member No.');
            2: exit('Import Reference');
            3: exit('Pensionable Salary');
            4: exit('Employee Contribution');
            5: exit('Employer Contribution');
            6: exit('Voluntary Contribution');
        end;
    end;

    local procedure CheckCell(var Excel: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer)
    begin
        if not Excel.Get(RowNo, ColumnNo) then
            exit;
        if (Excel.Formula <> '') or (Excel.Formula2 <> '') or (Excel.Formula3 <> '') or (Excel.Formula4 <> '') then
            Error('Excel row %1, column %2: formulas are not allowed; paste values only.', RowNo, ColumnNo);
        Excel.CalcFields("Cell Value as Blob");
        if Excel."Cell Value as Blob".HasValue() then
            Error('Excel row %1, column %2: value is too long.', RowNo, ColumnNo);
    end;

    local procedure GetCell(var Excel: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer): Text
    begin
        if Excel.Get(RowNo, ColumnNo) then
            exit(Excel."Cell Value as Text".Trim());
        exit('');
    end;

    local procedure BlankRow(var Excel: Record "Excel Buffer" temporary; RowNo: Integer): Boolean
    var
        ColumnNo: Integer;
    begin
        for ColumnNo := 1 to 6 do begin
            CheckCell(Excel, RowNo, ColumnNo);
            if GetCell(Excel, RowNo, ColumnNo) <> '' then
                exit(false);
        end;
        exit(true);
    end;

    local procedure ReadAmount(Value: Text; RowNo: Integer; Required: Boolean): Decimal
    var
        Amount: Decimal;
    begin
        if Value = '' then begin
            if Required then
                Error('Excel row %1: Pensionable Salary is required. Enter zero explicitly if applicable.', RowNo);
            exit(0);
        end;
        if not Evaluate(Amount, Value, 9) then
            Error('Excel row %1: use numeric amounts with a decimal point and no currency symbols or thousands separators.', RowNo);
        if Amount < 0 then
            Error('Excel row %1: amounts cannot be negative.', RowNo);
        exit(Amount);
    end;

    local procedure ExportExcel(var Excel: Record "Excel Buffer" temporary; FileName: Text)
    var
        Blob: Codeunit "Temp Blob";
        Output: OutStream;
        Input: InStream;
    begin
        Excel.Reset();
        Excel.CreateNewBook('Contributions');
        Excel.WriteSheet('Monthly Contributions', CompanyName, UserId());
        Excel.CloseBook();
        Blob.CreateOutStream(Output);
        Excel.SaveToStream(Output, true);
        Blob.CreateInStream(Input);
        DownloadFromStream(Input, '', '', '', FileName);
    end;
}
