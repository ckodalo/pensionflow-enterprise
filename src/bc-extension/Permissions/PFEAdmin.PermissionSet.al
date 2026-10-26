permissionset 50101 "PFE ADMIN"
{
    Assignable = true;
    Caption = 'PensionFlow Administrator';
    IncludedPermissionSets = "PFE USER";
    Permissions =
        tabledata "G/L Account" = i,
        tabledata "Customer Posting Group" = i,
        tabledata Customer = i,
        tabledata "Gen. Journal Template" = i,
        tabledata "Gen. Journal Batch" = i,
        tabledata "Source Code" = i,
        tabledata "PFE Setup" = IMD,
        tabledata "No. Series" = RIM,
        tabledata "No. Series Line" = RIM,
        page "PFE Setup" = X,
        codeunit "PFE Setup Management" = X;
}
