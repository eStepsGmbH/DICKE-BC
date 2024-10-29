pageextension 50118 pageextension50118 extends "Purch. Cr. Memo Subform"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld "Minimum Durability" hinzugefügt.
    layout
    {
        addafter("Gross Weight")
        {
            field("Minimum Durability"; Rec."Minimum Durability")
            {
            }
        }
    }
}

