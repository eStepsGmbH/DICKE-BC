pageextension 50064 pageextension50064 extends "Sales Lines"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld eingeblendet:
    //  - 50070 "Minimum Durability" (Mindesthaltbarkeit)
    layout
    {
        addafter(Description)
        {
            field("Minimum Durability"; "Minimum Durability")
            {
            }
        }
    }
}

