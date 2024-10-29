pageextension 50053 pageextension50053 extends "Purchases & Payables Setup"
{
    layout
    {
        addafter(Control1900383207)
        {
            group(Dicke)
            {
                Caption = 'Dicke';
                field("Check Post Order In Base Unit"; "Check Post Order In Base Unit")
                {
                }
            }
        }
    }
}

