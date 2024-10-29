tableextension 50122 "DIC Item Journal Line" extends "Item Journal Line"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Minimum Durability" hinzugefügt.
    //  - Feld 50078 "Coli" hinzugefügt.
    //  - Funktion "CopyFromSalesLine": (MOVE TO "DIC Event Subscriber")
    //    - Zuweisung von "Minimum Durability" (Mindesthaltbarkeit) hinzugefügt.
    //    - Zuweisung von "Coli" hinzugefügt.
    //  - Funktion "CopyFromPurchLine": (MOVE TO "DIC Event Subscriber")
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
}

