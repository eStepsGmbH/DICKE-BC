tableextension 50004 tableextension50004 extends "Sales Invoice Header"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Feld 50071 "Print Shipment Info On Invoice" hinzugefügt.
    // 
    fields
    {
        field(50071; "Print Shipment Info On Invoice"; Boolean)
        {
            Caption = 'Drucken Lieferscheininfo';
            InitValue = true;
        }
    }
}

