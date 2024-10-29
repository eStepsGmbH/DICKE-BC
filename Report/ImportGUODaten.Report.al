report 50077 "Import GUO Daten"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Objekt erstellt.
    // 
    //  No.   Date       Version Changes
    //  --------------------------------------------------------------------------------
    //  DIC01 06.08.2020 17.2.01 Modify functions:
    //                             - "InsertItemLineData"
    //                             - "OnPreReport"
    //                             - "Nummer - OnPreDataItem"
    //                             - "Nummer - OnAfterGetRecord"
    //                             - "Nummer - OnPostDataItem"
    //                           Add function: "ResetPurchaseQuantities"
    //  DIC02 30.05.2023         Modify function:
    //                             - "InsertItemLineData"

    ProcessingOnly = true;

    dataset
    {
        dataitem(Nummer; Integer)
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            var
                PurchaseOrdersText: Text;
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
                EnterCell(RowNo, 4, ImportedOrders_trec."Sell-to Customer Name", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 5, FORMAT(ImportedOrders_trec."Currency Factor"), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                EnterCell(RowNo, 6, FORMAT(ImportedOrders_trec."Posting Date"), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Date);
                EnterCell(RowNo, 7, ImportedOrders_trec."Package Tracking No.", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 8, ImportedOrders_trec."Your Reference", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);

                //DIC01 est.uki >>>
                PurchaseOrdersText := '';
                MultiTemp_trec.RESET;
                MultiTemp_trec.SETRANGE(Text1, ImportedOrders_trec."No.");
                IF MultiTemp_trec.FINDFIRST THEN
                    REPEAT
                        IF STRLEN(PurchaseOrdersText) > 0 THEN
                            PurchaseOrdersText := PurchaseOrdersText + ', ';
                        PurchaseOrdersText := PurchaseOrdersText + MultiTemp_trec.TextKey;
                    UNTIL MultiTemp_trec.NEXT = 0;
                EnterCell(RowNo, 9, PurchaseOrdersText, TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                //DIC01 est.uki <<<
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

                IF OpenExcel THEN
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
                EnterCell(1, 4, 'Debitor Name', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 5, 'Bruttogewicht', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 6, 'Buchungsdatum', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 7, 'Warn.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 8, 'Abweichung', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                //DIC01:est.uki >>>
                EnterCell(1, 9, 'Bestellung Nr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                //DIC01:est.uki <<<
                RowNo := 1;
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
                    Caption = 'Optionen';
                    field(ImportOption; ImportOption)
                    {
                        Caption = 'GUO Import Verarbeitung';

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
    var
        FileManagement: Codeunit "419";
        Text028: Label 'Import File';
    begin
        ServerFileName := FileManagement.ServerTempFileName('.dat');
        UPLOAD(Text028, '', 'GUO Datei (*.dat)|*.dat', '', ServerFileName);
        //DIC01:est.uk >>>
        SalesReceivablesSetup.GET;
        ImportOption := SalesReceivablesSetup."GUO Import Processing";
        IF ImportOption = ImportOption::"Verkauf u. Einkauf" THEN
            BookPurchaseOrder := TRUE;
        //DIC01:est.uk <<<
    end;

    trigger OnPostReport()
    begin
        IF OrderCountOtherCompany > 0 THEN BEGIN
            IF CONFIRM(STRSUBSTNO(Text0004, OrderCountOtherCompany)) THEN;
        END;
    end;

    trigger OnPreReport()
    var
        OrderNo_l: Code[20];
        OrderLineNo_lint: Integer;
        Instream_linstr: InStream;
        OrderDate_ltxt: Text[8];
        LineNo_ltxt: Text[9];
        Weight_ltxt: Text[10];
        Weight_ldec: Decimal;
    begin

        // --------------------------
        // Es gilt:
        // Satzlänge für Kopfsatz (=Kennung ZEN): 1553 Zeichen
        // Satzlänge für Positionssatz (=Kennung ZRG): 632 Zeichen
        //
        // - Kopfsatz wird eingelesen, aber nicht weiterverarbeitet.
        //
        // - Positionssätze, die ab der Stelle 87 den Wert '(NULL)' eingetragen haben,
        //   werden nicht weiterverarbeitet.
        //
        // - Wenn in der Auftragszeile im Feld "GUO Receive Date" ein Wert eingetragen wurde,
        //   wird diese Zeile beim Einlesen nicht mehr berührt, da hierüber gesteuert wird,
        //   ob eine zusätzliche Zeile angelegt werden muss, wenn von Nagel eine Zeile gesplittet
        //   wurde (wg. Mindesthalbarkeitsdatum).
        // --------------------------

        //DIC01:est.uk >>>
        MultiTemp_trec.DELETEALL;
        //DIC01:est.uk <<<

        OrderCountOtherCompany := 0;

        IF ServerFileName = '' THEN
            ERROR(Text0000);

        CLEAR(ImportFile);
        CLEAR(Instream_linstr);

        ImportFile.OPEN(ServerFileName);
        ImportFile.CREATEINSTREAM(Instream_linstr);

        WHILE NOT (Instream_linstr.EOS()) DO BEGIN
            TextLine := '';
            Instream_linstr.READTEXT(TextLineA, 632);
            IF COPYSTR(TextLineA, 1, 3) = 'ZEN' THEN BEGIN
                Instream_linstr.READTEXT(TextLineB, 921); //Rest der Zeile lesen.
                OrderNo_l := DELCHR(COPYSTR(TextLineA, 31, 7), '=', ' ');
                IsOrderFound_bol := SalesHdr_rec.GET(SalesHdr_rec."Document Type"::Order, OrderNo_l);
                IF IsOrderFound_bol = FALSE THEN
                    OrderCountOtherCompany += 1;
                IF IsOrderFound_bol THEN BEGIN
                    ImportedOrders_trec.INIT;
                    ImportedOrders_trec."Document Type" := ImportedOrders_trec."Document Type"::Order;
                    ImportedOrders_trec."No." := OrderNo_l;
                    ImportedOrders_trec."Sell-to Customer No." := COPYSTR(TextLineA, 217, 8);
                    ImportedOrders_trec."Sell-to Customer Name" := COPYSTR(TextLineA, 280, 30);
                    ImportedOrders_trec."Posting Date" := WORKDATE;
                    ImportedOrders_trec."Package Tracking No." := ''; // Feld wird für Warnungshinweis verwendet.
                                                                      // Bruttogewicht
                    Weight_ltxt := COPYSTR(TextLineB, 594, 10);
                    Weight_ltxt := CONVERTSTR(Weight_ltxt, '.', ',');
                    IF EVALUATE(Weight_ldec, Weight_ltxt) THEN
                        ImportedOrders_trec."Currency Factor" := Weight_ldec;
                    OrderDate_ltxt := COPYSTR(TextLineA, 105, 8);
                    IF (STRLEN(OrderDate_ltxt) = 8) AND (OrderDate_ltxt <> '        ') THEN
                        EVALUATE(ImportedOrders_trec."Order Date",
                                 COPYSTR(OrderDate_ltxt, 7, 2) + COPYSTR(OrderDate_ltxt, 5, 2) + COPYSTR(OrderDate_ltxt, 3, 2));
                    IF NOT ImportedOrders_trec.INSERT THEN
                        ImportedOrders_trec.MODIFY;
                    UpdateHeaderData(ImportedOrders_trec."No.");
                END;
            END;

            IF COPYSTR(TextLineA, 1, 3) = 'ZRG' THEN BEGIN
                IF IsOrderFound_bol THEN BEGIN
                    //der zugehörige Auftrag wurde in diesem Mandanten gefunden
                    IF COPYSTR(TextLineA, 87, 6) <> '(NULL)' THEN BEGIN
                        OrderNo_l := ImportedOrders_trec."No.";
                        LineNo_ltxt := COPYSTR(TextLineA, 61, 9);
                        IF LineNo_ltxt <> '         ' THEN
                            EVALUATE(OrderLineNo_lint, COPYSTR(TextLineA, 61, 9))
                        ELSE
                            OrderLineNo_lint := 0;
                        TextLine := COPYSTR(TextLineA, 1, 632);
                        InsertItemLineData(OrderNo_l, OrderLineNo_lint, TextLine);
                    END;
                END;
            END;

        END;

        ImportFile.CLOSE;
    end;

    var
        ServerFileName: Text;
        TextLine: Text[632];
        ImportFile: File;
        ImportedOrders_trec: Record "Sales Header" temporary;
        SalesHdr_rec: Record "Sales Header";
        TextLineA: Text[632];
        TextLineB: Text[921];
        SalesLineOriginalValue_rec: Record "Sales Line";
        NewLineNoCounter_int: Integer;
        ArchiveOrder_req: Boolean;
        IsOrderFound_bol: Boolean;
        OrderCountOtherCompany: Integer;
        Text0000: Label 'Enter the file name.';
        Text0001: Label 'The file to be imported has an unknown format.';
        Text0031: Label 'Aus Textdatei importieren';
        Text0002: Label 'Im Auftrag %1 fehlt eine Zeile für den Artikel %2.\Bitte, erfassen Sie diesen Artikel nach und starten Sie den Import erneut.';
        Text0003: Label 'Im Auftrag %1 sollte in der Zeile %2 der Artikel %3 eingetragen sein.\Es ist aber der Artikel %4 eingetragen.\Bitte, fügen Sie im Auftrag %1 an das Ende der Positionen eine Kopie der Zeile %2 an und löschen Sie dann die Zeile %2.\Anschließend fügen Sie an das Ende der Positionen noch eine Zeile mit dem Artikel %3 an.\Starten Sie den Import dann erneut.';
        Text0004: Label 'In der Datei sind %1 Aufträge anderer Mandanten enthalten. Bitte lesen Sie daher diese Dati erneut in die anderen Mandanten ein.';
        ServerFileNameExcel: Text;
        ExcelBuffer: Record "370" temporary;
        RowNo: Integer;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        MultiTemp_trec: Record "50008" temporary;
        ImportOption: Option Verkauf,"Verkauf u. Einkauf";
        BookPurchaseOrder: Boolean;

    [Scope('Internal')]
    procedure InsertItemLineData(OrderNo: Code[20]; OrderLineNo: Integer; ImportTextData: Text[632])
    var
        SalesLine_lrec: Record "Sales Line";
        NewSalesLine_lrec: Record "Sales Line";
        ItemUnitOfMeasure_lrec: Record "5404";
        NextLineNo: Integer;
        Text001_l: Label '*** IMPORTHINWEIS BITTE UNBEDINGT PRÜFEN!!! Artikelnummer fehlt für Tiho-Nr. %1 *** ';
        Item_lrec: Record "Item";
        Text002_l: Label '*** IMPORTHINWEIS BITTE UNBEDINGT PRÜFEN!!! Artikelnummer %1 ist unbekannt! *** ';
        ItemNo_lcode: Code[20];
        MinimumDurab_ltext: Text[8];
        MengeInEinheit_ldec: Decimal;
        NewQty_ltxt: Text[15];
        NewQty_ldec: Decimal;
        NewWeight_ltxt: Text[10];
        NewWeight_ldec: Decimal;
        InsertNewLine_lbool: Boolean;
        SalesDisc_lcu: Codeunit "60";
        SavedLineDiscount_ldec: Decimal;
        IsNewLine: Boolean;
        PurchaseLine: Record "Purchase Line";
        NewPurchaseLine: Record "Purchase Line";
        Colli_ltext: Text[6];
        Colli_ldec: Decimal;
    begin
        SalesLine_lrec.RESET;
        SalesLine_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
        SalesLine_lrec.SETRANGE("Document No.", OrderNo);
        SalesLine_lrec.SETRANGE("Line No.", OrderLineNo);

        IF NOT SalesLine_lrec.FIND('-') THEN BEGIN
            // ------------------------------------------------------
            // Es wurde von Nagel keine Referenz für die Zeilennr. mitgeliefert (z.B. wenn es sich um eine Nachlieferung handelt).
            // Zeile wird deshalb über die Artikelnummer gesucht.
            // Hierbei ist zu beachten, dass immer die erst gefundene Zeile mit diesem Artikel weiterverarbeitet wird!
            // ------------------------------------------------------
            ItemNo_lcode := DELCHR(COPYSTR(ImportTextData, 73, 10), '=', ' ');
            // Wenn importierte Artikelnummer eine führende Null hat, diese entfernen.
            IF COPYSTR(ItemNo_lcode, 1, 1) = '0' THEN
                ItemNo_lcode := COPYSTR(ItemNo_lcode, 2);
            IF ItemNo_lcode <> '' THEN BEGIN
                SalesLine_lrec.RESET;
                SalesLine_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
                SalesLine_lrec.SETRANGE("Document No.", OrderNo);
                SalesLine_lrec.SETRANGE(Type, SalesLine_lrec.Type::Item);
                SalesLine_lrec.SETRANGE("No.", ItemNo_lcode);
                ImportedOrders_trec."Package Tracking No." := '!!!';
                ImportedOrders_trec.MODIFY;
            END;
        END;

        IF SalesLine_lrec.FIND('-') THEN BEGIN

            SaveSalesLineOriginalValues(SalesLine_lrec);

            IF SalesLine_lrec.Type = SalesLine_lrec.Type::Item THEN BEGIN
                IF SalesLine_lrec."Purchasing Code" <> '' THEN BEGIN
                    // Spezialauftragskennungen entfernen
                    SalesLine_lrec.DeactivateSpecialOrderInfos(SalesLine_lrec);
                END;
                InsertNewLine_lbool := SalesLine_lrec."GUO Receive Date" <> 0D;
                IsNewLine := FALSE;

                //DIC01:est.uk >>>
                IF ImportOption = ImportOption::"Verkauf u. Einkauf" THEN BEGIN
                    //Falls vorhanden zugehörige Bestellzeile ermitteln
                    PurchaseLine.RESET;
                    PurchaseLine.SETRANGE(PurchaseLine."Document Type", PurchaseLine."Document Type"::Order);
                    PurchaseLine.SETRANGE("Special Order Sales No.", SalesLine_lrec."Document No.");
                    PurchaseLine.SETRANGE("Special Order Sales Line No.", SalesLine_lrec."Line No.");
                    IF PurchaseLine.FINDFIRST THEN BEGIN
                        MultiTemp_trec.INIT;
                        MultiTemp_trec.TextKey := PurchaseLine."Document No.";
                        MultiTemp_trec.Text1 := SalesLine_lrec."Document No.";
                        MultiTemp_trec.Dec1 := 0;
                        IF MultiTemp_trec.INSERT THEN
                            ResetPurchaseQuantities(PurchaseLine."Document No.");
                    END;
                END;
                //DIC01:est.uk <<<

                IF InsertNewLine_lbool THEN BEGIN
                    // ----------
                    // Eine zusätzliche Auftragszeile anlegen
                    // ----------
                    NewLineNoCounter_int := NewLineNoCounter_int + 100;
                    NextLineNo := SalesLine_lrec."Line No." + NewLineNoCounter_int;
                    NewSalesLine_lrec.INIT;
                    NewSalesLine_lrec."Document Type" := SalesLine_lrec."Document Type";
                    NewSalesLine_lrec."Document No." := SalesLine_lrec."Document No.";
                    NewSalesLine_lrec."Line No." := NextLineNo;
                    NewSalesLine_lrec."Sell-to Customer No." := SalesLine_lrec."Sell-to Customer No.";
                    IF NewSalesLine_lrec.INSERT THEN BEGIN
                        NewSalesLine_lrec.TRANSFERFIELDS(SalesLine_lrec);
                        NewSalesLine_lrec."Line No." := NextLineNo;
                        IF NewSalesLine_lrec.MODIFY THEN BEGIN
                            SalesLine_lrec := NewSalesLine_lrec;
                            InsertNewLine_lbool := FALSE;
                            IsNewLine := TRUE;
                        END;
                    END;
                    //DIC01:est.uk >>>
                    IF (IsNewLine) AND (ImportOption = ImportOption::"Verkauf u. Einkauf") THEN BEGIN
                        IF PurchaseLine.FINDFIRST THEN BEGIN
                            //Eine zusätzliche Bestellzeile zur neuen Auftragszeile anlegen
                            NextLineNo := PurchaseLine."Line No." + NewLineNoCounter_int;
                            NewPurchaseLine.INIT;
                            NewPurchaseLine."Document Type" := SalesLine_lrec."Document Type";
                            NewPurchaseLine."Document No." := SalesLine_lrec."Document No.";
                            NewPurchaseLine."Line No." := NextLineNo;
                            IF NewPurchaseLine.INSERT THEN BEGIN
                                NewPurchaseLine.TRANSFERFIELDS(PurchaseLine);
                                NewPurchaseLine."Line No." := NextLineNo;
                                NewPurchaseLine."Special Order Sales Line No." := SalesLine_lrec."Line No.";
                                IF NewPurchaseLine.MODIFY THEN BEGIN
                                    PurchaseLine := NewPurchaseLine;
                                END;
                            END;
                        END;
                    END;
                    //DIC01:est.uk <<<
                END;

                IF NOT InsertNewLine_lbool THEN BEGIN
                    // ----------
                    // Update einer vorhandenen Auftragszeile
                    // ----------
                    ItemNo_lcode := DELCHR(COPYSTR(ImportTextData, 73, 10), '=', ' ');
                    // Wenn importierte Artikelnummer eine führende Null hat, diese entfernen.
                    IF COPYSTR(ItemNo_lcode, 1, 1) = '0' THEN
                        ItemNo_lcode := COPYSTR(ItemNo_lcode, 2);

                    Item_lrec.RESET;
                    IF Item_lrec.GET(ItemNo_lcode) THEN;

                    MinimumDurab_ltext := '';
                    MinimumDurab_ltext := COPYSTR(ImportTextData, 150, 8);

                    //DIC02:est.uki >>>
                    Colli_ltext := '';
                    Colli_ltext := COPYSTR(ImportTextData, 250, 6);
                    //DIC02:est.uki <<<

                    IF SalesLine_lrec."No." = ItemNo_lcode THEN BEGIN

                        // Zeilenrabatt % sichern, da dieser nach Validierung der Menge gelöscht wird.
                        SavedLineDiscount_ldec := SalesLine_lrec."Line Discount %";

                        IF STRLEN(MinimumDurab_ltext) = 8 THEN BEGIN
                            MinimumDurab_ltext := COPYSTR(MinimumDurab_ltext, 7, 2) + COPYSTR(MinimumDurab_ltext, 5, 2) + COPYSTR(MinimumDurab_ltext, 1, 4);
                            EVALUATE(SalesLine_lrec."Minimum Durability", MinimumDurab_ltext);
                        END;

                        NewQty_ltxt := COPYSTR(ImportTextData, 295, 6);
                        NewQty_ltxt := CONVERTSTR(NewQty_ltxt, '.', ',');
                        EVALUATE(NewQty_ldec, NewQty_ltxt);
                        NewWeight_ltxt := COPYSTR(ImportTextData, 363, 10);
                        NewWeight_ltxt := CONVERTSTR(NewWeight_ltxt, '.', ',');
                        EVALUATE(NewWeight_ldec, NewWeight_ltxt);

                        IF SalesLineOriginalValue_rec."Base Unit of Measure Code" = 'ST.' THEN BEGIN
                            MengeInEinheit_ldec := 1;
                            IF SalesLineOriginalValue_rec."Unit of Measure Code" <> SalesLine_lrec."Base Unit of Measure Code" THEN BEGIN
                                IF SalesLineOriginalValue_rec."Base Unit Quantity" <> 0 THEN BEGIN
                                    MengeInEinheit_ldec := SalesLineOriginalValue_rec."Base Unit Quantity" / SalesLineOriginalValue_rec.Quantity;
                                END;
                            END;
                            ItemUnitOfMeasure_lrec.RESET;
                            ItemUnitOfMeasure_lrec.SETRANGE("Item No.", SalesLine_lrec."No.");
                            ItemUnitOfMeasure_lrec.SETRANGE(Code, Item_lrec."Sales Unit of Measure");
                            IF ItemUnitOfMeasure_lrec.FINDFIRST THEN
                                SalesLine_lrec."Base Unit Quantity (Original)" := SalesLine_lrec.Quantity
                                                                             * ItemUnitOfMeasure_lrec."Qty. per Unit of Measure"
                            ELSE
                                SalesLine_lrec."Base Unit Quantity (Original)" := SalesLine_lrec.Quantity;

                            SalesLine_lrec.VALIDATE("Unit of Measure Code", Item_lrec."Base Unit of Measure");
                            SalesLine_lrec.VALIDATE(Quantity, NewQty_ldec * MengeInEinheit_ldec);
                            SalesLine_lrec.MODIFY;

                            //DIC01:est.uk >>>
                            IF ImportOption = ImportOption::"Verkauf u. Einkauf" THEN BEGIN
                                IF PurchaseLine.FINDFIRST THEN BEGIN
                                    PurchaseLine.SuspendStatusCheck(TRUE);
                                    IF PurchaseLine."Quantity Received" = 0 THEN
                                        PurchaseLine.VALIDATE("Unit of Measure Code", Item_lrec."Base Unit of Measure");
                                    PurchaseLine.VALIDATE(Quantity, (NewQty_ldec * MengeInEinheit_ldec) + PurchaseLine."Quantity Received");
                                    IF STRLEN(MinimumDurab_ltext) = 8 THEN
                                        EVALUATE(PurchaseLine."Minimum Durability", MinimumDurab_ltext);
                                    PurchaseLine.MODIFY;
                                END;
                            END;
                            //DIC01:est.uk <<<

                            // Rechnungsrabatt neu berechnen (Wie Aufruf der Funktion "Rechnungsrabatt berechen" im VK-Auftragsformular)
                            SalesDisc_lcu.Run(SalesLine_lrec);
                        END;

                        IF SalesLineOriginalValue_rec."Base Unit of Measure Code" = 'KG' THEN BEGIN
                            ItemUnitOfMeasure_lrec.RESET;
                            ItemUnitOfMeasure_lrec.SETRANGE("Item No.", SalesLine_lrec."No.");
                            ItemUnitOfMeasure_lrec.SETRANGE(Code, Item_lrec."Sales Unit of Measure");
                            IF ItemUnitOfMeasure_lrec.FINDFIRST THEN
                                SalesLine_lrec."Base Unit Quantity (Original)" := SalesLine_lrec.Quantity
                                                                                  * ItemUnitOfMeasure_lrec."Qty. per Unit of Measure"
                                                                                  * Item_lrec."Net Weight"
                            ELSE
                                SalesLine_lrec."Base Unit Quantity (Original)" := SalesLine_lrec.Quantity * Item_lrec."Net Weight";

                            SalesLine_lrec.VALIDATE("Unit of Measure Code", Item_lrec."Base Unit of Measure");
                            SalesLine_lrec.VALIDATE(Quantity, NewWeight_ldec);
                            SalesLine_lrec.MODIFY;

                            //DIC01:est.uk >>>
                            IF ImportOption = ImportOption::"Verkauf u. Einkauf" THEN BEGIN
                                IF PurchaseLine.FINDFIRST THEN BEGIN
                                    PurchaseLine.SuspendStatusCheck(TRUE);
                                    IF PurchaseLine."Quantity Received" = 0 THEN
                                        PurchaseLine.VALIDATE("Unit of Measure Code", Item_lrec."Base Unit of Measure");
                                    PurchaseLine.VALIDATE(Quantity, NewWeight_ldec + PurchaseLine."Quantity Received");
                                    IF STRLEN(MinimumDurab_ltext) = 8 THEN
                                        EVALUATE(PurchaseLine."Minimum Durability", MinimumDurab_ltext);
                                    PurchaseLine.MODIFY;
                                END;
                            END;
                            //DIC01:est.uk <<<

                            // Rechnungsrabatt neu berechnen (Wie Aufruf der Funktion "Rechnungsrabatt berechen" im VK-Auftragsformular)
                            SalesDisc_lcu.Run(SalesLine_lrec);
                        END;

                        // Zeilenrabatt % ggf. erneut eintragen
                        IF SavedLineDiscount_ldec <> 0 THEN
                            SalesLine_lrec.VALIDATE("Line Discount %", SavedLineDiscount_ldec);

                        SalesLine_lrec."Net Weight" := NewWeight_ldec;
                        SalesLine_lrec."GUO Receive Date" := WORKDATE;

                        //DIC02:est.uki >>>
                        IF EVALUATE(Colli_ldec, Colli_ltext) THEN
                            SalesLine_lrec.Coli := Colli_ldec;
                        //DIC02:est.uki >>>

                        IF IsNewLine THEN BEGIN
                            //bei einer neuen Zeile werden die beiden Mengen gleichgesetzt damit eine Abweichung von 0 für die Anzeige entsteht
                            SalesLine_lrec."Base Unit Quantity (Original)" := SalesLine_lrec.Quantity;
                        END;

                        SalesLine_lrec.MODIFY;

                        IF ((SalesLine_lrec.Quantity - SalesLine_lrec."Base Unit Quantity (Original)" <> 0) OR (IsNewLine = TRUE)) THEN BEGIN
                            ImportedOrders_trec."Your Reference" := 'J';
                            ImportedOrders_trec.MODIFY;
                        END;

                    END ELSE BEGIN
                        ERROR(Text0003, OrderNo, OrderLineNo, ItemNo_lcode, SalesLine_lrec."No.");
                    END;

                END;

            END;

        END ELSE BEGIN
            ERROR(Text0002, OrderNo, ItemNo_lcode);
        END;
    end;

    [Scope('Internal')]
    procedure UpdateHeaderData(OrderNo: Code[20])
    var
        ArchiveManagement_lcu: Codeunit "5063";
    begin
        // ---------------------------
        // Buchungsdatum und Belegdatum wird auf Workdate gesetzt.
        // ---------------------------

        // Auftrag ggf. vorab archivieren
        IF ArchiveOrder_req THEN
            ArchiveManagement_lcu.StoreSalesDocument(SalesHdr_rec, FALSE);

        SalesHdr_rec.LOCKTABLE;
        IF SalesHdr_rec."Posting Date" <> WORKDATE THEN
            SalesHdr_rec.VALIDATE("Posting Date", WORKDATE);

        IF SalesHdr_rec."Document Date" <> WORKDATE THEN
            SalesHdr_rec.VALIDATE("Document Date", WORKDATE);

        CASE COMPANYNAME OF
            'Dicke Food', 'Dicke Gourmet Konzepte':
                SalesHdr_rec.VALIDATE("Print Shipment Info On Invoice", FALSE);
        END;

        // DI01:est.uk >>>
        SalesHdr_rec."Shipment Date Shipping Agent" := SalesHdr_rec."Order Date";
        // DI01:est.uk <<<

        SalesHdr_rec.MODIFY;

        CASE COMPANYNAME OF
            'Dicke Food', 'Dicke Gourmet Konzepte':
                InsertPositionHeadText(SalesHdr_rec."No.", COMPANYNAME);
        END;
    end;

    [Scope('Internal')]
    procedure SaveSalesLineOriginalValues(SalesLine_par: Record "Sales Line")
    begin
        IF NOT (
                (SalesLine_par."Document Type" = SalesLineOriginalValue_rec."Document Type"::Order) AND
                (SalesLine_par."Document No." = SalesLineOriginalValue_rec."Document No.") AND
                (SalesLine_par."Line No." = SalesLineOriginalValue_rec."Line No.")
               ) THEN BEGIN

            SalesLineOriginalValue_rec.RESET;
            SalesLineOriginalValue_rec.SETRANGE("Document Type", SalesLine_par."Document Type"::Order);
            SalesLineOriginalValue_rec.SETRANGE("Document No.", SalesLine_par."Document No.");
            SalesLineOriginalValue_rec.SETRANGE("Line No.", SalesLine_par."Line No.");
            IF SalesLineOriginalValue_rec.FIND('-') THEN;
            NewLineNoCounter_int := 0;

        END;
    end;

    [Scope('Internal')]
    procedure InsertPositionHeadText(OrderNo: Code[20]; Firma: Text[80])
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
        SalesHeader_lrec: Record "Sales Header";
    begin
        IF SalesHeader_lrec.GET(SalesHeader_lrec."Document Type"::Order, OrderNo) THEN BEGIN
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
                               SalesHeader_lrec."Order Date", SalesHeader_lrec."Promised Delivery Date",
                               SalesHeader_lrec."No.", SalesHeader_lrec."Shipment Date Shipping Agent");

                SalesLine_lrec.Description := NewLine_ltxt;
                SalesLine_lrec.INSERT(TRUE);

                NextLineNo += 10;
            UNTIL ExtTextLine_rec.NEXT = 0;

        NextLineNo += 10;

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
        ServerFileNameExcel := NewFileName;
    end;

    [TryFunction]
    local procedure OpenExcel()
    begin
        ExcelBuffer.CreateBook(ServerFileNameExcel, 'Import Thio Daten');
        ExcelBuffer.WriteSheet('TheHEADER', COMPANYNAME, USERID);
        ExcelBuffer.CloseBook;
        ExcelBuffer.OpenExcel;
        // ExcelBuffer.GiveUserControl;
    end;

    local procedure ResetPurchaseQuantities(DocumentNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        //DIC01:est.uk >>>
        PurchaseLine.RESET;
        PurchaseLine.SETRANGE("Document No.", DocumentNo);
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        IF PurchaseLine.FINDSET THEN
            REPEAT
                PurchaseLine.SuspendStatusCheck(TRUE);
                PurchaseLine.VALIDATE(Quantity, 0 + PurchaseLine."Quantity Received");
                PurchaseLine.MODIFY;
            UNTIL PurchaseLine.NEXT = 0;
        //DIC01:est.uk <<<
    end;
}

