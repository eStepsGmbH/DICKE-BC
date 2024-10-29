tableextension 50011 "DIC Purch. Cr. Memo Line" extends "Purch. Cr. Memo Line"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld "Minimum Durability" (50074) hinzugefügt.
    fields
    {
        field(50074; "Minimum Durability"; Date)
        {
            Caption = 'Mindesthaltbarkeit';
        }
    }
}

