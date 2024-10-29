tableextension 50029 tableextension50029 extends Customer
{
    //  ---------------------------------------------------------------------------
    //  Sievers-SNC GmbH & Co. KG
    //  ---------------------------------------------------------------------------
    //  Module:   SNC/DATEV  DTV    Datev specific modifications by Sievers-SNC
    //  ---------------------------------------------------------------------------
    // 
    //  Module Date     Change  Description
    //  ---------------------------------------------------------------------------
    //  DTV    11.11.16 100 NEW Field: 5041050 "Datev Account No."
    //                      NEW Field: 5041051 "Don't Export Bank Account"
    //                      NEW Field: 5041052 "Datev Export Date"
    //                      NEW Field: 5041053 "Datev Addressee Type"
    // 
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Feld 50070 "Export Dischinger" hinzugefügt.
    //  - Feld 50071 "Location Entry for Dischinger" hinzugefügt.
    //  - Feld 50072 "Extended Text" hinzugefügt.
    //  - Fieldgroup erweitert: Feld "Address" und "SearchName" hinzugefügt.
    //  - Feld 50073 "Central Payer" hinzugefügt.
    fields
    {
        modify(Image)
        {
            Caption = 'Image';
        }
        field(50070; "Export Dischinger"; Boolean)
        {
            Caption = 'Export Dischinger';
        }
        field(50071; "Location for Dischinger"; Option)
        {
            Caption = 'Location Entry Dischinger';
            OptionCaption = 'Kirn,Sodifrais,both';
            OptionMembers = Kirn,Sodifrais,beide;
        }
        field(50072; "Extended Text"; Code[10])
        {
            Caption = 'Textbaustein Desadv Kirn';
            TableRelation = "Standard Text";
        }
        field(50073; "Central Payer"; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            TableRelation = Customer WHERE("Is Central Payer" = CONST(true));

            trigger OnValidate()
            begin

                Rec.TESTFIELD("Is Central Payer", FALSE);
            end;
        }
        field(50074; "Is Central Payer"; Boolean)
        {
            Caption = 'Ist Zentralregulierer';

            trigger OnValidate()
            begin

                IF "Is Central Payer" = TRUE THEN
                    Rec.TESTFIELD("Central Payer", '');
            end;
        }
        field(50075; Branch; Code[10])
        {
            Caption = 'Branch';
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
      IF DocumentNoVisibility.CustomerNoSeriesIsDefault THEN BEGIN
        SalesSetup.GET;
        NoSeriesMgt.InitSeries(SalesSetup."Customer Nos.",xRec."No. Series",0D,"No.","No. Series");
      END;
    IF "Invoice Disc. Code" = '' THEN
      "Invoice Disc. Code" := "No.";

    #9..11
    DimMgt.UpdateDefaultDim(
      DATABASE::Customer,"No.",
      "Global Dimension 1 Code","Global Dimension 2 Code");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    IF "No." = '' THEN BEGIN
      SalesSetup.GET;
      SalesSetup.TESTFIELD("Customer Nos.");
      NoSeriesMgt.InitSeries(SalesSetup."Customer Nos.",xRec."No. Series",0D,"No.","No. Series");
    END;

    #6..14
    */
    //end;

    //Unsupported feature: Property Modification (Fields) on "DropDown(FieldGroup 1)".

}

