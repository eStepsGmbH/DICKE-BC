pageextension 50117 pageextension50117 extends "Purchase Quote Subform"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld eingeblendet:
    //  - 50070 "Minimum Durability" (Mindesthaltbarkeit)
    layout
    {
        addafter("Gross Weight")
        {
            field("Minimum Durability"; "Minimum Durability")
            {
            }
        }
    }
}

