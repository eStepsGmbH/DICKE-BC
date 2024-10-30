codeunit 50077 "DIC Event Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    local procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; var SkipCheckReleaseRestrictions: Boolean; SkipWhseRequestOperations: Boolean)
    begin
        CheckEdiRelease(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnInsertHeaderOnBeforeValidateSellToCustNoFromReqLine', '', false, false)]
    local procedure OnInsertHeaderOnBeforeValidateSellToCustNoFromReqLine(PurchOrderHeader: Record "Purchase Header"; ReqLine2: Record "Requisition Line"; var ShouldValidateSellToCustNo: Boolean)
    begin
        PurchOrderHeader."Expected Receipt Date" := ReqLine2."Due Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterSet', '', false, false)]
    local procedure OnAfterSet(NewPurchOrderHeader: Record "Purchase Header"; CommitIsSuppressed: Boolean; EndingOrderDate: Date; PrintPurchOrder: Boolean; var OrderDateReq: Date; ReceiveDateReq: Date; var PostingDateReq: Date; var PurchOrderHeader: Record "Purchase Header"; ReferenceReq: Text[35])
    begin
        ReceiveDateReq := PurchOrderHeader."Due Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post + Print", 'OnBeforeConfirmPost', '', false, false)]
    local procedure PurchPrintOnBeforeConfirmPost(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer)
    begin
        IF NOT PurchaseCheckBaseUnit(PurchaseHeader) THEN
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnBeforeConfirmPost', '', false, false)]
    local procedure PurchOnBeforeConfirmPost(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer)
    begin
        IF NOT PurchaseCheckBaseUnit(PurchaseHeader) THEN
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post + Print", 'OnBeforeConfirmPost', '', false, false)]
    local procedure SalesOnBeforeConfirmPost(var SalesHeader: Record "Sales Header"; var HideDialog: Boolean; var IsHandled: Boolean; var SendReportAsEmail: Boolean; var DefaultOption: Integer)
    begin
        IF NOT SalesCheckBaseUnit(SalesHeader) THEN
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    begin
        IF NOT SalesCheckBaseUnit(SalesHeader) THEN
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeConfirmDownloadShipment', '', false, false)]
    local procedure OnBeforeConfirmDownloadShipment(var SalesHeader: Record "Sales Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
        //Function "SendPostedDocumentRecord" in NAV2017: Confirm disabled
        IsHandled := true;
        Result := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnInitValueEntryOnAfterAssignFields', '', false, false)]
    local procedure OnInitValueEntryOnAfterAssignFields(var ValueEntry: Record "Value Entry"; ItemLedgEntry: Record "Item Ledger Entry"; ItemJnlLine: Record "Item Journal Line")
    begin
        ValueEntry."Source No. 2" := ItemJnlLine."Source No.";
        ValueEntry."Minimum Durability" := ItemJnlLine."Minimum Durability";
        ValueEntry.Coli := ItemJnlLine.Coli;
        ValueEntry."Sales Order No." := ItemJnlLine."Sales Order No.";
        ValueEntry."Shipment Date" := ItemJnlLine."Shipment Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer)
    begin
        NewItemLedgEntry."Minimum Durability" := ItemJournalLine."Minimum Durability";
        NewItemLedgEntry.Coli := ItemJournalLine.Coli;
        NewItemLedgEntry."Sales Order No." := ItemJournalLine."Sales Order No.";
        NewItemLedgEntry."Shipment Date" := ItemJournalLine."Shipment Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertCapValueEntry', '', false, false)]
    local procedure OnBeforeInsertCapValueEntry(var ValueEntry: Record "Value Entry"; ItemJnlLine: Record "Item Journal Line")
    begin
        ValueEntry."Source No. 2" := ItemJnlLine."Source No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Shipment Line", 'OnAfterDescriptionSalesLineInsert', '', false, false)]
    local procedure OnAfterDescriptionSalesLineInsert(var SalesLine: Record "Sales Line"; SalesShipmentLine: Record "Sales Shipment Line"; var NextLineNo: Integer)
    var
        SalesHeaderTextLine: Record "Sales Header";
        SalesOrderTextLine: Record "Sales Line";
        TempSalesLine: Record "Sales Line";
        ExtOrderNoTextLine: Label 'Ext. Order No.: %1';
        CopyTextLinesFromOrder: Boolean; //TODO: Müssen noch gesetzt werden
        HideShipmentTextLine: Boolean; //TODO: Müssen noch gesetzt werden
    begin
        TempSalesLine := SalesLine;
        IF (HideShipmentTextLine) THEN
            SalesLine.Description := '';
        IF CopyTextLinesFromOrder THEN BEGIN
            //Externe Belenummer als erste Zeile einfügen
            IF SalesHeaderTextLine.GET(SalesHeaderTextLine."Document Type"::Order, SalesShipmentLine."Order No.") THEN
                IF SalesHeaderTextLine."External Document No." <> '' THEN BEGIN
                    SalesLine.INIT();
                    SalesLine."Line No." := NextLineNo;
                    SalesLine."Document Type" := TempSalesLine."Document Type";
                    SalesLine."Document No." := TempSalesLine."Document No.";
                    SalesLine.Description := STRSUBSTNO(ExtOrderNoTextLine, SalesHeaderTextLine."External Document No.");
                    SalesLine.INSERT();
                    NextLineNo := NextLineNo + 10000;
                END;

            //Textzeilen aus dem Auftrag holen
            SalesOrderTextLine.RESET();
            SalesOrderTextLine.SETRANGE("Document Type", SalesOrderTextLine."Document Type"::Order);
            SalesOrderTextLine.SETRANGE("Document No.", SalesShipmentLine."Order No.");
            IF SalesOrderTextLine.FINDSET() THEN
                REPEAT
                    IF (SalesOrderTextLine.Type = SalesOrderTextLine.Type::" ") THEN BEGIN
                        SalesLine.INIT();
                        SalesLine."Line No." := NextLineNo;
                        SalesLine."Document Type" := TempSalesLine."Document Type";
                        SalesLine."Document No." := TempSalesLine."Document No.";
                        SalesLine.Description := SalesOrderTextLine.Description;
                        SalesLine."Description 2" := SalesOrderTextLine."Description 2";
                        SalesLine.INSERT();
                        NextLineNo := NextLineNo + 10000;
                    END;
                UNTIL (SalesOrderTextLine.Type <> SalesOrderTextLine.Type::" ") OR (SalesOrderTextLine.NEXT() = 0);
        END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesLine', '', false, false)]
    local procedure OnAfterCopyItemJnlLineFromSalesLine(var ItemJnlLine: Record "Item Journal Line"; SalesLine: Record "Sales Line")
    begin
        ItemJnlLine."Minimum Durability" := SalesLine."Minimum Durability";
        ItemJnlLine.Coli := SalesLine.Coli;
        ItemJnlLine."Sales Order No." := SalesLine."Document No.";
        ItemJnlLine."Shipment Date" := SalesLine."Shipment Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromPurchLine', '', false, false)]
    local procedure OnAfterCopyItemJnlLineFromPurchLine(var ItemJnlLine: Record "Item Journal Line"; PurchLine: Record "Purchase Line")
    begin
        ItemJnlLine."Minimum Durability" := PurchLine."Minimum Durability";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitRecord', '', false, false)]
    local procedure OnAfterInitRecord(var SalesHeader: Record "Sales Header")
    begin
        IF COPYSTR(UPPERCASE(COMPANYNAME), 1, 7) = 'MÜNNICH' THEN BEGIN
            SalesHeader."Shipment Date" := DWY2DATE(5, DATE2DWY(WORKDATE(), 2), DATE2DMY(WORKDATE(), 3));
            SalesHeader."Promised Delivery Date" := SalesHeader."Shipment Date" + 3;
            SalesHeader."Requested Delivery Date" := SalesHeader."Shipment Date" + 3;
            SalesHeader."Due Date" := SalesHeader."Shipment Date" + 3;
        END;

        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN
            IF COPYSTR(UPPERCASE(COMPANYNAME), 1, 7) <> 'MÜNNICH' THEN BEGIN
                // Warenausgangsdatum = Auftragsdatum + 1 Tag
                // Zuges. Lieferdatum = Auftragsdatum + 2 Tage
                SalesHeader."Shipment Date Shipping Agent" := GetDate(SalesHeader."Order Date", 1);
                SalesHeader."Promised Delivery Date" := GetDate(SalesHeader."Order Date", 2);
                // Für VUO ergänzt
                SalesHeader."Shipment Date" := SalesHeader."Shipment Date Shipping Agent";
                SalesHeader."Requested Delivery Date" := SalesHeader."Promised Delivery Date";
            END;
    end;

    local procedure GetDate(StartDate: Date; NumberofDays: Integer): Date
    var
        DateRec: Record Date;
    begin
        WITH DateRec DO BEGIN
            SETRANGE("Period Type", "Period Type"::Date);
            SETRANGE("Period No.", 1, 5);
            "Period Start" := StartDate;
            DateRec.NEXT(NumberofDays);
            EXIT("Period Start");
        END;
    end;

    local procedure SalesCheckBaseUnit(VAR Rec: Record "Sales Header"): Boolean
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        ErrUnitCodeMissing: Label 'Bei Artikel %1 ist nicht die Basiseinheit %2 eingetragen. Wollen Sie trotzdem buchen?';
    begin
        SalesSetup.GET();
        IF SalesSetup."Check Post Order In Base Unit" = FALSE THEN
            EXIT(TRUE);

        SalesLine.RESET();
        SalesLine.SETRANGE(SalesLine."Document Type", Rec."Document Type");
        SalesLine.SETRANGE("Document No.", Rec."No.");
        SalesLine.SETRANGE("Sell-to Customer No.", Rec."Sell-to Customer No.");
        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        IF SalesLine.FINDSET() THEN
            REPEAT
                Item.RESET();
                IF Item.GET(SalesLine."No.") THEN
                    IF Item."Base Unit of Measure" <> SalesLine."Unit of Measure Code" THEN
                        EXIT(CONFIRM(ErrUnitCodeMissing, FALSE, SalesLine."No.", Item."Base Unit of Measure"));
            UNTIL SalesLine.NEXT() = 0;
        EXIT(TRUE);
    end;

    local procedure PurchaseCheckBaseUnit(VAR Rec: Record "Purchase Header"): Boolean
    var
        PurchaseSetup: Record "Purchases & Payables Setup";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        ErrUnitCodeMissing: Label 'Bei Artikel %1 ist nicht die Basiseinheit %2 eingetragen. Wollen Sie trotzdem buchen?';
    begin
        PurchaseSetup.GET();
        IF PurchaseSetup."Check Post Order In Base Unit" = FALSE THEN
            EXIT(TRUE);

        PurchaseLine.RESET();
        PurchaseLine.SETRANGE(PurchaseLine."Document Type", Rec."Document Type");
        PurchaseLine.SETRANGE("Document No.", Rec."No.");
        PurchaseLine.SETRANGE("Buy-from Vendor No.", Rec."Buy-from Vendor No.");
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        IF PurchaseLine.FINDSET() THEN
            REPEAT
                Item.RESET();
                IF Item.GET(PurchaseLine."No.") THEN
                    IF Item."Base Unit of Measure" <> PurchaseLine."Unit of Measure Code" THEN
                        EXIT(CONFIRM(ErrUnitCodeMissing, FALSE, PurchaseLine."No.", Item."Base Unit of Measure"));
            UNTIL PurchaseLine.NEXT() = 0;
        EXIT(TRUE);
    end;

    local procedure CheckEdiRelease(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        CustomerCentralPayer: Record Customer;
        CompanyInformation: Record "Company Information";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        TEXT001_EDI: Label 'Auftrag (EDI) kann nicht freigegeben werden. GLN in der Firmeneinrichtung fehlt.';
        TEXT002_EDI: Label 'Auftrag (EDI) kann nicht freigegeben werden. GLN beim Debitoren (%1) fehlt.';
        TEXT003_EDI: Label ' Auftrag (EDI) kann nicht freigegeben werden. GLN beim Zentralregulierer (%1) fehlt.';
        TEXT005_EDI: Label ' Auftrag (EDI) kann nicht freigegeben werden. Artikelstamm (%1) GTIN nicht angegeben.';
    begin
        //wir berücksichtigen nur Aufträge für EDI
        IF SalesHeader."Document Type" <> SalesHeader."Document Type"::Order THEN
            EXIT;

        //prüfen, ob der Auftrag über einen Zentralregulierer abgerechnet wird
        IF SalesHeader."Bill-to Customer No." <> '' THEN
            Customer.GET(SalesHeader."Bill-to Customer No.")
        ELSE
            Customer.GET(SalesHeader."Sell-to Customer No.");

        IF Customer."Central Payer" <> '' THEN BEGIN
            //Wenn der Zentralregulierer das passende EDI Sendeprofil eingetragen
            //hat werden die Abhängigkeiten für EDI geprüft.
            CustomerCentralPayer.GET(Customer."Central Payer");
            IF CustomerCentralPayer."Document Sending Profile" = 'EANCOM_REWE' THEN BEGIN

                //Beteiligte Debitoren prüfen
                CompanyInformation.GET();
                IF CompanyInformation.GLN = '' THEN
                    ERROR(TEXT001_EDI);
                IF Customer.GLN = '' THEN
                    ERROR(TEXT002_EDI, Customer."No.");
                IF CustomerCentralPayer.GLN = '' THEN
                    ERROR(TEXT003_EDI, CustomerCentralPayer."No.");

                //Artikel prüfen
                SalesLine.RESET();
                SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SETRANGE("Document No.", SalesHeader."No.");
                SalesLine.SETRANGE(Type, SalesLine.Type::Item);
                IF SalesLine.FINDSET() THEN
                    REPEAT
                        Item.GET(SalesLine."No.");
                        IF Item.GTIN = '' THEN
                            ERROR(TEXT005_EDI, Item."No.");
                    UNTIL SalesLine.NEXT() = 0;
            END;
        END;
    end;
}

