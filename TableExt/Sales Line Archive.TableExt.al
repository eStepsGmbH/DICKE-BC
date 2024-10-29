tableextension 50056 tableextension50056 extends "Sales Line Archive"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Felder hinzugefügt:
    //  - 50070 "Minimum Durability" (Mindesthaltbarkeit)
    //  - 50071 "Base Unit of Measure Code" (Basiseinheitencode)
    //  - 50072 "Base Unit Price" (Basiseinheiten VK-Preis
    //  - 50073 "Base Unit Quantity" (Basiseinheiten Menge
    //  - 50074 "GUO Receive Date" (GUO verarbeitet am)
    //  - 50075 "EDI Send Date" (EDI gesendet amDate)
    //  - 50076 "EDI Receive Date"(EDI empfangen amDate)
    //  - 50077 "Base Unit Quantity (Original)"(Basiseinheiten Menge (Ursprung))
    //  - 50078 "Coli"
    //  Feld 11 "Description" von 50 auf 100 Zeichen erweitert.
    fields
    {

        //Unsupported feature: Property Modification (Data type) on "Description(Field 11)".

        field(50070; "Minimum Durability"; Date)
        {
            Caption = 'Mindesthaltbarkeit';
        }
        field(50071; "Base Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
        }
        field(50072; "Base Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Base Unit Price';
            Editable = false;
        }
        field(50073; "Base Unit Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50074; "GUO Receive Date"; Date)
        {
            Caption = 'GUO verarbeitet am';
        }
        field(50075; "EDI Send Date"; Date)
        {
            Caption = 'EDI gesendet am';
        }
        field(50076; "EDI Receive Date"; Date)
        {
            Caption = 'EDI empfangen am';
        }
        field(50077; "Base Unit Quantity (Original)"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50078; Coli; Decimal)
        {
            Caption = 'Coli';
        }
    }
}

