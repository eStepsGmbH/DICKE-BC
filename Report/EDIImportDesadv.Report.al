report 50088 "EDI Import Desadv"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Objekt erstellt.
    // 
    //  No.   Date       Version Changes
    //  --------------------------------------------------------------------------------
    //  DIC01 10.08.2020 17.2.01 Modify functions:

    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            var
                DummyString_ltxt: Text[1000];
            begin
                // Keine Datei ausgewählt?
                IF (FilePath_txt = '') THEN
                    CurrReport.BREAK;
                // Datei am Ende?
                IF FileOperator_fil.POS = FileOperator_fil.LEN THEN
                    CurrReport.BREAK;
                //Nächste Zeile einlesen
                FileOperator_fil.READ(ImportString);
                // letztes ' in der Zeile abschneiden
                ImportString := COPYSTR(ImportString, 1, (STRLEN(ImportString) - 1));
                //Sicherung der Zeile anlegen
                ImportString_Backup := ImportString;

                //Zeile analysieren
                CheckString := Token(ImportString, ':');
                IF STRPOS(CheckString, 'UNH+') = 1 THEN BEGIN
                    //Es beginnt eine neue DESADV Meldung
                    ActualSection := 'UNH';
                    ActualSalesHeaderNo := '';
                    ActualDeliveryDate := '';
                END;
                IF STRPOS(CheckString, 'LIN+') = 1 THEN BEGIN
                    //LIN+1++3384080002824:EN'
                    //Es beginnt eine neue Zeile (LIN)
                    ActualSection := 'LIN';
                    DummyString_ltxt := Token(CheckString, '+');
                    DummyString_ltxt := Token(CheckString, '+');
                    DummyString_ltxt := Token(CheckString, '+');
                    ActualItemNo := CheckString;
                    ActualItemId := '';
                    ActualQuantity := 0;
                END;

                //UNH Informationen einlesen >>>
                IF (ActualSection = 'UNH') AND (CheckString = 'DTM+17') THEN BEGIN
                    //in dieser Zeile steht das Lieferdatum
                    //DTM+17:201309250000:203'
                    //203:ccyymmddhhmm
                    CheckString := Token(ImportString, ':');
                    ActualDeliveryDate := ConvertEdiDate(CheckString);
                END;
                IF (ActualSection = 'UNH') AND (CheckString = 'RFF+ON') THEN BEGIN
                    //in dieser Zeile steht die Auftragsnummer (+ON = Order Bumber)
                    //RFF+ON:674766'
                    ActualSalesHeaderNo := ImportString;
                    LineId := 0;
                END;
                IF (ActualSection = 'UNH') AND (CheckString = 'CPS+1') THEN BEGIN
                    ActualPackageCountStart := TRUE;
                END;
                IF (ActualSection = 'UNH') AND (STRPOS(CheckString, 'PAC+') = 1) AND (ActualPackageCountStart) THEN BEGIN
                    //in dieser Zeile steht die Colli Anzahl
                    //PAC+1+::5E+X1::9'
                    DummyString_ltxt := Token(CheckString, '+');
                    DummyString_ltxt := Token(CheckString, '+');
                    IF EVALUATE(ActualPackageCount, DummyString_ltxt) THEN;
                END;
                IF (ActualSection = 'UNH') AND (CheckString = 'MEA+PD+AAD+KGM') AND (ActualPackageCountStart) THEN BEGIN
                    //in dieser Zeile steht das Gewicht
                    //MEA+PD+AAD+KGM:20.720'
                    IF EVALUATE(ActualWeight, Replace(ImportString, '.', ',')) THEN;
                    ActualPackageCountStart := FALSE;
                    InsertHeader(ActualSalesHeaderNo, ActualDeliveryDate, ActualWeight, ActualPackageCount);
                END;
                //UNH Informationen einlesen <<<

                //DIC01:est.uki >>>
                IF (STRPOS(CheckString, 'DTM+36') = 1) THEN BEGIN
                    //DTM+36:20200812:102'
                    CheckString := Token(ImportString, ':');
                    IF STRLEN(CheckString) = 8 THEN BEGIN
                        EVALUATE(MinimumDurabilityDate, COPYSTR(CheckString, 7, 2) + COPYSTR(CheckString, 5, 2) + COPYSTR(CheckString, 1, 4));
                    END;
                END;
                //DIC01:est.uki <<<

                //LIN Informationen einlesen >>>
                IF (ActualSection = 'LIN') AND (STRPOS(CheckString, 'PIA+1') = 1) THEN BEGIN
                    DummyString_ltxt := Token(CheckString, '+');
                    DummyString_ltxt := Token(CheckString, '+');
                    ActualItemId := CheckString;
                END;
                IF (ActualSection = 'LIN') AND (STRPOS(CheckString, 'QTY+12') = 1) THEN BEGIN
                    //QTY+12:2:PCE'
                    CheckString := Token(ImportString, ':');
                    IF ImportString = 'PCE' THEN BEGIN
                        IF EVALUATE(ActualQuantity, CheckString) THEN;
                        InsertLine(ActualSalesHeaderNo, ActualItemNo, ActualItemId, ActualQuantity);
                    END;
                    //QTY+12:3.430:KGM'
                    IF ImportString = 'KGM' THEN BEGIN
                        IF EVALUATE(ActualQuantity, Replace(CheckString, '.', ',')) THEN;
                        InsertLine(ActualSalesHeaderNo, ActualItemNo, ActualItemId, ActualQuantity);
                    END;
                END;
                //LIN Informationen einlesen <<<
            end;

            trigger OnPreDataItem()
            begin
                ActualPackageCountStart := FALSE;
                //DIC01:est.uki >>>
                //EDITransfer_rec.CHANGECOMPANY(COMPANYNAME);
                //DIC01:est.uki <<<
                EDITransfer_rec.RESET;

                IF (FilePath_txt = '') AND (EDITransfer_rec.COUNT = 0) THEN
                    //es wurde keine Datei ausgewählt und für den aktuellen
                    //Mandanten stehen keine Datensätze mehr in der Import Tabelle
                    CurrReport.BREAK;

                IF (FilePath_txt <> '') THEN BEGIN
                    //Die Desadv EDI Datei öffnen
                    FileOperator_fil.TEXTMODE(TRUE);
                    FileOperator_fil.WRITEMODE(FALSE);
                    FileOperator_fil.OPEN(FilePath_txt);
                END;

                // ------------------------------
                // Excel Überschriften erstellen
                // ------------------------------
                EnterCell(1, 1, 'Auftrag Datum', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 2, 'Debitor Nr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 3, 'Auftrag Nummer', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 4, 'Debitor Name', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 5, 'Verk. an Adresse', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 6, 'Verk. an Ort', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                //DIC01:est.uki >>>
                EnterCell(1, 7, 'EK Bestellung', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                //DIC01:est.uki <<<
                RowNo := 1;

                //vor dem Import die vorhandenen Daten löschen
                EDITransfer_rec.DELETEALL(TRUE);

                //DIC01:est.uki >>>
                CASE COMPANYNAME OF
                    'Dicke Gourmet Konzepte':
                        SalesHeaderCheckDigit := '8';
                    'Dicke Food':
                        SalesHeaderCheckDigit := '4';
                    'Münnich fromage GmbH & Co. KG':
                        SalesHeaderCheckDigit := '6';
                END;
                //DIC01:est.uki <<<
            end;
        }
        dataitem(Integer_EdiTransfer; Integer)
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            begin
                IF FirstRecord = FALSE THEN BEGIN
                    IF NOT EDITransfer_rec.FINDSET THEN
                        CurrReport.BREAK;
                    FirstRecord := TRUE;
                END ELSE BEGIN
                    IF EDITransfer_rec.NEXT = 0 THEN
                        CurrReport.BREAK;
                END;
                //Für diesen Mandanten die Zeilen durchgehen
                ProcessDesadvLine();
            end;

            trigger OnPostDataItem()
            var
                PurchaseHeader: Record "38";
            begin
                //DIC01 est.uki >>>
                IF BookPurchaseOrder THEN BEGIN
                    MultiTemp_trec.RESET;
                    IF MultiTemp_trec.FINDSET THEN
                        REPEAT
                            PurchaseHeader.RESET;
                            PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
                            PurchaseHeader.SETRANGE("No.", MultiTemp_trec.TextKey);
                            IF PurchaseHeader.FINDFIRST THEN
                                PurchaseHeader.Receive := TRUE;
                            PurchaseHeader.Invoice := FALSE;
                            CODEUNIT.RUN(CODEUNIT::"Purch.-Post", PurchaseHeader);
                        UNTIL MultiTemp_trec.NEXT = 0;
                END;
                //DIC01 est.uki <<<

                CASE COMPANYNAME OF
                    'Münnich fromage GmbH & Co. KG':
                        //gibt es für diesen Mandanten etwas zu verarbeiten?
                        IF OrderCountMuennich > 0 THEN
                            MESSAGE(STRSUBSTNO(Text007, 'Münnich fromage GmbH & Co. KG'));
                    'Dicke Gourmet Konzepte':
                        //gibt es für diesen Mandanten etwas zu verarbeiten?
                        IF OrderCountDicke > 0 THEN
                            MESSAGE(STRSUBSTNO(Text007, 'Dicke Food'));
                    'Dicke Food':
                        //gibt es für diesen Mandanten etwas zu verarbeiten?
                        IF OrderCountGourmet > 0 THEN
                            MESSAGE(STRSUBSTNO(Text007, 'Dicke Gourmet Konzepte'));
                    ELSE
                        MESSAGE(STRSUBSTNO('Mandant %1 wird nicht verarbeitet.', COMPANYNAME));
                END;

                EDITransfer_rec.DELETEALL(TRUE);
                ExcelBuffer.CreateBook(ServerFileNameExcel, 'Import Kirn Desadv Daten');
                ExcelBuffer.WriteSheet('TheHEADER', COMPANYNAME, USERID);
                ExcelBuffer.CloseBook;
                ExcelBuffer.OpenExcel;
                //ExcelBuffer.GiveUserControl;
                ExcelBuffer.DELETEALL;
            end;

            trigger OnPreDataItem()
            begin
                FirstRecord := FALSE;
                //DIC01:est.uki >>>
                //EDITransfer_rec.FIND('-');
                //EDITransfer_rec.CHANGECOMPANY(COMPANYNAME);
                EDITransfer_rec.RESET;
                //DIC01:est.uki <<<

                IF (OrderCountGourmet = 0) AND (OrderCountDicke = 0) AND (OrderCountMuennich = 0) AND (EDITransfer_rec.COUNT = 0) THEN
                    CurrReport.BREAK;

                CASE COMPANYNAME OF
                    'Münnich fromage GmbH & Co. KG':
                        //gibt es für diesen Mandanten etwas zu verarbeiten?
                        IF EDITransfer_rec.COUNT = 0 THEN
                            MESSAGE(STRSUBSTNO(Text005, COMPANYNAME, 'Münnich fromage GmbH & Co. KG'));
                    'Dicke Gourmet Konzepte':
                        //gibt es für diesen Mandanten etwas zu verarbeiten?
                        IF EDITransfer_rec.COUNT = 0 THEN
                            MESSAGE(STRSUBSTNO(Text005, COMPANYNAME, 'Dicke Food'));
                    'Dicke Food':
                        //gibt es für diesen Mandanten etwas zu verarbeiten?
                        IF EDITransfer_rec.COUNT = 0 THEN
                            MESSAGE(STRSUBSTNO(Text005, COMPANYNAME, 'Dicke Gourmet Konzepte'));
                    ELSE
                        MESSAGE(STRSUBSTNO('Mandant %1 wird nicht verarbeitet.', COMPANYNAME));
                END;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Einstellungen)
                {
                    Caption = 'Einstellungen';
                    field(ImportOption; ImportOption)
                    {
                        Caption = 'EDI Import Verarbeitung';

                        trigger OnValidate()
                        begin
                            IF ImportOption = ImportOption::Verkauf THEN
                                BookPurchaseOrder := FALSE;
                        end;
                    }
                    field(BookPurchaseOrder; BookPurchaseOrder)
                    {
                        Caption = 'Erzeugte EK-Bestellungen liefern';
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
        OrderCountDicke := 0;
        OrderCountGourmet := 0;
        OrderCountMuennich := 0;
        //DIC01:est.uki >>>
        SalesReceivablesSetup.GET;
        ImportOption := SalesReceivablesSetup."GUO Import Processing";
        IF ImportOption = ImportOption::"Verkauf u. Einkauf" THEN
            BookPurchaseOrder := TRUE;
        MultiTemp_trec.DELETEALL();
        //DIC01:est.uki <<<
    end;

    trigger OnPreReport()
    var
        FileManagement: Codeunit "419";
        Text028: Label 'Import File';
    begin
        FilePath_txt := FileManagement.ServerTempFileName('.edi');
        UPLOAD(Text028, '', 'EDI Dateien (*.edi)|*.edi|Alle Dateien (*.*)|*.*', '', FilePath_txt);
    end;

    var
        "*** File Dialog ***": Integer;
        DialogDefaultFileType: Option " ",Text,Excel,Word,Custom;
        DialogAction: Option Open,Save;
        "*** File Operation ***": Integer;
        FilePath_txt: Text[500];
        FileOperator_fil: File;
        "*** File Line ***": Integer;
        ImportString: Text[1000];
        EDITransfer_rec: Record "50009";
        OrderCountDicke: Integer;
        OrderCountGourmet: Integer;
        OrderCountMuennich: Integer;
        ActualSection: Text[250];
        ImportString_Backup: Text[1000];
        CheckString: Text[1000];
        "*** Order Vars ***": Integer;
        ActualSalesHeaderNo: Code[20];
        ActualItemNo: Code[20];
        ActualItemId: Code[20];
        ActualQuantity: Decimal;
        ActualDeliveryDate: Text[10];
        ActualWeight: Decimal;
        ActualPackageCount: Decimal;
        ActualPackageCountStart: Boolean;
        FirstRecord: Boolean;
        LineId: Integer;
        Error_Text: Text[1000];
        SalesHeader_lrec: Record "Sales Header";
        SalesLine_lrec: Record "Sales Line";
        Text001: Label 'Artikel %1 im Artikelstamm nicht gefunden.';
        Text002: Label 'Die Mengentoleranz von %1 wurde für Auftrag %2 Artikel %3 %4 (Org: %5 Imp: %6)';
        Text003: Label 'Auftrag %1 wurde im System nicht gefunden.';
        Text004: Label 'Artikel %1 im Auftrag %2 nicht gefunden.';
        Text005: Label 'Für den aktuellen Mandanten "%1" gibt es keine Datensätze zu verarbeiten. Wechseln Sie daher bitte in den Mandanten "%2".';
        Text006: Label 'Es wurde eine Menge von 0 geliefert.';
        Text007: Label 'Für den Mandanten "%1" sind ebenfalls Aufträge vorhanden. Wechseln Sie daher bitte in den Mandanten "%1".';
        ServerFileNameExcel: Text;
        ExcelBuffer: Record "370" temporary;
        RowNo: Integer;
        SalesHeaderCheckDigit: Code[1];
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        MultiTemp_trec: Record "50008" temporary;
        BookPurchaseOrder: Boolean;
        ImportOption: Option Verkauf,"Verkauf u. Einkauf";
        MinimumDurabilityDate: Date;

    [Scope('Internal')]
    procedure ProcessDesadvLine()
    var
        ItemNo_lcod: Code[20];
        SalesReceivablesSetup_lrec: Record "Sales & Receivables Setup";
        EdiBookingTolerance_ldec: Decimal;
        ToleranceValue_ldec: Decimal;
        ArchiveManagement_lcu: Codeunit "5063";
        PurchaseLine_lrec: Record "Purchase Line";
    begin
        EdiBookingTolerance_ldec := 0;
        Error_Text := '';
        IF SalesReceivablesSetup_lrec.GET() THEN
            EdiBookingTolerance_ldec := SalesReceivablesSetup_lrec."EDI Import Booking Tolerance";
        CASE EDITransfer_rec.MsgTyp OF
            'Header':
                BEGIN
                    //Sales Header hat gewechselt
                    ActualSalesHeaderNo := EDITransfer_rec."a50#2";
                    IF SalesHeader_lrec.GET(SalesHeader_lrec."Document Type"::Order, ActualSalesHeaderNo) THEN BEGIN
                        UpdateHeaderData(ActualSalesHeaderNo);
                        //Textbaustein 'R' hinzufügen
                        InsertPositionHeadText(ActualSalesHeaderNo, EDITransfer_rec."a50#1",
                          FORMAT(SalesHeader_lrec."Order Date"), SalesHeader_lrec."No.");
                    END ELSE BEGIN
                        Error_Text := Error_Text + STRSUBSTNO(Text003, ActualSalesHeaderNo);
                        EXIT;
                    END;
                END;
            'Line':
                BEGIN
                    //Zeile innerhalb eines Auftrages
                    ActualSalesHeaderNo := EDITransfer_rec."a50#2";
                    ActualItemNo := EDITransfer_rec."a50#3";
                    ActualItemId := EDITransfer_rec."a50#4";
                    //Artikel ermitteln
                    ItemNo_lcod := GetItemNo(ActualItemNo, ActualItemId);
                    IF STRLEN(ItemNo_lcod) > 0 THEN BEGIN
                        //Artikelzeile im Auftrag finden
                        SalesLine_lrec.RESET;
                        SalesLine_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
                        SalesLine_lrec.SETRANGE("Document No.", ActualSalesHeaderNo);
                        SalesLine_lrec.SETRANGE(Type, SalesLine_lrec.Type::Item);
                        SalesLine_lrec.SETRANGE("No.", ItemNo_lcod);
                        IF SalesLine_lrec.FINDFIRST() THEN BEGIN
                            //Artikelzeile im Auftrag gefunden
                            //Spezialauftrag entfernen falls vorhanden
                            IF SalesLine_lrec."Purchasing Code" <> '' THEN
                                SalesLine_lrec.DeactivateSpecialOrderInfos(SalesLine_lrec);
                            ToleranceValue_ldec := (SalesLine_lrec.Quantity / 100) * EdiBookingTolerance_ldec;
                            IF EDITransfer_rec."d1#1" = 0 THEN
                                //Menge 0 wurde geliefert
                                Error_Text := Error_Text + Text006;
                            IF EDITransfer_rec."d1#1" < SalesLine_lrec.Quantity - ToleranceValue_ldec THEN
                                //Buchungstoleranz nach unten überschritten
                                Error_Text := Error_Text + STRSUBSTNO(Text002, ToleranceValue_ldec, ActualSalesHeaderNo, ItemNo_lcod,
                    'unterschritten', SalesLine_lrec.Quantity, EDITransfer_rec."d1#1");
                            IF EDITransfer_rec."d1#1" > SalesLine_lrec.Quantity + ToleranceValue_ldec THEN
                                //Buchungstoleranz nach oben überschritten
                                Error_Text := Error_Text + STRSUBSTNO(Text002, ToleranceValue_ldec, ActualSalesHeaderNo, ItemNo_lcod,
                    'überschritten', SalesLine_lrec.Quantity, EDITransfer_rec."d1#1");
                            //Menge in die Auftragszeile eintragen
                            SalesLine_lrec.VALIDATE(Quantity, EDITransfer_rec."d1#1");
                            SalesLine_lrec."EDI Receive Date" := TODAY();
                            //DIC01:est.uki >>>
                            SalesLine_lrec."Minimum Durability" := EDITransfer_rec.MinimumDurability;
                            //DIC01:est.uki <<<
                            SalesLine_lrec.MODIFY;

                            PurchaseLine_lrec.RESET;
                            PurchaseLine_lrec.SETRANGE("Special Order Sales No.", ActualSalesHeaderNo);
                            PurchaseLine_lrec.SETRANGE("Special Order Sales Line No.", SalesLine_lrec."Line No.");
                            IF PurchaseLine_lrec.FINDFIRST() THEN BEGIN
                                //Spezialauftrag entfernen falls vorhanden
                                PurchaseLine_lrec.DeactivateSpecialOrderInfos(PurchaseLine_lrec);
                                //Menge setzen
                                PurchaseLine_lrec.VALIDATE(Quantity, EDITransfer_rec."d1#1");
                                //DIC01:est.uki >>>
                                PurchaseLine_lrec."Minimum Durability" := EDITransfer_rec.MinimumDurability;
                                //DIC01:est.uki <<<
                                PurchaseLine_lrec.MODIFY();
                            END;
                        END ELSE BEGIN
                            //Artikel in den Auftragszeilen nicht gefunden
                            Error_Text := Error_Text + STRSUBSTNO(Text004, ActualItemNo, ActualSalesHeaderNo);
                        END;
                    END ELSE BEGIN
                        //Artikel im Artikelstamm nicht gefunden
                        Error_Text := Error_Text + STRSUBSTNO(Text001, ActualItemNo);
                    END;
                END;
        END;
    end;

    [Scope('Internal')]
    procedure Token(var Text: Text[1000]; Separator: Text[1]) Token: Text[1000]
    var
        Pos: Integer;
    begin
        Pos := STRPOS(Text, Separator);
        IF Pos > 0 THEN BEGIN
            Token := COPYSTR(Text, 1, Pos - 1);
            IF Pos + 1 <= STRLEN(Text) THEN
                Text := COPYSTR(Text, Pos + 1)
            ELSE
                Text := '';
        END ELSE BEGIN
            Token := Text;
            Text := '';
        END;
    end;

    [Scope('Internal')]
    procedure ConvertEdiDate(var Text: Text[30]): Text[30]
    var
        NewDateString: Text[30];
        EdiDate: Date;
    begin
        // 201309250000
        NewDateString := COPYSTR(Text, 7, 2);
        NewDateString += '.';
        NewDateString += COPYSTR(Text, 5, 2);
        NewDateString += '.';
        NewDateString += COPYSTR(Text, 1, 4);

        EXIT(NewDateString);
    end;

    [Scope('Internal')]
    procedure Replace(String: Text[256]; Old: Text[256]; New: Text[256]): Text[256]
    var
        Pos: Integer;
    begin
        Pos := STRPOS(String, Old);
        WHILE Pos <> 0 DO BEGIN
            String := DELSTR(String, Pos, STRLEN(Old));
            String := INSSTR(String, New, Pos);
            Pos := STRPOS(String, Old);
        END;
        EXIT(String);
    end;

    [Scope('Internal')]
    procedure InsertHeader(var SalesHeader_par: Code[20]; var DeliveryDate_par: Text[30]; var Weight_par: Decimal; var PackageCount_par: Decimal)
    begin
        //Auftragsnummer in EDI Transfer Tabelle einfügen
        IF STRPOS(SalesHeader_par, '8') = 1 THEN BEGIN
            OrderCountGourmet := OrderCountGourmet + 1;
        END;
        IF STRPOS(SalesHeader_par, '4') = 1 THEN BEGIN
            OrderCountDicke := OrderCountDicke + 1;
        END;
        IF STRPOS(SalesHeader_par, '6') = 1 THEN BEGIN
            OrderCountMuennich := OrderCountMuennich + 1;
        END;

        //DIC01:est.uki >>>
        IF STRPOS(SalesHeader_par, SalesHeaderCheckDigit) = 1 THEN BEGIN
            //DIC01:est.uki <<<
            //EDITransfer_rec.CHANGECOMPANY(CompanyName_ltxt);
            EDITransfer_rec.INIT;
            EDITransfer_rec.MsgTyp := 'Header';
            EDITransfer_rec.MaiKey := SalesHeader_par;
            EDITransfer_rec."a50#1" := COMPANYNAME;
            EDITransfer_rec."a50#2" := SalesHeader_par;
            EDITransfer_rec."a50#3" := DeliveryDate_par;
            EDITransfer_rec."d1#1" := Weight_par;
            EDITransfer_rec."d1#2" := PackageCount_par;
            IF EDITransfer_rec.INSERT THEN;
            //DIC01:est.uki >>>
        END;
        //DIC01:est.uki <<<
    end;

    [Scope('Internal')]
    procedure InsertLine(var SalesHeader_par: Code[20]; var ItemNo_par: Code[20]; var ItemId_par: Code[20]; var Quantity_par: Decimal)
    begin
        //DIC01:est.uki >>>
        IF STRPOS(SalesHeader_par, SalesHeaderCheckDigit) = 1 THEN BEGIN
            //DIC01:est.uki <<<
            LineId := LineId + 1;
            //EDITransfer_rec.CHANGECOMPANY(CompanyName_ltxt);
            EDITransfer_rec.INIT;
            EDITransfer_rec.MsgTyp := 'Line';
            EDITransfer_rec.MaiKey := STRSUBSTNO('%1_%2', SalesHeader_par, PADSTR('', 4 - STRLEN(FORMAT(LineId)), '0') + FORMAT(LineId));
            EDITransfer_rec."a50#1" := COMPANYNAME;
            EDITransfer_rec."a50#2" := SalesHeader_par;
            EDITransfer_rec."a50#3" := ItemNo_par;
            EDITransfer_rec."a50#4" := ItemId_par;
            EDITransfer_rec."d1#1" := Quantity_par;
            EDITransfer_rec.MinimumDurability := MinimumDurabilityDate;
            IF EDITransfer_rec.INSERT THEN;
            //DIC01:est.uki >>>
        END;
        //DIC01:est.uki <<<
    end;

    [Scope('Internal')]
    procedure GetItemNo(var ItemNo: Code[20]; var ItemId: Code[20]): Code[20]
    var
        Item_lrec: Record "Item";
        SalesLineCheck_lrec: Record "Sales Line";
    begin
        //zunächst auf EAN 13 prüfen
        Item_lrec.RESET;
        Item_lrec.SETRANGE(EAN13, ItemNo);
        IF Item_lrec.FINDFIRST() THEN
            EXIT(Item_lrec."No.");

        //nun auf Kreditoren Artikel Nummer prüfen
        Item_lrec.RESET;
        Item_lrec.SETRANGE("Vendor Item No.", ItemId);
        IF Item_lrec.FINDFIRST() THEN
            EXIT(Item_lrec."No.");

        //nun die Artikelnummer auf die letzten 4 Stellen prüfen
        Item_lrec.RESET;
        Item_lrec.SETFILTER("No.", '%1', '*' + ItemId);
        IF Item_lrec.FINDFIRST() THEN
            REPEAT
                //Prüfen, ob dieser Artikel im Auftrag vorhanden ist
                SalesLineCheck_lrec.RESET;
                SalesLineCheck_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
                SalesLineCheck_lrec.SETRANGE("Document No.", ActualSalesHeaderNo);
                SalesLineCheck_lrec.SETRANGE(Type, SalesLine_lrec.Type::Item);
                SalesLineCheck_lrec.SETRANGE("No.", Item_lrec."No.");
                IF SalesLineCheck_lrec.FINDFIRST() THEN BEGIN
                    EXIT(Item_lrec."No.");
                END;
            UNTIL Item_lrec.NEXT = 0;

        //Artikel wurde nicht gefunden
        EXIT('');
    end;

    [Scope('Internal')]
    procedure InsertPositionHeadText(OrderNo: Code[20]; Firma: Text[80]; DeliveryDate: Text[30]; DeliveryNo: Text[30])
    var
        SalesLine_lrec: Record "Sales Line";
        NextLineNo: Integer;
        StrToDate_ldate: Date;
        Text001_l: Label 'LS der Firma %1 vom %2, Nr.: %3';
        Text002_l: Label 'Bezüglich der Entgeltminderungen verweisen wir auf';
        Text003_l: Label 'die aktuellen Zahlungs- und Konditionsvereinbarungen';
        Text004_l: Label '--------------------------------------------------';
        ExtTextLine_rec: Record "280";
        Customer_lrec: Record "Customer";
        NewLine_ltxt: Text[100];
    begin
        IF Customer_lrec.GET(SalesHeader_lrec."Sell-to Customer No.") THEN BEGIN
            IF Customer_lrec."Extended Text" <> '' THEN BEGIN
                ExtTextLine_rec.RESET;
                ExtTextLine_rec.SETRANGE("Table Name", ExtTextLine_rec."Table Name"::"Standard Text");
                ExtTextLine_rec.SETRANGE("No.", Customer_lrec."Extended Text");
            END ELSE BEGIN
                ExtTextLine_rec.RESET;
                ExtTextLine_rec.SETRANGE("Table Name", ExtTextLine_rec."Table Name"::"Standard Text");
                ExtTextLine_rec.SETRANGE("No.", 'R');
            END;
        END;

        NextLineNo := 1;
        IF ExtTextLine_rec.FINDFIRST() THEN
            REPEAT
                SalesLine_lrec.RESET;
                SalesLine_lrec.INIT;
                SalesLine_lrec.VALIDATE("Document Type", SalesLine_lrec."Document Type"::Order);
                SalesLine_lrec.VALIDATE("Document No.", OrderNo);
                SalesLine_lrec.VALIDATE("Line No.", NextLineNo);
                NewLine_ltxt := STRSUBSTNO(ExtTextLine_rec.Text, Firma,
                  DeliveryDate, SalesHeader_lrec."Order Date",
                  DeliveryNo, SalesHeader_lrec."Shipment Date Shipping Agent");
                SalesLine_lrec.Description := NewLine_ltxt;
                IF SalesLine_lrec.INSERT(TRUE) THEN;

                NextLineNo += 10;
            UNTIL ExtTextLine_rec.NEXT = 0;

        NextLineNo += 10;

        SalesLine_lrec.RESET;
        SalesLine_lrec.INIT;
        SalesLine_lrec.VALIDATE("Document Type", SalesLine_lrec."Document Type"::Order);
        SalesLine_lrec.VALIDATE("Document No.", OrderNo);
        SalesLine_lrec.VALIDATE("Line No.", NextLineNo);
        SalesLine_lrec.Description := '';
        IF SalesLine_lrec.INSERT(TRUE) THEN;
    end;

    [Scope('Internal')]
    procedure UpdateHeaderData(OrderNo: Code[20])
    var
        SalesHdr_lrec: Record "Sales Header";
        IsModified_lbool: Boolean;
        ArchiveManagement_lcu: Codeunit "5063";
    begin
        // ---------------------------
        // Buchungsdatum und Belegdatum wird auf Workdate gesetzt.
        // ---------------------------
        IsModified_lbool := FALSE;
        SalesHdr_lrec.RESET;
        IF SalesHdr_lrec.GET(SalesHdr_lrec."Document Type"::Order, OrderNo) THEN BEGIN
            // Auftrag ggf. vorab archivieren
            ArchiveManagement_lcu.StoreSalesDocument(SalesHdr_lrec, FALSE);
            SalesHdr_lrec.LOCKTABLE;
            SalesHdr_lrec.VALIDATE("Posting Date", WORKDATE);
            SalesHdr_lrec.VALIDATE("Print Shipment Info On Invoice", FALSE);
            SalesHdr_lrec.MODIFY;
            RowNo := RowNo + 1;
            EnterCell(RowNo, 1, FORMAT(SalesHdr_lrec."Order Date"), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Date);
            EnterCell(RowNo, 2, SalesHdr_lrec."Sell-to Customer No.", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
            EnterCell(RowNo, 3, SalesHdr_lrec."No.", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
            EnterCell(RowNo, 4, SalesHdr_lrec."Sell-to Customer Name", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
            EnterCell(RowNo, 5, SalesHdr_lrec."Sell-to Address", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
            EnterCell(RowNo, 6, SalesHdr_lrec."Sell-to City", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
            //DIC01:est.uki >>>
            IF ImportOption = ImportOption::"Verkauf u. Einkauf" THEN
                EnterCell(RowNo, 7, CreatePuchaseFromSalesHeader(SalesHdr_lrec), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
            //DIC01:est.uki <<<
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

    local procedure CreatePuchaseFromSalesHeader(SalesHeader: Record "Sales Header"): Code[20]
    var
        PurchaseHeader: Record "38";
    begin
        //DIC01:est.uki >>>
        //In einer KIRN (DesAdv) Datei wird immer der komplette Auftrag von Kirn 'geliefert'
        //Daher wird jetzt zu dem Auftrag eine Bestellung mit den gleichen Positionen angelegt
        IF NOT SalesHeader.SendToKirn THEN
            EXIT;
        IF SalesReceivablesSetup."EDI Import Vendor No" = '' THEN
            EXIT;
        PurchaseHeader.INIT;
        PurchaseHeader.VALIDATE("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.VALIDATE("Buy-from Vendor No.", SalesReceivablesSetup."EDI Import Vendor No");
        PurchaseHeader.INSERT;
        CopySalesLinesToPurchaseLines(PurchaseHeader, SalesHeader);

        MultiTemp_trec.INIT;
        MultiTemp_trec.TextKey := PurchaseHeader."No.";
        IF MultiTemp_trec.INSERT THEN
            EXIT(PurchaseHeader."No.");
        //DIC01:est.uki <<<
    end;

    local procedure CopySalesLinesToPurchaseLines(PurchaseHeader: Record "38"; SalesHeader: Record "Sales Header")
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseLineNo: Integer;
        SalesLine: Record "Sales Line";
    begin
        //DIC01:est.uki >>>
        PurchaseLineNo := 0;
        SalesLine.RESET;
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        IF SalesLine.FINDSET THEN
            REPEAT
                CLEAR(PurchaseLine);
                PurchaseLine.INIT;
                PurchaseLine."Document No." := PurchaseHeader."No.";
                PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                PurchaseLine.Type := PurchaseLine.Type::Item;
                PurchaseLineNo := PurchaseLineNo + 10000;
                PurchaseLine."Line No." := PurchaseLineNo;
                PurchaseLine.VALIDATE("No.", SalesLine."No.");
                PurchaseLine.Description := SalesLine.Description;
                IF PurchaseLine."No." <> '' THEN BEGIN
                    PurchaseLine.VALIDATE("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
                    PurchaseLine.VALIDATE(Quantity, SalesLine.Quantity);
                    PurchaseLine.VALIDATE("Unit of Measure Code", SalesLine."Unit of Measure Code");
                    PurchaseLine."Special Order Sales No." := SalesLine."Document No.";
                    PurchaseLine."Special Order Sales Line No." := SalesLine."Line No.";
                END;
                PurchaseLine.INSERT(TRUE);
            UNTIL SalesLine.NEXT = 0;
        //DIC01:est.uki <<<
    end;
}

