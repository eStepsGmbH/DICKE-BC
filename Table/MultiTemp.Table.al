table 50008 MultiTemp
{
    // 
    //  markmann + müller datensysteme gmbh
    //  --------------------------------------------------------------------------------
    //  Nr.   MID  Datum    Kennz. Beschreibung
    //  --------------------------------------------------------------------------------
    //  01    4596 27.05.02 mum.ag Portiert aus Attain 3.01 B
    //                             Felder Dec6 .. Dec10 hinzugefügt
    // 
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Felder ab 50070 hinzugefügt.


    fields
    {
        field(1; TextKey; Text[100])
        {
        }
        field(2; IntKey; Integer)
        {
        }
        field(3; DecKey; Decimal)
        {
        }
        field(10; Text1; Text[50])
        {
        }
        field(11; Text2; Text[50])
        {
        }
        field(12; Text3; Text[50])
        {
        }
        field(13; Text4; Text[50])
        {
        }
        field(14; Text5; Text[50])
        {
        }
        field(15; Text6; Text[50])
        {
        }
        field(16; Text7; Text[50])
        {
        }
        field(17; Text8; Text[50])
        {
        }
        field(19; Text9; Text[50])
        {
        }
        field(20; Int1; Integer)
        {
        }
        field(21; Int2; Integer)
        {
        }
        field(22; Int3; Integer)
        {
        }
        field(23; Int4; Integer)
        {
        }
        field(24; Int5; Integer)
        {
        }
        field(25; Dec1; Decimal)
        {
        }
        field(26; Dec2; Decimal)
        {
        }
        field(27; Dec3; Decimal)
        {
        }
        field(28; Dec4; Decimal)
        {
        }
        field(29; Dec5; Decimal)
        {
        }
        field(30; Dec6; Decimal)
        {
        }
        field(31; Dec7; Decimal)
        {
        }
        field(32; Dec8; Decimal)
        {
        }
        field(33; Dec9; Decimal)
        {
        }
        field(34; Dec10; Decimal)
        {
        }
        field(50072; CharA; Code[10])
        {
        }
        field(50073; CharB; Code[10])
        {
        }
        field(50074; CharC; Code[10])
        {
        }
        field(50075; Value; Code[3])
        {
        }
        field(50076; Encoding; Code[20])
        {
        }
    }

    keys
    {
        key(Key1; TextKey, IntKey, DecKey)
        {
            Clustered = true;
        }
        key(Key2; Value)
        {
        }
    }

    fieldgroups
    {
    }
}

