tableextension 50003 tableextension50003 extends "Sales Shipment Line"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Minimum Durability" hinzugefügt.
    //  - Feld 50078 "Coli" hinzugefügt.
    //  - Funktion "InsertInvLineFromShptLine": Code angepasst.
    //  - Feld 11 "Description" von 50 auf 100 Zeichen erweitert.
    //  - Funktion "SetInsertInvLineFromShptLineParameters" hinzugefügt
    fields
    {

        //Unsupported feature: Property Modification (Data type) on "Description(Field 11)".

        field(50070; "Minimum Durability"; Date)
        {
            Caption = 'Mindesthaltbarkeit';
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

    //Unsupported feature: Variable Insertion (Variable: LanguageManagement) (VariableCollection) on "InsertInvLineFromShptLine(PROCEDURE 2)".


    //Unsupported feature: Variable Insertion (Variable: SalesOrderTextLine) (VariableCollection) on "InsertInvLineFromShptLine(PROCEDURE 2)".


    //Unsupported feature: Variable Insertion (Variable: SalesHeaderTextLine) (VariableCollection) on "InsertInvLineFromShptLine(PROCEDURE 2)".



    //Unsupported feature: Code Modification on "InsertInvLineFromShptLine(PROCEDURE 2)".

    //procedure InsertInvLineFromShptLine();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    SETRANGE("Document No.","Document No.");

    TempSalesLine := SalesLine;
    #4..13
      SalesLine."Line No." := NextLineNo;
      SalesLine."Document Type" := TempSalesLine."Document Type";
      SalesLine."Document No." := TempSalesLine."Document No.";
      SalesLine.Description := STRSUBSTNO(Text000,"Document No.");
      SalesLine.INSERT;
      NextLineNo := NextLineNo + 10000;
    END;

    TransferOldExtLines.ClearLineNumbers;

    REPEAT
    #25..84
      SalesLine."Appl.-from Item Entry" := 0;
      IF NOT ExtTextLine AND (SalesLine.Type <> 0) THEN BEGIN
        SalesLine.VALIDATE(Quantity,Quantity - "Quantity Invoiced");
        SalesLine.VALIDATE("Unit Price",SalesOrderLine."Unit Price");
        SalesLine."Allow Line Disc." := SalesOrderLine."Allow Line Disc.";
        SalesLine."Allow Invoice Disc." := SalesOrderLine."Allow Invoice Disc.";
    #91..141
      SalesOrderHeader."Get Shipment Used" := TRUE;
      SalesOrderHeader.MODIFY;
    END;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..16
      LanguageManagement.SetGlobalLanguageByCode(SalesInvHeader."Language Code");
      SalesLine.Description := STRSUBSTNO(Text000,"Document No.");
      LanguageManagement.RestoreGlobalLanguage;

      // Dicke >>>
      IF (HideShipmentTextLine) THEN
        SalesLine.Description := '';
      // Dicke <<<
    #18..21
    //DICKE >>>
    IF CopyTextLinesFromOrder THEN BEGIN
      //Externe Belenummer als erste Zeile einfügen
      IF SalesHeaderTextLine.GET(SalesHeaderTextLine."Document Type"::Order,"Order No.") THEN BEGIN
        IF SalesHeaderTextLine."External Document No." <> '' THEN BEGIN
          SalesLine.INIT;
          SalesLine."Line No." := NextLineNo;
          SalesLine."Document Type" := TempSalesLine."Document Type";
          SalesLine."Document No." := TempSalesLine."Document No.";
          SalesLine.Description := STRSUBSTNO(ExtOrderNoTextLine,SalesHeaderTextLine."External Document No.");
          SalesLine.INSERT;
          NextLineNo := NextLineNo + 10000;
        END;
      END;

      //Textzeilen aus dem Auftrag holen
      SalesOrderTextLine.RESET;
      SalesOrderTextLine.SETRANGE("Document Type", SalesOrderTextLine."Document Type"::Order);
      SalesOrderTextLine.SETRANGE("Document No.","Order No.");
      IF SalesOrderTextLine.FINDFIRST THEN REPEAT
        IF (SalesOrderTextLine.Type = 0) THEN BEGIN
          SalesLine.INIT;
          SalesLine."Line No." := NextLineNo;
          SalesLine."Document Type" := TempSalesLine."Document Type";
          SalesLine."Document No." := TempSalesLine."Document No.";
          SalesLine.Description := SalesOrderTextLine.Description;
          SalesLine."Description 2" := SalesOrderTextLine."Description 2";
          SalesLine.INSERT;
          NextLineNo := NextLineNo + 10000;
        END;
      UNTIL (SalesOrderTextLine.Type <> 0) OR (SalesOrderTextLine.NEXT = 0);
    END;
    //DICKE <<<

    #22..87
        CalcBaseQuantities(SalesLine,"Quantity (Base)" / Quantity);
    #88..144
    */
    //end;

    procedure SetInsertInvLineFromShptLineParameters(CopyTextLinesFromOrder_par: Boolean; HideShipmentTextLine_par: Boolean)
    begin
        // DICKE >>>
        CopyTextLinesFromOrder := CopyTextLinesFromOrder_par;
        HideShipmentTextLine := HideShipmentTextLine_par;
        // DICKE <<<
    end;

    local procedure CalcBaseQuantities(var SalesLine: Record "Sales Line"; QtyFactor: Decimal)
    begin
        SalesLine."Quantity (Base)" := ROUND(SalesLine.Quantity * QtyFactor, 0.00001);
        SalesLine."Qty. to Asm. to Order (Base)" := ROUND(SalesLine."Qty. to Assemble to Order" * QtyFactor, 0.00001);
        SalesLine."Outstanding Qty. (Base)" := ROUND(SalesLine."Outstanding Quantity" * QtyFactor, 0.00001);
        SalesLine."Qty. to Ship (Base)" := ROUND(SalesLine."Qty. to Ship" * QtyFactor, 0.00001);
        SalesLine."Qty. Shipped (Base)" := ROUND(SalesLine."Quantity Shipped" * QtyFactor, 0.00001);
        SalesLine."Qty. Shipped Not Invd. (Base)" := ROUND(SalesLine."Qty. Shipped Not Invoiced" * QtyFactor, 0.00001);
        SalesLine."Qty. to Invoice (Base)" := ROUND(SalesLine."Qty. to Invoice" * QtyFactor, 0.00001);
        SalesLine."Qty. Invoiced (Base)" := ROUND(SalesLine."Quantity Invoiced" * QtyFactor, 0.00001);
        SalesLine."Return Qty. to Receive (Base)" := ROUND(SalesLine."Return Qty. to Receive" * QtyFactor, 0.00001);
        SalesLine."Return Qty. Received (Base)" := ROUND(SalesLine."Return Qty. Received" * QtyFactor, 0.00001);
        SalesLine."Ret. Qty. Rcd. Not Invd.(Base)" := ROUND(SalesLine."Return Qty. Rcd. Not Invd." * QtyFactor, 0.00001);
    end;

    var
        CopyTextLinesFromOrder: Boolean;
        HideShipmentTextLine: Boolean;
        ExtOrderNoTextLine: Label 'Ext. Order No.: %1';
}

