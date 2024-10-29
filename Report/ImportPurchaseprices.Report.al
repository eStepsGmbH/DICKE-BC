report 50083 "Import Purchaseprices"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Objekt erstellt.

    Caption = 'Import Einkaufspreise';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Durchlauf; Integer)
        {
            DataItemTableView = SORTING(Number)
                                ORDER(Ascending);
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            var
                OK: Boolean;
            begin
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(FileName; FileName)
                {
                    Caption = 'Arbeitsmappe Dateiname';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        FileName := FileManagement.ServerTempFileName('.xslx');
                        UPLOAD(Text006, '', 'Excel Dateien (*.xlsx)|*.xlsx|Excel 97-2003 Dateien (*.xls)|*.xls|Alle Dateien (*.*)|*.*', '', FileName);
                    end;
                }
                field(SheetName; SheetName)
                {
                    Caption = 'Tabellenname';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        SheetName := ExcelBuf.SelectSheetsName(FileName);
                    end;
                }
                field(OnlyTest; reqOnlyTest)
                {
                    Caption = 'Testlauf';
                }
                field(reqImportEkItem; reqImportEkItem)
                {
                    Caption = 'EK-Preis in Artikelkarte importieren';
                }
                field(reqImportEkList; reqImportEkList)
                {
                    Caption = 'EK-Preise in Preislisten importieren';
                }
                group("Spaltenangabe aus Excel")
                {
                    Caption = 'Spaltenangabe aus Excel';
                    Visible = false;
                    field(ItemNoColNo; ItemNoColNo)
                    {
                        Caption = 'Artikel Nr.';
                    }
                    field(UnitofMeasureCodeColNo; UnitofMeasureCodeColNo)
                    {
                        Caption = 'Einheitencode';
                    }
                    field(VendorColNo; VendorNoColNo)
                    {
                        Caption = 'Kreditor Nr.';
                    }
                    field(NewStartingDateColNo; NewStartingDateColNo)
                    {
                        Caption = 'EK Gültig ab';
                    }
                    field(NewUnitPriceColNo; NewUnitPriceColNo)
                    {
                        Caption = 'EK-Preis';
                    }
                    field(NewItemPriceColNo; NewItemPriceColNo)
                    {
                        Caption = 'VK-Preis';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin

        // ------------------------------
        // Excel Überschriften erstellen
        // ------------------------------
        EnterCell(1, 1, 'Excelspalte', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 2, 'Artikel', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 3, 'Beschreibung', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 4, 'EK-Preis alt', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 5, 'EK-Preis neu', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        //EnterCell(1,6,'VK-Preis alt',TRUE,FALSE,'',ExcelBuffer."Cell Type"::Text);
        //EnterCell(1,7,'VK-Preis neu',TRUE,FALSE,'',ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 6, 'Datum Aktualisierung', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 7, 'Fehler', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 8, 'Fehlerursache', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        RowNo := 1;

        ItemNoColNo := 1;
        VendorNoColNo := 2;
        UnitofMeasureCodeColNo := 3;
        NewStartingDateColNo := 4;
        NewUnitPriceColNo := 5;
        NewItemPriceColNo := 6;
    end;

    trigger OnPostReport()
    begin

        ExcelBuffer.CreateBook(ServerFileNameExcel, 'Preisimport-Protokoll');
        ExcelBuffer.WriteSheet('Import', COMPANYNAME, USERID);
        ExcelBuffer.CloseBook;
        ExcelBuffer.OpenExcel;
        // ExcelBuffer.GiveUserControl;

        ExcelBuffer.DELETEALL;
        ExcelBuf.DELETEALL;
    end;

    trigger OnPreReport()
    begin

        ExcelBuf.DELETEALL;
        ExcelBuf.LOCKTABLE;

        IF (ItemNoColNo = 0)
            OR (NewUnitPriceColNo = 0)
            OR (NewItemPriceColNo = 0)
            OR (VendorNoColNo = 0)
            OR (NewStartingDateColNo = 0)
            OR (UnitofMeasureCodeColNo = 0)
          THEN BEGIN
            MESSAGE('Auf der Optionskarte müssen die Zeilennummern für den Import angegeben sein.');
            EXIT;
        END ELSE BEGIN
            ReadExcelSheet;
            AnalyzeData;
        END;
    end;

    var
        ExcelBuf: Record "370" temporary;
        MultiTemp: Record "50008" temporary;
        FileName: Text[250];
        SheetName: Text[250];
        EntryNo: Integer;
        Window: Dialog;
        reqErrorLog: Boolean;
        reqOnlyTest: Boolean;
        VendorNoColNo: Integer;
        VendorNo: Code[20];
        NewStartingDateColNo: Integer;
        ItemNoColNo: Integer;
        UnitofMeasureCodeColNo: Integer;
        NewUnitPriceColNo: Integer;
        NewItemPriceColNo: Integer;
        Text001: Label 'Do you want to create %1 %2.';
        Text003: Label 'Are you sure you want to %1 for %2 %3.';
        Text004: Label '%1 table has been successfully updated with %2 entries.';
        Text005: Label 'Imported from Excel ';
        Text006: Label 'Import Excel File';
        Text007: Label 'Analyzing Data...\\';
        Text023: Label 'You cannot import the same information twice.\';
        Text026: Label 'Dates have not been recognized in the Excel worksheet.';
        NewStartingDate: Date;
        MaxRowNo: Integer;
        FileManagement: Codeunit "419";
        ServerFileNameExcel: Text;
        ExcelBuffer: Record "370" temporary;
        RowNo: Integer;
        ZeroPriceErr: Label 'Customer %1 doesn''t exists.';
        ItemNotExistsErr: Label 'Item %1 doesn''t exisits.';
        UpdateErr: Label 'No Update possible.';
        ZeroUnitPriceErr: Label 'Item %1: Unit Price is Zero!';
        reqImportEkItem: Boolean;
        reqImportEkList: Boolean;

    local procedure ReadExcelSheet()
    begin
        ExcelBuf.OpenBook(FileName, SheetName);
        ExcelBuf.ReadSheet;
    end;

    local procedure AnalyzeData()
    var
        i: Integer;
        HeaderRowNo: Integer;
        mMaxRowNo: Integer;
        mNoCustomerFound: Boolean;
        mNoItemFound: Boolean;
        mNoUpdate: Boolean;
        mNoInsert: Boolean;
        mRecSalesPrice: Record "7002";
        mRecNewSalesPrice: Record "7002";
        mRecCustomer: Record "Customer";
        mRecItem: Record "Item";
        mSalesType: Option Customer,"Customer Price Group";
        mItemNo: Code[20];
        mCustomerNo: Code[20];
        mStartingDate: Date;
        mNewStartingDate: Date;
        mUnitPrice: Decimal;
        mNewUnitPrice: Decimal;
        mVariantCode: Code[10];
        mUnitofMeasure: Code[10];
        mMinimumQty: Decimal;
        mEndingDate: Date;
        mNewEndDateExistingLine: Date;
        mNewEndDateNewLine: Date;
        Text001: Label 'Customer %1 doesn''t exists.';
        Text002: Label 'Item %1 doesn''t exisits.';
        Text003: Label 'No Update posible.';
        Text004: Label 'New Entry can''t insert.';
    begin
        ImportItemPrices();
    end;

    local procedure ImportItemPrices()
    var
        i: Integer;
        HeaderRowNo: Integer;
        mNoItemFound: Boolean;
        NewUnitPriceIsZero: Boolean;
        NewItemPriceIsZero: Boolean;
        mNoUpdate: Boolean;
        Item_lrec: Record "Item";
        ItemNo_lcode: Code[20];
        NewUnitPrice_ldec: Decimal;
        NewItemPrice_ldec: Decimal;
        UnitofMeasureCode_code: Code[10];
        UnitPrice_ldec: Decimal;
        ItemPrice_ldec: Decimal;
        mNoVendorFound: Boolean;
        Vendor_lrec: Record "Vendor";
        mRecPurchasePrice: Record "7012";
        mRecNewPurchasePrice: Record "7012";
    begin
        Window.OPEN(Text007 + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        Window.UPDATE(1, 0);

        ExcelBuf.SETCURRENTKEY("Column No.", "Row No.");

        IF ExcelBuf.FINDLAST THEN
            MaxRowNo := ExcelBuf."Row No.";

        IF ExcelBuf.FINDSET THEN BEGIN

            FOR i := 2 TO MaxRowNo DO BEGIN

                Window.UPDATE(1, ROUND(i / MaxRowNo * 10000, 1));

                mNoItemFound := FALSE;
                mNoVendorFound := FALSE;
                NewUnitPriceIsZero := FALSE;
                NewItemPriceIsZero := FALSE;
                mNoUpdate := FALSE;
                CLEAR(ItemNo_lcode);

                ExcelBuf.RESET;
                ExcelBuf.SETRANGE("Row No.", i);
                IF ExcelBuf.FIND('-') THEN
                    REPEAT
                        IF ExcelBuf."Column No." = ItemNoColNo THEN
                            //ItemNo_lcode := UPPERCASE(FormatData(ExcelBuf."Cell Value as Text"));
                            ItemNo_lcode := UPPERCASE(ExcelBuf."Cell Value as Text");
                        IF ExcelBuf."Column No." = VendorNoColNo THEN
                            VendorNo := FormatData(ExcelBuf."Cell Value as Text");
                        IF ExcelBuf."Column No." = NewUnitPriceColNo THEN
                            EVALUATE(NewUnitPrice_ldec, FormatData(ExcelBuf."Cell Value as Text"));
                        IF ExcelBuf."Column No." = NewItemPriceColNo THEN
                            EVALUATE(NewItemPrice_ldec, FormatData(ExcelBuf."Cell Value as Text"));
                        IF ExcelBuf."Column No." = NewStartingDateColNo THEN
                            EVALUATE(NewStartingDate, ExcelBuf."Cell Value as Text");
                        IF ExcelBuf."Column No." = UnitofMeasureCodeColNo THEN
                            UnitofMeasureCode_code := FormatData(ExcelBuf."Cell Value as Text");
                    UNTIL ExcelBuf.NEXT = 0;

                //-- CheckVendorNo;
                IF Vendor_lrec.GET(VendorNo) = FALSE THEN
                    mNoVendorFound := TRUE;

                //-- CheckItemNo;
                IF Item_lrec.GET(ItemNo_lcode) = FALSE THEN BEGIN
                    mNoItemFound := TRUE;
                    Item_lrec.INIT;
                    ItemPrice_ldec := 0;
                    UnitPrice_ldec := 0;
                END;

                IF (mNoItemFound = FALSE) AND (mNoVendorFound = FALSE) THEN BEGIN

                    ItemPrice_ldec := Item_lrec."Last Direct Cost";
                    UnitPrice_ldec := Item_lrec."Unit Price";

                    IF ROUND(NewUnitPrice_ldec, 0.01) = 0 THEN
                        NewUnitPriceIsZero := TRUE;

                    IF (NewUnitPriceIsZero = FALSE) AND (reqImportEkItem = TRUE) THEN BEGIN
                        Item_lrec.VALIDATE("Last Direct Cost", NewUnitPrice_ldec);
                        Item_lrec."Standard Cost" := Item_lrec."Last Direct Cost";
                        Item_lrec."Unit Cost" := Item_lrec."Standard Cost";
                        Item_lrec."Last Price Update" := WORKDATE;
                        IF NOT reqOnlyTest THEN
                            IF Item_lrec.MODIFY(TRUE) = FALSE THEN
                                mNoUpdate := TRUE;
                    END;

                    IF NOT reqOnlyTest AND (reqImportEkList = TRUE) THEN BEGIN
                        //In EK-Preisliste eintragen
                        //KEY: Item No.,Vendor No.,Starting Date
                        mRecPurchasePrice.RESET;
                        mRecPurchasePrice.SETRANGE("Item No.", ItemNo_lcode);
                        mRecPurchasePrice.SETRANGE("Vendor No.", VendorNo);
                        mRecPurchasePrice.SETRANGE("Unit of Measure Code", UnitofMeasureCode_code);
                        IF (mRecPurchasePrice.FINDFIRST) THEN
                            REPEAT
                                IF mRecPurchasePrice."Starting Date" >= NewStartingDate THEN BEGIN
                                    //Startdatum ist bereits höher oder gleich als vom Import,
                                    //wird daher zum löschen vorgemerkt
                                    mRecPurchasePrice.MARK := TRUE;
                                END ELSE
                                    IF (mRecPurchasePrice."Ending Date" >= NewStartingDate) OR (mRecPurchasePrice."Ending Date" = 0D) THEN BEGIN
                                        mRecPurchasePrice.VALIDATE("Ending Date", CALCDATE('-1T', NewStartingDate));
                                        mRecPurchasePrice.MODIFY();
                                    END;
                            UNTIL mRecPurchasePrice.NEXT = 0;

                        mRecPurchasePrice.MARKEDONLY := TRUE;
                        mRecPurchasePrice.DELETEALL;

                        //neuen Eintrag erstellen
                        mRecPurchasePrice.INIT;
                        mRecPurchasePrice."Item No." := ItemNo_lcode;
                        mRecPurchasePrice."Vendor No." := VendorNo;
                        mRecPurchasePrice.VALIDATE("Starting Date", NewStartingDate);
                        mRecPurchasePrice."Direct Unit Cost" := NewUnitPrice_ldec;
                        mRecPurchasePrice."Unit of Measure Code" := UnitofMeasureCode_code;
                        mRecPurchasePrice.INSERT;
                    END;

                END;

                MultiTemp.INIT;
                MultiTemp.TextKey := 'Protokoll';
                MultiTemp.IntKey := i;
                MultiTemp.DecKey := 0;
                MultiTemp.Text1 := ItemNo_lcode;
                MultiTemp.Text2 := Item_lrec.Description;
                MultiTemp.Dec1 := ItemPrice_ldec; // bisheriger Wert
                MultiTemp.Dec2 := NewUnitPrice_ldec; // neuer Wert
                MultiTemp.Text3 := FORMAT(Item_lrec."Last Price Update");

                // Sind Fehler aufgetreten?
                IF (NewItemPriceIsZero) OR (NewUnitPriceIsZero) OR (mNoItemFound) OR (mNoUpdate) THEN BEGIN

                    IF NewUnitPriceIsZero THEN BEGIN
                        MultiTemp.Text5 := 'NewUnitPriceIsZeroError';
                        MultiTemp.Text4 := STRSUBSTNO(ZeroUnitPriceErr, ItemNo_lcode);
                    END;

                    IF NewItemPriceIsZero THEN BEGIN
                        MultiTemp.Text5 := 'NewItemPriceIsZero';
                        MultiTemp.Text4 := STRSUBSTNO(ZeroPriceErr, ItemNo_lcode);
                    END;

                    IF mNoItemFound THEN BEGIN
                        MultiTemp.Text5 := 'NoItemFoundError';
                        MultiTemp.Text4 := STRSUBSTNO(ItemNotExistsErr, ItemNo_lcode);
                    END;

                    IF mNoUpdate THEN BEGIN
                        MultiTemp.Text5 := 'NoUpdateError';
                        MultiTemp.Text4 := UpdateErr;
                    END;

                END;  // IF -> Sind Fehler aufgetreten?

                //Multitemp nach Excel
                MultiTemp.INSERT;
                RowNo := RowNo + 1;
                EnterCell(RowNo, 1, FORMAT(MultiTemp.IntKey), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                EnterCell(RowNo, 2, MultiTemp.Text1, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 3, MultiTemp.Text2, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 4, FORMAT(MultiTemp.Dec1), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                EnterCell(RowNo, 5, FORMAT(MultiTemp.Dec2), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                //EnterCell(RowNo,6,FORMAT(MultiTemp.Dec3),FALSE,FALSE,'',ExcelBuffer."Cell Type"::Number);
                //EnterCell(RowNo,7,FORMAT(MultiTemp.Dec4),FALSE,FALSE,'',ExcelBuffer."Cell Type"::Number);
                EnterCell(RowNo, 6, MultiTemp.Text3, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 7, MultiTemp.Text5, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 8, MultiTemp.Text4, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);

            END;  //FOR

        END; // IF ExcelBuf.FIND('-')
    end;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; UnderLine: Boolean; NumberFormat: Text[30]; CellType: Option)
    begin
        ExcelBuffer.INIT;
        ExcelBuffer.VALIDATE("Row No.", RowNo);
        ExcelBuffer.VALIDATE("Column No.", ColumnNo);
        ExcelBuffer."Cell Value as Text" := CellValue;
        ExcelBuffer.Formula := '';
        ExcelBuffer.Bold := Bold;
        ExcelBuffer.Underline := UnderLine;
        ExcelBuffer.NumberFormat := NumberFormat;
        ExcelBuffer."Cell Type" := CellType;
        ExcelBuffer.INSERT;
    end;

    local procedure FormatData(TextToFormat: Text[250]): Text[250]
    var
        FormatInteger: Integer;
        FormatDecimal: Decimal;
        FormatDate: Date;
    begin
        CASE TRUE OF
            EVALUATE(FormatInteger, TextToFormat):
                EXIT(FORMAT(FormatInteger));
            EVALUATE(FormatDecimal, TextToFormat):
                EXIT(FORMAT(FormatDecimal));
            EVALUATE(FormatDate, TextToFormat):
                EXIT(FORMAT(FormatDate));
            ELSE
                EXIT(TextToFormat);
        END;
    end;

    [Scope('Internal')]
    procedure SetFileNameSilent(NewFileName: Text)
    begin
        ServerFileNameExcel := NewFileName;
    end;
}

