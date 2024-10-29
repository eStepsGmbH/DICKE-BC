table 50009 "EDI Transfer"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Tabelle erstellt.
    // 
    //  No.   Date       Version Changes
    //  --------------------------------------------------------------------------------
    //  DIC01 10.08.2020 17.2.01 Add field: "MinimumDurability" (Date)


    fields
    {
        field(10; MsgTyp; Text[10])
        {
        }
        field(20; MaiKey; Text[100])
        {
        }
        field(30; HrcLvl; Text[9])
        {
        }
        field(40; LinNum; Decimal)
        {
        }
        field(50; "a50#1"; Text[50])
        {
        }
        field(60; "a50#2"; Text[50])
        {
        }
        field(70; "a50#3"; Text[50])
        {
        }
        field(80; "a50#4"; Text[50])
        {
        }
        field(90; "a50#5"; Text[50])
        {
        }
        field(100; "n1#1"; Integer)
        {
        }
        field(110; "n1#2"; Integer)
        {
        }
        field(120; "n1#3"; Integer)
        {
        }
        field(130; "n1#4"; Integer)
        {
        }
        field(140; "n1#5"; Integer)
        {
        }
        field(150; "d1#1"; Decimal)
        {
        }
        field(160; "d1#2"; Decimal)
        {
        }
        field(170; "d1#3"; Decimal)
        {
        }
        field(180; "d1#4"; Decimal)
        {
        }
        field(190; "d1#5"; Decimal)
        {
        }
        field(200; MinimumDurability; Date)
        {
        }
    }

    keys
    {
        key(Key1; MsgTyp, MaiKey)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

