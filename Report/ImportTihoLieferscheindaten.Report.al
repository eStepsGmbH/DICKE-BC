report 50070 "Import Tiho Lieferscheindaten"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Nr.   Doku  Datum    Kennz.  Beschreibung
    //  --------------------------------------------------------------------------------
    //  beu00                        Objekt erstellt.
    //  beu01       21.09.20 est.uki Add code to function "InsertItemLineData"

    ProcessingOnly = true;

    dataset
    {
        dataitem(Number; Integer)
        {

            trigger OnAfterGetRecord()
            begin

                IF Number = 1 THEN BEGIN
                    ImportedOrders_trec.FIND('-');
                END
                ELSE BEGIN
                    IF ImportedOrders_trec.NEXT = 0 THEN;
                END;

                RowNo := RowNo + 1;
                EnterCell(RowNo, 1, ImportedOrders_trec."No.", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 2, FORMAT(ImportedOrders_trec."Order Date"), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Date);
                EnterCell(RowNo, 3, ImportedOrders_trec."Sell-to Customer No.", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 4, ImportedOrders_trec."External Document No.", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 5, FORMAT(ImportedOrders_trec."Posting Date"), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Date);
            end;

            trigger OnPostDataItem()
            begin
                ExcelBuffer.CreateBook(ServerFileName, 'Import Thio Daten');
                ExcelBuffer.WriteSheet('TheHEADER', COMPANYNAME, USERID);
                ExcelBuffer.CloseBook;
                ExcelBuffer.OpenExcel;
                // ExcelBuffer.GiveUserControl;
                ExcelBuffer.DELETEALL;
            end;

            trigger OnPreDataItem()
            begin
                SETRANGE(Number, 1, ImportedOrders_trec.COUNT);

                // ------------------------------
                // Excel Überschriften erstellen
                // ------------------------------
                EnterCell(1, 1, 'Auftrag Nummer', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 2, 'Auftrag Datum', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 3, 'Debitor Nr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 4, 'Lieferschein Nr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 5, 'Lieferdatum', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);

                RowNo := 1;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    var
        FileManagement: Codeunit "419";
        Text028: Label 'Import File';
    begin
        FileName := FileManagement.ServerTempFileName('.txt');
        UPLOAD(Text028, '', 'Thio Lieferschein Datei (*.txt)|*.txt', '', FileName);
    end;

    trigger OnPreReport()
    var
        TempGLAccount: Record "G/L Account" temporary;
        AnalysisView: Record "363";
        TempAnalysisView: Record "363" temporary;
        AnalysisViewEntry: Record "365";
        BusUnit2: Record "220";
        PrevAccountNo: Code[20];
        AnalysisViewFound: Boolean;
        "--": Integer;
        Satzart_l: Text[1];
        OrderNo_l: Code[20];
    begin

        IF FileName = '' THEN
            ERROR(Text0000);

        CLEAR(ImportFile);
        ImportFile.TEXTMODE := TRUE;

        ImportFile.OPEN(FileName);

        WHILE ImportFile.READ(TextLine) > 0 DO BEGIN
            Satzart_l := COPYSTR(TextLine, 1, 1);

            CASE Satzart_l OF
                '2':
                    BEGIN
                        Belegart := '';
                        Belegart := COPYSTR(TextLine, 10, 1);
                        IF Belegart = 'R' THEN BEGIN
                            OrderNo_l := CreateNewOrder();
                            InsertHeaderData(OrderNo_l, TextLine);
                            InsertPositionHeadText(OrderNo_l, TextLine);
                            ImportedOrders_trec.INIT;
                            ImportedOrders_trec."Document Type" := ImportedOrders_trec."Document Type"::Order;
                            ImportedOrders_trec."No." := OrderNo_l;
                            ImportedOrders_trec."Sell-to Customer No." := COPYSTR(TextLine, 39, 5);
                            ImportedOrders_trec."External Document No." :=
                                                     STRSUBSTNO('%1%2', COPYSTR(TextLine, 33, 2), COPYSTR(TextLine, 4, 6));
                            EVALUATE(ImportedOrders_trec."Posting Date", COPYSTR(TextLine, 29, 6));
                            ImportedOrders_trec.INSERT(TRUE);
                        END;
                    END;
                '4':
                    IF Belegart = 'R' THEN
                        InsertTextLineData(OrderNo_l, TextLine);
                '6':
                    IF Belegart = 'R' THEN
                        InsertItemLineData(OrderNo_l, TextLine);
            END;

        END;

        ImportFile.CLOSE;
    end;

    var
        FileName: Text[250];
        TextLine: Text[80];
        ImportFile: File;
        ImportedOrders_trec: Record "Sales Header" temporary;
        Belegart: Text[1];
        Text0000: Label 'Enter the file name.';
        Text0001: Label 'The file to be imported has an unknown format.';
        Text0031: Label 'Aus Textdatei importieren';
        ServerFileName: Text;
        ExcelBuffer: Record "370" temporary;
        RowNo: Integer;

    [Scope('Internal')]
    procedure CreateNewOrder(): Code[20]
    var
        SalesHeader_lrec: Record "Sales Header";
    begin

        SalesHeader_lrec.RESET;
        SalesHeader_lrec.INIT;
        SalesHeader_lrec.VALIDATE("Document Type", SalesHeader_lrec."Document Type"::Order);
        SalesHeader_lrec.INSERT(TRUE);
        EXIT(SalesHeader_lrec."No.");
    end;

    [Scope('Internal')]
    procedure InsertHeaderData(OrderNo: Code[20]; ImportTextData: Text[80])
    var
        SalesHeader_lrec: Record "Sales Header";
        Belegart_l: Text[1];
    begin

        SalesHeader_lrec.RESET;
        SalesHeader_lrec.SETRANGE("Document Type", SalesHeader_lrec."Document Type"::Order);
        SalesHeader_lrec.SETRANGE("No.", OrderNo);

        IF SalesHeader_lrec.FIND('-') THEN BEGIN
            CASE Belegart OF
                'R':
                    BEGIN
                        SalesHeader_lrec.VALIDATE("Sell-to Customer No.", COPYSTR(ImportTextData, 39, 5));
                        EVALUATE(SalesHeader_lrec."Document Date", COPYSTR(ImportTextData, 29, 6));
                        EVALUATE(SalesHeader_lrec."Order Date", COPYSTR(ImportTextData, 29, 6));
                        EVALUATE(SalesHeader_lrec."Posting Date", COPYSTR(ImportTextData, 29, 6));
                        SalesHeader_lrec.MODIFY(TRUE);
                    END;
                'G':
                    BEGIN
                    END;
            END;

        END;
    end;

    [Scope('Internal')]
    procedure InsertTextLineData(OrderNo: Code[20]; ImportTextData: Text[80])
    var
        SalesLine_lrec: Record "Sales Line";
        SalesHeader_lrec: Record "Sales Header";
        NextLineNo: Integer;
    begin
        NextLineNo := 10000;

        SalesLine_lrec.RESET;
        SalesLine_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
        SalesLine_lrec.SETRANGE("Document No.", OrderNo);

        IF SalesLine_lrec.FIND('+') THEN
            NextLineNo := SalesLine_lrec."Line No." + 1000;

        IF SalesHeader_lrec.GET(SalesHeader_lrec."Document Type"::Order, OrderNo) THEN BEGIN

            SalesLine_lrec.RESET;
            SalesLine_lrec.INIT;
            SalesLine_lrec.VALIDATE("Document Type", SalesLine_lrec."Document Type"::Order);
            SalesLine_lrec.VALIDATE("Document No.", OrderNo);
            SalesLine_lrec.VALIDATE("Line No.", NextLineNo);
            SalesLine_lrec.Description := COPYSTR(ImportTextData, 10, 46);
            SalesLine_lrec.INSERT(TRUE);

        END;
    end;

    [Scope('Internal')]
    procedure InsertItemLineData(OrderNo: Code[20]; ImportTextData: Text[80])
    var
        SalesLine_lrec: Record "Sales Line";
        SalesHeader_lrec: Record "Sales Header";
        NextLineNo: Integer;
        StrToDec_Qty: Decimal;
        StrToDec_Kg: Decimal;
        Text001_l: Label '*** IMPORTHINWEIS BITTE UNBEDINGT PRÜFEN!!! Artikelnummer fehlt für Tiho-Nr. %1 *** ';
        Item_lrec: Record "Item";
        Text002_l: Label '*** IMPORTHINWEIS BITTE UNBEDINGT PRÜFEN!!! Artikelnummer %1 ist unbekannt! *** ';
        StrToDate_MHD: Date;
        TransferExtendedText: Codeunit "378";
    begin
        SalesLine_lrec.RESET;
        SalesLine_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
        SalesLine_lrec.SETRANGE("Document No.", OrderNo);

        IF SalesLine_lrec.FIND('+') THEN
            NextLineNo := SalesLine_lrec."Line No." + 10000;

        IF SalesHeader_lrec.GET(SalesHeader_lrec."Document Type"::Order, OrderNo) THEN BEGIN

            SalesLine_lrec.RESET;
            SalesLine_lrec.INIT;
            SalesLine_lrec.VALIDATE("Document Type", SalesLine_lrec."Document Type"::Order);
            SalesLine_lrec.VALIDATE("Document No.", OrderNo);
            SalesLine_lrec.VALIDATE("Line No.", NextLineNo);
            SalesLine_lrec.VALIDATE("Sell-to Customer No.", SalesHeader_lrec."Sell-to Customer No.");

            //ULK 14.07.2016 >>>
            EVALUATE(StrToDate_MHD,
             COPYSTR(ImportTextData, 56, 2) + '.' +
             COPYSTR(ImportTextData, 58, 2) + '.' +
             COPYSTR(ImportTextData, 60, 2));
            //ULK 14.07.2016 <<<

            IF COPYSTR(ImportTextData, 46, 10) = '0000000000' THEN
                SalesLine_lrec.Description := STRSUBSTNO(Text001_l, COPYSTR(ImportTextData, 10, 6))
            ELSE BEGIN
                Item_lrec.RESET;
                IF Item_lrec.GET(COPYSTR(ImportTextData, 46, 10)) THEN BEGIN
                    SalesLine_lrec.VALIDATE(Type, SalesLine_lrec.Type::Item);
                    SalesLine_lrec.VALIDATE("No.", COPYSTR(ImportTextData, 46, 10));
                    SalesLine_lrec.VALIDATE("Minimum Durability", StrToDate_MHD);
                    StrToDec_Qty := 0;
                    StrToDec_Kg := 0;
                    EVALUATE(StrToDec_Qty, COPYSTR(ImportTextData, 23, 5));
                    EVALUATE(StrToDec_Kg, COPYSTR(ImportTextData, 28, 8));

                    IF StrToDec_Kg <> 0 THEN
                        SalesLine_lrec.VALIDATE(Quantity, StrToDec_Kg / 1000)
                    ELSE
                        SalesLine_lrec.VALIDATE(Quantity, StrToDec_Qty);
                END
                ELSE
                    SalesLine_lrec.Description := STRSUBSTNO(Text002_l, COPYSTR(ImportTextData, 46, 10))
            END;

            SalesLine_lrec.INSERT(TRUE);
            //beu01:est.uki >>>
            IF TransferExtendedText.SalesCheckIfAnyExtText(SalesLine_lrec, FALSE) THEN
                TransferExtendedText.InsertSalesExtText(SalesLine_lrec);
            //beu01:est.uki <<<

        END;
    end;

    [Scope('Internal')]
    procedure InsertPositionHeadText(OrderNo: Code[20]; ImportTextData: Text[80])
    var
        SalesLine_lrec: Record "Sales Line";
        NextLineNo: Integer;
        Cust_lrec: Record "Customer";
        StrToDate_ldate: Date;
        Text001_l: Label 'Lieferung an %1';
        Text002_l: Label 'Ls der Firma Tiho vom %1, Ls-Nr. %2%3';
        Text003_l: Label '-------------------------------------------------------------';
    begin
        NextLineNo := 1000;

        Cust_lrec.RESET;
        IF Cust_lrec.GET(COPYSTR(ImportTextData, 39, 5)) THEN;

        SalesLine_lrec.RESET;
        SalesLine_lrec.INIT;
        SalesLine_lrec.VALIDATE("Document Type", SalesLine_lrec."Document Type"::Order);
        SalesLine_lrec.VALIDATE("Document No.", OrderNo);
        SalesLine_lrec.VALIDATE("Line No.", NextLineNo);
        SalesLine_lrec.Description := STRSUBSTNO(Text001_l, Cust_lrec.City);
        SalesLine_lrec.INSERT(TRUE);

        NextLineNo += 1000;

        SalesLine_lrec.RESET;
        SalesLine_lrec.INIT;
        SalesLine_lrec.VALIDATE("Document Type", SalesLine_lrec."Document Type"::Order);
        SalesLine_lrec.VALIDATE("Document No.", OrderNo);
        SalesLine_lrec.VALIDATE("Line No.", NextLineNo);
        EVALUATE(StrToDate_ldate, COPYSTR(ImportTextData, 29, 6));
        SalesLine_lrec.Description := STRSUBSTNO(Text002_l, StrToDate_ldate, COPYSTR(ImportTextData, 33, 2), COPYSTR(ImportTextData, 4, 6));
        SalesLine_lrec.INSERT(TRUE);

        NextLineNo += 1000;

        SalesLine_lrec.RESET;
        SalesLine_lrec.INIT;
        SalesLine_lrec.VALIDATE("Document Type", SalesLine_lrec."Document Type"::Order);
        SalesLine_lrec.VALIDATE("Document No.", OrderNo);
        SalesLine_lrec.VALIDATE("Line No.", NextLineNo);
        SalesLine_lrec.Description := Text003_l;
        SalesLine_lrec.INSERT(TRUE);

        NextLineNo += 1000;

        SalesLine_lrec.RESET;
        SalesLine_lrec.INIT;
        SalesLine_lrec.VALIDATE("Document Type", SalesLine_lrec."Document Type"::Order);
        SalesLine_lrec.VALIDATE("Document No.", OrderNo);
        SalesLine_lrec.VALIDATE("Line No.", NextLineNo);
        SalesLine_lrec.Description := '';
        SalesLine_lrec.INSERT(TRUE);
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
        ServerFileName := NewFileName;
    end;
}

