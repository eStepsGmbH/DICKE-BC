codeunit 50077 EventSubscriber
{

    trigger OnRun()
    begin
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

