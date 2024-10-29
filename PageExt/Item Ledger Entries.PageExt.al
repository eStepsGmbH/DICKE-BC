pageextension 50042 pageextension50042 extends "Item Ledger Entries"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld eingeblendet:
    //  - 50070 "Minimum Durability" (Mindesthaltbarkeit)
    //  - 50078 "Coli"
    layout
    {
        addafter("Description")
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

