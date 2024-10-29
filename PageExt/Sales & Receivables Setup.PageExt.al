pageextension 50051 pageextension50051 extends "Sales & Receivables Setup"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Reiter "Dicke Food" hinzugefügt.
    //  - Feld 50070"VIO Export Path" hinzugefügt.
    //  - Feld 50071"VUO Export Path" hinzugefügt.
    //  - Feld 50072"Check Post Order In Base Unit" hinzugefügt.
    //  - Feld 50073"NVE Nos." hinzugefügt.
    //  - Feld 50074"GLN No." hinzugefügt.
    //  - Feld 50075"EDI Orders Nos." hinzugefügt.
    //  - Feld 50076"EDI Orders Export Path" hinzugefügt.
    //  - Feld 50077"EDI Import Booking Tolerance" hinzugefügt.
    // 
    //  No.   Date       Version Changes
    //  --------------------------------------------------------------------------------
    //  DIC01 06.08.2020 17.2.01 Add Field:
    //                             - "GUO Import Processing"
    //                             - "EDI Import Processing"
    //                             - "EDI Import Vendor No"
    layout
    {
        addafter(Control1900383207)
        {
            group("Dicke Food")
            {
                Caption = 'Dicke Food';
                field("VIO Export Path"; Rec."VIO Export Path")
                {
                }
                field("VUO Export Path"; Rec."VUO Export Path")
                {
                }
                field("GUO Import Processing"; Rec."GUO Import Processing")
                {
                }
                field("Check Post Order In Base Unit"; Rec."Check Post Order In Base Unit")
                {
                }
                field("NVE Nos."; Rec."NVE Nos.")
                {
                }
                field("GLN No."; Rec."GLN No.")
                {
                }
                field("EDI Orders Nos."; Rec."EDI Orders Nos.")
                {
                }
                field("EDI Orders Export Path"; Rec."EDI Orders Export Path")
                {
                }
                field("EDI Import Booking Tolerance"; Rec."EDI Import Booking Tolerance")
                {
                }
                field("EDI Import Processing"; Rec."EDI Import Processing")
                {
                }
                field("EDI Import Vendor No"; Rec."EDI Import Vendor No")
                {
                }
            }
        }
    }
}

