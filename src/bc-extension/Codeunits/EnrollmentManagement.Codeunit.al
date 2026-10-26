codeunit 50103 "PFE Enrollment Management"
{
    procedure CheckEligibility(SchemeCode: Code[20]; EmployerCode: Code[20]; EffectiveFrom: Date; EffectiveTo: Date; RequireActive: Boolean)
    var
        Scheme: Record "PFE Pension Scheme";
        Employer: Record "PFE Employer";
        Participation: Record "PFE Scheme Employer";
    begin
        Scheme.Get(SchemeCode);
        Scheme.TestField(Category);
        if EffectiveFrom = 0D then
            Error('Effective From is required.');
        if (EffectiveTo <> 0D) and (EffectiveTo < EffectiveFrom) then
            Error('Effective To cannot be before Effective From.');
        if Scheme.Category = Scheme.Category::Individual then begin
            if EmployerCode <> '' then
                Error('Individual scheme enrollments must not have an employer.');
        end else begin
            if EmployerCode = '' then
                Error('An employer is required for Occupational and Umbrella schemes.');
            Employer.Get(EmployerCode);
            Participation.Get(SchemeCode, EmployerCode);
            if RequireActive then begin
                Employer.TestField(Status, Employer.Status::Active);
                Participation.TestField(Active, true);
            end;
            if (Participation."Effective From" <> 0D) and (EffectiveFrom < Participation."Effective From") then
                Error('Enrollment begins before employer participation.');
            if (Participation."Effective To" <> 0D) and
               ((EffectiveTo = 0D) or (EffectiveTo > Participation."Effective To")) then
                Error('Enrollment must end within the employer participation period.');
        end;
        if RequireActive then begin
            Scheme.TestField(Status, Scheme.Status::Active);
            if (Scheme."Effective Date" <> 0D) and (EffectiveFrom < Scheme."Effective Date") then
                Error('Enrollment cannot begin before the scheme effective date.');
        end;
    end;
}
