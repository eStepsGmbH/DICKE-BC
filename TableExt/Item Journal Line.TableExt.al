tableextension 50122 tableextension50122 extends "Item Journal Line"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Minimum Durability" hinzugefügt.
    //  - Feld 50078 "Coli" hinzugefügt.
    //  - Funktion "CopyFromSalesLine":
    //    - Zuweisung von "Minimum Durability" (Mindesthaltbarkeit) hinzugefügt.
    //    - Zuweisung von "Coli" hinzugefügt.
    //  - Funktion "CopyFromPurchLine":
    //    - Zuweisung von "Minimum Durability" (Mindesthaltbarkeit) hinzugefügt.
    fields
    {
        field(50070; "Minimum Durability"; Date)
        {
            Caption = 'Mindesthaltbarkeit';
        }
        field(50078; Coli; Decimal)
        {
            Caption = 'Coli';
        }
        field(50080; "Sales Order No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = "Sales Header"."No.";
        }
        field(50081; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
        }
    }


    //Unsupported feature: Code Modification on "CopyFromSalesLine(PROCEDURE 12)".

    //procedure CopyFromSalesLine();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    "Item No." := SalesLine."No.";
    Description := SalesLine.Description;
    "Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
    #4..35
    "Source Type" := "Source Type"::Customer;
    "Source No." := SalesLine."Sell-to Customer No.";
    "Invoice-to Source No." := SalesLine."Bill-to Customer No.";
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..38
    // Dicke >>>
    "Minimum Durability" := SalesLine."Minimum Durability";
    Coli := SalesLine.Coli;
    "Sales Order No." := SalesLine."Document No.";
    "Shipment Date" := SalesLine."Shipment Date";
    // Dicke <<<
    */
    //end;


    //Unsupported feature: Code Modification on "CopyFromPurchLine(PROCEDURE 160)".

    //procedure CopyFromPurchLine();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    "Item No." := PurchLine."No.";
    Description := PurchLine.Description;
    "Shortcut Dimension 1 Code" := PurchLine."Shortcut Dimension 1 Code";
    #4..41
    "Indirect Cost %" := PurchLine."Indirect Cost %";
    "Overhead Rate" := PurchLine."Overhead Rate";
    "Return Reason Code" := PurchLine."Return Reason Code";
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..44
    // Dicke >>>
    "Minimum Durability" := PurchLine."Minimum Durability";
    // Dicke <<<
    */
    //end;
}

