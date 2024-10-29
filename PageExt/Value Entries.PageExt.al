pageextension 50075 pageextension50075 extends "Value Entries"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld eingeblendet:
    //  - 50070 "Minimum Durability" (Mindesthaltbarkeit)
    //  - 50078 "Coli"
    layout
    {
        addlast(content)
        {
            field("Minimum Durability"; Rec."Minimum Durability")
            {
            }
            field(Coli; Rec.Coli)
            {
                DecimalPlaces = 0 : 0;
            }
            field("Sales Order No."; Rec."Sales Order No.")
            {
            }
            field("Shipment Date"; Rec."Shipment Date")
            {
            }
        }
    }
}

