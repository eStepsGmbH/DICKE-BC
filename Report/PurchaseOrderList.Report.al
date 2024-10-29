report 50076 "Purchase Order List"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Objekt erstellt.
    DefaultLayout = RDLC;
    RDLCLayout = './PurchaseOrderList.rdlc';

    Caption = 'Purchase Order List';

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = SORTING("Buy-from Vendor No.", "Vendor Authorization No.");
            RequestFilterFields = "Buy-from Vendor No.", "Expected Receipt Date", "No.";
            column(USERID; USERID)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PAGENO)
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(Purchase_Header_BuyFromVendorNo_Caption; FIELDCAPTION("Buy-from Vendor No."))
            {
            }
            column(Purchase_Header_BuyFromVendorNo; "Buy-from Vendor No.")
            {
            }
            column(Purchase_Header_BuyFromVendorName; "Buy-from Vendor Name")
            {
            }
            column(KreditorCaption; KreditorCaption)
            {
            }
            column(BelegnrCaption; BelegnrCaption)
            {
            }
            column(ArtikelCaption; ArtikelCaption)
            {
            }
            column(BeschreibungCaption; BeschreibungCaption)
            {
            }
            column(VioCaption; VioCaption)
            {
            }
            column(VioErstelltCaption; VioErstelltCaption)
            {
            }
            column(KolliCaption; KolliCaption)
            {
            }
            column(ErwartetesWeDatumCaption; ErwartetesWeDatumCaption)
            {
            }
            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"),
                               "Buy-from Vendor No." = FIELD("Buy-from Vendor No."),
                               "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Buy-from Vendor No.", Type, "No.")
                                    WHERE("Document Type" = CONST(Order),
                                          Type = CONST(Item),
                                          Quantity = FILTER(<> 0));
                column(Purchase_Line_DocumentNo_Caption; FIELDCAPTION("Document No."))
                {
                }
                column(Purchase_Line_DocumentNo; "Document No.")
                {
                }
                column(Purchase_Line_No_Caption; FIELDCAPTION("No."))
                {
                }
                column(Purchase_Line_No; "No.")
                {
                }
                column(Purchase_Line_Description_Caption; FIELDCAPTION(Description))
                {
                }
                column(Purchase_Line_Description; Description)
                {
                }
                column(Purchase_Line_VIO_Caption; FIELDCAPTION(VIO))
                {
                }
                column(Purchase_Line_VIO; VIO)
                {
                }
                column(Purchase_Line_VIO_Creation_Date_Caption; FIELDCAPTION("VIO Creation Date"))
                {
                }
                column(Purchase_Line_VIO_Creation_Date; "VIO Creation Date")
                {
                }
                column(Purchase_Line_Toal_Item_Qty_Caption; FIELDCAPTION("Total Item Qty."))
                {
                }
                column(Purchase_Line_Toal_Item_Qty; "Total Item Qty.")
                {
                }
                column(Purchase_Line_Expected_Receipt_Date_Caption; FIELDCAPTION("Expected Receipt Date"))
                {
                }
                column(Purchase_Line_Expected_Receipt_Date; "Expected Receipt Date")
                {
                }

                trigger OnAfterGetRecord()
                var
                    PurchLine_lrec: Record "Purchase Line";
                begin

                    PurchLine_lrec.CALCFIELDS("Total Item Qty.");

                    IF "Purchase Line".Type = "Purchase Line".Type::Item THEN BEGIN
                        Item_trec.INIT;
                        Item_trec."No." := "Purchase Line"."No.";
                        IF NOT Item_trec.INSERT THEN
                            CurrReport.SKIP;
                    END;

                    IF DataExport_req THEN BEGIN
                        ExportLineText();
                        ExportFile.WRITE(Ascii2Ansi(ExportStringLine));
                        PurchLine_lrec.RESET;
                        PurchLine_lrec.SETRANGE("Document Type", "Purchase Line"."Document Type");
                        PurchLine_lrec.SETRANGE("Document No.", "Purchase Line"."Document No.");
                        PurchLine_lrec.SETRANGE(Type, "Purchase Line".Type::Item);
                        PurchLine_lrec.SETRANGE("No.", "Purchase Line"."No.");
                        IF PurchLine_lrec.FIND('-') THEN BEGIN
                            REPEAT
                                PurchLine_lrec."VIO Creation Date" := WORKDATE;
                                PurchLine_lrec.MODIFY;
                            UNTIL PurchLine_lrec.NEXT = 0;
                        END;
                    END;
                end;

                trigger OnPreDataItem()
                begin

                    LastFieldNo := FIELDNO("Document Type");
                    IF DataExport_req THEN BEGIN
                        "Purchase Line".SETFILTER("VIO Creation Date", '%1', 0D);
                        "Purchase Line".SETRANGE(VIO, TRUE);
                    END;

                    Item_trec.DELETEALL;
                end;
            }

            trigger OnAfterGetRecord()
            var
                value_ltxt: Text[250];
                PurchLines_lrec: Record "Purchase Line";
            begin

                IF DataExport_req THEN BEGIN
                    // Gibt es gültige Zeilen?
                    PurchLines_lrec.RESET;
                    PurchLines_lrec.SETRANGE("Document Type", "Purchase Header"."Document Type");
                    PurchLines_lrec.SETRANGE("Document No.", "Purchase Header"."No.");
                    PurchLines_lrec.SETFILTER("VIO Creation Date", '%1', 0D);
                    PurchLines_lrec.SETRANGE(VIO, TRUE);
                    IF NOT PurchLines_lrec.FIND('-') THEN
                        CurrReport.SKIP;

                    CLEAR(Vendor_rec);
                    Vendor_rec.RESET;
                    IF Vendor_rec.GET("Purchase Header"."Buy-from Vendor No.") THEN;
                    ExportHdrText();
                    ExportFile.WRITE(Ascii2Ansi(ExportStringHdr1) + Ascii2Ansi(ExportStringHdr2));
                END;
            end;

            trigger OnPostDataItem()
            begin

                IF DataExport_req THEN
                    ExportFile.CLOSE;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Optionen)
                {
                    Caption = 'Options';
                    field(VIO_Export; DataExport_req)
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
        SalesSetup_lrec: Record "311";
    begin

        IF DataExport_req THEN BEGIN
            SalesSetup_lrec.GET;
            SalesSetup_lrec.TESTFIELD(SalesSetup_lrec."VIO Export Path");
            FileName_req := SalesSetup_lrec."VIO Export Path" +
                            'VIO_' + FORMAT(WORKDATE, 0, '<YEAR4><Month><Day>') + '_' + FORMAT(TIME, 0, '<Hours24,2><Minutes,2><Seconds,2>') + '.txt';
            IF FileName_req = '' THEN
                ERROR('Dateiname für Textdatei fehlt!');
            ExportFile.CREATE(FileName_req);
            ExportFile.TEXTMODE(TRUE);
        END;
    end;

    var
        LastFieldNo: Integer;
        FooterPrinted: Boolean;
        Vendor_rec: Record "Vendor";
        ExportFile: File;
        ExportStringHdr1: Text[1023];
        ExportStringHdr2: Text[469];
        DataExport_req: Boolean;
        FileName_req: Text[250];
        ExportStringLine: Text[547];
        AsciiStr: Text[1024];
        AnsiStr: Text[1024];
        CharVar: array[32] of Char;
        Item_trec: Record "Item" temporary;
        KreditorCaption: Label 'Kreditor';
        BelegnrCaption: Label 'Belegnr.';
        ArtikelCaption: Label 'Artikel';
        BeschreibungCaption: Label 'Beschreibung';
        VioCaption: Label 'VIO';
        VioErstelltCaption: Label 'VIO erstellt am';
        KolliCaption: Label 'Kolli';
        ErwartetesWeDatumCaption: Label 'Erwartetes WE-Datum (Pos.)';

    [Scope('Internal')]
    procedure ExportHdrText()
    begin

        ExportStringHdr1 := PADSTR('ZEN', 3);
        ExportStringHdr1 += PADSTR('2', 1);
        ExportStringHdr1 += PADSTR('4399901854710', 14);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('001', 3);
        ExportStringHdr1 += PADSTR("Purchase Header"."No." +
                                    FORMAT("Purchase Header"."Expected Receipt Date", 0, '<Day,2><Month,2><Year,2>')
                                   , 35);
        ExportStringHdr1 += PADSTR('', 2);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 7);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 15);
        ExportStringHdr1 += PADSTR('', 3);
        ExportStringHdr1 += PADSTR('', 6);
        ExportStringHdr1 += PADSTR('', 8);
        ExportStringHdr1 += PADSTR('', 6);
        ExportStringHdr1 += PADSTR('', 8);
        ExportStringHdr1 += PADSTR('', 6);
        ExportStringHdr1 += PADSTR('', 8);
        ExportStringHdr1 += PADSTR('', 6);
        ExportStringHdr1 += PADSTR('', 8);
        ExportStringHdr1 += PADSTR('', 6);
        ExportStringHdr1 += PADSTR('0088' + "Purchase Header"."Buy-from Vendor No.", 14);
        ExportStringHdr1 += PADSTR('', 14);
        ExportStringHdr1 += PADSTR('', 35);
        ExportStringHdr1 += PADSTR(Vendor_rec.Name, 40);
        ExportStringHdr1 += PADSTR(Vendor_rec."Name 2", 40);
        ExportStringHdr1 += PADSTR(Vendor_rec.Address, 40);
        ExportStringHdr1 += PADSTR(Vendor_rec."Post Code", 10);
        ExportStringHdr1 += PADSTR(Vendor_rec.City, 40);
        ExportStringHdr1 += PADSTR('', 20);
        ExportStringHdr1 += PADSTR('', 20);

        ExportStringHdr1 += PADSTR(Vendor_rec."Country/Region Code", 1);
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
        ExportStringHdr1 += PADSTR('', 3);

        ExportStringHdr2 := PADSTR('', 3);
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
        ExportStringHdr2 += PADSTR('', 70);
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
    begin
        ExportStringLine := PADSTR('ZRG', 3);
        ExportStringLine += PADSTR('2', 1);
        ExportStringLine += PADSTR('4399901854710', 14);
        ExportStringLine += PADSTR('', 3);
        ExportStringLine += PADSTR('', 4);
        ExportStringLine += PADSTR('001', 3);
        ExportStringLine += PADSTR('', 35);
        ExportStringLine += PADSTR('', 3);

        //ExportStringLine += PADSTR('0' + "Purchase Line"."No.",14);
        IF STRLEN("Purchase Line"."No.") < 5 THEN BEGIN
            ExportStringLine += PadStrLeft(FORMAT("Purchase Line"."No."), 5, '0');
            ExportStringLine += PADSTR('', 9);
        END
        ELSE
            ExportStringLine += PADSTR("Purchase Line"."No.", 14);

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
        ExportStringLine += PadStrLeft(FORMAT("Purchase Line"."Total Item Qty."), 6, ' ');
        //ExportStringLine += PADSTR(FORMAT("Purchase Line"."Total Item Qty."),6);
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
}

