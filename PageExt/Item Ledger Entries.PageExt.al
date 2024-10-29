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

