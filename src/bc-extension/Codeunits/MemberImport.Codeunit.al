codeunit 50102 "PFE Member Import"
{
    procedure DownloadTemplate()
    var
        Excel: Record "Excel Buffer" temporary;
    begin
        WriteHeaders(Excel);
        ExportExcel(Excel, 'PensionFlow-Member-Template.xlsx');
    end;

    procedure UploadMembers()
    var
        Excel: Record "Excel Buffer" temporary;
        Errors: Record "Excel Buffer" temporary;
        Input: InStream;
        FileName: Text;
        OpenError: Text;
        Imported: Integer;
    begin
        if not UploadIntoStream('Import Pension Members', '', 'Excel workbook (*.xlsx)|*.xlsx', FileName, Input) then
            exit;
        OpenError := Excel.OpenBookStream(Input, 'Members');
        if OpenError <> '' then
            Error(OpenError);
        Excel.ReadSheet();
        Excel.CloseBook();
        Imported := ProcessWorksheet(Excel, Errors);
        if not Errors.IsEmpty() then begin
            ExportExcel(Errors, 'PensionFlow-Member-Import-Errors.xlsx');
            Message('No members were imported. Correct the rows in the downloaded error report and upload the original workbook again.');
        end else
            Message('%1 members were imported.', Imported);
    end;

    procedure ProcessWorksheet(var Excel: Record "Excel Buffer" temporary; var Errors: Record "Excel Buffer" temporary): Integer
    var
        Staging: Record "PFE Member Import Row";
        Seen: Record "PFE Member Import Row";
        Member: Record "PFE Pension Member";
        RowNo: Integer;
        LastRow: Integer;
        Imported: Integer;
        RowError: Text;
    begin
        Errors.Reset();
        Errors.DeleteAll();
        Errors.SetCurrent(0, 0);
        Excel.Reset();
        CheckHeaders(Excel);
        Excel.SetCurrentKey("Row No.", "Column No.");
        if not Excel.FindLast() then
            Error('The workbook contains no member rows.');
        LastRow := Excel."Row No.";
        if LastRow > 10001 then
            Error('Import a maximum of 10000 rows at a time.');
        WriteHeaders(Errors);
        Errors.AddColumn('Excel Row', false, '', true, false, false, '@', Errors."Cell Type"::Text);
        Errors.AddColumn('Error', false, '', true, false, false, '@', Errors."Cell Type"::Text);
        for RowNo := 2 to LastRow do
            if not IsBlankRow(Excel, RowNo) then begin
                Clear(Staging);
                Staging."Row No." := RowNo;
                ClearLastError();
                if not ParseRow(Excel, RowNo, Staging) then
                    RowError := GetLastErrorText()
                else
                    RowError := DuplicateError(Staging, Seen);
                if RowError <> '' then
                    AddErrorRow(Excel, Errors, RowNo, RowError)
                else begin
                    Staging.Insert();
                    Seen := Staging;
                    Seen.Insert();
                end;
            end;

        // A header-only workbook or a template has nothing to import.
        Errors.SetFilter("Row No.", '>1');
        if not Errors.IsEmpty() then begin
            Errors.Reset();
            exit(0);
        end;
        Errors.Reset();
        Errors.DeleteAll();
        if Staging.IsEmpty() then
            Error('The workbook contains no member rows.');

        // All database writes occur after validation, in one transaction.
        // Any unexpected insert/number-series error rolls back the entire import.
        Staging.Reset();
        if Staging.FindSet() then
            repeat
                Clear(Member);
                Member.Init();
                PopulateMember(Staging, Member);
                Member.Insert(true);
                Imported += 1;
            until Staging.Next() = 0;
        exit(Imported);
    end;

    [TryFunction]
    local procedure ParseRow(var Excel: Record "Excel Buffer" temporary; RowNo: Integer; var Row: Record "PFE Member Import Row")
    var
        Member: Record "PFE Pension Member" temporary;
        Existing: Record "PFE Pension Member";
        Setup: Record "PFE Setup";
        NoSeries: Codeunit "No. Series";
        StatusText: Text;
        ColumnNo: Integer;
    begin
        for ColumnNo := 1 to 10 do
            CheckCell(Excel, RowNo, ColumnNo);
        Row."Import Reference" := CheckedText(GetCell(Excel, RowNo, 1), 50, 'Import Reference');
        Row.TestField("Import Reference");
        Row."Member No." := CheckedText(GetCell(Excel, RowNo, 2), 20, 'Member No.');
        Row."Member Name" := CheckedText(GetCell(Excel, RowNo, 3), 100, 'Member Name');
        Row.TestField("Member Name");
        Row."Date of Birth" := ReadDate(GetCell(Excel, RowNo, 4), 'Date of Birth');
        Row."Email Address" := CheckedText(GetCell(Excel, RowNo, 5), 100, 'Email Address');
        Row."Phone No." := CheckedText(GetCell(Excel, RowNo, 6), 30, 'Phone No.');
        Row.Address := CheckedText(GetCell(Excel, RowNo, 7), 100, 'Address');
        Row.City := CheckedText(GetCell(Excel, RowNo, 8), 50, 'City');
        Row."Date Registered" := ReadDate(GetCell(Excel, RowNo, 9), 'Date Registered');
        if Row."Date Registered" = 0D then
            Row."Date Registered" := WorkDate();
        StatusText := LowerCase(GetCell(Excel, RowNo, 10));
        case StatusText of
            '', 'active':
                Row.Status := Row.Status::Active;
            'inactive':
                Row.Status := Row.Status::Inactive;
            else
                Error('Status must be Active or Inactive.');
        end;

        // Validate using the member table without inserting or consuming numbers.
        Member.Init();
        PopulateMember(Row, Member);
        Existing.SetRange("Import Reference", Row."Import Reference");
        if not Existing.IsEmpty() then
            Error('Import Reference %1 already exists. Existing members are never overwritten.', Row."Import Reference");
        if Row."Member No." <> '' then
            if Existing.Get(Row."Member No.") then
                Error('Member No. %1 already exists.', Row."Member No.");
        Setup.Get();
        Setup.TestField("Member Nos.");
        if Row."Member No." = '' then begin
            NoSeries.TestAutomatic(Setup."Member Nos.");
            if NoSeries.PeekNextNo(Setup."Member Nos.", WorkDate()) = '' then
                Error('The member number series has no available number.');
        end;
    end;

    local procedure PopulateMember(Row: Record "PFE Member Import Row"; var Member: Record "PFE Pension Member")
    begin
        Member."Import Reference" := Row."Import Reference";
        if Row."Member No." <> '' then
            Member.Validate("Member No.", Row."Member No.");
        Member.Validate("Member Name", Row."Member Name");
        Member.Validate("Date of Birth", Row."Date of Birth");
        Member.Validate("Email Address", Row."Email Address");
        Member.Validate("Phone No.", Row."Phone No.");
        Member.Validate(Address, Row.Address);
        Member.Validate(City, Row.City);
        Member.Validate("Date Registered", Row."Date Registered");
        Member.Validate(Status, Row.Status);
    end;

    local procedure DuplicateError(Row: Record "PFE Member Import Row"; var Seen: Record "PFE Member Import Row"): Text
    begin
        Seen.Reset();
        Seen.SetRange("Import Reference", Row."Import Reference");
        if not Seen.IsEmpty() then
            exit('Import Reference is repeated in the workbook.');
        Seen.Reset();
        if Row."Member No." <> '' then begin
            Seen.SetRange("Member No.", Row."Member No.");
            if not Seen.IsEmpty() then
                exit('Member No. is repeated in the workbook.');
        end;
        Seen.Reset();
        exit('');
    end;

    local procedure CheckHeaders(var Excel: Record "Excel Buffer" temporary)
    var
        ColumnNo: Integer;
    begin
        for ColumnNo := 1 to 10 do begin
            CheckCell(Excel, 1, ColumnNo);
            if GetCell(Excel, 1, ColumnNo) <> GetHeader(ColumnNo) then
                Error('Column %1 must have the header "%2". Download a new member import template.', ColumnNo, GetHeader(ColumnNo));
        end;
        Excel.Reset();
        Excel.SetFilter("Column No.", '>10');
        if not Excel.IsEmpty() then
            Error('The Members worksheet must contain exactly the 10 template columns.');
        Excel.Reset();
    end;

    procedure GetHeader(ColumnNo: Integer): Text
    begin
        case ColumnNo of
            1: exit('Import Reference');
            2: exit('Member No.');
            3: exit('Member Name');
            4: exit('Date of Birth');
            5: exit('Email Address');
            6: exit('Phone No.');
            7: exit('Address');
            8: exit('City');
            9: exit('Date Registered');
            10: exit('Status');
        end;
    end;

    local procedure WriteHeaders(var Excel: Record "Excel Buffer" temporary)
    var
        ColumnNo: Integer;
    begin
        Excel.NewRow();
        for ColumnNo := 1 to 10 do
            Excel.AddColumn(GetHeader(ColumnNo), false, 'Use a unique Import Reference. Leave Member No. blank for automatic numbering. Enter dates as text: YYYY-MM-DD. Status: Active or Inactive; blank means Active.', true, false, false, '@', Excel."Cell Type"::Text);
    end;

    local procedure CheckCell(var Excel: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer)
    begin
        if not Excel.Get(RowNo, ColumnNo) then
            exit;
        if (Excel.Formula <> '') or (Excel.Formula2 <> '') or
           (Excel.Formula3 <> '') or (Excel.Formula4 <> '') then
            Error('Formulas are not allowed in column %1. Paste values only.', ColumnNo);
        Excel.CalcFields("Cell Value as Blob");
        if Excel."Cell Value as Blob".HasValue() then
            Error('The value in column %1 is too long.', ColumnNo);
    end;

    local procedure GetCell(var Excel: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer): Text
    begin
        if Excel.Get(RowNo, ColumnNo) then
            exit(Excel."Cell Value as Text".Trim());
        exit('');
    end;

    local procedure IsBlankRow(var Excel: Record "Excel Buffer" temporary; RowNo: Integer): Boolean
    var
        ColumnNo: Integer;
    begin
        for ColumnNo := 1 to 10 do
            if Excel.Get(RowNo, ColumnNo) then begin
                Excel.CalcFields("Cell Value as Blob");
                if (Excel."Cell Value as Text".Trim() <> '') or
                   (Excel.Formula <> '') or (Excel.Formula2 <> '') or
                   (Excel.Formula3 <> '') or (Excel.Formula4 <> '') or
                   Excel."Cell Value as Blob".HasValue() then
                    exit(false);
            end;
        exit(true);
    end;

    local procedure CheckedText(Value: Text; MaxLength: Integer; FieldName: Text): Text
    begin
        if StrLen(Value) > MaxLength then
            Error('%1 exceeds the maximum length of %2 characters.', FieldName, MaxLength);
        exit(Value);
    end;

    local procedure ReadDate(Value: Text; FieldName: Text): Date
    var
        YearNo: Integer;
        MonthNo: Integer;
        DayNo: Integer;
    begin
        if Value = '' then
            exit(0D);
        if StrLen(Value) <> 10 then
            Error('%1 must be text in YYYY-MM-DD format.', FieldName);
        if (CopyStr(Value, 5, 1) <> '-') or (CopyStr(Value, 8, 1) <> '-') then
            Error('%1 must be text in YYYY-MM-DD format.', FieldName);
        if not Evaluate(YearNo, CopyStr(Value, 1, 4)) or
           not Evaluate(MonthNo, CopyStr(Value, 6, 2)) or
           not Evaluate(DayNo, CopyStr(Value, 9, 2)) then
            Error('%1 must be text in YYYY-MM-DD format.', FieldName);
        if (YearNo < 1753) or (MonthNo < 1) or (MonthNo > 12) or (DayNo < 1) or (DayNo > 31) then
            Error('%1 contains an invalid date.', FieldName);
        exit(DMY2Date(DayNo, MonthNo, YearNo));
    end;

    local procedure AddErrorRow(var Source: Record "Excel Buffer" temporary; var Errors: Record "Excel Buffer" temporary; RowNo: Integer; ErrorText: Text)
    var
        ColumnNo: Integer;
    begin
        Errors.NewRow();
        for ColumnNo := 1 to 10 do
            Errors.AddColumn(GetCell(Source, RowNo, ColumnNo), false, '', false, false, false, '@', Errors."Cell Type"::Text);
        Errors.AddColumn(Format(RowNo), false, '', false, false, false, '@', Errors."Cell Type"::Text);
        Errors.AddColumn(CopyStr(ErrorText, 1, 250), false, '', false, false, false, '@', Errors."Cell Type"::Text);
    end;

    local procedure ExportExcel(var Excel: Record "Excel Buffer" temporary; FileName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        Output: OutStream;
        Input: InStream;
    begin
        Excel.Reset();
        Excel.CreateNewBook('Members');
        Excel.WriteSheet('PensionFlow Members', CompanyName, UserId);
        Excel.CloseBook();
        TempBlob.CreateOutStream(Output);
        Excel.SaveToStream(Output, true);
        TempBlob.CreateInStream(Input);
        DownloadFromStream(Input, '', '', '', FileName);
    end;
}
