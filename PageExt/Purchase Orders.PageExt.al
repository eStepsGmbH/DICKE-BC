pageextension 50069 pageextension50069 extends "Purchase Orders"
{
    layout
    {
        addlast(content)
        {
            field("Qty. to Receive"; Rec."Qty. to Receive")
            {
            }
            field("Qty. to Invoice"; Rec."Qty. to Invoice")
            {
            }
        }
    }
}

