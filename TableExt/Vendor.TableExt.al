tableextension 50032 tableextension50032 extends Vendor
{
    // ---------------------------------------------------------------------------
    // Sievers-SNC GmbH & Co. KG
    // ---------------------------------------------------------------------------
    // Module:   SNC/DATEV  DTV    Datev specific modifications by Sievers-SNC
    // ---------------------------------------------------------------------------
    // 
    // Module Date     Change  Description
    // ---------------------------------------------------------------------------
    // DTV    11.11.16 100     NEW Field: 5041050 "Datev Account No."
    //                         NEW Field: 5041051 "Don't Export Bank Account"
    //                         NEW Field: 5041052 "Datev Export Date"
    //                         NEW Field: 5041053 "Datev Addressee Type"
    fields
    {
        modify(Image)
        {
            Caption = 'Image';
        }
        field(5041050; "Datev Account No."; Code[20])
        {
            Caption = 'Datev Account No.';
            Description = 'DTV';
        }
        field(5041051; "Don't Export Bank Account"; Boolean)
        {
            Caption = 'Don''t Export Bank Account';
            Description = 'DTV';
        }
        field(5041052; "Datev Export Date"; Date)
        {
            Caption = 'Datev Export Date';
            Description = 'DTV';
        }
        field(5041053; "Datev Addressee Type"; Option)
        {
            Caption = 'Datev Addressee Type';
            Description = 'DTV';
            OptionCaption = 'No Information,Natural Person,Company';
            OptionMembers = "No Information","Natural Person",Company;
        }
    }


    //Unsupported feature: Code Modification on "OnInsert".

    //trigger OnInsert()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    IF "No." = '' THEN
      IF DocumentNoVisibility.VendorNoSeriesIsDefault THEN BEGIN
        PurchSetup.GET;
        NoSeriesMgt.InitSeries(PurchSetup."Vendor Nos.",xRec."No. Series",0D,"No.","No. Series");
      END;
    IF "Invoice Disc. Code" = '' THEN
      "Invoice Disc. Code" := "No.";

    #9..11
    DimMgt.UpdateDefaultDim(
      DATABASE::Vendor,"No.",
      "Global Dimension 1 Code","Global Dimension 2 Code");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    IF "No." = '' THEN BEGIN
      PurchSetup.GET;
      PurchSetup.TESTFIELD("Vendor Nos.");
      NoSeriesMgt.InitSeries(PurchSetup."Vendor Nos.",xRec."No. Series",0D,"No.","No. Series");
    END;

    #6..14
    */
    //end;
}
