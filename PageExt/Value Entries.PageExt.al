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
            field("Minimum Durability"; "Minimum Durability")
            {
            }
            field(Coli; Coli)
            {
                DecimalPlaces = 0 : 0;
            }
            field("Sales Order No."; "Sales Order No.")
            {
            }
            field("Shipment Date"; "Shipment Date")
            {
            }
        }
    }
}

