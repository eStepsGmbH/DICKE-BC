tableextension 50046 "DIC Sales Line" extends "Sales Line"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Felder hinzugefügt:
    //  - 50070 "Minimum Durability" (Mindesthaltbarkeit)
    //  - 50071 "Base Unit of Measure Code" (Basiseinheitencode)
    //  - 50072 "Base Unit Price" (Basiseinheiten VK-Preis
    //  - 50073 "Base Unit Quantity" (Basiseinheiten Menge
    //  - 50074 "GUO Receive Date" (GUO verarbeitet am)
    //  - 50075 "EDI Send Date" (EDI gesendet amDate)
    //  - 50076 "EDI Receive Date"(EDI empfangen amDate)
    //  - 50077 "Base Unit Quantity (Original)"(Basiseinheiten Menge (Ursprung))
    //  - 50078 "Coli"
    //  Feld 11 "Description" von 50 auf 100 Zeichen erweitert.
    //  Zuweisungen erfolgten bei Valdidierung der Artikelnummer und Menge.
    //  Zuweisung für das Feld "Einkaufscode" erfolgt bei Valdierung von "No.".
    //  Feld "No." - OnValidate: Code erweitert.
    //  Funktion "DeactivateSpecialOrderInfos" hinzugefügt (wird u.a. von Report 50077 verwendet).
    // 
    //  No.   Date       Version Changes
    //  --------------------------------------------------------------------------------
    //  DIC01 07.08.2020 17.2.01 Modify function: "No. - OnValidate"
    //  DIC02 14.12.2021         Add field: "External Document Pos. No."
    //  DIC03 26.04.2023         Modify Code: "No. - OnValidate"
    fields
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
                SalesHeader: Record "Sales Header";
            begin
                "Base Unit of Measure Code" := Item."Base Unit of Measure";
                "Base Unit Price" := Item."Unit Price";
                VALIDATE("Purchasing Code", Item."Purchasing Code");
                IF COPYSTR(UPPERCASE(COMPANYNAME), 7) = 'MÜNNICH' THEN
                    IF "Special Order" THEN
                        IF Item2.GET("No.") THEN
                            IF Vendor.GET(Item2."Vendor No.") THEN
                                VALIDATE("Location Code", Vendor."Location Code");
                SalesPriceFound := FALSE;
                if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then begin
                    SalesPrice.RESET();
                    SalesPrice.SETRANGE("Item No.", Item."No.");
                    SalesPrice.SETRANGE("Sales Type", SalesPrice."Sales Type"::Customer);
                    SalesPrice.SETRANGE("Sales Code", SalesHeader."Bill-to Customer No.");
                    SalesPrice.SETFILTER("Unit of Measure Code", '''''|%1', "Unit of Measure Code");
                    SalesPrice.SETFILTER("Ending Date", '%1|>=%2', 0D, SalesHeader."Document Date");
                    SalesPrice.SETFILTER("Starting Date", '%1|<=%2', 0D, SalesHeader."Document Date");
                    IF SalesPrice.FINDFIRST() THEN
                        SalesPriceFound := TRUE;
                    IF NOT SalesPriceFound THEN
                        IF "Customer Price Group" <> '' THEN BEGIN
                            SalesPrice.SETRANGE("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
                            SalesPrice.SETRANGE("Sales Code", "Customer Price Group");
                            IF SalesPrice.FINDFIRST() THEN
                                SalesPriceFound := TRUE;
                        END;
                    IF NOT SalesPriceFound THEN
                        IF NOT CONFIRM(NoPriceFoundWarningErr, FALSE, Item."No.") THEN
                            ERROR(NoItemInsertErr);
                end;
            end;

        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
            begin
                IF Type = Type::Item THEN
                    If Item.Get(Rec."No.") then
                        IF "Unit of Measure Code" = Item."Base Unit of Measure" THEN
                            "Base Unit Quantity" := Quantity
                        ELSE BEGIN
                            ItemUnitOfMeasure2.RESET();
                            ItemUnitOfMeasure2.SETRANGE("Item No.", "No.");
                            ItemUnitOfMeasure2.SETRANGE(Code, Item."Sales Unit of Measure");
                            IF ItemUnitOfMeasure2.FINDFIRST() THEN
                                "Base Unit Quantity" := Quantity * ItemUnitOfMeasure2."Qty. per Unit of Measure";
                        END;
            end;
        }
        field(50070; "Minimum Durability"; Date)
        {
            Caption = 'Mindesthaltbarkeit';
        }
        field(50071; "Base Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE IF (Type = CONST(Resource)) "Resource Unit of Measure".Code WHERE("Resource No." = FIELD("No."))
            ELSE
            "Unit of Measure";

            trigger OnValidate()
            var
                UnitOfMeasureTranslation: Record 5402;
                ResUnitofMeasure: Record "Resource Unit of Measure";
            begin
            end;
        }
        field(50072; "Base Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Base Unit Price';
            Editable = false;
        }
        field(50073; "Base Unit Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50074; "GUO Receive Date"; Date)
        {
            Caption = 'GUO verarbeitet am';
        }
        field(50075; "EDI Send Date"; Date)
        {
            Caption = 'EDI gesendet am';
        }
        field(50076; "EDI Receive Date"; Date)
        {
            Caption = 'EDI empfangen am';
        }
        field(50077; "Base Unit Quantity (Original)"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50078; Coli; Decimal)
        {
            Caption = 'Coli';
        }
        field(50079; "External Document Pos. No."; Code[35])
        {
            Caption = 'Externe Beleg Pos. Nr.';
        }
    }

    procedure DeactivateSpecialOrderInfos(VAR SalesLine_par: Record "Sales Line")
    begin
        IF (SalesLine_par."Document Type" IN [SalesLine_par."Document Type"::Order]) AND (SalesLine_par."Special Order") THEN BEGIN
            SalesLine_par.LOCKTABLE();
            SalesLine_par."Special Order Purch. Line No." := 0;
            IF SalesLine_par.MODIFY() THEN BEGIN
                SalesLine_par."Special Order" := FALSE;
                SalesLine_par."Purchasing Code" := '';
                SalesLine_par.MODIFY();
            END;
        END;
    end;

    var
        Item2: Record "Item";
        Vendor: Record "Vendor";
        SalesPrice: Record "7002";
        ItemUnitOfMeasure2: Record "Item Unit of Measure";
        SalesPriceFound: Boolean;
        NoPriceFoundWarningErr: Label 'Es ist kein Verkaufspreis (Artikel: %1) für den Debitor hinterlegt, trotzdem einfügen?';
        NoItemInsertErr: Label 'Artikel einfügen abgebrochen.';
}

