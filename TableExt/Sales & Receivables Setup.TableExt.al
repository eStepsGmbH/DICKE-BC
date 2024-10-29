tableextension 50041 tableextension50041 extends "Sales & Receivables Setup"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
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
    //                             - "EDI Import Vendor No"
    //                             - "EDI Import Processing"
    fields
    {
        field(50070; "VIO Export Path"; Text[250])
        {
            Caption = 'VIO Export-Pfadangabe';
        }
        field(50071; "VUO Export Path"; Text[250])
        {
            Caption = 'VUO Export-Pfadangabe';
        }
        field(50072; "Check Post Order In Base Unit"; Boolean)
        {
            Caption = 'Aufträge in Basiseinheit buchen';
        }
        field(50073; "NVE Nos."; Code[10])
        {
            Caption = 'Posted Shipment Nos.';
            TableRelation = "No. Series";
        }
        field(50074; "GLN No."; Code[7])
        {
            Caption = 'GLN/ILN-Nr.';
        }
        field(50075; "EDI Orders Nos."; Code[10])
        {
            Caption = 'Posted Shipment Nos.';
            TableRelation = "No. Series";
        }
        field(50076; "EDI Orders Export Path"; Text[250])
        {
            Caption = 'EDI Export-Pfadangabe';
        }
        field(50077; "EDI Import Booking Tolerance"; Decimal)
        {
            Caption = 'EDI Import Buchungstoleranz';
        }
        field(50078; "GUO Import Processing"; Option)
        {
            Caption = 'GUO Import Processing';
            InitValue = Sales;
            OptionCaption = 'Sales,Sales and Purchase';
            OptionMembers = Sales,"Sales and Purchase";
        }
        field(50079; "EDI Import Vendor No"; Code[20])
        {
            Caption = 'EDI Import Kreditor Nr.';
            TableRelation = Vendor;
        }
        field(50080; "EDI Import Processing"; Option)
        {
            Caption = 'GUO Import Processing';
            InitValue = Sales;
            OptionCaption = 'Sales,Sales and Purchase';
            OptionMembers = Sales,"Sales and Purchase";
        }
    }
}

