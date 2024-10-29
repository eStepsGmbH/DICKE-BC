pageextension 50020 pageextension50020 extends "Posted Sales Shipments"
{
    // 
    // DIC 18.04.2019 Add Field: "Order No."
    layout
    {
        addfirst(Control1)
        {
            field("Order No."; Rec."Order No.")
            {
            }
        }
    }

    var
        SelectedCompanyName: Text[100];


    //Unsupported feature: Code Modification on "OnOpenPage".

    //trigger OnOpenPage()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    SetSecurityFilterOnRespCenter;
    IF FINDFIRST THEN;
    IsOfficeAddin := OfficeMgt.IsAvailable;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    SetSecurityFilterOnRespCenter;
    //Dicke >>>
    IF SelectedCompanyName <> '' THEN BEGIN
      Rec.CHANGECOMPANY(SelectedCompanyName);
      SelectedCompanyName := '';
    END;
    //Dicke <<<
    IF FINDFIRST THEN;
    IsOfficeAddin := OfficeMgt.IsAvailable;
    */
    //end;

    procedure SetCompany(CompName: Text[100])
    begin
        //Dicke >>>
        SelectedCompanyName := CompName;
        //Dicke <<<
    end;
}

