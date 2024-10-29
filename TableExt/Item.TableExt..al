tableextension 50036 tableextension50036 extends Item
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Fat Content %" (Fettgehalt in %)
    //  - Feld 50071 "Purchasing Code" (Einkaufscode)
    //  - Feld 50072 "Last Price Update" (Letzte Preisaktulaisierung)
    //  - Feld 50073 "Assortment" (Sortiment)
    //  - Feld 50074 "Presentation" (Warenpräsentation)
    //  - Feld50075"Milk Use"
    //  - Feld50076"EAN13"
    //  - Feld50077"EAN128"
    //  - Feld 21 "Costing Method" - Property "InitValue" auf STANDARD gesetzt.
    //  - Fieldgroup erweitert: Feld "SearchName" hinzugefügt.
    fields
    {

        //Unsupported feature: Property Insertion (InitValue) on ""Costing Method"(Field 21)".

        field(50070; "Fat Content %"; Decimal)
        {
            Caption = 'Fettgehalt in %';
        }
        // field(50071; "Purchasing Code"; Code[10]) // TODO: Microsoft Feld
        // {
        //     Caption = 'Purchasing Code';
        //     TableRelation = Purchasing;
        // }
        field(50072; "Last Price Update"; Date)
        {
            Caption = 'Letzte Preisaktulaisierung';
        }
        field(50073; Assortment; Option)
        {
            Caption = 'Sortiment';
            OptionMembers = "0","10","20","30","40","50","60";
        }
        field(50074; Presentation; Option)
        {
            Caption = 'Warenpräsentation';
            OptionMembers = "0","10","20","30";
        }
        field(50075; "Milk Use"; Option)
        {
            Caption = 'Milchbehandlung';
            OptionMembers = "0","10","20","30";
        }
        field(50076; EAN13; Code[15])
        {
            Caption = 'EAN 13';
        }
        field(50077; EAN128; Code[15])
        {
            Caption = 'EAN 128';
        }
    }


    //Unsupported feature: Code Modification on "OnInsert".

    //trigger OnInsert()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    IF "No." = '' THEN
      IF DocumentNoVisibility.ItemNoSeriesIsDefault THEN BEGIN
        GetInvtSetup;
        NoSeriesMgt.InitSeries(InvtSetup."Item Nos.",xRec."No. Series",0D,"No.","No. Series");
      END;

    DimMgt.UpdateDefaultDim(
      DATABASE::Item,"No.",
      "Global Dimension 1 Code","Global Dimension 2 Code");

    SetLastDateTimeModified;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    IF "No." = '' THEN BEGIN
      GetInvtSetup;
      InvtSetup.TESTFIELD("Item Nos.");
      NoSeriesMgt.InitSeries(InvtSetup."Item Nos.",xRec."No. Series",0D,"No.","No. Series");
    END;
    #6..11
    */
    //end;

    //Unsupported feature: Variable Insertion (Variable: PurchaseLine) (VariableCollection) on "TestNoEntriesExist(PROCEDURE 1006)".



    //Unsupported feature: Code Modification on "TestNoEntriesExist(PROCEDURE 1006)".

    //procedure TestNoEntriesExist();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    IF "No." = '' THEN
      EXIT;

    #4..7
        Text007,
        CurrentFieldName);

    PurchOrderLine.SETCURRENTKEY("Document Type",Type,"No.");
    PurchOrderLine.SETFILTER(
      "Document Type",'%1|%2',
      PurchOrderLine."Document Type"::Order,
      PurchOrderLine."Document Type"::"Return Order");
    PurchOrderLine.SETRANGE(Type,PurchOrderLine.Type::Item);
    PurchOrderLine.SETRANGE("No.","No.");
    IF PurchOrderLine.FINDFIRST THEN
      ERROR(
        Text008,
        CurrentFieldName,
        PurchOrderLine."Document Type");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..10
    PurchaseLine.SETCURRENTKEY("Document Type",Type,"No.");
    PurchaseLine.SETFILTER(
      "Document Type",'%1|%2',
      PurchaseLine."Document Type"::Order,
      PurchaseLine."Document Type"::"Return Order");
    PurchaseLine.SETRANGE(Type,PurchaseLine.Type::Item);
    PurchaseLine.SETRANGE("No.","No.");
    IF PurchaseLine.FINDFIRST THEN
    #19..21
        PurchaseLine."Document Type");
    */
    //end;


    //Unsupported feature: Code Modification on "CheckDocuments(PROCEDURE 23)".

    //procedure CheckDocuments();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    CheckBOM(CurrFieldNo);
    CheckPurchLine(CurrFieldNo);
    CheckSalesLine(CurrFieldNo);
    #4..10
    CheckAsmHeader(CurrFieldNo);
    CheckAsmLine(CurrFieldNo);
    CheckJobPlanningLine(CurrFieldNo);
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    IF "No." = '' THEN
      EXIT;

    #1..13
    */
    //end;

    //Unsupported feature: Variable Insertion (Variable: PurchaseLine) (VariableCollection) on "CheckPurchLine(PROCEDURE 26)".



    //Unsupported feature: Code Modification on "CheckPurchLine(PROCEDURE 26)".

    //procedure CheckPurchLine();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    PurchOrderLine.SETCURRENTKEY(Type,"No.");
    PurchOrderLine.SETRANGE(Type,PurchOrderLine.Type::Item);
    PurchOrderLine.SETRANGE("No.","No.");
    IF NOT PurchOrderLine.ISEMPTY THEN BEGIN
      IF CurrFieldNo = 0 THEN
        ERROR(Text000,TABLECAPTION,"No.",PurchOrderLine."Document Type");
      IF CurrFieldNo = FIELDNO(Type) THEN
        ERROR(CannotChangeFieldErr,FIELDCAPTION(Type),TABLECAPTION,"No.",PurchOrderLine.TABLECAPTION);
    END;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    PurchaseLine.SETCURRENTKEY(Type,"No.");
    PurchaseLine.SETRANGE(Type,PurchaseLine.Type::Item);
    PurchaseLine.SETRANGE("No.","No.");
    IF PurchaseLine.FINDFIRST THEN BEGIN
      IF CurrFieldNo = 0 THEN
        ERROR(Text000,TABLECAPTION,"No.",PurchaseLine."Document Type");
      IF CurrFieldNo = FIELDNO(Type) THEN
        ERROR(CannotChangeFieldErr,FIELDCAPTION(Type),TABLECAPTION,"No.",PurchaseLine.TABLECAPTION);
    END;
    */
    //end;

    //Unsupported feature: Variable Insertion (Variable: SalesLine) (VariableCollection) on "CheckSalesLine(PROCEDURE 28)".



    //Unsupported feature: Code Modification on "CheckSalesLine(PROCEDURE 28)".

    //procedure CheckSalesLine();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    SalesOrderLine.SETCURRENTKEY(Type,"No.");
    SalesOrderLine.SETRANGE(Type,SalesOrderLine.Type::Item);
    SalesOrderLine.SETRANGE("No.","No.");
    IF NOT SalesOrderLine.ISEMPTY THEN BEGIN
      IF CurrFieldNo = 0 THEN
        ERROR(Text001,TABLECAPTION,"No.",SalesOrderLine."Document Type");
      IF CurrFieldNo = FIELDNO(Type) THEN
        ERROR(CannotChangeFieldErr,FIELDCAPTION(Type),TABLECAPTION,"No.",SalesOrderLine.TABLECAPTION);
    END;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    SalesLine.SETCURRENTKEY(Type,"No.");
    SalesLine.SETRANGE(Type,SalesLine.Type::Item);
    SalesLine.SETRANGE("No.","No.");
    IF SalesLine.FINDFIRST THEN BEGIN
      IF CurrFieldNo = 0 THEN
        ERROR(Text001,TABLECAPTION,"No.",SalesLine."Document Type");
      IF CurrFieldNo = FIELDNO(Type) THEN
        ERROR(CannotChangeFieldErr,FIELDCAPTION(Type),TABLECAPTION,"No.",SalesLine.TABLECAPTION);
    END;
    */
    //end;

    //Unsupported feature: Variable Insertion (Variable: ProductionBOMVersion) (VariableCollection) on "CheckProdBOMLine(PROCEDURE 30)".



    //Unsupported feature: Code Modification on "CheckProdBOMLine(PROCEDURE 30)".

    //procedure CheckProdBOMLine();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    ProdBOMLine.RESET;
    ProdBOMLine.SETCURRENTKEY(Type,"No.");
    ProdBOMLine.SETRANGE(Type,ProdBOMLine.Type::Item);
    #4..10
             (ProdBOMHeader.Status = ProdBOMHeader.Status::Certified)
          THEN
            ERROR(Text004,TABLECAPTION,"No.");
        UNTIL ProdBOMLine.NEXT = 0;
    END;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..13
          IF ProductionBOMVersion.GET(ProdBOMLine."Production BOM No.",ProdBOMLine."Version Code") AND
             (ProductionBOMVersion.Status = ProductionBOMVersion.Status::Certified)
          THEN
            ERROR(CannotDeleteItemIfProdBOMVersionExistsErr,TABLECAPTION,"No.");
        UNTIL ProdBOMLine.NEXT = 0;
    END;
    */
    //end;

    //Unsupported feature: Property Modification (Fields) on "DropDown(FieldGroup 1)".


    var
        CannotDeleteItemIfProdBOMVersionExistsErr: Label 'You cannot delete %1 %2 because there are one or more certified production BOM version that include this item.', Comment = '%1 - Tablecaption, %2 - No.';
}

