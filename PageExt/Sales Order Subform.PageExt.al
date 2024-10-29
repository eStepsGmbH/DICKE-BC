pageextension 50052 pageextension50052 extends "Sales Order Subform"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Funktion "OnAfterGetRecord": Code erweitert.
    //  Felder eingeblendet:
    //  - "Special Order Purchase No."
    //  - 50070 "Minimum Durability" (Mindesthaltbarkeit)
    //  - 50071 "Base Unit of Measure Code" (Basiseinheitencode)
    //  - 50072 "Base Unit Price" (Basiseinheiten VK-Preis
    //  - 50073 "Base Unit Quantity" (Basiseinheiten Menge
    //  - 50074 "GUO Receive Date" (GUO verarbeitet am)
    //  - 50075 "EDI Send Date" (EDI gesendet amDate)
    //  - 50076 "EDI Receive Date"(EDI empfangen amDate)
    //  - 50077 "Base Unit Quantity (Original)"(Basiseinheiten Menge (Ursprung))
    //  - 50078 "Coli"
    //  - Diff. Qty (Abw. Menge) - Wird in "OnAfterGetRecord" berechnet.
    // 
    // DIC01 14.12.2021         Add field: "External Document Pos. No."
    layout
    {
        addafter(Control1)
        {
            field(DiffQty; DiffQty)
            {
                Caption = 'Diff. Qty.';
            }
        }
        addafter(Control1)
        {
            field("Minimum Durability"; Rec."Minimum Durability")
            {
            }
            field(Coli; Rec.Coli)
            {
                DecimalPlaces = 0 : 0;
            }
            field("Base Unit of Measure Code"; Rec."Base Unit of Measure Code")
            {
            }
            field("Base Unit Price"; Rec."Base Unit Price")
            {
            }
            field("Base Unit Quantity"; Rec."Base Unit Quantity")
            {
            }
            field("GUO Receive Date"; Rec."GUO Receive Date")
            {
            }
            field("EDI Send Date"; Rec."EDI Send Date")
            {
            }
            field("EDI Receive Date"; Rec."EDI Receive Date")
            {
            }
            field("Base Unit Quantity (Original)"; Rec."Base Unit Quantity (Original)")
            {
            }
            field("Special Order Purchase No."; Rec."Special Order Purchase No.")
            {
                Caption = 'Special Order Purchase No.';
            }
            field("External Document Pos. No."; Rec."External Document Pos. No.")
            {
                Visible = false;
            }
        }
    }

    var
        DiffQty: Decimal;


    //Unsupported feature: Code Modification on "OnAfterGetRecord".

    //trigger OnAfterGetRecord()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    ShowShortcutDimCode(ShortcutDimCode);
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    ShowShortcutDimCode(ShortcutDimCode);

    // Dicke >>>
    IF ( ("GUO Receive Date" <> 0D) AND ("Base Unit Quantity (Original)" <> 0) ) THEN
      DiffQty := Quantity - "Base Unit Quantity (Original)"
    ELSE
      DiffQty := 0;
    // Dicke <<<
    */
    //end;
}

