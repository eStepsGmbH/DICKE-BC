pageextension 50014 pageextension50014 extends "Posted Sales Invoice Subform"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld eingeblendet:
    //  - 50070 "Minimum Durability" (Mindesthaltbarkeit)
    //  - 50078 "Coli"
    layout
    {
        addafter("Net Weight")
        {
            field("Minimum Durability"; "Minimum Durability")
            {
            }
            field(Coli; Coli)
            {
                DecimalPlaces = 0 : 0;
            }
        }
    }
}

