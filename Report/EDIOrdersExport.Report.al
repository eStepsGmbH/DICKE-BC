report 50084 "EDI Orders Export"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Objekt erstellt.

    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            RequestFilterFields = "Order Date", "Shipping Agent Code", "No.";
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document No." = FIELD("No."),
                               "Document Type" = FIELD("Document Type");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");

                trigger OnAfterGetRecord()
                var
                    lrec_Item: Record "Item";
                begin

                    IF "Sales Line".Type = "Sales Line".Type::Item THEN BEGIN

                        l_PositionsZaehler := l_PositionsZaehler + 1;

                        lrec_Item.RESET;
                        lrec_Item.SETRANGE("No.", "Sales Line"."No.");

                        IF lrec_Item.FIND('-') THEN BEGIN
                            IF FORMAT(lrec_Item.EAN13) = '' THEN BEGIN
                                //LIN - Positionssegment BP=Artikelnummer des Käufers
                                l_SegmentZaehler := l_SegmentZaehler + 1;
                                WriteValue(STRSUBSTNO('LIN+%1+4''', l_PositionsZaehler));
                                l_SegmentZaehler := l_SegmentZaehler + 1;
                                IF FORMAT(lrec_Item."Vendor Item No.") <> '' THEN
                                    WriteValue(STRSUBSTNO('PIA+1+%1:IN''', lrec_Item."Vendor Item No."))
                                ELSE
                                    WriteValue(STRSUBSTNO('PIA+1+%1:IN''', ConvertItemNo("No.")));
                            END ELSE BEGIN
                                //LIN - Positionssegment EN=Internationale Artikelnummer EAN
                                l_SegmentZaehler := l_SegmentZaehler + 1;
                                WriteValue(STRSUBSTNO('LIN+%1++%2:EN''', l_PositionsZaehler, lrec_Item.EAN13));
                            END;
                        END
                        ELSE BEGIN
                            //LIN - Positionssegment BP=Artikelnummer des Käufers
                            l_SegmentZaehler := l_SegmentZaehler + 1;
                            WriteValue(STRSUBSTNO('LIN+%1+4''', l_PositionsZaehler));

                            l_SegmentZaehler := l_SegmentZaehler + 1;
                            WriteValue(STRSUBSTNO('PIA+1+%1:IN''', ConvertItemNo("No.")));
                        END;

                        //QTY - Menge
                        l_SegmentZaehler := l_SegmentZaehler + 1;
                        WriteValue(STRSUBSTNO('QTY+21:%1:PCE''', CONVERTSTR(FORMAT("Sales Line".Quantity), ',', '.')));

                        l_SegmentZaehler := l_SegmentZaehler + 1;
                        WriteValue(STRSUBSTNO('QTY+21:%1:KGM''', CONVERTSTR(FORMAT("Sales Line"."Net Weight" * "Sales Line".Quantity), ',', '.')));

                        //PRI - Preisangaben
                        l_SegmentZaehler := l_SegmentZaehler + 1;
                        WriteValue(STRSUBSTNO('PRI+AAA:0::NTP::KGM''')); //AAA=Nettopreis

                    END;
                end;

                trigger OnPostDataItem()
                begin

                    // die Lines sind abgearbeitet, jetzt die Kontrollsegmente
                    // für diese Nachricht

                    //UNS - Abschnits-Kontrollsegment
                    l_SegmentZaehler := l_SegmentZaehler + 1;
                    WriteValue('UNS+S''');

                    //CNT - Count der Positionen (Anzahl LIN Saetze)
                    l_SegmentZaehler := l_SegmentZaehler + 1;
                    WriteValue(STRSUBSTNO('CNT+2+%1''', l_PositionsZaehler));

                    //UNT - Nachrichten-Schlußsegment
                    l_SegmentZaehler := l_SegmentZaehler + 1;
                    WriteValue(STRSUBSTNO('UNT+%1+%2''', l_SegmentZaehler, l_UNH_Nummer));
                end;

                trigger OnPreDataItem()
                begin
                    l_PositionsZaehler := 0;
                end;
            }

            trigger OnAfterGetRecord()
            var
                lrec_SalesLine: Record "Sales Line";
                l_Freitext: Text[1024];
                l_DummyString: Text[1024];
            begin

                l_SegmentZaehler := 0;
                l_UNH_Nummer := l_UNH_Nummer + 1;
                // UNH - Nachrichten-Kopfsegment
                l_SegmentZaehler := l_SegmentZaehler + 1;
                WriteValue(STRSUBSTNO('UNH+%1+ORDERS:D:96A:UN:EAN008''', FORMAT(l_UNH_Nummer)));

                // BGM - Beginn der Nachricht
                l_SegmentZaehler := l_SegmentZaehler + 1;
                WriteValue(STRSUBSTNO('BGM+220+%1+9''', FORMAT("No.")));

                // DTM - Datum/Uhrzeit/Zeitspanne
                l_SegmentZaehler := l_SegmentZaehler + 1;
                WriteValue(STRSUBSTNO('DTM+137:%1:102''', FormatDate(WORKDATE()))); //137=Tagesatum

                l_SegmentZaehler := l_SegmentZaehler + 1;
                WriteValue(STRSUBSTNO('DTM+171:%1:102''', FormatDate("Order Date"))); //171=Dokument Datum

                IF "Shipment Date Shipping Agent" <> 0D THEN BEGIN
                    l_SegmentZaehler := l_SegmentZaehler + 1;
                    WriteValue(STRSUBSTNO('DTM+2:%1:102''', FormatDate("Shipment Date Shipping Agent"))); //2=Gew. Lieferdatum
                END;

                IF "Promised Delivery Date" <> 0D THEN BEGIN
                    l_SegmentZaehler := l_SegmentZaehler + 1;
                    WriteValue(STRSUBSTNO('DTM+64:%1:102''', FormatDate("Promised Delivery Date"))); //64=Lieferdatum Bis
                END;

                // RFF - Reference
                IF "Sales Header"."External Document No." <> '' THEN BEGIN
                    l_SegmentZaehler := l_SegmentZaehler + 1;
                    WriteValue(STRSUBSTNO('RFF+CR:%1''', ASCII2ANSI("Sales Header"."External Document No."))); //CR=Customer Reference
                END;

                // FTX - Freitext
                // den Freitext aus den Positionen zusammensuchen
                l_Freitext := '';
                lrec_SalesLine.RESET;
                lrec_SalesLine.SETRANGE("Document No.", "No.");

                IF lrec_SalesLine.FIND('-') THEN
                    REPEAT
                        IF lrec_SalesLine.Type = 0 THEN
                            IF STRLEN(l_Freitext) + STRLEN(lrec_SalesLine.Description) < 1014 THEN BEGIN
                                l_Freitext := l_Freitext + lrec_SalesLine.Description + ' ';
                            END;
                    UNTIL (lrec_SalesLine.NEXT = 0) OR (lrec_SalesLine.Type = lrec_SalesLine.Type::Item);

                //l_SegmentZaehler := l_SegmentZaehler + 1;
                //l_DummyString := Umlaut2PlainText(l_Freitext);
                //l_DummyString := ASCII2ANSI(l_DummyString);
                //l_DummyString := 'FTX+DEL+++' + l_DummyString + '''';
                //WriteValue(l_DummyString);

                // TDT - Transportangaben
                l_SegmentZaehler := l_SegmentZaehler + 1;
                WriteValue(STRSUBSTNO('TDT+20++30++%1''', GetShippingAgentCode("Shipping Agent Code")));

                // NAD - Name und Anschrift
                l_SegmentZaehler := l_SegmentZaehler + 1;
                WriteValue(STRSUBSTNO('NAD+BY+%1::9''', ILNNo_text)); //BY=Auftraggeber 9=ILN

                l_SegmentZaehler := l_SegmentZaehler + 1;
                WriteValue(STRSUBSTNO('NAD+DP+++D%1::9''', "Sales Header"."Sell-to Customer No.")); //DP=Warenempfänger 9=ILN

                l_SegmentZaehler := l_SegmentZaehler + 1;
                WriteValue(ASCII2ANSI(STRSUBSTNO('NAD+UD+++%1+%2+%3+%4+%5::ZZZ'''
                  , "Sales Header"."Ship-to Name"
                  , "Sales Header"."Ship-to Address"
                  , "Sales Header"."Ship-to City"
                  , "Sales Header"."Ship-to Post Code"
                  , "Sales Header"."Ship-to Country/Region Code"
                  ))); //SU=Lieferant ZZZ=keine ILN

                // CUX - Währungsangaben
                l_SegmentZaehler := l_SegmentZaehler + 1;
                WriteValue('CUX+2:EUR:9''');

                // TOD - Terms of Delivery
                l_SegmentZaehler := l_SegmentZaehler + 1;
                WriteValue('TOD+10E''');

                //Auftrag steht in der EDI Datei
                SendToKirnDate := TODAY();
                SendToKirnTime := TIME();
                MODIFY;

                RowNo := RowNo + 1;
                EnterCell(RowNo, 1, FORMAT("Order Date"), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Date);
                EnterCell(RowNo, 2, "No.", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 3, "Sell-to Customer No.", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 4, "Sell-to Customer Name", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 5, "Sell-to Address", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 6, "Sell-to City", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 7, FORMAT(SendToKirnDate), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Date);
                EnterCell(RowNo, 8, FORMAT(SendToKirnTime), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Time);
            end;

            trigger OnPostDataItem()
            begin

                RowNo := RowNo + 1;
                EnterCell(RowNo, 1, 'Anzahl Nachrichten', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 2, FORMAT(l_UNH_Nummer), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                RowNo := RowNo + 1;
                EnterCell(RowNo, 1, 'Nachrichten-Id', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 2, l_EdiNachrichtenNr, TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);

                ExcelBuffer.CreateBook(ServerFileNameExcel, 'EDI-Protokoll');
                ExcelBuffer.WriteSheet('TheHEADER', COMPANYNAME, USERID);
                ExcelBuffer.CloseBook;
                ExcelBuffer.OpenExcel;
                // ExcelBuffer.GiveUserControl;
                ExcelBuffer.DELETEALL;
            end;

            trigger OnPreDataItem()
            begin
                "Sales Header".SETRANGE(SendToKirn, TRUE);
                "Sales Header".SETRANGE(SendToKirnDate, 0D);

                // ------------------------------
                // Excel Überschriften erstellen
                // ------------------------------
                EnterCell(1, 1, 'Auftrag Datum', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 2, 'Auftrag Nummer', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 3, 'Debitor Nr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 4, 'Debitor Name', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 5, 'Verk. an Adresse', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 6, 'Verk. an Ort', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 7, 'Gesendet am', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 8, 'Gesendet um', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                RowNo := 1;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

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
    begin

        "Sales Header".SETRANGE(SendToKirn, TRUE);
        "Sales Header".SETRANGE(SendToKirnDate, 0D);
        IF "Sales Header".COUNT = 0 THEN
            ERROR('Es existieren keine offenen Aufträge für den Edi Export.');
    end;

    trigger OnPostReport()
    begin

        // UNZ - EDI-Schlusssegment
        WriteValue(STRSUBSTNO('UNZ+%1+%2''', l_UNH_Nummer, l_EdiNachrichtenNr));
        l_File.CLOSE;
    end;

    trigger OnPreReport()
    var
        NoSeriesMgmt_lcu: Codeunit "396";
    begin

        ILNNo_text := '1234567890123';
        ReceiptILNo_text := '3013840800102';
        l_UNH_Nummer := 0;

        SalesSetup_rec.GET;
        SalesSetup_rec.TESTFIELD("EDI Orders Nos.");
        SalesSetup_rec.TESTFIELD("EDI Orders Export Path");

        // Neue Nachrichtennummer holen
        l_EdiNachrichtenNr := NoSeriesMgmt_lcu.GetNextNo(SalesSetup_rec."EDI Orders Nos.", WORKDATE, TRUE);

        File_txt := STRSUBSTNO('%1/order_%2.txt', SalesSetup_rec."EDI Orders Export Path", l_EdiNachrichtenNr);
        IF ERASE(File_txt) THEN;
        l_File.TEXTMODE(TRUE);

        // * Neue Datei erstellen *
        IF NOT l_File.CREATE(File_txt) THEN
            ERROR(Text001, File_txt);

        //l_File.OPEN(File_txt);
        l_File.CREATEOUTSTREAM(l_OutStream);

        // Nachrichtenzaehler initialisieren
        l_NachrichtenNummer := 0;

        // UNB - Nutzdatenkopfsegment
        WriteValue(STRSUBSTNO('UNB+UNOA:3+%1:14+%2:14+%3:%4+%5'''
           , ILNNo_text, ReceiptILNo_text, FormatDate2(WORKDATE), FormatTime(TIME), l_EdiNachrichtenNr));
    end;

    var
        File_txt: Text[250];
        l_OutStream: OutStream;
        l_File: File;
        l_NachrichtenNummer: Integer;
        l_EdiNachrichtenNr: Code[10];
        l_SegmentZaehler: Integer;
        l_PositionsZaehler: Integer;
        ILNNo_text: Code[20];
        ReceiptILNo_text: Code[20];
        SalesSetup_rec: Record "Sales & Receivables Setup";
        l_UNH_Nummer: Integer;
        Text001: Label 'Datei %1 konnte nicht erstellt werden!';
        ServerFileNameExcel: Text;
        ExcelBuffer: Record "370" temporary;
        RowNo: Integer;

    [Scope('Internal')]
    procedure FormatDate(Par1Date: Date): Text[30]
    var
        txtFormatDate: Text[100];
    begin
        //DATE2DMY
        //1=Day (1-31)
        //2=Month (1-12)
        //3=Year

        IF Par1Date = 0D THEN BEGIN
            txtFormatDate := '000000';
        END ELSE BEGIN
            txtFormatDate := COPYSTR(FORMAT(DATE2DMY(Par1Date, 3)), 1, 4) +
                                     coFuellen(FORMAT(DATE2DMY(Par1Date, 2)), 2) +
                                     coFuellen(FORMAT(DATE2DMY(Par1Date, 1)), 2);
        END;
        EXIT(txtFormatDate);
    end;

    [Scope('Internal')]
    procedure FormatDate2(Par1Date: Date): Text[30]
    var
        txtFormatDate: Text[100];
    begin
        //DATE2DMY
        //1=Day (1-31)
        //2=Month (1-12)
        //3=Year

        IF Par1Date = 0D THEN BEGIN
            txtFormatDate := '000000';
        END ELSE BEGIN
            txtFormatDate := COPYSTR(FORMAT(DATE2DMY(Par1Date, 3)), 3, 2) +
                                     coFuellen(FORMAT(DATE2DMY(Par1Date, 2)), 2) +
                                     coFuellen(FORMAT(DATE2DMY(Par1Date, 1)), 2);
        END;
        EXIT(txtFormatDate);
    end;

    [Scope('Internal')]
    procedure FormatTime(Par1Time: Time): Text[5]
    var
        l_Time: Text[30];
    begin
        l_Time := FORMAT(Par1Time);
        l_Time := COPYSTR(l_Time, 1, 2);
        l_Time := l_Time + COPYSTR(FORMAT(Par1Time), 4, 2);
        EXIT(l_Time);
    end;

    [Scope('Internal')]
    procedure coFuellen(lvNummer: Text[100]; lvStellen: Integer): Text[100]
    var
        i: Integer;
        lvNeueNummer: Text[100];
    begin
        lvNeueNummer := lvNummer;
        FOR i := 1 TO (lvStellen - STRLEN(lvNeueNummer)) DO
            lvNeueNummer := '0' + lvNeueNummer;

        EXIT(lvNeueNummer);
    end;

    [Scope('Internal')]
    procedure ANSI2ASCII(Text: Text[1024]): Text[1024]
    var
        i: Integer;
    begin
        FOR i := 1 TO STRLEN(Text) DO BEGIN
            CASE Text[i] OF
                //  ANSI             ASCII
                131:
                    Text[i] := 159;  // ƒ
                161:
                    Text[i] := 173;  // ¡
                162:
                    Text[i] := 189;  // ¢
                163:
                    Text[i] := 156;  // £
                164:
                    Text[i] := 207;  // ¤
                165:
                    Text[i] := 190;  // ¥
                166:
                    Text[i] := 221;  // ¦
                167:
                    Text[i] := 245;  // §
                168:
                    Text[i] := 249;  // ¨
                169:
                    Text[i] := 184;  // ©
                170:
                    Text[i] := 166;  // ª
                171:
                    Text[i] := 174;  // «
                173:
                    Text[i] := 240;  // ­
                174:
                    Text[i] := 169;  // ®
                175:
                    Text[i] := 238;  // ¯
                176:
                    Text[i] := 167;  // °
                177:
                    Text[i] := 241;  // ±
                178:
                    Text[i] := 253;  // ²
                179:
                    Text[i] := 252;  // ³
                180:
                    Text[i] := 239;  // ´
                181:
                    Text[i] := 230;  // µ
                182:
                    Text[i] := 244;  // ¶
                183:
                    Text[i] := 250;  // ·
                184:
                    Text[i] := 247;  // ¸
                185:
                    Text[i] := 251;  // ¹
                187:
                    Text[i] := 175;  // »
                188:
                    Text[i] := 172;  // ¼
                189:
                    Text[i] := 171;  // ½
                190:
                    Text[i] := 243;  // ¾
                191:
                    Text[i] := 168;  // ¿
                192:
                    Text[i] := 183;  // À
                193:
                    Text[i] := 181;  // Á
                194:
                    Text[i] := 182;  // Â
                195:
                    Text[i] := 199;  // Ã
                196:
                    Text[i] := 142;  // Ä
                197:
                    Text[i] := 143;  // Å
                198:
                    Text[i] := 146;  // Æ
                199:
                    Text[i] := 128;  // Ç
                200:
                    Text[i] := 212;  // È
                201:
                    Text[i] := 144;  // É
                202:
                    Text[i] := 210;  // Ê
                203:
                    Text[i] := 211;  // Ë
                204:
                    Text[i] := 222;  // Ì
                205:
                    Text[i] := 214;  // Í
                206:
                    Text[i] := 215;  // Î
                207:
                    Text[i] := 216;  // Ï
                208:
                    Text[i] := 209;  // Ð
                209:
                    Text[i] := 165;  // Ñ
                210:
                    Text[i] := 227;  // Ò
                211:
                    Text[i] := 224;  // Ó
                212:
                    Text[i] := 226;  // Ô
                213:
                    Text[i] := 229;  // Õ
                214:
                    Text[i] := 153;  // Ö
                215:
                    Text[i] := 158;  // ×
                216:
                    Text[i] := 157;  // Ø
                217:
                    Text[i] := 235;  // Ù
                218:
                    Text[i] := 233;  // Ú
                219:
                    Text[i] := 234;  // Û
                220:
                    Text[i] := 154;  // Ü
                221:
                    Text[i] := 237;  // Ý
                222:
                    Text[i] := 232;  // Þ
                223:
                    Text[i] := 225;  // ß
                224:
                    Text[i] := 133;  // à
                225:
                    Text[i] := 160;  // á
                226:
                    Text[i] := 131;  // â
                227:
                    Text[i] := 198;  // ã
                228:
                    Text[i] := 132;  // ä
                229:
                    Text[i] := 134;  // å
                230:
                    Text[i] := 145;  // æ
                231:
                    Text[i] := 135;  // ç
                232:
                    Text[i] := 138;  // è
                233:
                    Text[i] := 130;  // é
                234:
                    Text[i] := 136;  // ê
                235:
                    Text[i] := 137;  // ë
                236:
                    Text[i] := 141;  // ì
                237:
                    Text[i] := 161;  // í
                238:
                    Text[i] := 140;  // î
                239:
                    Text[i] := 139;  // ï
                240:
                    Text[i] := 208;  // ð
                241:
                    Text[i] := 164;  // ñ
                242:
                    Text[i] := 149;  // ò
                243:
                    Text[i] := 162;  // ó
                244:
                    Text[i] := 147;  // ô
                245:
                    Text[i] := 228;  // õ
                246:
                    Text[i] := 148;  // ö
                247:
                    Text[i] := 246;  // ÷
                248:
                    Text[i] := 155;  // ø
                249:
                    Text[i] := 151;  // ù
                250:
                    Text[i] := 163;  // ú
                251:
                    Text[i] := 150;  // û
                252:
                    Text[i] := 129;  // ü
                253:
                    Text[i] := 236;  // ý
                254:
                    Text[i] := 231;  // þ
                255:
                    Text[i] := 152;  // ÿ
            END;
        END;
        EXIT(Text);
    end;

    [Scope('Internal')]
    procedure ASCII2ANSI(Text: Text[1024]): Text[1024]
    var
        i: Integer;
    begin
        Text := Umlaut2PlainText(Text);

        FOR i := 1 TO STRLEN(Text) DO BEGIN
            CASE Text[i] OF
                //  ASCII            ANSI
                159:
                    Text[i] := 131;  // ƒ
                173:
                    Text[i] := 161;  // ¡
                189:
                    Text[i] := 162;  // ¢
                156:
                    Text[i] := 163;  // £
                207:
                    Text[i] := 164;  // ¤
                190:
                    Text[i] := 165;  // ¥
                221:
                    Text[i] := 166;  // ¦
                245:
                    Text[i] := 167;  // §
                249:
                    Text[i] := 168;  // ¨
                184:
                    Text[i] := 169;  // ©
                166:
                    Text[i] := 170;  // ª
                174:
                    Text[i] := 171;  // «
                240:
                    Text[i] := 173;  // ­
                169:
                    Text[i] := 174;  // ®
                238:
                    Text[i] := 175;  // ¯
                167:
                    Text[i] := 176;  // °
                241:
                    Text[i] := 177;  // ±
                253:
                    Text[i] := 178;  // ²
                252:
                    Text[i] := 179;  // ³
                239:
                    Text[i] := 180;  // ´
                230:
                    Text[i] := 181;  // µ
                244:
                    Text[i] := 182;  // ¶
                250:
                    Text[i] := 183;  // ·
                247:
                    Text[i] := 184;  // ¸
                251:
                    Text[i] := 185;  // ¹
                175:
                    Text[i] := 187;  // »
                172:
                    Text[i] := 188;  // ¼
                171:
                    Text[i] := 189;  // ½
                243:
                    Text[i] := 190;  // ¾
                168:
                    Text[i] := 191;  // ¿
                183:
                    Text[i] := 192;  // À
                181:
                    Text[i] := 193;  // Á
                182:
                    Text[i] := 194;  // Â
                199:
                    Text[i] := 195;  // Ã
                142:
                    Text[i] := 196;  // Ä
                143:
                    Text[i] := 197;  // Å
                146:
                    Text[i] := 198;  // Æ
                128:
                    Text[i] := 199;  // Ç
                212:
                    Text[i] := 200;  // È
                144:
                    Text[i] := 201;  // É
                210:
                    Text[i] := 202;  // Ê
                211:
                    Text[i] := 203;  // Ë
                222:
                    Text[i] := 204;  // Ì
                214:
                    Text[i] := 205;  // Í
                215:
                    Text[i] := 206;  // Î
                216:
                    Text[i] := 207;  // Ï
                209:
                    Text[i] := 208;  // Ð
                165:
                    Text[i] := 209;  // Ñ
                227:
                    Text[i] := 210;  // Ò
                224:
                    Text[i] := 211;  // Ó
                226:
                    Text[i] := 212;  // Ô
                229:
                    Text[i] := 213;  // Õ
                153:
                    Text[i] := 214;  // Ö
                158:
                    Text[i] := 215;  // ×
                157:
                    Text[i] := 216;  // Ø
                235:
                    Text[i] := 217;  // Ù
                233:
                    Text[i] := 218;  // Ú
                234:
                    Text[i] := 219;  // Û
                154:
                    Text[i] := 220;  // Ü
                237:
                    Text[i] := 221;  // Ý
                232:
                    Text[i] := 222;  // Þ
                225:
                    Text[i] := 223;  // ß
                133:
                    Text[i] := 224;  // à
                160:
                    Text[i] := 225;  // á
                131:
                    Text[i] := 226;  // â
                198:
                    Text[i] := 227;  // ã
                132:
                    Text[i] := 228;  // ä
                134:
                    Text[i] := 229;  // å
                145:
                    Text[i] := 230;  // æ
                135:
                    Text[i] := 231;  // ç
                138:
                    Text[i] := 232;  // è
                130:
                    Text[i] := 233;  // é
                136:
                    Text[i] := 234;  // ê
                137:
                    Text[i] := 235;  // ë
                141:
                    Text[i] := 236;  // ì
                161:
                    Text[i] := 237;  // í
                140:
                    Text[i] := 238;  // î
                139:
                    Text[i] := 239;  // ï
                208:
                    Text[i] := 240;  // ð
                164:
                    Text[i] := 241;  // ñ
                149:
                    Text[i] := 242;  // ò
                162:
                    Text[i] := 243;  // ó
                147:
                    Text[i] := 244;  // ô
                228:
                    Text[i] := 245;  // õ
                148:
                    Text[i] := 246;  // ö
                246:
                    Text[i] := 247;  // ÷
                155:
                    Text[i] := 248;  // ø
                151:
                    Text[i] := 249;  // ù
                163:
                    Text[i] := 250;  // ú
                150:
                    Text[i] := 251;  // û
                129:
                    Text[i] := 252;  // ü
                236:
                    Text[i] := 253;  // ý
                231:
                    Text[i] := 254;  // þ
                152:
                    Text[i] := 255;  // ÿ
            END;
        END;
        EXIT(Text);
    end;

    [Scope('Internal')]
    procedure WriteValue(Text: Text[1024])
    begin
        l_OutStream.WRITETEXT(Text);
        //l_File.Write(Text);
    end;

    [Scope('Internal')]
    procedure ConvertItemNo(ItemNo: Text[250]): Text[250]
    begin
        //nur die letzten 4 Stellen
        IF STRLEN(ItemNo) <= 4 THEN
            EXIT(ItemNo);

        EXIT(COPYSTR(ItemNo, STRLEN(ItemNo) - 3, 4));
    end;

    [Scope('Internal')]
    procedure AddChar(var Text: Text[1024]; NewText: Text[30]; var NewTextPos: Integer)
    var
        Counter: Integer;
    begin
        FOR Counter := 1 TO STRLEN(NewText) DO BEGIN
            IF NewTextPos < MAXSTRLEN(Text) THEN BEGIN
                NewTextPos += 1;
                Text[NewTextPos] := NewText[Counter];
            END;
        END;
    end;

    [Scope('Internal')]
    procedure Umlaut2PlainText(Text: Text[1024]) NewText: Text[1024]
    var
        J: Integer;
        I: Integer;
    begin
        J := 0;
        FOR I := 1 TO STRLEN(Text) DO
            CASE Text[I] OF
                'Ä', 'Å', 'Æ':
                    AddChar(NewText, 'AE', J);
                'ä', 'å', 'æ':
                    AddChar(NewText, 'ae', J);
                'Á', 'À', 'Â', 'Ã':
                    AddChar(NewText, 'A', J);
                'á', 'à', 'â', 'ã':
                    AddChar(NewText, 'a', J);

                'Ç':
                    AddChar(NewText, 'C', J);
                'ç':
                    AddChar(NewText, 'c', J);

                'Ð':
                    AddChar(NewText, 'D', J);
                'ð':
                    AddChar(NewText, 'd', J);

                'É', 'È', 'Ê', 'Ë':
                    AddChar(NewText, 'E', J);
                'é', 'è', 'ê', 'ë':
                    AddChar(NewText, 'e', J);

                'Í', 'Ì', 'Î', 'Ï':
                    AddChar(NewText, 'I', J);
                'í', 'ì', 'î', 'ï':
                    AddChar(NewText, 'i', J);

                'Ñ':
                    AddChar(NewText, 'N', J);
                'ñ':
                    AddChar(NewText, 'n', J);

                'Ö', 'Ø':
                    AddChar(NewText, 'OE', J);
                'ö', 'ø':
                    AddChar(NewText, 'oe', J);
                'Ó', 'Ò', 'Ô', 'Õ':
                    AddChar(NewText, 'O', J);
                'ó', 'ò', 'ô', 'õ':
                    AddChar(NewText, 'o', J);

                'Ü':
                    AddChar(NewText, 'UE', J);
                'ü':
                    AddChar(NewText, 'ue', J);
                'Ú', 'Ù', 'Û':
                    AddChar(NewText, 'U', J);
                'ú', 'ù', 'û':
                    AddChar(NewText, 'u', J);

                'Ý':
                    AddChar(NewText, 'Y', J);
                'ý', 'ÿ':
                    AddChar(NewText, 'y', J);

                'ß':
                    AddChar(NewText, 'ss', J);

                '©':
                    AddChar(NewText, '(c)', J);
                '®':
                    AddChar(NewText, '(r)', J);
                '«':
                    AddChar(NewText, '<<', J);
                '»':
                    AddChar(NewText, '>>', J);
                '¼':
                    AddChar(NewText, '1/4', J);
                '½':
                    AddChar(NewText, '1/2', J);
                '¾':
                    AddChar(NewText, '3/4', J);
                ELSE
                    AddChar(NewText, FORMAT(Text[I]), J);
            END;
    end;

    [Scope('Internal')]
    procedure GetShippingAgentCode(ShippingAgentCode: Code[10]): Code[10]
    begin
        //ALB = Albatros -> T5
        //KIRN = Kirn -> T18
        //NAG = Nagel -> T22
        //DIS = Dischinger -> T23
        //EHG,SÜDWE = leer

        CASE ShippingAgentCode OF
            'ALB':
                BEGIN
                    EXIT('T5');
                END;
            'KIRN':
                BEGIN
                    EXIT('T0');
                END;
            'NAG':
                BEGIN
                    EXIT('T22');
                END;
            'DIS':
                BEGIN
                    EXIT('T23');
                END;
        END;
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

