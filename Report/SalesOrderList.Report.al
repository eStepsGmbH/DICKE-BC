report 50073 "Sales Order List"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Objekt erstellt.

    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            dataitem("Sales Header"; "Sales Header")
            {
                DataItemLink = "Sell-to Customer No." = FIELD("No.");
                RequestFilterFields = "Sell-to Customer No.", "Shipment Date", "No.", "Shipping Agent Code", SendToKirn, "VUO Creation Date";
                dataitem("Sales Line"; "Sales Line")
                {
                    DataItemLink = "Document Type" = FIELD("Document Type"),
                                   "Sell-to Customer No." = FIELD("Sell-to Customer No."),
                                   "Document No." = FIELD("No.");
                    DataItemTableView = SORTING("Document Type", "Document No.", "Line No.")
                                        WHERE("Document Type" = CONST(Order),
                                              Type = CONST(Item),
                                              Quantity = FILTER(<> 0));

                    trigger OnAfterGetRecord()
                    begin
                        IF DataExport_req THEN BEGIN
                            ExportLineText();
                            ExportFile.WRITE(Ascii2Ansi(ExportStringLine));
                        END;
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    SalesLine_lrec: Record "Sales Line";
                    SalesHdr_lrec: Record "Sales Header";
                begin

                    OrderWeight_dec := 0;
                    OrderQty_dec := 0;
                    OrderCounter_int += 1;

                    SalesLine_lrec.RESET;
                    SalesLine_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
                    SalesLine_lrec.SETRANGE("Document No.", "Sales Header"."No.");
                    IF SalesLine_lrec.FIND('-') THEN
                        REPEAT
                            OrderWeight_dec := OrderWeight_dec + (SalesLine_lrec.Quantity * SalesLine_lrec."Net Weight");
                            OrderQty_dec := OrderQty_dec + SalesLine_lrec.Quantity;
                        UNTIL SalesLine_lrec.NEXT = 0;

                    TotalOrderWeight_dec := TotalOrderWeight_dec + OrderWeight_dec;
                    TotalOrderQty_dec := TotalOrderQty_dec + OrderQty_dec;

                    IF DataExport_req THEN BEGIN
                        CLEAR(Customer_rec);
                        Customer_rec.RESET;
                        IF Customer_rec.GET("Sales Header"."Sell-to Customer No.") THEN;
                        ExportHdrText();
                        ExportFile.WRITE(Ascii2Ansi(ExportStringHdr1) + Ascii2Ansi(ExportStringHdr2));
                        SalesHdr_lrec.RESET;
                        SalesHdr_lrec.SETRANGE("Document Type", "Sales Header"."Document Type");
                        SalesHdr_lrec.SETRANGE("No.", "Sales Header"."No.");
                        IF SalesHdr_lrec.FIND('-') THEN BEGIN
                            SalesHdr_lrec."VUO Creation Date" := WORKDATE;
                            SalesHdr_lrec.MODIFY;
                        END;
                    END;

                    RowNo := RowNo + 1;
                    EnterCell(RowNo, 1, "Sales Header"."Sell-to Customer No.", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                    EnterCell(RowNo, 2, "Sales Header"."Sell-to Customer Name", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                    EnterCell(RowNo, 3, "Sales Header"."No.", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                    EnterCell(RowNo, 4, FORMAT("Sales Header"."Order Date"), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Date);
                    EnterCell(RowNo, 5, FORMAT("Sales Header"."Shipment Date"), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Date);
                    EnterCell(RowNo, 6, FORMAT("Sales Header"."Requested Delivery Date"), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Date);
                    EnterCell(RowNo, 7, FORMAT(OrderQty_dec), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                    EnterCell(RowNo, 8, FORMAT(OrderWeight_dec), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                    EnterCell(RowNo, 9, FORMAT("Sales Header"."External Document No."), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                    EnterCell(RowNo, 10, FORMAT("Sales Header".Status), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                end;

                trigger OnPreDataItem()
                begin
                    IF DataExport_req THEN BEGIN
                        "Sales Header".SETFILTER("VUO Creation Date", '%1', 0D);
                    END;
                end;
            }

            trigger OnPostDataItem()
            begin
                IF DataExport_req THEN
                    ExportFile.CLOSE;

                RowNo := RowNo + 1;
                EnterCell(RowNo, 1, 'Anzahl Aufträge', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 2, FORMAT(OrderCounter_int), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);

                EnterCell(RowNo, 7, FORMAT(TotalOrderQty_dec), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                EnterCell(RowNo, 8, FORMAT(TotalOrderWeight_dec), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Number);

                IF NOT OpenExcel THEN
                    MESSAGE('Es ist ein Fehler augetreten: ' + GETLASTERRORTEXT);

                ExcelBuffer.DELETEALL;
            end;
        }
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
                    field(VUO_Export; DataExport_req)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Export VUO';
                        ToolTip = 'Specifies the date from which the report or batch job processes information.';
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

    trigger OnPreReport()
    var
        SalesSetup_lrec: Record "Sales & Receivables Setup";
    begin

        CustFilter := Customer.GETFILTERS;
        SalesHeaderFilter := "Sales Header".GETFILTERS;

        IF DataExport_req THEN BEGIN
            SalesSetup_lrec.GET;
            SalesSetup_lrec.TESTFIELD(SalesSetup_lrec."VUO Export Path");
            FileName_req := SalesSetup_lrec."VUO Export Path" +
                             'VUO_' + FORMAT(WORKDATE, 0, '<YEAR4><Month><Day>') + '_' + FORMAT(TIME, 0, '<Hours24,2><Minutes,2><Seconds,2>') + '.txt';
            IF FileName_req = '' THEN
                ERROR('Dateiname für Textdatei fehlt!');
            ExportFile.CREATE(FileName_req);
            ExportFile.TEXTMODE(TRUE);
        END;

        // ------------------------------
        // Excel Überschriften erstellen
        // ------------------------------
        EnterCell(1, 1, 'Debitor Nr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 2, 'Debitor Name', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 3, 'Auftrag Nummer', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 4, 'Auftrag Datum', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 5, 'Warenausgang', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 6, 'Gew. Lieferdatum', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 7, 'Kolli', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 8, 'KG', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 9, 'Ext. Belegnr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 10, 'Status', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        RowNo := 1;
    end;

    var
        CustFilter: Text[250];
        SalesHeaderFilter: Text[250];
        PrintOnlyOnePerPage: Boolean;
        OrderWeight_dec: Decimal;
        TotalOrderWeight_dec: Decimal;
        OrderQty_dec: Decimal;
        TotalOrderQty_dec: Decimal;
        OrderCounter_int: Integer;
        Customer_rec: Record "Customer";
        ExportFile: File;
        ExportStringHdr1: Text[1020];
        ExportStringHdr2: Text[471];
        DataExport_req: Boolean;
        FileName_req: Text[250];
        ExportStringLine: Text[547];
        AsciiStr: Text[1024];
        AnsiStr: Text[1024];
        CharVar: array[32] of Char;
        Text000: Label 'Shipment Date: %1';
        Text001: Label 'Sales Order Line: %1';
        ServerFileNameExcel: Text;
        ExcelBuffer: Record "370" temporary;
        RowNo: Integer;

    [Scope('Internal')]
    procedure ExportHdrText()
    var
        ExportStringField_ltext: Text[30];
    begin
        ExportStringHdr1 := PADSTR('ZEN', 3);
        ExportStringHdr1 += PADSTR('2', 1);
        ExportStringHdr1 += PADSTR('4399901854710', 14);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('011', 3);
        ExportStringHdr1 += PADSTR("Sales Header"."No.", 35);
        ExportStringHdr1 += PADSTR('', 2);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 7);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 15);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 6);
        ExportStringHdr1 += PADSTR('', 8);
        ExportStringHdr1 += PADSTR('', 6);
        ExportStringHdr1 += PADSTR(FORMAT("Sales Header"."Requested Delivery Date", 0, '<Year4><Month,2><Day,2>'), 8);
        ExportStringHdr1 += PADSTR('', 6);
        ExportStringHdr1 += PADSTR('', 8);
        ExportStringHdr1 += PADSTR('', 6);
        ExportStringHdr1 += PADSTR('', 8);
        ExportStringHdr1 += PADSTR('', 6);

        //ExportStringHdr1 += PADSTR("Sales Header"."Sell-to Customer No.",14);
        ExportStringField_ltext := "Sales Header"."Sell-to Customer No.";
        IF STRLEN(ExportStringField_ltext) < 6 THEN
            ExportStringField_ltext := COPYSTR('000000', 1, 6 - STRLEN(ExportStringField_ltext)) + ExportStringField_ltext;
        ExportStringHdr1 += PADSTR(ExportStringField_ltext, 6);
        ExportStringHdr1 += PADSTR('', 8);

        ExportStringHdr1 += PADSTR('', 14);
        ExportStringHdr1 += PADSTR('', 35);
        ExportStringHdr1 += PADSTR("Sales Header"."Sell-to Customer Name", 40);
        ExportStringHdr1 += PADSTR("Sales Header"."Sell-to Customer Name 2", 40);
        ExportStringHdr1 += PADSTR("Sales Header"."Sell-to Address", 40);
        ExportStringHdr1 += PADSTR("Sales Header"."Sell-to Post Code", 10);
        ExportStringHdr1 += PADSTR("Sales Header"."Sell-to City", 40);
        ExportStringHdr1 += PADSTR('', 20);
        ExportStringHdr1 += PADSTR('', 20);

        //ExportStringHdr1 += PADSTR("Sales Header"."Sell-to Country Code",3);
        ExportStringHdr1 += PADSTR("Sales Header"."Sell-to Country/Region Code", 1);
        ExportStringHdr1 += PADSTR('', 2);

        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 35);
        ExportStringHdr1 += PADSTR('', 6);
        ExportStringHdr1 += PADSTR('', 40);
        ExportStringHdr1 += PADSTR('', 25);
        ExportStringHdr1 += PADSTR('', 14);
        ExportStringHdr1 += PADSTR('', 14);
        ExportStringHdr1 += PADSTR('', 35);
        ExportStringHdr1 += PADSTR('', 40);
        ExportStringHdr1 += PADSTR('', 40);
        ExportStringHdr1 += PADSTR('', 10);
        ExportStringHdr1 += PADSTR('', 40);
        ExportStringHdr1 += PADSTR('', 20);
        ExportStringHdr1 += PADSTR('', 20);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 14);
        ExportStringHdr1 += PADSTR('', 14);
        ExportStringHdr1 += PADSTR('', 35);
        ExportStringHdr1 += PADSTR('', 40);
        ExportStringHdr1 += PADSTR('', 40);
        ExportStringHdr1 += PADSTR('', 10);
        ExportStringHdr1 += PADSTR('', 40);
        ExportStringHdr1 += PADSTR('', 20);
        ExportStringHdr1 += PADSTR('', 20);

        ExportStringHdr2 := PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 40);
        ExportStringHdr2 += PADSTR('', 15);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 15);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 15);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 15);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 10);
        ExportStringHdr2 += PADSTR('', 10);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 10);
        ExportStringHdr2 += PADSTR('', 10);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 6);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 6);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 70);
        ExportStringHdr2 += PADSTR('', 70);
        ExportStringHdr2 += PADSTR("Sales Header"."External Document No.", 70);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 3);
        ExportStringHdr2 += PADSTR('', 15);
        ExportStringHdr2 += PADSTR('', 40);
        ExportStringHdr2 += PADSTR('', 3);
    end;

    [Scope('Internal')]
    procedure ExportLineText()
    var
        ExportStringField_ltext: Text[30];
        Qty_ltext: Text[8];
    begin
        ExportStringLine := PADSTR('ZRG', 3);
        ExportStringLine += PADSTR('2', 1);
        ExportStringLine += PADSTR('4399901854710', 14);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 4);
        ExportStringLine += PADSTR('011', 3);
        //ExportStringLine += PADSTR('',35);

        ExportStringField_ltext := "Sales Header"."Sell-to Customer No.";
        IF STRLEN(ExportStringField_ltext) < 10 THEN
            ExportStringField_ltext := COPYSTR('0000000000', 1, 10 - STRLEN(ExportStringField_ltext)) + ExportStringField_ltext;
        ExportStringLine += PADSTR(ExportStringField_ltext, 10);

        ExportStringLine += PADSTR('39', 2);

        ExportStringField_ltext := "Sales Header"."No.";
        IF STRLEN(ExportStringField_ltext) < 5 THEN
            ExportStringField_ltext := COPYSTR('00000', 1, 5 - STRLEN(ExportStringField_ltext)) + ExportStringField_ltext;
        ExportStringLine += PADSTR(ExportStringField_ltext, 5);

        ExportStringField_ltext := "Sales Line"."No.";
        IF STRLEN(ExportStringField_ltext) < 8 THEN
            ExportStringField_ltext := COPYSTR('00000000', 1, 8 - STRLEN(ExportStringField_ltext)) + ExportStringField_ltext;
        ExportStringLine += PADSTR(ExportStringField_ltext, 8);

        ExportStringField_ltext := FORMAT("Sales Line"."Line No.");
        IF STRLEN(ExportStringField_ltext) < 10 THEN
            ExportStringField_ltext := COPYSTR('0000000000', 1, 10 - STRLEN(ExportStringField_ltext)) + ExportStringField_ltext;
        ExportStringLine += PADSTR(ExportStringField_ltext, 10);

        ExportStringLine += PADSTR('', 3);

        //ExportStringLine += PADSTR('0' + "Sales Line"."No.",14);
        IF STRLEN("Sales Line"."No.") < 5 THEN BEGIN
            ExportStringLine += PadStrLeft(FORMAT("Sales Line"."No."), 5, '0');
            ExportStringLine += PADSTR('', 9);
        END
        ELSE
            ExportStringLine += PADSTR("Sales Line"."No.", 14);

        ExportStringLine += PADSTR('', 35);
        ExportStringLine += PADSTR('', 25);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 8);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 40);
        ExportStringLine += PADSTR('', 40);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 6);
        ExportStringLine += PADSTR('', 3);
        Qty_ltext := FORMAT("Sales Line".Quantity);
        Qty_ltext := DELCHR(Qty_ltext, '=', '.');
        ExportStringLine += PadStrLeft(Qty_ltext, 6, ' ');
        // ExportStringLine += PadStrLeft(FORMAT("Sales Line".Quantity),6,' ');

        ExportStringLine += PADSTR('', 6);
        ExportStringLine += PADSTR('', 10);
        ExportStringLine += PADSTR('', 10);
        ExportStringLine += PADSTR('', 10);
        ExportStringLine += PADSTR('', 10);
        ExportStringLine += PADSTR('', 10);
        ExportStringLine += PADSTR('', 10);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 10);
        ExportStringLine += PADSTR('', 10);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 15);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 15);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 6);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 40);
        ExportStringLine += PADSTR('', 35);
        ExportStringLine += PADSTR('', 14);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 35);
        ExportStringLine += PADSTR('', 2);
        ExportStringLine += PADSTR('', 8);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 3);
    end;

    [Scope('Internal')]
    procedure Ansi2Ascii(_Text: Text[1024]): Text[1024]
    begin
        MakeVars;
        EXIT(CONVERTSTR(_Text, AnsiStr, AsciiStr));
    end;

    [Scope('Internal')]
    procedure Ascii2Ansi(_Text: Text[1024]): Text[1024]
    begin
        MakeVars;
        EXIT(CONVERTSTR(_Text, AsciiStr, AnsiStr));
    end;

    [Scope('Internal')]
    procedure MakeVars()
    begin
        AsciiStr := 'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜø£Ø×ƒáíóúñÑªº¿®¬½¼¡«»¦¦¦¦¦ÁÂÀ©¦¦++¢¥++--+-+ãÃ++--¦-+';
        AsciiStr := AsciiStr + '¤ðÐÊËÈiÍÎÏ++¦_¦Ì¯ÓßÔÒõÕµþÞÚÛÙýÝ¯´­±=¾¶§÷¸°¨·¹³²¦ ';
        CharVar[1] := 196;
        CharVar[2] := 197;
        CharVar[3] := 201;
        CharVar[4] := 242;
        CharVar[5] := 220;
        CharVar[6] := 186;
        CharVar[7] := 191;
        CharVar[8] := 188;
        CharVar[9] := 187;
        CharVar[10] := 193;
        CharVar[11] := 194;
        CharVar[12] := 192;
        CharVar[13] := 195;
        CharVar[14] := 202;
        CharVar[15] := 203;
        CharVar[16] := 200;
        CharVar[17] := 205;
        CharVar[18] := 206;
        CharVar[19] := 204;
        CharVar[20] := 175;
        CharVar[21] := 223;
        CharVar[22] := 213;
        CharVar[23] := 254;
        CharVar[24] := 218;
        CharVar[25] := 219;
        CharVar[26] := 217;
        CharVar[27] := 180;
        CharVar[28] := 177;
        CharVar[29] := 176;
        CharVar[30] := 185;
        CharVar[31] := 179;
        CharVar[32] := 178;
        AnsiStr := 'Ã³ÚÔõÓÕþÛÙÞ´¯ý' + FORMAT(CharVar[1]) + FORMAT(CharVar[2]) + FORMAT(CharVar[3]) + 'µã¶÷' + FORMAT(CharVar[4]);
        AnsiStr := AnsiStr + '¹¨ Í' + FORMAT(CharVar[5]) + '°úÏÎâßÝ¾·±Ð¬' + FORMAT(CharVar[6]) + FORMAT(CharVar[7]);
        AnsiStr := AnsiStr + '«¼¢' + FORMAT(CharVar[8]) + 'í½' + FORMAT(CharVar[9]) + '___ªª' + FORMAT(CharVar[10]) + FORMAT(CharVar[11]);
        AnsiStr := AnsiStr + FORMAT(CharVar[12]) + '®ªª++óÑ++--+-+Ò' + FORMAT(CharVar[13]) + '++--ª-+ñ­ð';
        AnsiStr := AnsiStr + FORMAT(CharVar[14]) + FORMAT(CharVar[15]) + FORMAT(CharVar[16]) + 'i' + FORMAT(CharVar[17]) + FORMAT(CharVar[18]);
        AnsiStr := AnsiStr + '¤++__ª' + FORMAT(CharVar[19]) + FORMAT(CharVar[20]) + 'Ë' + FORMAT(CharVar[21]) + 'ÈÊ§';
        AnsiStr := AnsiStr + FORMAT(CharVar[22]) + 'Á' + FORMAT(CharVar[23]) + 'Ì' + FORMAT(CharVar[24]) + FORMAT(CharVar[25]);
        AnsiStr := AnsiStr + FORMAT(CharVar[26]) + '²¦»' + FORMAT(CharVar[27]) + '¡' + FORMAT(CharVar[28]) + '=¥Âº¸©' + FORMAT(CharVar[29]);
        AnsiStr := AnsiStr + '¿À' + FORMAT(CharVar[30]) + FORMAT(CharVar[31]) + FORMAT(CharVar[32]) + '_ ';
    end;

    [Scope('Internal')]
    procedure PadStrLeft(_Text: Text[250]; _Length: Integer; _Filler: Text[1]): Text[250]
    begin
        IF STRLEN(_Text) >= _Length THEN BEGIN
            EXIT(PADSTR(_Text, _Length))
        END;
        EXIT(PADSTR(_Filler, _Length - STRLEN(_Text)) + _Text)
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
    local procedure OpenExcel()
    begin
        ExcelBuffer.CreateBook(ServerFileNameExcel, 'Verkaufauftragsübersicht');
        ExcelBuffer.WriteSheet('TheHEADER', COMPANYNAME, USERID);
        ExcelBuffer.CloseBook;
        ExcelBuffer.OpenExcel;
        // ExcelBuffer.GiveUserControl;
    end;
}

