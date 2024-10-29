pageextension 50011 pageextension50011 extends "Posted Sales Shpt. Subform"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld eingeblendet:
    //  - 50070 "Minimum Durability" (Mindesthaltbarkeit)
    //  - 50078 "Coli"
    layout
    {
        addafter("Gross Weight")
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

