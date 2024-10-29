pageextension 50062 pageextension50062 extends "Purchase Invoice"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld "Vendor Shipment No." auf Reiter "Allgemein" eingeblendet.
    layout
    {
        addlast(General)
        {
            field("Vendor Shipment No."; Rec."Vendor Shipment No.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}

