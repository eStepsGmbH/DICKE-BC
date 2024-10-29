pageextension 50066 pageextension50066 extends "Purchase Order Subform"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "VIO Creation Date" (VIO erstellt am) eingeblendet.
    //  - Feld 50071 "VIO" (VIO erstellen) eingeblendet.
    //  - Feld 50074 "Minimum Durability" (Mindesthaltbarkeit) eingeblendet.
    //  - Felder "Special Order Sales No." und "Special Order Sales Line No." eingeblendet.
    layout
    {
        addafter("Net Weight")
        {
            field("Minimum Durability"; "Minimum Durability")
            {
            }
            field("VIO Creation Date"; "VIO Creation Date")
            {
            }
            field(VIO; VIO)
            {
            }
            field("Special Order Sales No."; "Special Order Sales No.")
            {
                Visible = false;
            }
            field("Special Order Sales Line No."; "Special Order Sales Line No.")
            {
                Visible = false;
            }
        }
    }
}

