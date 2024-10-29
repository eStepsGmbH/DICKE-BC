tableextension 50047 "DIC Purchase Header" extends "Purchase Header"
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

    procedure ChangeLocationCode(NewLocationCode: Code[10])
    var
        PurchaseLine_lrec: Record "Purchase Line";
        SalesLine_lrec: Record "Sales Line";
        TempPurchaseLine: Record "Purchase Line" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        Location: Record Location;
        CompanyInfo: Record "Company Information";
        InvtSetup: Record "Inventory Setup";
    begin
        TESTFIELD(Status, Status::Open);

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

        PurchaseLine_lrec.SETRANGE("Document Type", "Document Type");
        PurchaseLine_lrec.SETRANGE("Document No.", "No.");
        PurchaseLine_lrec.SETRANGE(Type, PurchaseLine_lrec.Type::Item);
        PurchaseLine_lrec.SETRANGE("Special Order", TRUE);

        IF PurchaseLine_lrec.FINDFIRST() THEN
            REPEAT
                //Bestellzeile merken
                TempPurchaseLine.INIT();
                TempPurchaseLine.TRANSFERFIELDS(PurchaseLine_lrec, TRUE);
                TempPurchaseLine.INSERT();

                //zugehörige Auftragszeile holen
                SalesLine_lrec.RESET();
                SalesLine_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
                SalesLine_lrec.SETRANGE("Document No.", PurchaseLine_lrec."Special Order Sales No.");
                SalesLine_lrec.SETRANGE("Line No.", PurchaseLine_lrec."Special Order Sales Line No.");
                SalesLine_lrec.SETRANGE("Special Order", TRUE);

                //und falls gefunden merken
                IF SalesLine_lrec.FINDFIRST() THEN BEGIN
                    TempSalesLine.INIT();
                    TempSalesLine.TRANSFERFIELDS(SalesLine_lrec, TRUE);
                    TempSalesLine.INSERT();
                    SalesLine_lrec.DeactivateSpecialOrderInfos(SalesLine_lrec);
                    SalesLine_lrec.VALIDATE("Location Code", "Location Code");
                    SalesLine_lrec."Special Order" := TRUE;
                    SalesLine_lrec."Special Order Purch. Line No." := TempSalesLine."Special Order Purch. Line No.";
                    SalesLine_lrec."Purchasing Code" := TempSalesLine."Purchasing Code";
                    SalesLine_lrec.MODIFY();
                END;

                PurchaseLine_lrec.DeactivateSpecialOrderInfos(PurchaseLine_lrec);
                PurchaseLine_lrec.VALIDATE("Location Code", "Location Code");
                PurchaseLine_lrec."Special Order" := TRUE;
                PurchaseLine_lrec."Special Order Sales Line No." := TempPurchaseLine."Special Order Sales Line No.";
                PurchaseLine_lrec."Purchasing Code" := TempPurchaseLine."Purchasing Code";
                PurchaseLine_lrec.MODIFY();

            UNTIL PurchaseLine_lrec.NEXT() = 0;
    end;
}