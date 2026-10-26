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
    begin
        UploadFile(ImportMode::"Register Only", '', '', 0D, 0D);
    end;

    procedure UploadEnrolledMembers(Mode: Enum "PFE Member Import Mode")
    var
        Options: Page "PFE Import Enrollment Options";
        SelectedScheme: Code[20];
        SelectedEmployer: Code[20];
        SelectedFrom: Date;
        SelectedTo: Date;
    begin
        Options.SetMode(Mode);
        if Options.RunModal() <> Action::OK then
            exit;
        Options.GetSelection(SelectedScheme, SelectedEmployer, SelectedFrom, SelectedTo);
        UploadFile(Mode, SelectedScheme, SelectedEmployer, SelectedFrom, SelectedTo);
    end;

    local procedure UploadFile(Mode: Enum "PFE Member Import Mode"; SelectedScheme: Code[20]; SelectedEmployer: Code[20]; SelectedFrom: Date; SelectedTo: Date)
    var
        Excel: Record "Excel Buffer" temporary;
        Errors: Record "Excel Buffer" temporary;
        Input: InStream;
        FileName: Text;
        Imported: Integer;
    begin
        if not UploadIntoStream('Import Pension Members', '', 'Member files (*.xlsx;*.csv)|*.xlsx;*.csv', FileName, Input) then
            exit;
        ReadMemberFile(Input, FileName, Excel);
        if Mode = Mode::"Register Only" then
            Imported := ProcessWorksheet(Excel, Errors)
        else
            Imported := ProcessEnrollmentWorksheet(Excel, Errors, Mode, SelectedScheme, SelectedEmployer, SelectedFrom, SelectedTo);
        if not Errors.IsEmpty() then begin
            ExportExcel(Errors, 'PensionFlow-Member-Import-Errors.xlsx');
            Message('No members or enrollments were created. Correct the rows in the downloaded error report and upload the original file again.');
        end else
            Message('%1 rows processed. New members: %2. Existing members reused: %3. New enrollments: %4. Existing enrollments retained: %5.',
                Imported, NewMembers, ReusedMembers, NewEnrollments, RetainedEnrollments);
    end;

    procedure ProcessWorksheet(var Excel: Record "Excel Buffer" temporary; var Errors: Record "Excel Buffer" temporary): Integer
    begin
        SetContext(ImportMode::"Register Only", '', '', 0D, 0D);
        exit(ProcessRows(Excel, Errors));
    end;

    procedure ProcessEnrollmentWorksheet(var Excel: Record "Excel Buffer" temporary; var Errors: Record "Excel Buffer" temporary; Mode: Enum "PFE Member Import Mode"; SelectedScheme: Code[20]; SelectedEmployer: Code[20]; SelectedFrom: Date; SelectedTo: Date): Integer
    begin
        if Mode = Mode::"Register Only" then
            Error('Select Employer Members or Individual Members for an enrollment import.');
        CheckImportSelection(Mode, SelectedScheme, SelectedEmployer, SelectedFrom, SelectedTo);
        SetContext(Mode, SelectedScheme, SelectedEmployer, SelectedFrom, SelectedTo);
        exit(ProcessRows(Excel, Errors));
    end;

    local procedure SetContext(Mode: Enum "PFE Member Import Mode"; SelectedScheme: Code[20]; SelectedEmployer: Code[20]; SelectedFrom: Date; SelectedTo: Date)
    begin
        ImportMode := Mode;
        SchemeCode := SelectedScheme;
        EmployerCode := SelectedEmployer;
        EffectiveFrom := SelectedFrom;
        EffectiveTo := SelectedTo;
        NewMembers := 0;
        ReusedMembers := 0;
        NewEnrollments := 0;
        RetainedEnrollments := 0;
    end;

    local procedure ProcessRows(var Excel: Record "Excel Buffer" temporary; var Errors: Record "Excel Buffer" temporary): Integer
    var
        Staging: Record "PFE Member Import Row";
        Seen: Record "PFE Member Import Row";
        Member: Record "PFE Pension Member";
        Setup: Record "PFE Setup";
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
        Setup.LockTable();
        Setup.Get();
        Member.LockTable();
        Staging.Reset();
        if Staging.FindSet() then
            repeat
                Clear(Member);
                if Staging."Existing Member No." <> '' then begin
                    Member.Get(Staging."Existing Member No.");
                    CheckExistingIdentity(Staging, Member);
                    if Member."Import Reference" = '' then begin
                        Member."Import Reference" := Staging."Import Reference";
                        Member.Modify(true);
                    end;
                    ReusedMembers += 1;
                end else begin
                    Member.Init();
                    PopulateMember(Staging, Member);
                    Member.Insert(true);
                    NewMembers += 1;
                end;
                if ImportMode <> ImportMode::"Register Only" then
                    CreateEnrollment(Member);
                Imported += 1;
            until Staging.Next() = 0;
        exit(Imported);
    end;

    [TryFunction]
    local procedure ParseRow(var Excel: Record "Excel Buffer" temporary; RowNo: Integer; var Row: Record "PFE Member Import Row")
    var
        Member: Record "PFE Pension Member" temporary;
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
        ResolveMember(Row);
        Member.Init();
        PopulateMember(Row, Member);
        Setup.Get();
        Setup.TestField("Member Nos.");
        if (Row."Member No." = '') and (Row."Existing Member No." = '') then begin
            NoSeries.TestAutomatic(Setup."Member Nos.");
            if NoSeries.PeekNextNo(Setup."Member Nos.", WorkDate()) = '' then
                Error('The member number series has no available number.');
        end;
        if ImportMode <> ImportMode::"Register Only" then begin
            Row.TestField(Status, Row.Status::Active);
            if (Row."Existing Member No." = '') or not CheckEnrollmentPeriod(Row."Existing Member No.") then
                if NoSeries.PeekNextNo(Setup."Enrollment Nos.", WorkDate()) = '' then
                    Error('The enrollment number series has no available number.');
        end;
    end;

    local procedure PopulateMember(Row: Record "PFE Member Import Row"; var Member: Record "PFE Pension Member")
    begin
        Member."Import Reference" := Row."Import Reference";
        if Row."Existing Member No." <> '' then
            Member."Member No." := Row."Existing Member No."
        else
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

    procedure CheckImportSelection(Mode: Enum "PFE Member Import Mode"; SelectedScheme: Code[20]; SelectedEmployer: Code[20]; SelectedFrom: Date; SelectedTo: Date)
    var
        Scheme: Record "PFE Pension Scheme";
        Setup: Record "PFE Setup";
        NoSeries: Codeunit "No. Series";
        Eligibility: Codeunit "PFE Enrollment Management";
    begin
        Scheme.Get(SelectedScheme);
        case Mode of
            Mode::Employer:
                if not (Scheme.Category in [Scheme.Category::Occupational, Scheme.Category::Umbrella]) then
                    Error('Employer imports require an Occupational or Umbrella scheme.');
            Mode::Individual:
                Scheme.TestField(Category, Scheme.Category::Individual);
            else
                Error('Select an employer or individual import.');
        end;
        Eligibility.CheckEligibility(SelectedScheme, SelectedEmployer, SelectedFrom, SelectedTo, true);
        Setup.Get();
        Setup.TestField("Enrollment Nos.");
        NoSeries.TestAutomatic(Setup."Enrollment Nos.");
    end;

    local procedure ResolveMember(var Row: Record "PFE Member Import Row")
    var
        ByReference: Record "PFE Pension Member";
        ByNumber: Record "PFE Pension Member";
        Found: Boolean;
    begin
        ByReference.SetRange("Import Reference", Row."Import Reference");
        Found := ByReference.FindFirst();
        if Row."Member No." <> '' then
            if ByNumber.Get(Row."Member No.") then begin
                if Found and (ByNumber."Member No." <> ByReference."Member No.") then
                    Error('Member No. and Import Reference identify different members.');
                ByReference := ByNumber;
                Found := true;
            end else
                if Found then
                    Error('Member No. does not match the existing Import Reference.');
        if not Found then
            exit;
        if ImportMode = ImportMode::"Register Only" then
            Error('Member or Import Reference already exists. Use an enrollment import to enroll an existing member.');
        CheckExistingIdentity(Row, ByReference);
        ByReference.TestField(Status, ByReference.Status::Active);
        Row."Existing Member No." := ByReference."Member No.";
    end;

    local procedure CheckExistingIdentity(Row: Record "PFE Member Import Row"; Member: Record "PFE Pension Member")
    begin
        if (Member."Import Reference" <> '') and (Member."Import Reference" <> Row."Import Reference") then
            Error('Member %1 has a different Import Reference. Use its existing reference.', Member."Member No.");
        if UpperCase(Member."Member Name".Trim()) <> UpperCase(Row."Member Name".Trim()) then
            Error('The member name does not match the existing member identity.');
        if (Row."Date of Birth" <> 0D) and (Member."Date of Birth" <> 0D) and
           (Row."Date of Birth" <> Member."Date of Birth") then
            Error('Date of Birth does not match the existing member identity.');
    end;

    local procedure CheckEnrollmentPeriod(MemberNo: Code[20]): Boolean
    var
        Enrollment: Record "PFE Scheme Enrollment";
    begin
        Enrollment.SetRange("Member No.", MemberNo);
        Enrollment.SetRange("Scheme Code", SchemeCode);
        Enrollment.SetRange("Employer Code", EmployerCode);
        Enrollment.SetFilter(Status, '<>%1', Enrollment.Status::Cancelled);
        Enrollment.SetRange("Effective From", EffectiveFrom);
        Enrollment.SetRange("Effective To", EffectiveTo);
        Enrollment.SetRange(Status, Enrollment.Status::Active);
        if not Enrollment.IsEmpty() then
            exit(true);
        Enrollment.SetRange(Status);
        Enrollment.SetFilter(Status, '<>%1', Enrollment.Status::Cancelled);
        Enrollment.SetRange("Effective From");
        Enrollment.SetRange("Effective To");
        if EffectiveTo <> 0D then
            Enrollment.SetFilter("Effective From", '<=%1', EffectiveTo);
        Enrollment.SetFilter("Effective To", '%1|>=%2', 0D, EffectiveFrom);
        if not Enrollment.IsEmpty() then
            Error('An overlapping enrollment already exists for this member, scheme, and employer.');
        exit(false);
    end;

    local procedure CreateEnrollment(Member: Record "PFE Pension Member")
    var
        Enrollment: Record "PFE Scheme Enrollment";
        Eligibility: Codeunit "PFE Enrollment Management";
    begin
        Member.TestField(Status, Member.Status::Active);
        Eligibility.CheckEligibility(SchemeCode, EmployerCode, EffectiveFrom, EffectiveTo, true);
        if CheckEnrollmentPeriod(Member."Member No.") then begin
            RetainedEnrollments += 1;
            exit;
        end;
        Enrollment.Init();
        Enrollment.Validate("Member No.", Member."Member No.");
        Enrollment.Validate("Employer Code", EmployerCode);
        Enrollment.Validate("Scheme Code", SchemeCode);
        Enrollment.Validate("Effective From", EffectiveFrom);
        Enrollment.Validate("Effective To", EffectiveTo);
        Enrollment.Validate(Status, Enrollment.Status::Active);
        Enrollment.Insert(true);
        NewEnrollments += 1;
    end;

    procedure ReadMemberFile(Input: InStream; FileName: Text; var Excel: Record "Excel Buffer" temporary)
    var
        TempBlob: Codeunit "Temp Blob";
        Output: OutStream;
        TextInput: InStream;
        OpenError: Text;
        Line: Text;
        RowNo: Integer;
    begin
        Excel.Reset();
        Excel.DeleteAll();
        Excel.SetCurrent(0, 0);
        if FileName.ToLower().EndsWith('.xlsx') then begin
            OpenError := Excel.OpenBookStream(Input, 'Members');
            if OpenError <> '' then
                Error(OpenError);
            Excel.ReadSheet();
            Excel.CloseBook();
            exit;
        end;
        if not FileName.ToLower().EndsWith('.csv') then
            Error('Select an .xlsx workbook or a UTF-8 .csv file.');
        TempBlob.CreateOutStream(Output);
        CopyStream(Output, Input);
        TempBlob.CreateInStream(TextInput, TextEncoding::UTF8);
        while not TextInput.EOS() do begin
            TextInput.ReadText(Line);
            RowNo += 1;
            if RowNo > 10001 then
                Error('Import a maximum of 10000 rows at a time.');
            ReadCsvLine(Line, RowNo, Excel);
        end;
    end;

    local procedure ReadCsvLine(Line: Text; RowNo: Integer; var Excel: Record "Excel Buffer" temporary)
    var
        Value: Text;
        Character: Text[1];
        InQuotes: Boolean;
        ClosedQuote: Boolean;
        ColumnNo: Integer;
        Position: Integer;
    begin
        ColumnNo := 1;
        Position := 1;
        while Position <= StrLen(Line) do begin
            Character := CopyStr(Line, Position, 1);
            if InQuotes then begin
                if Character = '"' then
                    if CopyStr(Line, Position + 1, 1) = '"' then begin
                        Value += '"';
                        Position += 1;
                    end else begin
                        InQuotes := false;
                        ClosedQuote := true;
                    end
                else
                    Value += Character;
            end else
                case Character of
                    ',':
                        begin
                            AddCsvCell(Excel, RowNo, ColumnNo, Value);
                            ColumnNo += 1;
                            Value := '';
                            ClosedQuote := false;
                        end;
                    '"':
                        begin
                            if (Value <> '') or ClosedQuote then
                                Error('Invalid CSV quote at row %1.', RowNo);
                            InQuotes := true;
                        end;
                    else begin
                        if ClosedQuote then
                            Error('Unexpected text after a CSV quote at row %1.', RowNo);
                        Value += Character;
                    end;
                end;
            Position += 1;
        end;
        if InQuotes then
            Error('Unclosed CSV quote at row %1. Quoted values must fit on one line.', RowNo);
        AddCsvCell(Excel, RowNo, ColumnNo, Value);
    end;

    local procedure AddCsvCell(var Excel: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer; Value: Text)
    begin
        if (ColumnNo > 10) or (StrLen(Value) > 250) then
            Error('CSV row %1 has more than 10 columns or a cell longer than 250 characters.', RowNo);
        Excel.Init();
        Excel."Row No." := RowNo;
        Excel."Column No." := ColumnNo;
        Excel."Cell Value as Text" := Value;
        Excel."Cell Type" := Excel."Cell Type"::Text;
        Excel.NumberFormat := '@';
        Excel.Insert();
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
    var
        ImportMode: Enum "PFE Member Import Mode";
        SchemeCode: Code[20];
        EmployerCode: Code[20];
        EffectiveFrom: Date;
        EffectiveTo: Date;
        NewMembers: Integer;
        ReusedMembers: Integer;
        NewEnrollments: Integer;
        RetainedEnrollments: Integer;
}
