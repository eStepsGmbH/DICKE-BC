tableextension 50021 tableextension50021 extends "G/L Account"
{
    // ---------------------------------------------------------------------------
    // Sievers-SNC GmbH & Co. KG
    // ---------------------------------------------------------------------------
    // Module:   SNC/DATEV DTV    Datev specific modifications by Sievers-SNC
    // ---------------------------------------------------------------------------
    // 
    // Module Date     Change  Description
    // ---------------------------------------------------------------------------
    // DTV    11.11.16 100      NEW Field: 5041050 "Datev Account Type", 5041051 "Datev Account No.", 5041052 "Datev Account Name"
    fields
    {
        field(5041050; "Datev Account Type"; Option)
        {
            Caption = 'Datev Account Type';
            Description = 'DTV: 33';
            OptionCaption = ' ,Automatic Account,Receivable Account,Payable Account,Bank/Cash Account,VAT Account';
            OptionMembers = " ","Automatic Account","Receivable Account","Payable Account","Bank/Cash Account","VAT Account";
        }
        field(5041051; "Datev Account No."; Code[20])
        {
            Caption = 'Datev Account No.';
            Description = 'DTV: 20';
        }
        field(5041052; "Datev Account Name"; Text[40])
        {
            Caption = 'Datev Account Name';
            Description = 'DTV: 37';
        }
    }
}

