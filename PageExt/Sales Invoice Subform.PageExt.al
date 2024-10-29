pageextension 50054 pageextension50054 extends "Sales Invoice Subform"
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
            field("Minimum Durability"; Rec."Minimum Durability")
            {
            }
            field(Coli; Rec.Coli)
            {
                DecimalPlaces = 0 : 0;
            }
        }
    }
}

