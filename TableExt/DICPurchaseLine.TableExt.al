tableextension 50048 "DIC Purchase Line" extends "Purchase Line"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Felder hinzugefügt:
    //  - 50070 "VIO Creation Date" (VIO erstellt am)
    //  - 50071 "VIO" (VIO erstellen)
    //  - 50072 "Total Item Qty." (Gesamtartikelmenge)
    //  - 50073 "GUO Received Date" (GUO erhalten am)
    //  - 50074 "Minimum Durability" (Mindesthaltbarkeit)
    // 
    //  OnValidate von Feld "Quantity" erweitert:
    //    Bei Spezialaufträgen, kann im zugehörigen VK-Auftrag
    //    eine geänderte Menge angepasst werden, wenn der VK-Auftrag
    //    noch nicht per VUO gesendet wurde.
    // 
    //  Key hinzugefügt:
    //  - "Document Type,Buy-from Vendor No.,Type,No."
    // 
    //  No.   Date       Version Changes
    //  --------------------------------------------------------------------------------
    //  DIC01 06.08.2020 17.2.01 Modify function: "Quantity - OnValidate"
    fields
    {
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                IF NOT StatusCheckSuspended THEN
                    IF ("Document Type" IN ["Document Type"::Order]) AND ("Special Order") THEN
                        IF (xRec.Quantity <> Quantity) OR (xRec."Quantity (Base)" <> "Quantity (Base)") THEN
                            IF CONFIRM(Text001_l, TRUE, "Special Order Sales No.") THEN BEGIN
                                SalesHdr.RESET();
                                SalesHdr.GET(SalesHdr."Document Type"::Order, "Special Order Sales No.");
                                IF SalesHdr."VUO Creation Date" <> 0D THEN
                                    ERROR(Text002_l, "Special Order Sales No.");
                                SalesLine.RESET();
                                LOCKTABLE();
                                SalesLine.LOCKTABLE();
                                SalesLine.GET(SalesLine."Document Type"::Order, "Special Order Sales No.", "Special Order Sales Line No.");
                                SalesLine."Special Order Purch. Line No." := 0;
                                SalesLine.MODIFY();
                                SalesLine.VALIDATE(Quantity, Rec.Quantity);
                                SalesLine."Special Order Purch. Line No." := "Special Order Sales Line No.";
                                SalesLine.MODIFY();
                            END;
            END;
        }
        field(50070; "VIO Creation Date"; Date)
        {
            Caption = 'VIO erstellt am';
        }
        field(50071; VIO; Boolean)
        {
            Caption = 'VIO erstellen';
            InitValue = true;
        }
        field(50072; "Total Item Qty."; Decimal)
        {
            CalcFormula = Sum("Purchase Line".Quantity WHERE("Document Type" = FIELD("Document Type"),
                                                              "Buy-from Vendor No." = FIELD("Buy-from Vendor No."),
                                                              "Document No." = FIELD("Document No."),
                                                              Type = FIELD(Type),
                                                              "No." = FIELD("No.")));
            Caption = 'Gesamtartikelmenge';
            FieldClass = FlowField;
        }
        field(50073; "GUO Received Date"; Date)
        {
            Caption = 'GUO erhalten am';
        }
        field(50074; "Minimum Durability"; Date)
        {
            Caption = 'Mindesthaltbarkeit';
        }
    }

    procedure DeactivateSpecialOrderInfos(var PurchaseLine_par: Record "Purchase Line")
    begin
        IF (PurchaseLine_par."Document Type" IN [PurchaseLine_par."Document Type"::Order]) AND (PurchaseLine_par."Special Order") THEN BEGIN
            PurchaseLine_par.LOCKTABLE();
            PurchaseLine_par."Special Order Sales Line No." := 0;
            IF PurchaseLine_par.MODIFY() THEN BEGIN
                PurchaseLine_par."Special Order" := FALSE;
                PurchaseLine_par."Purchasing Code" := '';
                PurchaseLine_par.MODIFY();
            END;
        END;
    end;

    var
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Text001_l: Label 'Diese Bestellzeile gehört zu Auftrag %1. Möchten Sie die Menge auch in diesem Auftrag anpassen!';
        Text002_l: Label 'Die Menge kann im Auftrag %1 nicht angepasst werden, da bereits eine VUO-Datei erstellt wurde!';
}

