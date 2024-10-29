pageextension 50116 pageextension50116 extends "Sales Cr. Memo Subform"
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

