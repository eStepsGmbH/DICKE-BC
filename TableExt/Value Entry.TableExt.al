tableextension 50099 tableextension50099 extends "Value Entry"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Minimum Durability" hinzugefügt.
    //  - Feld 50078 "Coli" hinzugefügt.
    //  - Feld 50079 "Source No. 2" hinzugefügt.
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
        field(50079; "Source No. 2"; Code[20])
        {
            Caption = 'Herkunftsnr. 2';
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

