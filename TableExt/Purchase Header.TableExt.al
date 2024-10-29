tableextension 50047 tableextension50047 extends "Purchase Header"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Add Action: "Lagerort aktualisieren"
    //  Add Function: "ChangeLocationCode"
    fields
    {
        modify("Document Date")
        {
            Caption = 'Document Date';
        }
    }


    //Unsupported feature: Code Insertion (VariableCollection) on "OnDelete".

    //trigger (Variable: ArchiveManagement)()
    //Parameters and return type have not been exported.
    //begin
    /*
    */
    //end;


    //Unsupported feature: Code Modification on "OnDelete".

    //trigger OnDelete()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    IF NOT UserSetupMgt.CheckRespCenter(1,"Responsibility Center") THEN
      ERROR(
        Text023,
    #4..28
    VALIDATE("Applies-to ID",'');
    VALIDATE("Incoming Document Entry No.",0);

    ApprovalsMgmt.DeleteApprovalEntry(Rec);
    PurchLine.LOCKTABLE;

    WhseRequest.SETRANGE("Source Type",DATABASE::"Purchase Line");
    #36..55
       (PurchCrMemoHeaderPrepmt."No." <> '')
    THEN
      MESSAGE(PostedDocsToPrintCreatedMsg);
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..31
    ApprovalsMgmt.DeleteApprovalEntries(RECORDID);
    #33..58
    */
    //end;


    //Unsupported feature: Code Modification on "OnInsert".

    //trigger OnInsert()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    IF NOT SkipInitialization THEN
      InitInsert;

    IF GETFILTER("Buy-from Vendor No.") <> '' THEN
      IF GETRANGEMIN("Buy-from Vendor No.") = GETRANGEMAX("Buy-from Vendor No.") THEN
        VALIDATE("Buy-from Vendor No.",GETRANGEMIN("Buy-from Vendor No."));

    "Doc. No. Occurrence" := ArchiveManagement.GetNextOccurrenceNo(DATABASE::"Purchase Header","Document Type","No.");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..6
    */
    //end;

    //Unsupported feature: Variable Insertion (Variable: ArchiveManagement) (VariableCollection) on "InitRecord(PROCEDURE 10)".



    //Unsupported feature: Code Modification on "InitRecord(PROCEDURE 10)".

    //procedure InitRecord();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    PurchSetup.GET;

    CASE "Document Type" OF
    #4..38
        END;
    END;

    IF "Document Type" IN ["Document Type"::Order,"Document Type"::Invoice,"Document Type"::"Return Order"] THEN
      "Order Date" := WORKDATE;

    IF "Document Type" = "Document Type"::Invoice THEN
    #46..67
      "Inbound Whse. Handling Time" := InvtSetup."Inbound Whse. Handling Time";

    "Responsibility Center" := UserSetupMgt.GetRespCenter(1,"Responsibility Center");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..41
    IF "Document Type" IN
       ["Document Type"::Order,"Document Type"::Invoice,"Document Type"::"Return Order","Document Type"::Quote]
    THEN
    #43..70
    "Doc. No. Occurrence" := ArchiveManagement.GetNextOccurrenceNo(DATABASE::"Purchase Header","Document Type","No.");
    */
    //end;

    local procedure "**Dicke**"()
    begin
    end;

    procedure ChangeLocationCode(NewLocationCode: Code[10])
    var
        PurchaseLine_lrec: Record "Purchase Line";
        SalesLine_lrec: Record "Sales Line";
        PurchaseLine_tmp: Record "Purchase Line" temporary;
        SalesLine_tmp: Record "Sales Line" temporary;
        Location: Record Location;
        CompanyInfo: Record "Company Information";
        InvtSetup: Record "Inventory Setup";
    begin
        TESTFIELD(Status, Status::Open);

        //UpdateShipToAddress >>>
        IF IsCreditDocType() THEN
            EXIT;

        "Location Code" := NewLocationCode;

        IF ("Location Code" <> '') AND Location.GET("Location Code") THEN BEGIN
            SetShipToAddress(
              Location.Name, Location."Name 2", Location.Address, Location."Address 2",
              Location.City, Location."Post Code", Location.County, Location."Country/Region Code");
            "Ship-to Contact" := Location.Contact;
        END;

        IF ("Location Code" = '') THEN BEGIN
            CompanyInfo.GET();
            "Ship-to Code" := '';
            SetShipToAddress(
              CompanyInfo."Ship-to Name", CompanyInfo."Ship-to Name 2", CompanyInfo."Ship-to Address", CompanyInfo."Ship-to Address 2",
              CompanyInfo."Ship-to City", CompanyInfo."Ship-to Post Code", CompanyInfo."Ship-to County",
              CompanyInfo."Ship-to Country/Region Code");
            "Ship-to Contact" := CompanyInfo."Ship-to Contact";
        END;

        IF "Location Code" = '' THEN BEGIN
            IF InvtSetup.GET() THEN
                "Inbound Whse. Handling Time" := InvtSetup."Inbound Whse. Handling Time";
        END ELSE BEGIN
            IF Location.GET("Location Code") THEN;
            "Inbound Whse. Handling Time" := Location."Inbound Whse. Handling Time";
        END;
        //UpdateShipToAddress <<<

        //ChangeLocationInLines >>>
        PurchaseLine_lrec.SETRANGE("Document Type", "Document Type");
        PurchaseLine_lrec.SETRANGE("Document No.", "No.");
        PurchaseLine_lrec.SETRANGE(Type, PurchaseLine_lrec.Type::Item);
        PurchaseLine_lrec.SETRANGE("Special Order", TRUE);

        IF PurchaseLine_lrec.FINDFIRST() THEN
            REPEAT
                //Bestellzeile merken
                PurchaseLine_tmp.INIT();
                PurchaseLine_tmp.TRANSFERFIELDS(PurchaseLine_lrec, TRUE);
                PurchaseLine_tmp.INSERT();

                //zugehörige Auftragszeile holen
                SalesLine_lrec.RESET();
                SalesLine_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
                SalesLine_lrec.SETRANGE("Document No.", PurchaseLine_lrec."Special Order Sales No.");
                SalesLine_lrec.SETRANGE("Line No.", PurchaseLine_lrec."Special Order Sales Line No.");
                SalesLine_lrec.SETRANGE("Special Order", TRUE);

                //und falls gefunden merken
                IF SalesLine_lrec.FINDFIRST() THEN BEGIN
                    SalesLine_tmp.INIT();
                    SalesLine_tmp.TRANSFERFIELDS(SalesLine_lrec, TRUE);
                    SalesLine_tmp.INSERT();
                    SalesLine_lrec.DeactivateSpecialOrderInfos(SalesLine_lrec);
                    SalesLine_lrec.VALIDATE("Location Code", "Location Code");
                    SalesLine_lrec."Special Order" := TRUE;
                    SalesLine_lrec."Special Order Purch. Line No." := SalesLine_tmp."Special Order Purch. Line No.";
                    SalesLine_lrec."Purchasing Code" := SalesLine_tmp."Purchasing Code";
                    SalesLine_lrec.MODIFY();
                END;

                PurchaseLine_lrec.DeactivateSpecialOrderInfos(PurchaseLine_lrec);
                PurchaseLine_lrec.VALIDATE("Location Code", "Location Code");
                PurchaseLine_lrec."Special Order" := TRUE;
                PurchaseLine_lrec."Special Order Sales Line No." := PurchaseLine_tmp."Special Order Sales Line No.";
                PurchaseLine_lrec."Purchasing Code" := PurchaseLine_tmp."Purchasing Code";
                PurchaseLine_lrec.MODIFY();

            UNTIL PurchaseLine_lrec.NEXT() = 0;

        //ChangeLocationInLines <<<
    end;

    var
        ArchiveManagement: Codeunit "5063";
}

