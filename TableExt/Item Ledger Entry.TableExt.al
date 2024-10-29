tableextension 50043 tableextension50043 extends "Item Ledger Entry"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Minimum Durability" hinzugefügt.
    //  - Feld 50078 "Coli" hinzugefügt.
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

