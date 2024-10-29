report 50001 "Item Copy Dicke"
{
    Caption = 'Item Copy Dicke';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Optionen)
                {
                    Caption = 'Options';
                    field(FromCompany; FromCompany)
                    {
                        Caption = 'From Company';
                        Lookup = true;
                        LookupPageID = Companies;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Company: Record Company;
                            Companies: Page Companies;
                        begin
                            Companies.LOOKUPMODE := TRUE;
                            IF Companies.RUNMODAL() = ACTION::LookupOK THEN BEGIN
                                Companies.GETRECORD(Company);
                                FromCompany := Company.Name;
                            END;
                        end;

                        trigger OnValidate()
                        var
                            Company: Record "2000000006";
                        begin
                            IF NOT Company.GET(FromCompany) THEN
                                ERROR('Mandant %1 nicht vorhanden.');
                        end;
                    }
                    field(FromItemNo; FromItemNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Source Item No.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            ItemList: Page "31";
                            Item_lrec: Record "Item";
                        begin
                            IF FromCompany = '' THEN
                                ERROR('Wählen Sie zunächst einen Herkunftsmandanten aus.');

                            CLEAR(ItemList);
                            Item_lrec.RESET();
                            Item_lrec.CHANGECOMPANY(FromCompany);
                            IF PAGE.RUNMODAL(0, Item_lrec) = ACTION::LookupOK THEN BEGIN
                                FromItemNo := Item_lrec."No.";
                                Item.CHANGECOMPANY(FromCompany);
                                Item.SETRANGE("No.", FromItemNo);
                            END;
                        end;

                        trigger OnValidate()
                        begin
                            IF FromCompany = '' THEN
                                ERROR('Wählen Sie zunächst einen Herkunftsmandanten aus.');
                            Item.CHANGECOMPANY(FromCompany);
                            Item.SETRANGE("No.", FromItemNo);
                            IF NOT Item.FINDFIRST THEN
                                ERROR('Artikel (%1) im Mandanten %2 nicht vorhanden.', FromItemNo, FromCompany);
                        end;
                    }
                    field(TargetItemNo; InItem."No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Target Item No.';
                        Lookup = true;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            IF PAGE.RUNMODAL(PAGE::"Item List", InItem, InItem."No.") = ACTION::LookupOK THEN;
                        end;
                    }
                    field(NewNoSeries; NewNoSeries)
                    {
                        ApplicationArea = Basic, Suite;
                        AssistEdit = true;
                        Caption = 'Target No. Series';
                        Editable = false;
                        Visible = false;

                        trigger OnAssistEdit()
                        begin
                            ItemSetup.GET;
                            ItemSetup.TESTFIELD("Item Nos.");
                            NoSeriesMgt.SelectSeries(ItemSetup."Item Nos.", Item."No. Series", NewNoSeries);
                        end;
                    }
                    group(Allgemein)
                    {
                        Caption = 'General';
                        field(GeneralItemInformation; CopyGenItemInfo)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'General Item Information';
                        }
                        field(Comments; CopyComments)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Comments';
                        }
                        field(CopyPic; CopyPic)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Picture';
                        }
                    }
                    group(Verkauf)
                    {
                        Caption = 'Sale';
                        field(SalesPrices; CopySalesPrices)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Sales Prices';
                        }
                        field(SalesLineDisc; CopySalesLineDisc)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Sales Line Disc.';
                        }
                    }
                    group(Einkauf)
                    {
                        Caption = 'Purchase';
                        field(PurchasePrices; CopyPurchPrices)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Purchase Prices';
                        }
                        field(PurchaseLineDisc; CopyPurchLineDisc)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Purchase Line Disc.';
                        }
                    }
                    group(Service)
                    {
                        Caption = 'Service';
                        Visible = false;
                        field(Troubleshooting; CopyTroubleshooting)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Troubleshooting';
                        }
                        field(ResourceSkills; CopyResourceSkills)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Resource Skills';
                        }
                    }
                    group(Erweitert)
                    {
                        Caption = 'Extended';
                        field(UnitsOfMeasure; CopyUnitOfMeasure)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Units of measure';
                        }
                        field(ItemVariants; CopyVariants)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Item Variants';
                        }
                        field(Translations; CopyTranslations)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Translations';
                        }
                        field(ExtendedTexts; CopyExtTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Extended Texts';
                        }
                        field(BOMComponents; CopyBOM)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'BOM Components';
                            Visible = false;
                        }
                        field(Dimensions; CopyDimensions)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Dimensions';
                            Visible = false;
                        }
                        field(CopyItemVendor; CopyItemVendor)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Item Vendors';
                        }
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            Item := TmpItem;
            CLEAR(InItem);
            NewNoSeries := '';
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        Window.OPEN(
          Text001 + // copy item
          Text002 + // From item
          Text003 + // To item
          '             #3############## #4#####');

        Window.UPDATE(1, Item."No.");
        Window.UPDATE(2, InItem."No.");
        IF FromCompany = '' THEN
            ERROR('Wählen Sie zunächst einen Herkunftsmandanten aus.');
        Item.CHANGECOMPANY(FromCompany);
        Item.SETRANGE("No.", FromItemNo);
        IF NOT Item.FINDFIRST THEN
            ERROR('Artikel (%1) im Mandanten %2 nicht vorhanden.', FromItemNo, FromCompany);

        CopyItem(Item."No.", InItem."No.");

        MESSAGE(
          RecapitulationTxt +
          DialogTxt[1] + DialogTxt[2] + DialogTxt[3] + DialogTxt[4] + DialogTxt[5] +
          DialogTxt[6] + DialogTxt[7] + DialogTxt[8] + DialogTxt[9] + DialogTxt[10] +
          DialogTxt[11] + DialogTxt[12] + DialogTxt[13] + DialogTxt[14] + DialogTxt[15] +
          DialogTxt[16] + DialogTxt[17] + DialogTxt[18] + DialogTxt[19] + DialogTxt[20] +
          DialogTxt[21] + DialogTxt[22] + DialogTxt[23] + DialogTxt[24] + DialogTxt[25] +
          DialogTxt[26] + DialogTxt[27] + DialogTxt[28] + DialogTxt[29] + DialogTxt[30],
          Item."No.", InItem."No.");

        Window.CLOSE;

        CopySuccessful := TRUE;
    end;

    var
        Item: Record "Item";
        InItem: Record "Item";
        Comments: Record "97";
        ItemUnitOfMeasure: Record "5404";
        ItemVariant: Record "5401";
        ItemTranslation: Record "30";
        ExtTxtHead: Record "279";
        ExtTxtLine: Record "280";
        BOMComponent: Record "90";
        ItemVendor: Record "99";
        TmpItem: Record "Item";
        ItemSetup: Record "313";
        DefaultDim: Record "352";
        TroubleshootingSetup: Record "5945";
        ResSkills: Record "5956";
        SalesPrice: Record "7002";
        SalesLineDisc: Record "7004";
        PurchPrice: Record "7012";
        PurchLineDisc: Record "7014";
        NoSeriesMgt: Codeunit "396";
        Window: Dialog;
        CopyGenItemInfo: Boolean;
        CopyComments: Boolean;
        CopyPic: Boolean;
        CopyUnitOfMeasure: Boolean;
        CopyVariants: Boolean;
        CopyTranslations: Boolean;
        CopyExtTxt: Boolean;
        CopyBOM: Boolean;
        CopyItemVendor: Boolean;
        CopyDimensions: Boolean;
        CopyTroubleshooting: Boolean;
        CopyResourceSkills: Boolean;
        CopySalesPrices: Boolean;
        CopySalesLineDisc: Boolean;
        CopyPurchPrices: Boolean;
        CopyPurchLineDisc: Boolean;
        DialogTxt: array[30] of Text[250];
        DialogTitle: Text[50];
        RecCount: Integer;
        CopyCount: Integer;
        TmpItemNo: Code[20];
        CopySuccessful: Boolean;
        Text001: Label 'Copy Item\\';
        Text002: Label 'Source Item     #1########\';
        Text003: Label 'Target Item     #2########\';
        RecapitulationTxt: Label 'Recapitulation of copy job:\\Source Item: %1\Target Item: %2\', Comment = 'Parameters 1 and 2 - item number';
        Text007: Label 'Source Item No. %1 doesn''t exist.';
        Text008: Label 'Target Item No. must not be empty.';
        Text009: Label 'General item information';
        Text010: Label 'Target Item No.%1 already exists.';
        Text011: Label 'Target Item %1 doesn''t exist.';
        Text013: Label 'Comments';
        Text014: Label 'Item units of measure';
        Text015: Label 'Item variants';
        Text016: Label 'Item translations';
        Text017: Label 'Extended texts';
        Text018: Label 'BOM components';
        Text021: Label 'Item vendors';
        Text025: Label 'copied.';
        Text026: Label 'Resource skills';
        Text027: Label 'Dimensions';
        Text028: Label 'Troubleshootings';
        Text029: Label 'Sales Prices';
        Text030: Label 'Sales Line Disc.';
        Text031: Label 'Purchase Prices';
        Text032: Label 'Purchase Line Disc.';
        NewNoSeries: Code[10];
        FromCompany: Text[50];
        FromItemNo: Code[20];
        FromComments: Record "97";
        FromItemUnitOfMeasure: Record "5404";
        FromItemVariant: Record "5401";
        FromItemTranslation: Record "30";
        FromExtTxtHead: Record "279";
        FromExtTxtLine: Record "280";
        FromItemVendor: Record "99";
        FromTmpItem: Record "Item";
        CheckVendor: Record "Vendor";
        CheckCustomer: Record "Customer";
        FromSalesPrice: Record "7002";
        FromSalesLineDisc: Record "7004";
        FromPurchPrice: Record "7012";
        FromPurchLineDisc: Record "7014";

    [Scope('Internal')]
    procedure CopyItem(_FromItemNo: Code[20]; _InItemNo: Code[20])
    var
        CopyBool: Boolean;
        CustomerPriceGroup: Record "6";
        CustomerDiscountGroup: Record "340";
    begin
        IF NOT Item.GET(_FromItemNo) THEN
            ERROR(Text007, _FromItemNo);

        IF (_InItemNo = '') AND (NOT CopyGenItemInfo) THEN
            ERROR(Text008);

        ItemSetup.GET;

        IF CopyGenItemInfo THEN
            InsertTargetItem(_InItemNo)
        ELSE BEGIN
            IF NOT InItem.GET(_InItemNo) THEN
                ERROR(Text011, _InItemNo);
        END;

        IF NOT (CopySalesLineDisc OR CopyPurchLineDisc) THEN BEGIN
            InItem."Item Disc. Group" := '';
            InItem.MODIFY;
        END;

        // Copy picture
        IF CopyPic THEN BEGIN
            InItem.Picture := Item.Picture;
            InItem.MODIFY;
        END ELSE BEGIN
            CLEAR(InItem.Picture);
            InItem.MODIFY;
        END;

        // Copy Comments
        IF CopyComments THEN BEGIN
            FromComments.CHANGECOMPANY(FromCompany);
            FromComments.SETRANGE("Table Name", Comments."Table Name"::Item);
            FromComments.SETRANGE("No.", Item."No.");
            IF FromComments.FINDSET THEN BEGIN
                InitDialog(Text013);
                REPEAT
                    Comments.INIT();
                    Comments.COPY(FromComments);
                    Comments."No." := InItem."No.";
                    Comments.INSERT;
                    //Comments."No." := Item."No.";
                    UpdateDialog;
                UNTIL FromComments.NEXT = 0;
                EndDialog;
            END;
        END;

        // copy units of measure
        IF CopyUnitOfMeasure THEN BEGIN
            FromItemUnitOfMeasure.CHANGECOMPANY(FromCompany);
            FromItemUnitOfMeasure.SETRANGE("Item No.", Item."No.");
            IF FromItemUnitOfMeasure.FINDSET THEN BEGIN
                InitDialog(Text014);
                REPEAT
                    ItemUnitOfMeasure.INIT();
                    ItemUnitOfMeasure.COPY(FromItemUnitOfMeasure);
                    ItemUnitOfMeasure."Item No." := InItem."No.";
                    ItemUnitOfMeasure.INSERT;
                    //ItemUnitOfMeasure."Item No." := Item."No.";
                    UpdateDialog;
                UNTIL FromItemUnitOfMeasure.NEXT = 0;
                EndDialog;
            END;
        END ELSE
            IF CopyGenItemInfo THEN BEGIN
                InItem."Base Unit of Measure" := '';
                InItem."Sales Unit of Measure" := '';
                InItem."Purch. Unit of Measure" := '';
                InItem.MODIFY;
            END;

        // copy variants
        IF CopyVariants THEN BEGIN
            FromItemVariant.CHANGECOMPANY(FromCompany);
            FromItemVariant.SETRANGE("Item No.", Item."No.");
            IF FromItemVariant.FINDSET THEN BEGIN
                InitDialog(Text015);
                REPEAT
                    ItemVariant.INIT();
                    ItemVariant.COPY(FromItemVariant);
                    ItemVariant."Item No." := InItem."No.";
                    ItemVariant.INSERT;
                    //ItemVariant."Item No." := Item."No.";
                    UpdateDialog;
                UNTIL FromItemVariant.NEXT = 0;
                EndDialog;
            END;
        END;

        // copy item translations
        IF CopyTranslations THEN BEGIN
            FromItemTranslation.CHANGECOMPANY(FromCompany);
            FromItemTranslation.SETRANGE("Item No.", Item."No.");
            IF NOT CopyVariants THEN
                FromItemTranslation.SETRANGE("Variant Code", '');
            IF FromItemTranslation.FINDSET THEN BEGIN
                InitDialog(Text016);
                REPEAT
                    ItemTranslation.INIT();
                    ItemTranslation.COPY(FromItemTranslation);
                    ItemTranslation."Item No." := InItem."No.";
                    ItemTranslation.INSERT;
                    //ItemTranslation."Item No." := Item."No.";
                    UpdateDialog;
                UNTIL FromItemTranslation.NEXT = 0;
                EndDialog;
            END;
        END;

        // Copy extended texts
        IF CopyExtTxt THEN BEGIN
            FromExtTxtHead.CHANGECOMPANY(FromCompany);
            FromExtTxtHead.SETRANGE("Table Name", ExtTxtHead."Table Name"::Item);
            FromExtTxtHead.SETRANGE("No.", Item."No.");
            IF FromExtTxtHead.FINDSET THEN BEGIN
                InitDialog(Text017);
                REPEAT
                    ExtTxtHead.INIT();
                    ExtTxtHead.COPY(FromExtTxtHead);
                    ExtTxtHead."No." := InItem."No.";
                    IF ExtTxtHead.INSERT(TRUE) THEN BEGIN
                        FromExtTxtLine.CHANGECOMPANY(FromCompany);
                        FromExtTxtLine.SETRANGE("Table Name", FromExtTxtHead."Table Name");
                        FromExtTxtLine.SETRANGE("No.", FromExtTxtHead."No.");
                        FromExtTxtLine.SETRANGE("Language Code", FromExtTxtHead."Language Code");
                        FromExtTxtLine.SETRANGE("Text No.", FromExtTxtHead."Text No.");
                        IF FromExtTxtLine.FINDSET THEN
                            REPEAT
                                ExtTxtLine.INIT();
                                ExtTxtLine.COPY(FromExtTxtLine);
                                ExtTxtLine."No." := InItem."No.";
                                ExtTxtLine.INSERT;
                            //ExtTxtLine."No." := Item."No.";
                            UNTIL FromExtTxtLine.NEXT = 0;
                    END;
                    // change header
                    // ExtTxtHead."No." := InItem."No.";
                    // ExtTxtHead.INSERT;
                    // ExtTxtHead."No." := Item."No.";
                    UpdateDialog;
                UNTIL FromExtTxtHead.NEXT = 0;
                EndDialog;
            END;
        END;

        /*
        // copy BOM
        IF CopyBOM THEN BEGIN
          BOMComponent.SETRANGE("Parent Item No.",Item."No.");
          IF BOMComponent.FINDSET THEN BEGIN
            InitDialog(Text018);
            REPEAT
              BOMComponent."Parent Item No." := InItem."No.";
              BOMComponent.INSERT;
              BOMComponent."Parent Item No." := Item."No.";
              UpdateDialog;
            UNTIL BOMComponent.NEXT = 0;
            EndDialog;
          END;
        END;
        */

        // copy item vendors
        IF CopyItemVendor THEN BEGIN
            FromItemVendor.CHANGECOMPANY(FromCompany);
            FromItemVendor.SETRANGE("Item No.", Item."No.");
            IF FromItemVendor.FINDSET THEN BEGIN
                InitDialog(Text021);
                REPEAT
                    IF CheckVendor.GET(FromItemVendor."Vendor No.") THEN BEGIN
                        ItemVendor.INIT();
                        ItemVendor.COPY(FromItemVendor);
                        ItemVendor."Item No." := InItem."No.";
                        ItemVendor.INSERT;
                        //ItemVendor."Item No." := Item."No.";
                        UpdateDialog;
                    END;
                UNTIL FromItemVendor.NEXT = 0;
                EndDialog;
            END;
        END;

        /*
        IF CopyDimensions THEN BEGIN
          DefaultDim.SETRANGE("Table ID",27);
          DefaultDim.SETRANGE("No.",Item."No.");
          IF DefaultDim.FINDSET THEN BEGIN
            InitDialog(Text027);
            REPEAT
              DefaultDim."No." := InItem."No.";
              DefaultDim.INSERT;
              DefaultDim."No." := Item."No.";
              UpdateDialog;
            UNTIL DefaultDim.NEXT = 0;
            EndDialog;
          END;
          InItem."Global Dimension 1 Code" := Item."Global Dimension 1 Code";
          InItem."Global Dimension 2 Code" := Item."Global Dimension 2 Code";
          InItem.MODIFY;
        END ELSE
          IF CopyGenItemInfo THEN BEGIN
            InItem."Global Dimension 1 Code" := '';
            InItem."Global Dimension 2 Code" := '';
            InItem.MODIFY;
          END;
        */
        /*
        IF CopyTroubleshooting THEN BEGIN
          TroubleshootingSetup.SETRANGE(Type,TroubleshootingSetup.Type::Item);
          TroubleshootingSetup.SETRANGE("No.",Item."No.");
          IF TroubleshootingSetup.FINDSET THEN BEGIN
            InitDialog(Text028);
            REPEAT
              TroubleshootingSetup."No." := InItem."No.";
              TroubleshootingSetup.INSERT;
              TroubleshootingSetup."No." := Item."No.";
              UpdateDialog;
            UNTIL TroubleshootingSetup.NEXT = 0;
            EndDialog;
          END;
        END;
        */
        /*
        // copy resource skills
        IF CopyResourceSkills THEN BEGIN
          ResSkills.SETRANGE(Type,ResSkills.Type::Item);
          ResSkills.SETRANGE("No.",Item."No.");
          IF ResSkills.FINDSET THEN BEGIN
            InitDialog(Text026);
            REPEAT
              ResSkills."No." := InItem."No.";
              ResSkills.INSERT;
              ResSkills."No." := Item."No.";
              UpdateDialog;
            UNTIL ResSkills.NEXT = 0;
            EndDialog;
          END;
        END;
        */
        // copy discounts
        IF CopySalesPrices THEN BEGIN
            FromSalesPrice.CHANGECOMPANY(FromCompany);
            FromSalesPrice.SETRANGE("Item No.", Item."No.");
            IF FromSalesPrice.FINDSET THEN BEGIN
                InitDialog(Text029);
                REPEAT
                    CopyBool := FALSE;
                    CASE FromSalesPrice."Sales Type" OF
                        FromSalesPrice."Sales Type"::"Customer Price Group":
                            IF CustomerPriceGroup.GET(FromSalesPrice."Sales Code") THEN
                                CopyBool := TRUE;
                        FromSalesPrice."Sales Type"::Customer:
                            IF CheckCustomer.GET(FromSalesPrice."Sales Code") THEN
                                CopyBool := TRUE;
                        FromSalesPrice."Sales Type"::"All Customers":
                            CopyBool := TRUE;
                    END;
                    IF CopyBool THEN BEGIN
                        SalesPrice.INIT();
                        SalesPrice.COPY(FromSalesPrice);
                        SalesPrice."Item No." := InItem."No.";
                        SalesPrice.INSERT();
                        //SalesPrice."Item No." := Item."No.";
                        UpdateDialog;
                    END;
                UNTIL FromSalesPrice.NEXT = 0;
            END;
        END;

        IF CopySalesLineDisc THEN BEGIN
            FromSalesLineDisc.CHANGECOMPANY(FromCompany);
            FromSalesLineDisc.SETRANGE(Type, SalesLineDisc.Type::Item);
            FromSalesLineDisc.SETRANGE(Code, Item."No.");
            IF FromSalesLineDisc.FINDSET THEN BEGIN
                InitDialog(Text030);
                REPEAT
                    CopyBool := FALSE;
                    CASE FromSalesLineDisc."Sales Type" OF
                        FromSalesLineDisc."Sales Type"::"Customer Disc. Group":
                            IF CustomerDiscountGroup.GET(FromSalesLineDisc."Sales Code") THEN
                                CopyBool := TRUE;
                        FromSalesLineDisc."Sales Type"::Customer:
                            IF CheckCustomer.GET(FromSalesLineDisc."Sales Code") THEN
                                CopyBool := TRUE;
                        FromSalesLineDisc."Sales Type"::"All Customers":
                            CopyBool := TRUE;
                    END;
                    IF CopyBool THEN BEGIN
                        SalesLineDisc.INIT();
                        SalesLineDisc.COPY(FromSalesLineDisc);
                        SalesLineDisc.Code := InItem."No.";
                        SalesLineDisc.INSERT();
                        //SalesLineDisc.Code := Item."No.";
                        UpdateDialog;
                    END;
                UNTIL FromSalesLineDisc.NEXT = 0;
            END;
        END;

        IF CopyPurchPrices THEN BEGIN
            FromPurchPrice.CHANGECOMPANY(FromCompany);
            FromPurchPrice.SETRANGE("Item No.", Item."No.");
            IF FromPurchPrice.FINDSET THEN BEGIN
                InitDialog(Text031);
                REPEAT
                    IF CheckVendor.GET(FromPurchPrice."Vendor No.") THEN BEGIN
                        PurchPrice.INIT();
                        PurchPrice.COPY(FromPurchPrice);
                        PurchPrice."Item No." := InItem."No.";
                        PurchPrice.INSERT();
                        //PurchPrice."Item No." := Item."No.";
                        UpdateDialog;
                    END;
                UNTIL FromPurchPrice.NEXT = 0;
            END;
        END;

        IF CopyPurchLineDisc THEN BEGIN
            FromPurchLineDisc.CHANGECOMPANY(FromCompany);
            FromPurchLineDisc.SETRANGE("Item No.", Item."No.");
            IF FromPurchLineDisc.FINDSET THEN BEGIN
                InitDialog(Text032);
                REPEAT
                    IF CheckVendor.GET(PurchLineDisc."Vendor No.") THEN BEGIN
                        PurchLineDisc.INIT();
                        PurchLineDisc.COPY(FromPurchLineDisc);
                        PurchLineDisc."Item No." := InItem."No.";
                        PurchLineDisc.INSERT();
                        //PurchLineDisc."Item No." := Item."No.";
                        UpdateDialog;
                    END;
                UNTIL FromPurchLineDisc.NEXT = 0;
            END;
        END;

    end;

    [Scope('Internal')]
    procedure InitDialog(Txt: Text[50])
    begin
        RecCount := 0;
        CopyCount := CopyCount + 1;
        DialogTitle := Txt;
        Window.UPDATE(3, Txt);
        Window.UPDATE(4, 0);
    end;

    [Scope('Internal')]
    procedure UpdateDialog()
    begin
        RecCount := RecCount + 1;
        Window.UPDATE(4, RecCount);
    end;

    [Scope('Internal')]
    procedure EndDialog()
    begin
        IF RecCount <> 0 THEN
            DialogTitle := STRSUBSTNO('%1 %2', RecCount, DialogTitle);
        DialogTitle := DialogTitle + ' ' + Text025;
        DialogTxt[CopyCount] := DialogTitle + '\';
    end;

    [Scope('Internal')]
    procedure ItemDef(var Item2: Record "Item")
    begin
        TmpItem := Item2;
    end;

    [Scope('Internal')]
    procedure ItemReturn(var ReturnItem: Record "Item"): Boolean
    begin
        ReturnItem := InItem;
        EXIT(CopySuccessful);
    end;

    local procedure SetTargetItemNo(NewItemNo: Code[20]; var TargetItemNo: Code[20]; var TargetNoSeries: Code[10])
    var
        TmpItemNo: Code[20];
    begin
        IF NewItemNo = '' THEN
            IF NewNoSeries <> '' THEN BEGIN
                NoSeriesMgt.SetSeries(TargetItemNo);
                TargetNoSeries := NewNoSeries;
            END ELSE BEGIN
                ItemSetup.TESTFIELD("Item Nos.");
                NoSeriesMgt.InitSeries(ItemSetup."Item Nos.", Item."No. Series", 0D, TargetItemNo, TargetNoSeries);
            END
        ELSE BEGIN
            IF InItem.GET(NewItemNo) THEN
                ERROR(Text010, NewItemNo);
            IF ItemSetup."Item Nos." <> '' THEN
                NoSeriesMgt.TestManual(ItemSetup."Item Nos.");

            TargetItemNo := NewItemNo;
            TargetNoSeries := '';
        END
    end;

    local procedure InsertTargetItem(NewItemNo: Code[20])
    var
        TempItemNo: Code[20];
        TempItemNoSeries: Code[10];
    begin
        InitDialog(Text009);
        WITH InItem DO BEGIN
            SetTargetItemNo(NewItemNo, TempItemNo, TempItemNoSeries);
            COPY(Item);
            "No." := TempItemNo;
            "No. Series" := TempItemNoSeries;
            "Last Date Modified" := TODAY;
            "Created From Nonstock Item" := FALSE;
            INSERT;
        END;
        EndDialog;
    end;
}

