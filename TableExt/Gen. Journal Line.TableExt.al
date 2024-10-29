tableextension 50121 tableextension50121 extends "Gen. Journal Line"
{
    // ---------------------------------------------------------------------------
    // Sievers-SNC GmbH & Co. KG
    // ---------------------------------------------------------------------------
    // Module:   DTV    Datev specific modifications by Sievers-SNC
    // ---------------------------------------------------------------------------
    // 
    // Module Date     V.  Description
    // ---------------------------------------------------------------------------
    // DTV    11.11.16 100 NEW Field: 5041050 "Datev Entry No."; 5041054 "Datev Pmt. Discount"
    //                                5041055 "Datev Import Warning"; 5041056 "Datev Document No."
    //                     NEW Key:   Journal Template Name,Journal Batch Name,External Document No.
    //                                Journal Template Name,Journal Batch Name,Document No.,Line No.
    //                                Journal Template Name,Journal Batch Name,Document Type,Document No.,Line No.
    //                                Posting Date,Document No.,Document Type,Account Type,Account No.
    fields
    {
        field(5041050; "Datev Entry No."; Integer)
        {
            Caption = 'Datev Entry No.';
            Description = 'DTV';
        }
        field(5041054; "Datev Pmt. Discount"; Decimal)
        {
            Caption = 'Datev Pmt. Discount';
            Description = 'DTV';
        }
        field(5041055; "Datev Import Warning"; Text[80])
        {
            Caption = 'Datev Import Warning';
            Description = 'DTV';
        }
        field(5041056; "Datev Document No."; Code[20])
        {
            Caption = 'Datev Document No.';
            Description = 'DTV';
        }
    }


    //Unsupported feature: Code Modification on "GetVendLedgerEntry(PROCEDURE 37)".

    //procedure GetVendLedgerEntry();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    IF ("Account Type" = "Account Type"::Vendor) AND ("Account No." = '') AND
       ("Applies-to Doc. No." <> '') AND (Amount = 0)
    THEN BEGIN
    #4..10
      VendLedgEntry.CALCFIELDS("Remaining Amount");

      IF "Posting Date" <= VendLedgEntry."Pmt. Discount Date" THEN
        Amount := -(CustLedgEntry."Remaining Amount" - VendLedgEntry."Remaining Pmt. Disc. Possible")
      ELSE
        Amount := -VendLedgEntry."Remaining Amount";

    #18..43
      END ELSE
        VALIDATE(Amount);
    END;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..13
        Amount := -(VendLedgEntry."Remaining Amount" - VendLedgEntry."Remaining Pmt. Disc. Possible")
    #15..46
    */
    //end;

    procedure NeedCheckZeroAmount(): Boolean
    begin
        EXIT(
          ("Account No." <> '') AND
          NOT "System-Created Entry" AND
          NOT "Allow Zero-Amount Posting" AND
          ("Account Type" <> "Account Type"::"Fixed Asset"));
    end;

    procedure IsRecurring(): Boolean
    var
        GenJournalTemplate: Record "80";
    begin
        IF "Journal Template Name" <> '' THEN
            IF GenJournalTemplate.GET("Journal Template Name") THEN
                EXIT(GenJournalTemplate.Recurring);

        EXIT(FALSE);
    end;
}

