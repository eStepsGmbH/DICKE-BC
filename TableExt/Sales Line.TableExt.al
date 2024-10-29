tableextension 50046 tableextension50046 extends "Sales Line"
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

        //Unsupported feature: Property Modification (Data type) on "Description(Field 11)".



        //Unsupported feature: Code Modification on ""No."(Field 6).OnValidate".

        //trigger "(Field 6)()
        //Parameters and return type have not been exported.
        //>>>> ORIGINAL CODE:
        //begin
        /*
        "No." := FindNoFromTypedValue("No.");

        TestJobPlanningLine;
        #4..111
                Reserve := Item.Reserve;

              "Unit of Measure Code" := Item."Sales Unit of Measure";
              InitDeferralCode;
              SetDefaultItemQuantity;
            END;
        #118..192
        END;

        UpdateItemCrossRef;
        */
        //end;
        //>>>> MODIFIED CODE:
        //begin
        /*
        #1..114
        // Dicke >>>
              "Base Unit of Measure Code" := Item."Base Unit of Measure";
              "Base Unit Price" := Item."Unit Price";
              VALIDATE("Purchasing Code",Item."Purchasing Code");

              IF COPYSTR(UPPERCASE(COMPANYNAME),7) = 'MÜNNICH' THEN BEGIN
                IF "Special Order" THEN BEGIN
                  IF Item2.GET("No.") THEN
                    IF Vendor.GET(Item2."Vendor No.") THEN
                      VALIDATE("Location Code",Vendor."Location Code");
                END;
              END;

        //DIC03:est.uki >>>
              SalesPriceFound := FALSE;
              SalesPrice.RESET;
              SalesPrice.SETRANGE("Item No.",Item."No.");
              SalesPrice.SETRANGE("Sales Type",SalesPrice."Sales Type"::Customer);
              SalesPrice.SETRANGE("Sales Code", SalesHeader."Bill-to Customer No.");
              SalesPrice.SETFILTER("Unit of Measure Code",'''''|%1',"Unit of Measure Code");
              SalesPrice.SETFILTER("Ending Date",'%1|>=%2',0D,SalesHeader."Document Date");
              SalesPrice.SETFILTER("Starting Date",'%1|<=%2',0D,SalesHeader."Document Date");
              IF SalesPrice.FINDFIRST THEN
                SalesPriceFound:= TRUE;
              IF NOT SalesPriceFound THEN BEGIN
                IF "Customer Price Group" <> '' THEN BEGIN
                  SalesPrice.SETRANGE("Sales Type",SalesPrice."Sales Type"::"Customer Price Group");
                  SalesPrice.SETRANGE("Sales Code","Customer Price Group");
                  IF SalesPrice.FINDFIRST THEN
                    SalesPriceFound:= TRUE;
                END;
              END;
              IF NOT SalesPriceFound THEN
                IF NOT CONFIRM(NoPriceFoundWarning, FALSE, Item."No.") THEN
                  ERROR(NoItemInsertError);
        //DIC03:est.uki <<<

        #115..195
        */
        //end;


        //Unsupported feature: Code Modification on "Quantity(Field 15).OnValidate".

        //trigger OnValidate()
        //Parameters and return type have not been exported.
        //>>>> ORIGINAL CODE:
        //begin
        /*
        TestJobPlanningLine;
        TestStatusOpen;

        #4..87

        CALCFIELDS("Reserved Qty. (Base)");
        VALIDATE("Reserved Qty. (Base)");
        */
        //end;
        //>>>> MODIFIED CODE:
        //begin
        /*
        #1..90

        // Dicke >>>
        IF Type = Type::Item THEN BEGIN
          IF "Unit of Measure Code" = Item."Base Unit of Measure" THEN BEGIN
            "Base Unit Quantity" := Quantity
          END
          ELSE BEGIN
            ItemUnitOfMeasure2.RESET;
            ItemUnitOfMeasure2.SETRANGE("Item No.","No.");
            ItemUnitOfMeasure2.SETRANGE(Code,Item."Sales Unit of Measure");
            IF ItemUnitOfMeasure2.FINDFIRST THEN
              "Base Unit Quantity" := Quantity * ItemUnitOfMeasure2."Qty. per Unit of Measure";
          END;
        END;
        // Dicke <<<
        */
        //end;
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


    //Unsupported feature: Code Modification on "OnDelete".

    //trigger OnDelete()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    TestStatusOpen;
    IF NOT StatusCheckSuspended AND (SalesHeader.Status = SalesHeader.Status::Released) AND
       (Type IN [Type::"G/L Account",Type::"Charge (Item)",Type::Resource])
    #4..17
    IF ("Document Type" = "Document Type"::Order) AND (Quantity <> "Quantity Invoiced") THEN
      TESTFIELD("Prepmt. Amt. Inv.","Prepmt Amt Deducted");

    CheckAssocPurchOrder('');
    NonstockItemMgt.DelNonStockSales(Rec);

    IF "Document Type" = "Document Type"::"Blanket Order" THEN BEGIN
    #25..69
      DeferralUtilities.DeferralCodeOnDelete(
        DeferralUtilities.GetSalesDeferralDocType,'','',
        "Document Type","Document No.","Line No.");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..20
    CleanSpecialOrderFieldsAndCheckAssocPurchOrder;
    #22..72
    */
    //end;

    local procedure IsFullyInvoiced(): Boolean
    begin
        EXIT(("Qty. Shipped Not Invd. (Base)" = 0) AND ("Qty. Shipped (Base)" = "Quantity (Base)"))
    end;

    local procedure CleanSpecialOrderFieldsAndCheckAssocPurchOrder()
    begin
        IF ("Special Order Purch. Line No." <> 0) AND IsFullyInvoiced THEN
            IF CleanPurchaseLineSpecialOrderFields THEN BEGIN
                "Special Order Purchase No." := '';
                "Special Order Purch. Line No." := 0;
            END;
        CheckAssocPurchOrder('');
    end;

    local procedure CleanPurchaseLineSpecialOrderFields(): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        IF PurchaseLine.GET(PurchaseLine."Document Type"::Order, "Special Order Purchase No.", "Special Order Purch. Line No.") THEN BEGIN
            IF PurchaseLine."Qty. Received (Base)" < "Qty. Shipped (Base)" THEN
                EXIT(FALSE);

            PurchaseLine."Special Order" := FALSE;
            PurchaseLine."Special Order Sales No." := '';
            PurchaseLine."Special Order Sales Line No." := 0;
            PurchaseLine.MODIFY;
        END;

        EXIT(TRUE);
    end;

    procedure ClearSalesHeader()
    begin
        // CLEAR(SalesHeader);
    end;

    local procedure "**Dicke**"()
    begin
    end;

    procedure DeactivateSpecialOrderInfos(var SalesLine_par: Record "Sales Line")
    begin
        // Dicke >>>
        IF (SalesLine_par."Document Type" IN [SalesLine_par."Document Type"::Order]) AND (SalesLine_par."Special Order") THEN BEGIN
            SalesLine_par.LOCKTABLE;
            SalesLine_par."Special Order Purch. Line No." := 0;
            IF SalesLine_par.MODIFY THEN BEGIN
                SalesLine_par."Special Order" := FALSE;
                SalesLine_par."Purchasing Code" := '';
                SalesLine_par.MODIFY;
            END;
        END;
        // Dicke <<<
    end;

    //Unsupported feature: Property Deletion (PasteIsValid).


    var
        Item2: Record "Item";
        Vendor: Record "Vendor";
        SalesPrice: Record "7002";
        SalesPriceFound: Boolean;

    var
        ItemUnitOfMeasure2: Record "5404";

    var
        NoPriceFoundWarning: Label 'Es ist kein Verkaufspreis (Artikel: %1) für den Debitor hinterlegt, trotzdem einfügen?';
        NoItemInsertError: Label 'Artikel einfügen abgebrochen.';
}

