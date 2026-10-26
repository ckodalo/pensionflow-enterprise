codeunit 50106 "PFE Contribution Currency"
{
    Permissions = tabledata Currency = I;

    procedure EnsureKES()
    var
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if GLSetup."LCY Code" = 'KES' then
            exit;
        Currency.LockTable();
        if Currency.Get('KES') then
            exit;
        Currency.Init();
        Currency.Validate(Code, 'KES');
        Currency.Validate(Description, 'Kenyan Shilling');
        Currency.Validate("Amount Rounding Precision", 0.01);
        Currency.Validate("Unit-Amount Rounding Precision", 0.00001);
        Currency.Validate("Invoice Rounding Precision", 0.01);
        Currency."Amount Decimal Places" := '2:2';
        Currency."Unit-Amount Decimal Places" := '2:5';
        Currency.Insert(true);
    end;

    procedure Precision(CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
    begin
        if CurrencyCode = '' then begin
            GLSetup.Get();
            GLSetup.TestField("Amount Rounding Precision");
            exit(GLSetup."Amount Rounding Precision");
        end;
        Currency.Get(CurrencyCode);
        Currency.TestField("Amount Rounding Precision");
        exit(Currency."Amount Rounding Precision");
    end;
}
