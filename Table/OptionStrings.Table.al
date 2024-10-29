table 50003 "Option Strings"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Tabelle erstellt. Hinweis. Tabelle ist mandantenübergreifend!

    DataPerCompany = false;

    fields
    {
        field(1; TableNo; Integer)
        {
            Caption = 'Tabellenr.';
        }
        field(2; "No."; Integer)
        {
            Caption = 'Nr.';
        }
        field(3; TableName; Text[30])
        {
            Caption = 'Tabellenname';
        }
        field(4; FieldName; Text[30])
        {
            Caption = 'Feldname';
        }
        field(5; FieldInteger; Integer)
        {
            Caption = 'Feld ID';
        }
        field(6; "Field Caption"; Text[50])
        {
            Caption = 'Feld Caption';
        }
        field(7; OptionString; Text[250])
        {
            Caption = 'Optionsstring';
        }
    }

    keys
    {
        key(Key1; TableNo, "No.", FieldInteger)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

