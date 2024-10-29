report 50090 "Import Salesprices"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Objekt erstellt.

    Caption = 'Import Verkaufspreise';
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
                field(reqImportVkItem; reqImportVkItem)
                {
                    Caption = 'VK-Preis in Artikelkarte importieren';
                }
                field(reqImportVkList; reqImportVkList)
                {
                    Caption = 'VK-Preise in Preislisten importieren';
                    Enabled = true;
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
                    field(VendorColNo; CustomerNoColNo)
                    {
                        Caption = 'Debitoren Nr.';
                    }
                    field(NewStartingDateColNo; NewStartingDateColNo)
                    {
                        Caption = 'VK Gültig ab';
                    }
                    field(NewItemPriceColNo; NewUnitPriceColNo)
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
        EnterCell(1, 2, 'Debitor', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 3, 'Artikel', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 4, 'Beschreibung', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 5, 'VK-Preis alt', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 6, 'VK-Preis neu', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 7, 'Gültig ab', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 8, 'Fehler', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 9, 'Fehlerursache', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        RowNo := 1;

        ItemNoColNo := 1;
        CustomerNoColNo := 2;
        UnitofMeasureCodeColNo := 3;
        NewStartingDateColNo := 4;
        NewUnitPriceColNo := 6;
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
            OR (NewUnitPriceColNo = 0)
            OR (CustomerNoColNo = 0)
            OR (NewStartingDateColNo = 0)
            OR (UnitofMeasureCodeColNo = 0)
          THEN BEGIN
            MESSAGE('Auf der Optionskarte müssen die Zeilennummern für den Import angegeben sein.');
            EXIT;
        END ELSE BEGIN
            //Falls Artikelkarten Import und Preislistenimport angehakt ist nachfragen.
            IF reqImportVkItem AND reqImportVkList THEN
                IF NOT CONFIRM(Text027) THEN
                    ERROR('VK-Preise Import abgebrochen.');

            //Alles bestens, es kann losgehen
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
        CustomerNoColNo: Integer;
        CustomerNo: Code[20];
        NewStartingDateColNo: Integer;
        ItemNoColNo: Integer;
        UnitofMeasureCodeColNo: Integer;
        NewUnitPriceColNo: Integer;
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
        reqImportVkItem: Boolean;
        reqImportVkList: Boolean;
        Text027: Label 'Sind Sie sicher, dass Sie die Preise sowohl in die Artikelkarte als auch in Debitoren Preislisten importieren möchten?';
        CustomerNotExistsErr: Label 'Debitor %1 exisitiert nicht.';
        ItemNo_lcode: Code[20];
        UnitofMeasureCode_code: Code[10];
        UnitPrice_ldec: Decimal;
        NewUnitPrice_ldec: Decimal;
        Text028: Label 'Beim Import ist folgender Fehler aufgetreten: %1. Der Fehler befindet sich in der Exceltabelle in Zeile %2.';
        mRecSalesPrice: Record "7002";

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
        mNoUpdate: Boolean;
        Item_lrec: Record "Item";
        mNoCustomerFound: Boolean;
        Customer_lrec: Record "Customer";
        mRecNewSalesPrice: Record "7002";
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
                mNoCustomerFound := FALSE;
                NewUnitPriceIsZero := FALSE;
                mNoUpdate := FALSE;
                CustomerNo := '';
                UnitofMeasureCode_code := '';
                NewUnitPrice_ldec := 0;
                CLEAR(ItemNo_lcode);

                ExcelBuf.RESET;
                ExcelBuf.SETRANGE("Row No.", i);
                IF ExcelBuf.FIND('-') THEN
                    REPEAT
                        IF ExcelBuf."Column No." = ItemNoColNo THEN
                            ItemNo_lcode := UPPERCASE(ExcelBuf."Cell Value as Text");
                        IF ExcelBuf."Column No." = CustomerNoColNo THEN
                            CustomerNo := ExcelBuf."Cell Value as Text";
                        IF ExcelBuf."Column No." = NewUnitPriceColNo THEN
                            EVALUATE(NewUnitPrice_ldec, FormatData(ExcelBuf."Cell Value as Text"));
                        IF ExcelBuf."Column No." = NewStartingDateColNo THEN
                            EVALUATE(NewStartingDate, ExcelBuf."Cell Value as Text");
                        IF ExcelBuf."Column No." = UnitofMeasureCodeColNo THEN
                            UnitofMeasureCode_code := ExcelBuf."Cell Value as Text";
                    UNTIL ExcelBuf.NEXT = 0;

                //-- CheckCustomerNo;
                IF Customer_lrec.GET(CustomerNo) = FALSE THEN
                    mNoCustomerFound := TRUE;

                //-- CheckItemNo;
                IF Item_lrec.GET(ItemNo_lcode) = FALSE THEN BEGIN
                    mNoItemFound := TRUE;
                    Item_lrec.INIT;
                    UnitPrice_ldec := 0;
                END;

                IF (mNoItemFound = FALSE) THEN BEGIN

                    //alten VK-Preis für Berichtsausgabe merken
                    UnitPrice_ldec := Item_lrec."Unit Price";

                    IF ROUND(NewUnitPrice_ldec, 0.01) = 0 THEN
                        NewUnitPriceIsZero := TRUE;

                    //Falls angehakt Preis in Artikelkarte eintragen
                    //aber nur wenn kein Debitor eingetragen ist.
                    IF (NewUnitPriceIsZero = FALSE) AND (reqImportVkItem = TRUE) AND (CustomerNo = '') THEN BEGIN
                        mNoCustomerFound := FALSE;
                        Item_lrec.VALIDATE("Unit Price", ROUND(NewUnitPrice_ldec, 0.01));
                        NewStartingDate := WORKDATE;
                        Item_lrec."Last Price Update" := WORKDATE;
                        IF NOT reqOnlyTest THEN
                            IF Item_lrec.MODIFY(TRUE) = FALSE THEN
                                mNoUpdate := TRUE;
                    END;

                    IF (NOT reqOnlyTest) AND (reqImportVkList = TRUE) AND (mNoCustomerFound = FALSE) THEN BEGIN

                        //In VK-Preisliste eintragen
                        mRecSalesPrice.RESET;
                        mRecSalesPrice.SETRANGE("Item No.", ItemNo_lcode);
                        mRecSalesPrice.SETRANGE("Sales Type", mRecSalesPrice."Sales Type"::Customer);
                        mRecSalesPrice.SETRANGE("Sales Code", CustomerNo);
                        mRecSalesPrice.SETRANGE("Unit of Measure Code", UnitofMeasureCode_code);
                        IF (mRecSalesPrice.FINDFIRST) THEN
                            REPEAT
                                IF mRecSalesPrice."Starting Date" >= NewStartingDate THEN BEGIN
                                    //Startdatum ist bereits höher oder gleich als vom Import,
                                    //wird daher zum löschen vorgemerkt.
                                    mRecSalesPrice.MARK := TRUE;
                                END ELSE
                                    IF (mRecSalesPrice."Ending Date" >= NewStartingDate) OR (mRecSalesPrice."Ending Date" = 0D) THEN BEGIN
                                        //das Endedatum dieses Preises wird auf einen Tag
                                        //vor dem neuen Preis Startdatum gesetzt.
                                        mRecSalesPrice.VALIDATE("Ending Date", CALCDATE('-1T', NewStartingDate));
                                        mRecSalesPrice.MODIFY();
                                    END;
                            UNTIL mRecSalesPrice.NEXT = 0;

                        //jetzt werden alle ungültigen Preise gelöscht
                        mRecSalesPrice.MARKEDONLY := TRUE;
                        mRecSalesPrice.DELETEALL;

                        IF NOT UpdateSalesprice THEN BEGIN
                            ERROR(Text028, GETLASTERRORTEXT, FORMAT(i));
                        END ELSE BEGIN
                            mRecSalesPrice.INSERT;
                        END;

                    END;

                END;

                MultiTemp.INIT;
                MultiTemp.TextKey := 'Protokoll';
                MultiTemp.IntKey := i;
                MultiTemp.DecKey := 0;
                MultiTemp.Text1 := ItemNo_lcode;
                MultiTemp.Text2 := Item_lrec.Description;
                MultiTemp.Dec1 := UnitPrice_ldec; // bisheriger Wert
                MultiTemp.Dec2 := NewUnitPrice_ldec; // neuer Wert
                MultiTemp.Text3 := FORMAT(NewStartingDate);

                // Sind Fehler aufgetreten?
                IF (NewUnitPriceIsZero) OR (mNoItemFound) OR (mNoUpdate) OR (mNoCustomerFound) THEN BEGIN

                    IF NewUnitPriceIsZero THEN BEGIN
                        MultiTemp.Text5 := 'NewUnitPriceIsZeroError';
                        MultiTemp.Text4 := STRSUBSTNO(ZeroUnitPriceErr, ItemNo_lcode);
                    END;

                    IF mNoItemFound THEN BEGIN
                        MultiTemp.Text5 := 'NoItemFoundError';
                        MultiTemp.Text4 := STRSUBSTNO(ItemNotExistsErr, ItemNo_lcode);
                    END;

                    IF mNoCustomerFound THEN BEGIN
                        MultiTemp.Text5 := 'NoCustomerFoundError';
                        MultiTemp.Text4 := STRSUBSTNO(CustomerNotExistsErr, CustomerNo);
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
                EnterCell(RowNo, 2, CustomerNo, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 3, MultiTemp.Text1, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 4, MultiTemp.Text2, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 5, FORMAT(MultiTemp.Dec1), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                EnterCell(RowNo, 6, FORMAT(MultiTemp.Dec2), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                EnterCell(RowNo, 7, MultiTemp.Text3, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 8, MultiTemp.Text5, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 9, MultiTemp.Text4, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);

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

    [TryFunction]
    local procedure UpdateSalesprice()
    begin

        //neuen Eintrag in die Preisliste erstellen
        mRecSalesPrice.INIT;
        mRecSalesPrice.VALIDATE("Sales Type", mRecSalesPrice."Sales Type"::Customer);
        mRecSalesPrice."Sales Code" := CustomerNo;
        mRecSalesPrice.VALIDATE("Item No.", ItemNo_lcode);
        mRecSalesPrice.VALIDATE("Unit of Measure Code", UnitofMeasureCode_code);
        mRecSalesPrice.VALIDATE("Starting Date", NewStartingDate);
        mRecSalesPrice."Unit Price" := NewUnitPrice_ldec;
    end;
}

