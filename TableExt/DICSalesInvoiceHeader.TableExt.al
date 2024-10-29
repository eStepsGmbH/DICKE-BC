tableextension 50004 "DIC Sales Invoice Header" extends "Sales Invoice Header"
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

