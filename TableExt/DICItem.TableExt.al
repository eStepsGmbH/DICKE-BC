tableextension 50036 "DIC Item" extends Item
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Fat Content %" (Fettgehalt in %)
    //  - Feld 50071 "Purchasing Code" (Einkaufscode)
    //  - Feld 50072 "Last Price Update" (Letzte Preisaktulaisierung)
    //  - Feld 50073 "Assortment" (Sortiment)
    //  - Feld 50074 "Presentation" (Warenpräsentation)
    //  - Feld50075"Milk Use"
    //  - Feld50076"EAN13"
    //  - Feld50077"EAN128"
    //  - Feld 21 "Costing Method" - Property "InitValue" auf STANDARD gesetzt.
    //  - Fieldgroup erweitert: Feld "SearchName" hinzugefügt.
    fields
    {

        field(50070; "Fat Content %"; Decimal)
        {
            Caption = 'Fettgehalt in %';
        }
        // field(50071; "Purchasing Code"; Code[10]) // TODO: Microsoft Feld
        // {
        //     Caption = 'Purchasing Code';
        //     TableRelation = Purchasing;
        // }
        field(50072; "Last Price Update"; Date)
        {
            Caption = 'Letzte Preisaktulaisierung';
        }
        field(50073; Assortment; Option)
        {
            Caption = 'Sortiment';
            OptionMembers = "0","10","20","30","40","50","60";
        }
        field(50074; Presentation; Option)
        {
            Caption = 'Warenpräsentation';
            OptionMembers = "0","10","20","30";
        }
        field(50075; "Milk Use"; Option)
        {
            Caption = 'Milchbehandlung';
            OptionMembers = "0","10","20","30";
        }
        field(50076; EAN13; Code[15])
        {
            Caption = 'EAN 13';
        }
        field(50077; EAN128; Code[15])
        {
            Caption = 'EAN 128';
        }
    }
}