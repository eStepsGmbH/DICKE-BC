tableextension 50120 tableextension50120 extends "Company Information"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Felder hinzugefügt:
    //    - 50001 Company Type
    //    - 50002 Company Leader
    //    -  50073   Jurisdiction
    fields
    {
        field(50001; "Company Type"; Text[30])
        {
            Caption = 'Company Type';
        }
        field(50002; "Company Leader"; Text[50])
        {
            Caption = 'Company Leader';
        }
        field(50073; Jurisdiction; Text[80])
        {
            Caption = 'Gerichtsstand';
        }
    }
}

