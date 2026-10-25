permissionset 50100 "PFE USER"
{
    Assignable = true;
    Caption = 'PensionFlow User';
    Permissions =
        table "PFE Activities Cue" = X,
        page "PFE Activities" = X,
        codeunit "PFE Member Import" = X,
        table "PFE Member Import Row" = X,
        tabledata "PFE Pension Member" = RIMD,
        tabledata "PFE Scheme Enrollment" = RIMD,
        table "PFE Pension Member" = X,
        table "PFE Scheme Enrollment" = X,
        page "PFE Member List" = X,
        page "PFE Member Card" = X,
        page "PFE Enrollment List" = X,
        page "PFE Enrollment Card" = X,
        tabledata "PFE Setup" = R,
        tabledata "PFE Employer" = RIMD,
        tabledata "PFE Pension Scheme" = RIMD,
        table "PFE Setup" = X,
        table "PFE Employer" = X,
        table "PFE Pension Scheme" = X,
        page "PFE Employer Card" = X,
        page "PFE Employer List" = X,
        page "PFE Pension Scheme Card" = X,
        page "PFE Pension Scheme List" = X,
        page "PFE Pension Role Center" = X;
}
