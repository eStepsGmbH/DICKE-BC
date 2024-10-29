pageextension 50007 pageextension50007 extends "Posted Sales Shipment"
{

    actions
    {
        // addlast(processing)  TODO: REPORTS MISSING
        // {
        //     action(SendDesadv)
        //     {
        //         Caption = 'EDI Lieferavis';
        //         Image = SendElectronicDocument;
        //         Promoted = true;
        //         PromotedCategory = Process;
        //         PromotedIsBig = true;

        //         trigger OnAction()
        //         var
        //             stratEdiSetup: Record "50005";
        //             EDIShipment45: Report "50095";
        //         begin
        //             stratEdiSetup.RESET();
        //             stratEdiSetup.SETRANGE("Customer No.", Rec."Sell-to Customer No.");
        //             stratEdiSetup.SETRANGE("EDI Document Type", stratEdiSetup."EDI Document Type"::Lieferavis);
        //             IF stratEdiSetup.FINDFIRST() THEN BEGIN
        //                 CLEAR(EDIShipment45);
        //                 EDIShipment45.SendShipmentHeader(Rec."No.", Rec."Sell-to Customer No.");
        //                 MESSAGE('CCTOP Lieferavis wurde erstellt.');
        //             END;
        //         end;
        //     }
        // }
    }
}

