table 50001 "Export Dischinger"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Tabelle erstellt.

    Caption = 'Export Dischinger';

    fields
    {
        field(5; Pickup; Date)
        {
            Caption = 'Abholung';
        }
        field(10; Company; Text[30])
        {
            Caption = 'Mandant';
        }
        field(15; Location; Option)
        {
            Caption = 'Lager';
            OptionCaption = 'Kirn,Sodifrais';
            OptionMembers = Kirn,Sodifrais;
        }
        field(20; Day; Date)
        {
            Caption = 'Tag';
        }
        field(25; "Customer No."; Code[20])
        {
            Caption = 'Debitor Nr.';
        }
        field(30; "Customer Name"; Text[50])
        {
            Caption = 'Debitorname';
        }
        field(40; Address; Text[30])
        {
            Caption = 'Address';
        }
        field(50; "Post Code"; Code[20])
        {
            Caption = 'Address 2';
        }
        field(60; City; Text[30])
        {
            Caption = 'Ort';
        }
        field(70; Package; Integer)
        {
            Caption = 'Karton';
        }
        field(80; Quantity; Decimal)
        {
            Caption = 'Menge';
        }
        field(90; Route; Text[30])
        {
            Caption = 'Leitweg';
        }
        field(100; "Shipment No."; Code[20])
        {
            Caption = 'Liefernr.';
        }
    }

    keys
    {
        key(Key1; Company, Day, "Customer No.", Location)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

