codeunit 50077 "DIC Event Subscriber"
{

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


    // [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, false)]
    // local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "12"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    // var
    //     SalesShipmentHeader: Record "Sales Shipment Header";
    //     stratEdiSetup: Record "50005";
    //     EDIShipment45: Report "50095"; TODO: REPORTS MISSING
    // begin
    //     //FÜR DIE TESTPHASE HIER ZUNÄCHST DIREKT WIEDER RAUS
    //     EXIT;
    //     IF SalesShptHdrNo <> '' THEN
    //         IF SalesShipmentHeader.GET(SalesShptHdrNo) THEN BEGIN
    //             stratEdiSetup.RESET();
    //             stratEdiSetup.SETRANGE("Customer No.", SalesShipmentHeader."Bill-to Customer No.");
    //             stratEdiSetup.SETRANGE("EDI Document Type", stratEdiSetup."EDI Document Type"::Lieferavis);
    //             IF stratEdiSetup.FINDFIRST() THEN BEGIN
    //                 CLEAR(EDIShipment45);
    //                 EDIShipment45.SendShipmentHeader(SalesShptHdrNo, SalesShipmentHeader."Bill-to Customer No.");
    //             END;
    //         END;
    // end;
}

