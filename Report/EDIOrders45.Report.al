report 50093 "EDI Orders 45"
{
    //  --------------------------------------------------------------------------------
    //  No.   SC-No.    Date     Sign    Description
    //  --------------------------------------------------------------------------------
    //  DI01            24.07.18 est.uki Modify Shipment Infos.
    //  DI02            08.10.20 est.uki Add Code in function "GetShippingAgentCode".
    //  DI03            12.01.22 est.uki Modify function:
    //                                   - "CloseDocumentList"

    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = WHERE("Document Type" = CONST(Order),
                                      SendToKirn = CONST(true),
                                      SendToKirnDate = CONST());
            RequestFilterFields = "Shipping Agent Code", "No.", "Shipment Date", "Order Date";

            trigger OnAfterGetRecord()
            begin
                SendOrderDocument("Sales Header");
            end;

            trigger OnPostDataItem()
            begin
                //Edi Datei wegschreiben
                CloseDocumentList();
            end;

            trigger OnPreDataItem()
            begin
                "Sales Header".SETFILTER("Document Date", '>=%1', CALCDATE('-' + FORMAT(ToleranceDays) + 'T', WORKDATE));

                IF NOT "Sales Header".FINDSET THEN
                    ERROR(NoOrderFoundErr);

                //neue EDI Datei anlegen
                CreateDocumentList();
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
                    field(CustomerNoCentralPayer; CustomerNoCentralPayer)
                    {
                        Caption = 'Central Payer';
                        TableRelation = "stratEdi Setup"."Customer No.";
                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            stratEdiSetup.RESET;
                            stratEdiSetup.SETRANGE("EDI Document Type", stratEdiSetup."EDI Document Type"::Aufträge);

                            IF PAGE.RUNMODAL(PAGE::"stratEdi Setup", stratEdiSetup) = ACTION::LookupOK THEN BEGIN
                                CustomerNoCentralPayer := stratEdiSetup."Customer No.";
                                ToleranceDays := stratEdiSetup."stratEDI Tolerance Days";
                            END;
                        end;
                    }
                    field("EDI Document Type"; stratEdiSetup."EDI Document Type")
                    {
                        Caption = 'EDI Beleg';
                        DrillDown = false;
                        Editable = false;
                        Enabled = false;
                        Lookup = false;
                    }
                    field(ToleranceDays; ToleranceDays)
                    {
                        Caption = 'Anzahl Karenztage';
                    }
                    field(TestRun; TestRun)
                    {
                        Caption = 'Test';
                    }
                    field(PriceExport; PriceExport)
                    {
                        Caption = 'Preise exportieren';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            stratEdiSetup.SETRANGE("EDI Document Type", stratEdiSetup."EDI Document Type"::Aufträge);
            IF stratEdiSetup.FINDFIRST THEN;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        TestRun := FALSE;
        PriceExport := FALSE;
    end;

    trigger OnPostReport()
    var
        stratEdiProtocol: Record "50004";
    begin
        MESSAGE('Der stratEDI Export wurde erfolgreich durchgeführt.\Liste-Nr.: %1.\Anzahl Belege: %2', Listennummer, SalesHeaderCounter);
    end;

    trigger OnPreReport()
    begin
        IF CustomerNoCentralPayer = '' THEN
            ERROR(NoCustomerFoundErr);

        CentralPayerCustomer.RESET;
        CentralPayerCustomer.GET(CustomerNoCentralPayer);

        IF stratEdiSetup."stratEDI List Nos." = '' THEN
            ERROR('In der stratEDI Einrichtung muss das Feld ''stratEDI Liste Nummern'' gepflegt sein.');
    end;

    var
        StringBuilder_dn: DotNet StringBuilder;
        String_dn: DotNet String;
        DateTime_dn: DotNet DateTime;
        StreamWriter_dn: DotNet StreamWriter;
        TextLine: Text;
        ILNIdSender: Text[35];
        ILNIdReceiver: Text[35];
        Datenaustauschreferenz: Text;
        Versionsnummer: Text;
        NachrichtenReferenz: Code[10];
        ArtDerTransaktion: Text[3];
        Listennummer: Code[10];
        Listenendbetrag: Decimal;
        MwStListenendbetrag: Decimal;
        CompanyInformation: Record "Company Information";
        TXT001: Label 'Es bestehen Vereinbarungen, aus denen sich nachträgliche Entgeltminderungen ergeben können';
        NoSeriesManagement: Codeunit "396";
        ShipmentNo: Code[20];
        ShipmentDate: Date;
        Customer: Record "Customer";
        SalesHeaderCounter: Integer;
        ToleranceDays: Integer;
        stratEdiSetup: Record "50005";
        SpecialFiller: Text[100];
        NoCustomerFoundErr: Label 'Please select a Central payer';
        NoOrderFoundErr: Label 'Es gibt nichts zu senden.';
        TestRun: Boolean;
        CustomerNoCentralPayer: Code[20];
        CentralPayerCustomer: Record "Customer";
        PriceExport: Boolean;
        UnitPrice: Decimal;
        LineAmount: Decimal;
        LineDiscountAmount: Decimal;

    local procedure GetYYYYMMDD(Date_par: Date): Text
    begin

        IF Date_par = 0D THEN
            EXIT('');

        EXIT
        (
        FORMAT(DATE2DMY(Date_par, 3))
        +
        PADSTR('', 2 - STRLEN(FORMAT(DATE2DMY(Date_par, 2))), '0') + FORMAT(DATE2DMY(Date_par, 2))
        +
        PADSTR('', 2 - STRLEN(FORMAT(DATE2DMY(Date_par, 1))), '0') + FORMAT(DATE2DMY(Date_par, 1))
        )
    end;

    local procedure GetHHMM(): Text
    begin

        DateTime_dn := DateTime_dn.Now;
        EXIT(DateTime_dn.ToString('hhmm'));
    end;

    local procedure CreateDocumentList()
    begin
        StringBuilder_dn := StringBuilder_dn.StringBuilder();
        StringBuilder_dn.Clear();

        //Satzart 000: Interchange-Header (1 x pro Übertragungsdatei)
        CompanyInformation.GET;
        //ILNIdSender := CompanyInformation.GLN;
        ILNIdSender := '4260022560005'; //TODO: Dicke GLN für alle Versendungen benutzen
        ILNIdReceiver := CentralPayerCustomer.GLN;

        Versionsnummer := '4.5';
        Listennummer := NoSeriesManagement.GetNextNo(stratEdiSetup."stratEDI List Nos.", WORKDATE, TRUE);
        Datenaustauschreferenz := FORMAT(DATE2DMY(TODAY, 3)) + FORMAT(DATE2DMY(TODAY, 2)) + FORMAT(DATE2DMY(TODAY, 1)); //TODO: Wie soll die Referenz aussehen

        MwStListenendbetrag := 0;
        Listenendbetrag := 0;
        SalesHeaderCounter := 0;

        StringBuilder_dn.AppendLine
        (
        '000;' //000-01
        + ILNIdSender + ';' //000-02
        + ILNIdReceiver + ';' //000-03
        + GetYYYYMMDD(TODAY) + ';' //000-04
        + GetHHMM() + ';' //000-05
        + Listennummer + ';' //000-06
        //+ ';;1;' //000-07 - 000-09 FÜR TESTÜBERTRAGUNG FELD 9 = 1 setzen!
        + ';;;' //000-07 - 000-09 ECHTBETRIEB
        + Versionsnummer + ';' //000-10
        );
    end;

    local procedure CloseDocumentList()
    var
        FileManagement: Codeunit "419";
        ServerTempFileName: Text[250];
        ClientFolderName: Text[250];
        stratEdiProtocol: Record "50004";
    begin
        //Datei abspeichern
        ServerTempFileName := STRSUBSTNO('StratEDI-%1-%2-%3.inh', Listennummer, CustomerNoCentralPayer, Datenaustauschreferenz);
        //ServerTempFileName := FileManagement.ServerTempFileName('.inh');

        StreamWriter_dn := StreamWriter_dn.StreamWriter(stratEdiSetup."stratEDI Export Path" + ServerTempFileName);
        StreamWriter_dn.WriteLine(StringBuilder_dn.ToString());
        StreamWriter_dn.Close();

        //Protokoll Einträge ändern
        IF NOT TestRun THEN BEGIN
            stratEdiProtocol.RESET();
            //DI03:est.uki >>>
            stratEdiProtocol.SETRANGE("Document Type", stratEdiProtocol."Document Type"::Order);
            //DI03:est.uki <<<
            stratEdiProtocol.SETRANGE("Document Direction", stratEdiProtocol."Document Direction"::Ausgehend);
            stratEdiProtocol.SETRANGE("List No.", Listennummer);
            stratEdiProtocol.SETRANGE("Central Payer No.", CustomerNoCentralPayer);
            stratEdiProtocol.MODIFYALL("Posted Date", TODAY);
            stratEdiProtocol.MODIFYALL("Posted Time", TIME);
            stratEdiProtocol.MODIFYALL("Edi File Name", ServerTempFileName);
        END;
    end;

    local procedure SendOrderDocument(SalesHeader_par: Record "Sales Header")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record "Customer";
        ExternalDocumentNo: Code[35];
        SalesLine: Record "Sales Line";
        stratEdiProtocol: Record "50004";
        ShipmentDate: Date;
        CustInvoiceDisc: Record "19";
    begin
        //*****************************************
        //Eine Rechnung ist eine Transaktion
        //*****************************************

        //zunächst prüfen, ob diese Rechnung nicht
        //schon gesendet wurde.
        IF NOT TestRun THEN BEGIN
            stratEdiProtocol.RESET();
            stratEdiProtocol.SETRANGE("Document Type", stratEdiProtocol."Document Type"::Order);
            stratEdiProtocol.SETRANGE("Document No.", SalesHeader_par."No.");
            stratEdiProtocol.SETRANGE("Document Direction", stratEdiProtocol."Document Direction"::Ausgehend);
            stratEdiProtocol.SETRANGE(Status, stratEdiProtocol.Status::Posted);
            IF (stratEdiProtocol.FINDSET) THEN
                stratEdiProtocol.DELETE; //Rechnung wurde bereits gesendet, daher im Protokoll löschen.
        END;

        ShipmentDate := SalesHeader_par."Shipment Date";

        IF NOT CompanyInformation.GET() THEN
            CompanyInformation.INIT;

        //Satzart 100: Transaktionskopf (1 x pro Transaktion)
        NachrichtenReferenz := SalesHeader_par."No."; //TODO: Ist die Rechnungsnummer die korrekte Referenz für die Transaktion?
        ArtDerTransaktion := '220'; //220=Auftrag

        SpecialFiller := '';

        StringBuilder_dn.AppendLine
        (
        '100;' //100-01
        + FORMAT(NachrichtenReferenz) + ';' //100-02
        + 'ORDERS;D;96A;UN;EAN008;' //100-03 - 100-07
        + ArtDerTransaktion + ';' //100-08
        + ';' //100-09
        + SalesHeader_par."No." + ';' //100-10
        + GetYYYYMMDD(SalesHeader_par."Document Date") + ';' //100-11
        + ';;;;' //100-12 - //100-15
        + SpecialFiller + ';' //100-16
        );

        //Satzart 111: Referenzen zur Transaktion (max. 1 x pro Transaktion)
        SpecialFiller := '';
        ShipmentNo := SalesHeader_par."No.";

        ExternalDocumentNo := SalesHeader_par."External Document No.";
        StringBuilder_dn.AppendLine
        (
        '111;' //111-01
        + ';;;;' //111-02 - 111-05
        + ExternalDocumentNo + ';' //111-06
        + GetYYYYMMDD(SalesHeader_par."Order Date") + ';' //111-07
        + SalesHeader_par."No." + ';' //111-08
        + GetYYYYMMDD(SalesHeader_par."Order Date") + ';' //111-09
        + GetYYYYMMDD(ShipmentDate) + ';' //111-10
        //+ GetYYYYMMDD("Sales Invoice Header"."Shipment Date") + ';' //111-10
        + ShipmentNo + ';' //111-11
        + GetYYYYMMDD(ShipmentDate) + ';' //111-12
        + FORMAT(Listennummer) + ';' //111-13
        + GetYYYYMMDD(TODAY) + ';' //111-14
        + SpecialFiller + ';' //111-15
        + ';;' //111-16 - //100-17
        );

        //Satzart 115: Termine (max. 1 x pro Transaktion)
        StringBuilder_dn.AppendLine
        (
        '115;' //115-01
        + GetYYYYMMDD(SalesHeader_par."Requested Delivery Date") + ';' //115-02
        + ';;' //115-03 - 115-04
        + GetYYYYMMDD(SalesHeader_par."Promised Delivery Date") + ';' //115-05
        + GetYYYYMMDD(SalesHeader_par."Shipment Date Shipping Agent") + ';' //115-06
        + GetYYYYMMDD(SalesHeader_par."Shipment Date") + ';' //115-07
        + ';;;;;;;;;;;;;;' //115-08 - 115-21
        );

        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET(SalesHeader_par."Sell-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        + 'BY;' //119-02
        + STRSUBSTNO('D%1', SalesHeader_par."Sell-to Customer No.") + ';' //119-03
        + SalesHeader_par."Sell-to Customer Name" + ';' //119-04
        + SalesHeader_par."Sell-to Customer Name 2" + ';' //119-05
        + ';' //119-06
        + SalesHeader_par."Sell-to Address" + ';' //119-07
        + SalesHeader_par."Sell-to Address 2" + ';' //119-08
        + ';' //119-09
        + SalesHeader_par."Sell-to Post Code" + ';' //119-10
        + SalesHeader_par."Sell-to City" + ';' //119-11
        + SalesHeader_par."Sell-to Country/Region Code" + ';' //119-12
        + SalesHeader_par."Sell-to Customer No." + ';' //119-13
        + ';;;;;;;;' //119-14 - 119-21
        );

        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET(SalesHeader_par."Bill-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        + 'SU;' //119-02
        + ILNIdReceiver + ';' //119-03
        + ';;;;;;;;;;;;;;;;;;;' //119-04 - 119-22
        );

        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET(SalesHeader_par."Sell-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        + 'DP;' //119-02
        + STRSUBSTNO('D%1', SalesHeader_par."Sell-to Customer No.") + ';' //119-03
        + SalesHeader_par."Ship-to Name" + ';' //119-04
        + SalesHeader_par."Ship-to Name 2" + ';' //119-05
        + ';' //119-06
        + SalesHeader_par."Ship-to Address" + ';' //119-07
        + SalesHeader_par."Ship-to Address 2" + ';' //119-08
        + ';' //119-09
        + SalesHeader_par."Ship-to Post Code" + ';' //119-10
        + SalesHeader_par."Ship-to City" + ';' //119-11
        + SalesHeader_par."Ship-to Country/Region Code" + ';' //119-12
        + ';;;;;;;;;;' //119-13 - 119-22
        );

        //Satzart 120: Währung, MwSt.-Satz, Zahlungsbedingungen (max. 1 x pro Transaktion)
        StringBuilder_dn.AppendLine
        (
        '120;' //120-01
        + 'EUR' + ';' //120-02
        + '7.00' + ';' //120-03
        + ';;;;;;;;' //120-04 - 120-11
        + GetShippingAgentCode(SalesHeader_par."Shipping Agent Code") + ';' //120-12
        + ';;;;;' //120-13 - 120-17
        );

        //Satzart 130: Textsatz (max. 10 pro Transaktion)
        StringBuilder_dn.AppendLine
        (
        '130;' //130-01
        + 'SUR' + ';' //130-02
        + TXT001 + ';' //130-03
        + ';' //130-04
        );

        //Debitoren Rabatt holen
        CustInvoiceDisc.RESET;
        CustInvoiceDisc.SETRANGE(Code, SalesHeader_par."Bill-to Customer No.");
        CustInvoiceDisc.SETFILTER("Minimum Amount", '<=%1', SalesHeader_par.Amount);
        IF NOT CustInvoiceDisc.FINDLAST THEN
            CustInvoiceDisc.INIT;

        //Summen berechnen
        SalesHeader_par.CALCFIELDS("Amount Including VAT", Amount, "Invoice Discount Amount");

        //Satzart 140: Skonto, Fracht, Verpackung, Versicherung (max. 1 x pro Transaktion und MWSt.-Satz)
        StringBuilder_dn.AppendLine
        (
        '140;' //140-01
        + '7.00' + ';' //140-02
        + '0' + ';' //140-03
        + '0' + ';' //140-04
        + ';;;;;;;;;' //140-05 - 140-13
        );

        //jetzt die Auftragszeilen senden
        SalesLine.RESET();
        SalesLine.SETRANGE("Document Type", SalesHeader_par."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader_par."No.");
        SalesLine.SETRANGE(Type, SalesLine.Type::Item);

        IF SalesLine.FINDSET() THEN
            REPEAT
                SendOrderLine(SalesLine);
            UNTIL SalesLine.NEXT = 0;

        //Satzart 900: Belegsummen (1 x pro Transaktion)
        IF PriceExport THEN
            StringBuilder_dn.AppendLine
            (
            '900;' //900-01
            + CONVERTSTR(FORMAT(SalesHeader_par.Amount, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-02
            + CONVERTSTR(FORMAT(SalesHeader_par."Amount Including VAT" - SalesHeader_par.Amount, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-03
            + ';' //900-04
            )
        ELSE
            StringBuilder_dn.AppendLine
            (
            '900;' //900-01
            + '0.00' + ';' //900-02
            + '0.00' + ';' //900-03
            + ';' //900-04
            );
        //900;277.82;19.45;;
        IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN BEGIN
            //Satzart 913: Zu-/Abschläge auf Belegebene (1 x pro Abschlagsart)
            StringBuilder_dn.AppendLine
            (
            '913;' //913-01
            + 'A;' //913-02
            + 'DI;' //913-03
            + '1;' //913-04
            + '7.00' + ';' //913-05
            + CONVERTSTR(FORMAT(CustInvoiceDisc."Discount %", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-06
            + CONVERTSTR(FORMAT(SalesHeader_par."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-07
            + ';;' //913-08 - 913-09
            + CONVERTSTR(FORMAT(SalesHeader_par.Amount + SalesHeader_par."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-10
            + 'Vereinbarter Rabatt;' //913-11
            + ';' //913-12
            );
        END;

        Listenendbetrag := Listenendbetrag + SalesHeader_par."Amount Including VAT";
        MwStListenendbetrag := MwStListenendbetrag + (SalesHeader_par."Amount Including VAT" - SalesHeader_par.Amount);

        //Satzart 901: MWSt.-Angaben (1 x pro Transaktion und MWSt.-Satz)
        // nur erforderlich falls mehrer MWSt. Sätze pro Rechnung vorhanden sind...

        //Rechnung als gesendet protokollieren
        IF NOT TestRun THEN BEGIN
            stratEdiProtocol.INIT();
            stratEdiProtocol."Document Type" := stratEdiProtocol."Document Type"::Order;
            stratEdiProtocol."Document No." := SalesHeader_par."No.";
            stratEdiProtocol."Document Direction" := stratEdiProtocol."Document Direction"::Ausgehend;
            stratEdiProtocol.Status := stratEdiProtocol.Status::Posted;
            stratEdiProtocol."List No." := Listennummer;
            stratEdiProtocol."Central Payer No." := CustomerNoCentralPayer;
            stratEdiProtocol."Edi Version" := Versionsnummer;
            IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::KIRN THEN
                stratEdiProtocol.Protocol := 'EANCOM_KIRN';
            stratEdiProtocol.INSERT;

            SalesHeader_par.SendToKirnDate := TODAY();
            SalesHeader_par.SendToKirnTime := TIME();
            SalesHeader_par.MODIFY;
        END;

        SalesHeaderCounter := SalesHeaderCounter + 1;
    end;

    local procedure SendOrderLine(SalesLine_par: Record "Sales Line")
    var
        Item_lrec: Record "Item";
        SalesInvoiceLine: Record "113";
        UnitOfMeasureCode: Code[3];
    begin
        IF NOT Item_lrec.GET(SalesLine_par."No.") THEN;

        // Feld 500-22 TODO: 'PCE'= Stück, 'KGM' = Kilogramm
        UnitOfMeasureCode := 'PCE';
        //IF COPYSTR(SalesLine_par."Unit of Measure",1,2) = 'KG' THEN
        //  UnitOfMeasureCode := 'KGM';

        UnitPrice := 0;
        LineAmount := 0;
        LineDiscountAmount := 0;
        IF PriceExport THEN BEGIN
            UnitPrice := SalesLine_par."Unit Price";
            LineAmount := SalesLine_par."Line Amount";
            LineDiscountAmount := SalesLine_par."Line Discount Amount";

        END;

        //Satzart 500: Rechnungsposition (n-mal pro Transaktion / 1 x pro Artikel)
        StringBuilder_dn.AppendLine
        (
        '500;' //500-01
        + FORMAT(SalesLine_par."Line No.") + ';' //500-02
        + ';' //500-03
        + Item_lrec.GTIN + ';' //500-04
        + Item_lrec."Vendor Item No." + ';' //500-05
        + ConvertItemNo(Item_lrec."No.") + ';' //500-06
        // + Item_lrec."Product Group Code" + ';' //500-07 TODO: REMOVED
        + SalesLine_par.Description + ';' //500-08
        + SalesLine_par."Description 2" + ';' //500-09
        + ';;' //500-10 - 500-11
        + CONVERTSTR(FORMAT(SalesLine_par.Quantity, 0, '<Sign><Integer><Decimals,3><Comma,,>'), ',', '.') + ';' //500-12
        + ';;' //500-13 - 500-14
        + CONVERTSTR(FORMAT(SalesLine_par."VAT %", 0, '<Sign><Integer><Decimals,3><Comma,,>'), ',', '.') + ';' //500-15
        + CONVERTSTR(FORMAT(UnitPrice, 0, '<Sign><Integer><Decimals,3><Comma,,>'), ',', '.') + ';' //500-16
        + ';;;;;' //500-17 - 500-21
        + UnitOfMeasureCode + ';' // 500-22 TODO: 'PCE'= Stück, 'KGM' = Kilogramm
        //+  CONVERTSTR(FORMAT(SalesInvoiceLine_par.Amount,0,'<Sign><Integer><Decimals><Comma,,>'),',','.')  + ';' //500-23
        + CONVERTSTR(FORMAT(LineAmount, 0, '<Sign><Integer><Decimals,3><Comma,,>'), ',', '.') + ';' //500-23
        + ';' //500-24
        + CONVERTSTR(FORMAT(LineDiscountAmount, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-25
        + ';;;;;;;;;;;' //500-26 - 500-36
        + 'N;' //500-37 - Konditionssperre
        );

        //Satzart 513: Artikelzuschläge/-rabatte (max. 1 x pro Artikel und Abschlagsart / -stufe)
        IF SalesLine_par."Line Discount %" > 0 THEN BEGIN
            StringBuilder_dn.AppendLine
            (
            '513;' //513-01
            + 'A;' //513-02
            + 'DI;' //513-03
            + '1;' //513-04
            + '7.00;' //513-05
            + FORMAT(SalesLine_par."Line Discount %") + ';' //513-06
            + CONVERTSTR(FORMAT(SalesLine_par."Line Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //513-07
            + ';;;;;' //500-08 - 500-12
            )
        END;

        //Satzart 530: Artikeltextsatz (max. 5 pro Belegposition)
        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETRANGE("Document No.", SalesLine_par."Document No.");
        SalesInvoiceLine.SETRANGE("Attached to Line No.", SalesLine_par."Line No.");
        SalesInvoiceLine.SETRANGE(Type, SalesInvoiceLine.Type::" ");
        IF SalesInvoiceLine.FINDSET THEN
            REPEAT
                StringBuilder_dn.AppendLine
                (
                '530;' //530-01
                + 'INF;' //530-02
                + SalesLine_par.Description + ';' //530-03
                + ';' //530-04
                )
UNTIL SalesInvoiceLine.NEXT = 0;
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
    procedure GetShippingAgentCode(ShippingAgentCode: Code[10]): Code[10]
    begin
        //ALB = Albatros -> T5
        //KIRN = Kirn -> T18
        //NAG = Nagel -> T22
        //DIS = Dischinger -> T23
        //EHG,SÜDWE = leer
        //R9 = T90
        //R11 = T91

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
            'R9':
                BEGIN
                    EXIT('T90');
                END;
            'R11':
                BEGIN
                    EXIT('T91');
                END;
        END;
    end;
}

