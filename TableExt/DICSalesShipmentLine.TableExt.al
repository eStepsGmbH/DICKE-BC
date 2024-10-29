tableextension 50003 "DIC Sales Shipment Line" extends "Sales Shipment Line"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Minimum Durability" hinzugefügt.
    //  - Feld 50078 "Coli" hinzugefügt.
    //  - Funktion "InsertInvLineFromShptLine": Code angepasst.
    //  - Feld 11 "Description" von 50 auf 100 Zeichen erweitert.
    //  - Funktion "SetInsertInvLineFromShptLineParameters" hinzugefügt
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
        field(50079; "External Document Pos. No."; Code[35])
        {
            Caption = 'Externe Beleg Pos. Nr.';
        }
    }

    procedure SetInsertInvLineFromShptLineParameters(CopyTextLinesFromOrder_par: Boolean; HideShipmentTextLine_par: Boolean)
    begin
        CopyTextLinesFromOrder := CopyTextLinesFromOrder_par;
        HideShipmentTextLine := HideShipmentTextLine_par;
    end;

    var
        CopyTextLinesFromOrder: Boolean;
        HideShipmentTextLine: Boolean;

}

