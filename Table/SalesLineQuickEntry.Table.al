table 50002 "Sales Line Quick Entry"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Tabelle erstellt.
    //  - est.uki   DIC01   26.02.2021  Modify function: "AddLinesToSalesOrder"
    //                                  Modify function: "AddShipLinesFromOtherCompany"
    //  - est.uki   DIC02   26.04.2023  Modify functions:
    //                                  - "AddShipLinesFromOtherCompany"
    //                                  - "AddLinesToSalesOrder"

    Caption = 'Sales Line Quick Entry';
    DataCaptionFields = "Document No.";

    fields
    {
        field(20; "Document No."; Code[20])
        {
            Caption = 'Belegnr.';
            TableRelation = "Sales Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(30; "Line No."; Integer)
        {
            Caption = 'Zeilnennr.';
        }
        field(40; "User ID"; Code[100])
        {
            Caption = 'Benutzer';
            Editable = false;
        }
        field(50; "Item No."; Code[20])
        {
            Caption = 'Artikelnr.';
            TableRelation = Item;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                ItemFound: Boolean;
            begin
                Item.SETCURRENTKEY("Search Description");
                Item.SETRANGE("Search Description", Rec."Item No.");
                IF Item.FINDFIRST() THEN
                    ItemFound := TRUE;

                IF NOT ItemFound THEN
                    Item.SETFILTER("Search Description", '@' + Rec."Item No." + '*');

                IF Item.FINDFIRST() THEN
                    ItemFound := TRUE;

                IF ItemFound THEN BEGIN
                    "Item No." := Item."No.";
                    Description := Item.Description;
                    "Description 2" := Item."Description 2";
                    "Unit of Measure" := Item."Sales Unit of Measure"
                END ELSE BEGIN
                    Item.RESET();
                    Item.SETFILTER("No.", '@' + Rec."Item No." + '*');
                    IF Item.FINDFIRST() THEN BEGIN
                        "Item No." := Item."No.";
                        Description := Item.Description;
                        "Description 2" := Item."Description 2";
                        "Unit of Measure" := Item."Sales Unit of Measure"
                    END;
                END;
            end;
        }
        field(60; Description; Text[100])
        {
            Caption = 'Beschreibung';
        }
        field(70; "Description 2"; Text[100])
        {
            Caption = 'Beschreibung 2';
        }
        field(80; Quantity; Decimal)
        {
            Caption = 'Menge';
        }
        field(90; "Unit of Measure"; Code[20])
        {
            Caption = 'Einheit';

            trigger OnLookup()
            begin
                ItemUnitofMeasure.SETRANGE("Item No.", Rec."Item No.");
                IF PAGE.RUNMODAL(0, ItemUnitofMeasure) = ACTION::LookupOK THEN
                    VALIDATE("Unit of Measure", ItemUnitofMeasure.Code);
            end;
        }
        field(100; "Customer No."; Code[20])
        {
            Caption = 'Debitornr.';
            TableRelation = Customer;
        }
        field(110; "Minimum Durability"; Date)
        {
            Caption = 'Mindesthaltbarkeit';
        }
        field(120; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
        }
        field(130; "Promised Delivery Date"; Date)
        {
            Caption = 'Promised Delivery Date';
            Editable = false;
        }
        field(140; Coli; Decimal)
        {
            Caption = 'Coli';
        }
        field(150; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(160; "Order No."; Code[20])
        {
            Caption = 'No.';
        }
    }

    keys
    {
        key(Key1; "User ID", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "User ID" := USERID;
    end;

    trigger OnModify()
    begin
        "User ID" := USERID;
    end;

    var
        Item: Record "Item";
        ItemUnitofMeasure: Record "5404";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ErrSalesOrderDoesntExist: Label 'Sales Order %1 does not exist!';
        ErrNoCustomerFound: Label 'Es gibt in diesem Mandanten keinen Debitor mit dem Namen %1 !';
        ErrNoSellToCustomerFound: Label 'Es gibt in diesem Mandanten keinen Debitor mit der Nummer %1 !';


    procedure AddLinesToSalesOrder(var SalesLineQuickEntry: Record "Sales Line Quick Entry"): Boolean
    var
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        SalesCalcDiscount: Codeunit "Sales-Calc. Discount";
        SalesHeaderUpdated: Boolean;
    begin
        IF NOT SalesHeader.GET(SalesHeader."Document Type"::Order, SalesLineQuickEntry."Document No.") THEN
            ERROR(ErrSalesOrderDoesntExist, SalesLineQuickEntry."Document No.");

        SalesHeader.TESTFIELD("Sell-to Customer No.");
        SalesHeaderUpdated := FALSE;

        IF SalesLineQuickEntry.FINDSET() THEN
            REPEAT
                SalesLine.INIT();
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := GetNextLineNo(SalesLine);
                IF SalesLine.INSERT(TRUE) THEN
                    SalesLineQuickEntry.MARK(TRUE);
                SalesLine.VALIDATE(Type, SalesLine.Type::Item);
                SalesLine.VALIDATE("No.", SalesLineQuickEntry."Item No.");
                IF (SalesLine."Description 2" = '') AND (SalesLineQuickEntry."Description 2" <> '') THEN
                    SalesLine."Description 2" := SalesLineQuickEntry."Description 2";
                InsertExtendedText(SalesLine, FALSE);
                SalesLine.VALIDATE(Quantity, SalesLineQuickEntry.Quantity);
                SalesLine.VALIDATE("Unit of Measure Code", SalesLineQuickEntry."Unit of Measure");
                SalesLine."Minimum Durability" := SalesLineQuickEntry."Minimum Durability";
                SalesLine."Shipment Date" := SalesLineQuickEntry."Shipment Date";
                SalesLine."Promised Delivery Date" := SalesLineQuickEntry."Promised Delivery Date";
                SalesLine.Coli := SalesLineQuickEntry.Coli;
                IF NOT SalesHeaderUpdated THEN BEGIN
                    IF SalesLineQuickEntry."External Document No." <> '' THEN
                        SalesHeader."External Document No." := SalesLineQuickEntry."External Document No.";
                    IF SalesLineQuickEntry."Order No." <> '' THEN
                        SalesHeader."Source Order No." := SalesLineQuickEntry."Order No.";
                    SalesHeader.MODIFY();
                    SalesHeaderUpdated := TRUE;
                END;
                IF SalesLine.MODIFY(TRUE) THEN;
            UNTIL SalesLineQuickEntry.NEXT() = 0;
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        IF SalesLine.FINDSET() THEN
            SalesCalcDiscount.Run(SalesLine);
        SalesCalcDiscountByType.ResetRecalculateInvoiceDisc(SalesHeader);
        SalesLineQuickEntry.MARKEDONLY(TRUE);
        SalesLineQuickEntry.DELETEALL();
        SalesLineQuickEntry.MARKEDONLY(FALSE);
        EXIT(SalesLineQuickEntry.COUNT = 0);
    end;


    procedure AddShipLinesFromOtherCompany(SalesLineQuickEntry: Record "Sales Line Quick Entry"): Boolean
    var
        ItemCrossReference: Record "Item Reference";
        CustomerMandant: Record "Customer";
        Customer: Record "Customer";
        CustomerItem: Record "Item";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesHeaderCompany: Record "Sales Header";
        PostedSalesShipments: Page "Posted Sales Shipments";
        ActualLineNo: Integer;
    begin
        IF NOT SalesHeader.GET(SalesHeader."Document Type"::Order, SalesLineQuickEntry."Document No.") THEN
            ERROR(ErrSalesOrderDoesntExist, SalesLineQuickEntry."Document No.");

        SalesHeader.TESTFIELD(Status, SalesHeader.Status::Open);
        SalesHeader.TESTFIELD("Source Company");
        SalesHeader.TESTFIELD("Sell-to Customer No.");

        CLEAR(PostedSalesShipments);
        PostedSalesShipments.LOOKUPMODE(TRUE);
        PostedSalesShipments.SetCompany(SalesHeader."Source Company");
        PostedSalesShipments.SETTABLEVIEW(SalesShipmentHeader);
        IF PostedSalesShipments.RUNMODAL() = ACTION::LookupOK THEN
            PostedSalesShipments.GETRECORD(SalesShipmentHeader);
        Rec.SETRANGE("User ID", USERID);
        Rec.SETRANGE("Document No.", SalesHeader."No.");
        IF Rec.FINDLAST() THEN
            ActualLineNo := "Line No.";
        Customer.SETRANGE("No.", SalesHeader."Sell-to Customer No.");
        IF NOT Customer.FINDFIRST() THEN
            ERROR(ErrNoSellToCustomerFound, SalesHeader."Sell-to Customer No.");
        CustomerMandant.SETFILTER(Name, '=%1', SalesHeader."Source Company");
        IF NOT CustomerMandant.FINDFIRST() THEN
            ERROR(ErrNoCustomerFound, SalesHeader."Source Company");
        SalesHeaderCompany.RESET();
        SalesHeaderCompany.CHANGECOMPANY(SalesHeader."Source Company");
        IF SalesHeaderCompany.GET(SalesHeaderCompany."Document Type"::Order, SalesShipmentHeader."Order No.") THEN;
        CustomerItem.CHANGECOMPANY(SalesHeader."Source Company");
        SalesShipmentLine.CHANGECOMPANY(SalesHeader."Source Company");
        SalesShipmentLine.SETRANGE(SalesShipmentLine."Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SETRANGE(Type, SalesShipmentLine.Type::Item);
        IF SalesShipmentLine.FINDSET() THEN
            REPEAT
                ActualLineNo += 10000;
                Rec.INIT();
                Rec."Document No." := SalesHeader."No.";
                Rec."Line No." := ActualLineNo;
                ItemCrossReference.RESET();
                ItemCrossReference.SETRANGE("Reference Type", ItemCrossReference."Reference Type"::Customer);
                ItemCrossReference.SETRANGE("Reference Type No.", Customer."No.");
                ItemCrossReference.SETRANGE("Reference No.", SalesShipmentLine."No.");
                IF ItemCrossReference.FINDFIRST() THEN BEGIN
                    Rec.VALIDATE("Item No.", ItemCrossReference."Item No.");
                    Rec."Unit of Measure" := ItemCrossReference."Unit of Measure";
                END ELSE BEGIN
                    ItemCrossReference.SETRANGE("Reference Type No.", CustomerMandant."No.");
                    IF ItemCrossReference.FINDFIRST() THEN BEGIN
                        Rec.VALIDATE("Item No.", ItemCrossReference."Item No.");
                        Rec."Unit of Measure" := ItemCrossReference."Unit of Measure";
                    END ELSE BEGIN
                        Rec.VALIDATE("Item No.", SalesShipmentLine."No.");
                        Rec."Unit of Measure" := '';
                    END;
                END;

                //DIC03:est.uki >>>
                IF Rec."Unit of Measure" = '' THEN BEGIN
                    IF CustomerItem.GET(SalesShipmentLine."No.") THEN
                        Rec."Unit of Measure" := CustomerItem."Base Unit of Measure";
                END;
                //DIC03:est.uki <<<

                Rec."Minimum Durability" := SalesShipmentLine."Minimum Durability";
                Rec.Quantity := SalesShipmentLine.Quantity;
                //Rec."Unit of Measure" := SalesShipmentLine."Unit of Measure";
                //Rec."Unit of Measure" := ItemCrossReference."Unit of Measure";

                //DIC02:est.uki >>>
                Rec."Shipment Date" := SalesShipmentLine."Shipment Date";
                Rec."Promised Delivery Date" := SalesShipmentLine."Promised Delivery Date";
                Rec.Coli := SalesShipmentLine.Coli;
                Rec."External Document No." := SalesHeaderCompany."External Document No.";
                Rec."Order No." := SalesShipmentHeader."Order No.";
                //DIC02:est.uki <<<

                Rec.INSERT(TRUE);
            UNTIL SalesShipmentLine.NEXT() = 0;

        CLEAR(PostedSalesShipments);
        EXIT(TRUE);
    end;

    local procedure GetNextLineNo(SalesLine: Record "Sales Line"): Integer
    var
        SalesLineCheck: Record "Sales Line";
    begin
        SalesLineCheck.RESET();
        SalesLineCheck.SETRANGE("Document Type", SalesLine."Document Type");
        SalesLineCheck.SETRANGE("Document No.", SalesLine."Document No.");
        IF SalesLineCheck.FINDLAST() THEN
            EXIT(SalesLineCheck."Line No." + 10000)
        ELSE
            EXIT(10000);
    end;


    procedure InsertExtendedText(SalesLine: Record "Sales Line"; Unconditionally: Boolean)
    var
        TransferExtendedText: Codeunit "378";
    begin
        IF TransferExtendedText.SalesCheckIfAnyExtText(SalesLine, Unconditionally) THEN BEGIN
            TransferExtendedText.InsertSalesExtText(SalesLine);
        END;
    end;
}

