tableextension 50010 "DIC Purch. Inv. Line" extends "Purch. Inv. Line"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld hinzugefügt:
    //  - 50074 "Minimum Durability" (Mindesthaltbarkeit)
    // 
    fields
    {
        field(50074; "Minimum Durability"; Date)
        {
            Caption = 'Mindesthaltbarkeit';
        }
    }
}

