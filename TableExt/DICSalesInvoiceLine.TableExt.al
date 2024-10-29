tableextension 50005 "DIC Sales Invoice Line" extends "Sales Invoice Line"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Minimum Durability" hinzugefügt.
    //  - Feld 50078 "Coli" hinzugefügt.
    //  Feld 11 "Description" von 50 auf 100 Zeichen erweitert.
    fields
    {

        //Unsupported feature: Property Modification (Data type) on "Description(Field 11)".

        field(50070; "Minimum Durability"; Date)
        {
            Caption = 'Mindesthaltbarkeit';
        }
        field(50078; Coli; Decimal)
        {
            Caption = 'Coli';
        }
    }
}

