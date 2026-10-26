page 50112 "PFE Import Enrollment Options"
{
    PageType = StandardDialog;
    Caption = 'Member Import Options';
    layout
    {
        area(Content)
        {
            group(Selection)
            {
                Caption = 'Registration and Enrollment';
                field(Mode; ImportMode)
                {
                    ApplicationArea = All;
                    Caption = 'Registration Type';
                    Editable = false;
                    ToolTip = 'Specifies whether members are enrolled through an employer or individually.';
                }
                field(Employer; EmployerCode)
                {
                    ApplicationArea = All;
                    Caption = 'Employer Code';
                    TableRelation = "PFE Employer";
                    Enabled = ImportMode = ImportMode::Employer;
                    ToolTip = 'Select the participating employer for an employer import.';
                }
                field(Scheme; SchemeCode)
                {
                    ApplicationArea = All;
                    Caption = 'Scheme Code';
                    TableRelation = "PFE Pension Scheme";
                    ToolTip = 'Select an eligible scheme. Employer participation must be configured for employer imports.';
                }
                field(FromDate; EffectiveFrom)
                {
                    ApplicationArea = All;
                    Caption = 'Effective From';
                    ToolTip = 'Specifies the first date of the enrollments created by this import.';
                }
                field(ToDate; EffectiveTo)
                {
                    ApplicationArea = All;
                    Caption = 'Effective To';
                    ToolTip = 'Specifies the optional last date. Blank creates open-ended enrollments.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        EffectiveFrom := WorkDate();
    end;
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Importer: Codeunit "PFE Member Import";
    begin
        if CloseAction = Action::OK then
            Importer.CheckImportSelection(ImportMode, SchemeCode, EmployerCode, EffectiveFrom, EffectiveTo);
        exit(true);
    end;
    procedure SetMode(NewMode: Enum "PFE Member Import Mode")
    begin
        ImportMode := NewMode;
    end;
    procedure GetSelection(var SelectedScheme: Code[20]; var SelectedEmployer: Code[20]; var SelectedFrom: Date; var SelectedTo: Date)
    begin
        SelectedScheme := SchemeCode;
        SelectedEmployer := EmployerCode;
        SelectedFrom := EffectiveFrom;
        SelectedTo := EffectiveTo;
    end;
    var
        ImportMode: Enum "PFE Member Import Mode";
        EmployerCode: Code[20];
        SchemeCode: Code[20];
        EffectiveFrom: Date;
        EffectiveTo: Date;
}
