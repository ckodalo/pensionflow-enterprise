page 50102 "PFE Pension Role Center"
{
    PageType = RoleCenter;
    Caption = 'PensionFlow';

    actions
    {
        area(Sections)
        {
            group(PensionManagement)
            {
                Caption = 'Pension Management';

                action(PensionSchemes)
                {
                    ApplicationArea = All;
                    Caption = 'Pension Schemes';
                    RunObject = page "PFE Pension Scheme List";
                    ToolTip = 'View and manage pension schemes.';
                }
            }
        }

        area(Embedding)
        {
            action(PensionSchemeList)
            {
                ApplicationArea = All;
                Caption = 'Pension Schemes';
                RunObject = page "PFE Pension Scheme List";
                ToolTip = 'View and manage pension schemes.';
            }
        }
    }
}
