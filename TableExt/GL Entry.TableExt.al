tableextension 50024 tableextension50024 extends "G/L Entry"
{
    // ---------------------------------------------------------------------------
    // Sievers-SNC GmbH & Co. KG
    // ---------------------------------------------------------------------------
    // Module:   SNC/DATEV  DTV    Datev specific modifications by Sievers-SNC
    // ---------------------------------------------------------------------------
    // 
    // Module Date     Change  Description
    // ---------------------------------------------------------------------------
    // DTV    11.11.16 100     NEW Field: 5041050 Datev Entry No.
    //                         NEW Key:   Datev Entry No.,Posting Date,Entry No.,Document No.,Document Date,Document Type,Source Code; SumIndexFields: Debit Amount,Credit Amount
    fields
    {
        field(5041050; "Datev Entry No."; Integer)
        {
            Caption = 'Datev Entry No.';
            Description = 'DTV';
            Editable = false;
        }
    }
}

