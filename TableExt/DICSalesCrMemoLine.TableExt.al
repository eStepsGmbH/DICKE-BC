tableextension 50006 "DIC Sales Cr.Memo Line" extends "Sales Cr.Memo Line"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Minimum Durability" hinzugefügt.
    //  - Feld 50078 "Coli" hinzugefügt.
    //  Feld 11 "Description" von 50 auf 100 Zeichen erweitert.
    fields
    {

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

