pageextension 50067 pageextension50067 extends "Purch. Invoice Subform"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50074 "Minimum Durability" (Mindesthaltbarkeit) eingeblendet.
    layout
    {
        addafter("Net Weight")
        {
            field("Minimum Durability"; Rec."Minimum Durability")
            {
            }
        }
    }
}

