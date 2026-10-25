permissionset 50101 "PFE ADMIN"
{
    Assignable = true;
    Caption = 'PensionFlow Administrator';
    IncludedPermissionSets = "PFE USER";
    Permissions =
        tabledata "PFE Setup" = IMD,
        tabledata "No. Series" = RIM,
        tabledata "No. Series Line" = RIM,
        page "PFE Setup" = X,
        codeunit "PFE Setup Management" = X;
}
