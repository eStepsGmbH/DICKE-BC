report 50009 "Update Value Entry"
{
    Permissions = TableData "Value Entry" = rm;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Value Entry"; "Value Entry")
        {
            RequestFilterFields = "Document Type", "Document No.";

            trigger OnAfterGetRecord()
            var
                SalesInvoiceHeader: Record "Sales Invoice Header";
                ItemLedgerEntry: Record "32";
                SalesShipmentLine: Record "Sales Shipment Line";
            begin
                CurrRec += 1;
                CASE "Value Entry"."Document Type" OF
                    "Value Entry"."Document Type"::"Sales Invoice":
                        BEGIN
                            IF SalesInvoiceHeader.GET("Value Entry"."Document No.") THEN BEGIN
                                IF ItemLedgerEntry.GET("Value Entry"."Item Ledger Entry No.") THEN
                                    IF ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" THEN
                                        IF SalesShipmentLine.GET(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") THEN BEGIN
                                            "Value Entry"."Sales Order No." := SalesShipmentLine."Order No.";
                                            "Value Entry"."Shipment Date" := SalesShipmentLine."Shipment Date";
                                            "Value Entry".MODIFY();
                                        END;
                            END;
                        END;
                END;
                IF GUIALLOWED THEN
                    Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
            end;

            trigger OnPostDataItem()
            begin
                IF GUIALLOWED THEN
                    Window.CLOSE();
            end;

            trigger OnPreDataItem()
            begin
                IF GUIALLOWED THEN BEGIN
                    Window.OPEN('Wertposten werden aktualisiert... @1@@@@@@@@@@');
                    NoOfRecs := "Value Entry".COUNT;
                END;
            end;
        }
    }

    var
        Window: Dialog;
        NoOfRecs: Integer;
        CurrRec: Integer;
}

