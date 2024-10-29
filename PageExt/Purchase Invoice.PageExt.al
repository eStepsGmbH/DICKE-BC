pageextension 50062 pageextension50062 extends "Purchase Invoice"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld "Vendor Shipment No." auf Reiter "Allgemein" eingeblendet.
    layout
    {
        addafter("Bank Code")
        {
            field("Vendor Shipment No."; "Vendor Shipment No.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}

