pageextension 50050 pageextension50050 extends "Sales List"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Felder eingeblendet:
    //  - 50070 "VUO Creation Date"
    // 
    layout
    {
        addafter(Control1)
        {
            field("VUO Creation Date"; Rec."VUO Creation Date")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
}

