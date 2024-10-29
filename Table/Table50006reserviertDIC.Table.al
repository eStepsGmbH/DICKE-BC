table 50006 "Table 50006 - reserviert DIC -"
{

    fields
    {
        field(1; "No."; Code[30])
        {
        }
        field(2; Hersteller; Code[50])
        {
        }
        field(3; MEK; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}

