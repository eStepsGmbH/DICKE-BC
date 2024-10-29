#pragma implicitwith disable
pageextension 50016 pageextension50016 extends "Posted Sales Cr. Memo Subform"
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


#pragma implicitwith restore