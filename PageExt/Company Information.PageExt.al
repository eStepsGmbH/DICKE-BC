pageextension 50001 pageextension50001 extends "Company Information"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Reiter "Dicke Food" hinzugefügt.
    //  Felder hinzugefügt:
    //    - 50001 Company Type
    //    - 50002 Company Leader
    //    -      3   Name 2
    //    -  50073   Jurisdiction
    layout
    {
        addafter("Name")
        {
            field("Name 2"; Rec."Name 2")
            {
            }
        }
        addlast("content")
        {
            group("Dicke Food")
            {
                Caption = 'Dicke Food';
                field("Company Type"; Rec."Company Type")
                {
                }
                field("Company Leader"; Rec."Company Leader")
                {
                }
                field(Jurisdiction; Rec.Jurisdiction)
                {
                }
            }
        }
    }
}

