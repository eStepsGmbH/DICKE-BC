report 50091 "EDI Invoic 45"
{
    //  --------------------------------------------------------------------------------
    //  No.   SC-No.    Date     Sign    Description
    //  --------------------------------------------------------------------------------
    //  DI01            24.07.18 est.uki Modify Shipment Infos.
    //  DI02            03.05.23 est.uki Modify Shipment Infos.
    //  DI03            11.03.24 est.uki Add 913 for Rewe Specific

    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number)
                                ORDER(Ascending);
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            begin
                //Zentralregulierer holen
                //CentralPayerCustomer.RESET;
                //CentralPayerCustomer.SETRANGE("Is Central Payer",TRUE);
                //CentralPayerCustomer.SETRANGE("No.",CustomerNoCentralPayer);
                //CentralPayerCustomer.SETRANGE("Document Sending Profile",'EANCOM_REWE');
                CentralPayerCustomer.RESET;
                CentralPayerCustomer.SETRANGE("No.", CustomerNoCentralPayer);

                //und abarbeiten
                IF CentralPayerCustomer.FINDFIRST THEN BEGIN

                    //neue EDI Datei anlegen
                    CreateDocumentList();

                    Customer.SETRANGE("Central Payer", CentralPayerCustomer."No.");
                    IF Customer.FINDSET THEN
                        REPEAT

                            IF SingleDocument <> '' THEN BEGIN
                                IF SingleDocumentType = SingleDocumentType::Rechnung THEN BEGIN
                                    "Sales Invoice Header".RESET;
                                    "Sales Invoice Header".SETRANGE("Sell-to Customer No.", Customer."No.");
                                    "Sales Invoice Header".SETRANGE("No.", SingleDocument);
                                    IF "Sales Invoice Header".FINDFIRST THEN
                                        SendInvoiceDocument("Sales Invoice Header");
                                END;
                                IF SingleDocumentType = SingleDocumentType::Gutschrift THEN BEGIN
                                    SalesCrMemoHeader.RESET;
                                    SalesCrMemoHeader.SETRANGE("Sell-to Customer No.", Customer."No.");
                                    SalesCrMemoHeader.SETRANGE("No.", SingleDocument);
                                    IF SalesCrMemoHeader.FINDFIRST THEN
                                        SendCrMemoDocument(SalesCrMemoHeader);
                                END;
                            END ELSE BEGIN
                                IF (stratEdiSetup."EDI Document Type" = stratEdiSetup."EDI Document Type"::Rechnungen)
                                OR (stratEdiSetup."EDI Document Type" = stratEdiSetup."EDI Document Type"::"Rech. und Gutschr.") THEN BEGIN
                                    //nur die Rechnungen holen, bei denen das Belegdatum in der Karenzzeit
                                    //die in der Verkaufseinrichtung angegeben ist liegt.
                                    "Sales Invoice Header".RESET;
                                    "Sales Invoice Header".SETRANGE("Sell-to Customer No.", Customer."No.");
                                    "Sales Invoice Header".SETFILTER("Posting Date", '>=%1', CALCDATE('-' + FORMAT(ToleranceDays) + 'T', WORKDATE));
                                    IF "Sales Invoice Header".FINDSET THEN
                                        REPEAT
                                            SendInvoiceDocument("Sales Invoice Header");
                                        UNTIL "Sales Invoice Header".NEXT = 0;
                                END;
                                IF (stratEdiSetup."EDI Document Type" = stratEdiSetup."EDI Document Type"::Gutschriften)
                                  OR (stratEdiSetup."EDI Document Type" = stratEdiSetup."EDI Document Type"::"Rech. und Gutschr.") THEN BEGIN
                                    //nur die Gutschriften holen, bei denen das Belegdatum in der Karenzzeit
                                    //die in der Verkaufseinrichtung angegeben ist liegt.
                                    SalesCrMemoHeader.RESET;
                                    SalesCrMemoHeader.SETRANGE("Sell-to Customer No.", Customer."No.");
                                    SalesCrMemoHeader.SETFILTER("Posting Date", '>=%1', CALCDATE('-' + FORMAT(ToleranceDays) + 'T', WORKDATE));
                                    IF SalesCrMemoHeader.FINDSET THEN
                                        REPEAT
                                            SendCrMemoDocument(SalesCrMemoHeader);
                                        UNTIL SalesCrMemoHeader.NEXT = 0;
                                END;
                            END;

                        UNTIL Customer.NEXT = 0;

                    //Edi Datei wegschreiben
                    CloseDocumentList();

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
                group(Optionen)
                {
                    field(CustomerNoCentralPayer; CustomerNoCentralPayer)
                    {
                        Caption = 'Central Payer';
                        TableRelation = "stratEdi Setup"."Customer No.";

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            stratEdiSetup.RESET;
                            stratEdiSetup.SETFILTER("EDI Document Type", '<>%1', stratEdiSetup."EDI Document Type"::Aufträge);

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
                }
                group(Einzeldokument)
                {
                    Caption = 'Einzeldokument';
                    field(SingleDocumentType; SingleDocumentType)
                    {
                        Caption = 'Belegtyp';
                    }
                    field(SingleDocument; SingleDocument)
                    {
                        Caption = 'Belegnummer';
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

    trigger OnPostReport()
    var
        stratEdiProtocol: Record "50004";
    begin

        MESSAGE('Der stratEDI Export wurde erfolgreich durchgeführt.\Liste-Nr.: %1.\Anzahl Belege: %2', Rechnungslistennummer, SalesInvoiceCounter);

        //stratEdiProtocol.RESET;
        //stratEdiProtocol.SETRANGE("List No.",Rechnungslistennummer);
        //REPORT.RUN(50092,FALSE,FALSE,stratEdiProtocol);
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
        Rechnungslistennummer: Code[10];
        Rechnungslistenendbetrag: Decimal;
        MwStListenendbetrag: Decimal;
        CentralPayerCustomer: Record "Customer";
        CompanyInformation: Record "Company Information";
        TXT001: Label 'Es bestehen Vereinbarungen, aus denen sich nachträgliche Entgeltminderungen ergeben können';
        NoSeriesManagement: Codeunit "396";
        ShipmentNo: Code[20];
        ShipmentDate: Date;
        "Sales Invoice Header": Record "Sales Invoice Header";
        Customer: Record "Customer";
        SalesInvoiceCounter: Integer;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ToleranceDays: Integer;
        CustomerNoCentralPayer: Code[20];
        NoCustomerFoundErr: Label 'Please select a Central payer';
        stratEdiSetup: Record "50005";
        SpecialFiller: Text[100];
        SpecialFiller2: Text[100];
        SingleDocument: Code[20];
        SingleDocumentType: Option " ",Rechnung,Gutschrift;

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

    local procedure GetShipmentInfos()
    var
        SalesInvoiceLine: Record "113";
        ValueEntry: Record "5802";
        ItemLedgerEntry: Record "32";
    begin
        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETRANGE("Document No.", "Sales Invoice Header"."No.");
        SalesInvoiceLine.SETRANGE(Type, SalesInvoiceLine.Type::Item);
        IF SalesInvoiceLine.FINDFIRST() THEN BEGIN
            ValueEntry.RESET;
            ValueEntry.SETRANGE("Document Type", ValueEntry."Document Type"::"Sales Invoice");
            ValueEntry.SETRANGE("Document No.", SalesInvoiceLine."Document No.");
            ValueEntry.SETRANGE("Document Line No.", SalesInvoiceLine."Line No.");
            IF ValueEntry.FINDSET() THEN BEGIN
                //Artikelposten holen
                ItemLedgerEntry.RESET;
                IF ItemLedgerEntry.GET(ValueEntry."Item Ledger Entry No.") THEN BEGIN
                    IF ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" THEN BEGIN
                        ShipmentNo := ItemLedgerEntry."Document No.";
                        ShipmentDate := ItemLedgerEntry."Document Date";
                    END;
                END;
            END;
        END;
    end;

    local procedure CreateDocumentList()
    begin
        StringBuilder_dn := StringBuilder_dn.StringBuilder();
        StringBuilder_dn.Clear();

        //Satzart 000: Interchange-Header (1 x pro Übertragungsdatei)
        CompanyInformation.GET;
        ILNIdSender := CompanyInformation.GLN;
        ILNIdReceiver := CentralPayerCustomer.GLN;

        Versionsnummer := '4.5';
        Rechnungslistennummer := NoSeriesManagement.GetNextNo(stratEdiSetup."stratEDI List Nos.", WORKDATE, TRUE);
        Datenaustauschreferenz := FORMAT(DATE2DMY(TODAY, 3)) + FORMAT(DATE2DMY(TODAY, 2)) + FORMAT(DATE2DMY(TODAY, 1)); //TODO: Wie soll die Referenz aussehen

        MwStListenendbetrag := 0;
        Rechnungslistenendbetrag := 0;
        SalesInvoiceCounter := 0;

        StringBuilder_dn.AppendLine
        (
        '000;' //000-01
        + ILNIdSender + ';' //000-02
        + ILNIdReceiver + ';' //000-03
        + GetYYYYMMDD(TODAY) + ';' //000-04
        + GetHHMM() + ';' //000-05
        + Rechnungslistennummer + ';' //000-06
        + ';;;' //000-07 - 000-09 FÜR TESTÜBERTRAGUNG FELD 9 = 1 setzen!
        // + ';;;' //000-07 - 000-09 ECHTBETRIEB
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

        //Satzart 990: Rechnungsliste (1 x pro Übertragungsdatei)
        StringBuilder_dn.AppendLine
        (
        '990;' //990-01
        + '393' + ';' //990-02: "390" = Rechnungsliste (mit Delcredere); "393" = ReLi (ohne Delcredere)
        + Rechnungslistennummer + ';' //990-03
        + GetYYYYMMDD(TODAY) + ';' //990-04
        + ';' //990-05
        + FORMAT(ILNIdSender) + ';' //990-06 - ILN RL-Ersteller
        + ';' //990-07
        + FORMAT(CentralPayerCustomer.GLN) + ';' //990-08 - ILN RL-Zentralregulierer
        + FORMAT(ILNIdSender) + ';' //990-09 - ILN Zahlungsempfänger
        + FORMAT(CentralPayerCustomer.GLN) + ';' //990-10 - ILN Zahlungsleistender
        + 'EUR;' //990-11
        + ';;' //990-12 - 990-13 TODO: Gibt es ein Valuta oder Fälligkeitsdatum?
        + CONVERTSTR(FORMAT(Rechnungslistenendbetrag, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //990-14
        + CONVERTSTR(FORMAT(MwStListenendbetrag, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //990-15
        + CONVERTSTR(FORMAT(Rechnungslistenendbetrag - MwStListenendbetrag, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //990-16
        + ';;;' //990-17 - 990-19
        + GetVatPercent("Sales Invoice Header") + ';' //990-20
        + ';;' //990-21 - 990-22
        );

        //Datei abspeichern
        ServerTempFileName := STRSUBSTNO('StratEDI-%1-%2-%3.inh', Rechnungslistennummer, CentralPayerCustomer."No.", Datenaustauschreferenz);
        //ServerTempFileName := FileManagement.ServerTempFileName('.inh');

        StreamWriter_dn := StreamWriter_dn.StreamWriter(stratEdiSetup."stratEDI Export Path" + ServerTempFileName);
        StreamWriter_dn.WriteLine(StringBuilder_dn.ToString());
        StreamWriter_dn.Close();

        //Protokoll Einträge ändern
        stratEdiProtocol.RESET();
        stratEdiProtocol.SETRANGE("List No.", Rechnungslistennummer);
        stratEdiProtocol.SETRANGE("Central Payer No.", CustomerNoCentralPayer);
        stratEdiProtocol.MODIFYALL("Posted Date", TODAY);
        stratEdiProtocol.MODIFYALL("Posted Time", TIME);
        stratEdiProtocol.MODIFYALL("Edi File Name", ServerTempFileName);
    end;

    local procedure SendInvoiceDocument(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesHeaderArchiv_lrec: Record "5107";
        CompanyInformation: Record "Company Information";
        Customer: Record "Customer";
        ExternalDocumentNo: Code[35];
        SalesInvoiceLine: Record "113";
        stratEdiProtocol: Record "50004";
        ShipmentDate: Date;
        CustInvoiceDisc: Record "19";
        SalesOrderNo: Code[20];
    begin
        //*****************************************
        //Eine Rechnung ist eine Transaktion
        //*****************************************

        //zunächst prüfen, ob diese Rechnung nicht
        //schon gesendet wurde.
        stratEdiProtocol.RESET();
        stratEdiProtocol.SETRANGE("Document Type", stratEdiProtocol."Document Type"::Invoice);
        stratEdiProtocol.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        stratEdiProtocol.SETRANGE("Document Direction", stratEdiProtocol."Document Direction"::Ausgehend);
        stratEdiProtocol.SETRANGE(Status, stratEdiProtocol.Status::Posted);
        IF (stratEdiProtocol.FINDSET) THEN
            EXIT; //Rechnung wurde bereits gesendet

        SalesHeaderArchiv_lrec.RESET;
        SalesHeaderArchiv_lrec.SETRANGE("Document Type", SalesHeaderArchiv_lrec."Document Type"::Order);
        SalesHeaderArchiv_lrec.SETRANGE("No.", "Sales Invoice Header"."Order No.");

        ShipmentDate := "Sales Invoice Header"."Shipment Date";

        IF NOT SalesHeaderArchiv_lrec.FINDLAST THEN
            SalesHeaderArchiv_lrec.INIT;

        IF (SalesHeaderArchiv_lrec.FINDLAST) AND (ShipmentDate = 0D) THEN
            REPEAT
                ShipmentDate := SalesHeaderArchiv_lrec."Shipment Date";
            UNTIL (SalesHeaderArchiv_lrec.NEXT(-1) = 0) OR (ShipmentDate <> 0D);

        IF NOT CompanyInformation.GET() THEN
            CompanyInformation.INIT;

        //Satzart 100: Transaktionskopf (1 x pro Transaktion)
        NachrichtenReferenz := "Sales Invoice Header"."No."; //TODO: Ist die Rechnungsnummer die korrekte Referenz für die Transaktion?
        ArtDerTransaktion := '380'; //380=Rechnung, 381=Gutschrift

        SpecialFiller := '';
        CASE stratEdiSetup."stratEDI Export Specifics" OF
            stratEdiSetup."stratEDI Export Specifics"::EDEKA,
          stratEdiSetup."stratEDI Export Specifics"::REWE:
                SpecialFiller := 'BA';
        END;

        //IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN
        //  SpecialFiller := 'BA';

        StringBuilder_dn.AppendLine
        (
        '100;' //100-01
        + FORMAT(NachrichtenReferenz) + ';' //100-02
        + 'INVOIC;D;96A;UN;EAN008;' //100-03 - 100-07
        + ArtDerTransaktion + ';' //100-08
        + ';' //100-09
        + "Sales Invoice Header"."No." + ';' //100-10
        + GetYYYYMMDD("Sales Invoice Header"."Document Date") + ';' //100-11
        + ';;;;' //100-12 - //100-15
        + SpecialFiller + ';' //100-16
        );

        // DI01:est.uk >>>
        ShipmentNo := SalesInvoiceHeader."Order No.";
        ShipmentDate := SalesHeaderArchiv_lrec."Shipment Date Shipping Agent";
        // DI01:est.uk <<<

        //Satzart 111: Referenzen zur Transaktion (max. 1 x pro Transaktion)
        // DI01:est.uk >>>
        IF ShipmentNo = '' THEN
            GetShipmentInfos();
        // DI01:est.uk <<<

        SpecialFiller := '';
        IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN
            SpecialFiller := '20';

        //DI02:est.uki >>>
        SalesOrderNo := SalesHeaderArchiv_lrec."No.";
        IF SalesHeaderArchiv_lrec."Source Order No." <> '' THEN BEGIN
            ShipmentNo := SalesHeaderArchiv_lrec."Source Order No.";
            SalesOrderNo := SalesHeaderArchiv_lrec."Source Order No.";
        END;
        //DI02:est.uki <<<

        ExternalDocumentNo := "Sales Invoice Header"."External Document No.";
        StringBuilder_dn.AppendLine
        (
        '111;' //111-01
        + ';;;;' //111-02 - 111-05
        + ExternalDocumentNo + ';' //111-06
        + GetYYYYMMDD(SalesHeaderArchiv_lrec."Order Date") + ';' //111-07
        + SalesOrderNo + ';' //111-08
        //+ SalesHeaderArchiv_lrec."No." + ';' //111-08
        + GetYYYYMMDD(SalesHeaderArchiv_lrec."Order Date") + ';' //111-09
        + GetYYYYMMDD(ShipmentDate) + ';' //111-10
        //+ GetYYYYMMDD("Sales Invoice Header"."Shipment Date") + ';' //111-10
        + ShipmentNo + ';' //111-11 ----->
        + GetYYYYMMDD(ShipmentDate) + ';' //111-12
        + FORMAT(Rechnungslistennummer) + ';' //111-13
        + GetYYYYMMDD(TODAY) + ';' //111-14
        + SpecialFiller + ';' //111-15
        + ';;;;;;' //111-16 - //100-21
        );

        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'SU;' //119-02
        + ILNIdSender + ';' //119-03
        + CompanyInformation.Name + ';' //119-04
        + CompanyInformation."Name 2" + ';' //119-05
        + ';' //119-06
        + CompanyInformation.Address + ';' //119-07
        + CompanyInformation."Address 2" + ';' //119-08
        + ';' //119-09
        + CompanyInformation."Post Code" + ';' //119-10
        + CompanyInformation.City + ';' //119-11
        + CompanyInformation."Country/Region Code" + ';' //119-12
        + ';;' //119-13 - 119-14
        + CompanyInformation."VAT Registration No." + ';' //119-15
        + ';;;;;;;' //119-16 - 119-22
        );
        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET("Sales Invoice Header"."Sell-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'BY;' //119-02
        + Customer.GLN + ';' //119-03
        + "Sales Invoice Header"."Sell-to Customer Name" + ';' //119-04
        + "Sales Invoice Header"."Sell-to Customer Name 2" + ';' //119-05
        + ';' //119-06
        + "Sales Invoice Header"."Sell-to Address" + ';' //119-07
        + "Sales Invoice Header"."Sell-to Address 2" + ';' //119-08
        + ';' //119-09
        + "Sales Invoice Header"."Sell-to Post Code" + ';' //119-10
        + "Sales Invoice Header"."Sell-to City" + ';' //119-11
        + "Sales Invoice Header"."Sell-to Country/Region Code" + ';' //119-12
        + "Sales Invoice Header"."Bill-to Customer No." + ';' //119-13
        + ';;;;;;;;;' //119-14 - 119-22
        );
        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET("Sales Invoice Header"."Bill-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'IV;' //119-02
        + Customer.GLN + ';' //119-03
        + "Sales Invoice Header"."Bill-to Name" + ';' //119-04
        + "Sales Invoice Header"."Bill-to Name 2" + ';' //119-05
        + ';' //119-06
        + "Sales Invoice Header"."Bill-to Address" + ';' //119-07
        + "Sales Invoice Header"."Bill-to Address 2" + ';' //119-08
        + ';' //119-09
        + "Sales Invoice Header"."Bill-to Post Code" + ';' //119-10
        + "Sales Invoice Header"."Bill-to City" + ';' //119-11
        + "Sales Invoice Header"."Bill-to Country/Region Code" + ';' //119-12
        + "Sales Invoice Header"."Bill-to Customer No." + ';' //119-13
        + ';;;;;;;;;' //119-14 - 119-22
        );
        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET("Sales Invoice Header"."Sell-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'DP;' //119-02
        + Customer.GLN + ';' //119-03
        + "Sales Invoice Header"."Ship-to Name" + ';' //119-04
        + "Sales Invoice Header"."Ship-to Name 2" + ';' //119-05
        + ';' //119-06
        + "Sales Invoice Header"."Ship-to Address" + ';' //119-07
        + "Sales Invoice Header"."Ship-to Address 2" + ';' //119-08
        + ';' //119-09
        + "Sales Invoice Header"."Ship-to Post Code" + ';' //119-10
        + "Sales Invoice Header"."Ship-to City" + ';' //119-11
        + "Sales Invoice Header"."Ship-to Country/Region Code" + ';' //119-12
        + ';;;;;;;;;;' //119-13 - 119-22
        );

        //Satzart 120: Währung, MwSt.-Satz, Zahlungsbedingungen (max. 1 x pro Transaktion)
        StringBuilder_dn.AppendLine
        (
        '120;' //120-01
        + 'EUR' + ';' //120-02
        + GetVatPercent("Sales Invoice Header") + ';' //120-03
        + ';;;;;;;;;;;;;;' //120-04 - 120-17
        );

        //Satzart 130: Textsatz (max. 10 pro Transaktion)
        StringBuilder_dn.AppendLine
        (
        '130;' //130-01
        + 'SUR' + ';' //130-02
        + TXT001 + ';' //130-03
        + ';' //130-04
        );

        //Summen berechnen
        "Sales Invoice Header".CALCFIELDS("Amount Including VAT", Amount, "Invoice Discount Amount");

        //Debitoren Rabatt holen
        CustInvoiceDisc.RESET;
        CustInvoiceDisc.SETRANGE(Code, "Sales Invoice Header"."Bill-to Customer No.");
        CustInvoiceDisc.SETFILTER("Minimum Amount", '<=%1', "Sales Invoice Header".Amount);
        IF NOT CustInvoiceDisc.FINDLAST THEN
            CustInvoiceDisc.INIT;

        //Satzart 140: Skonto, Fracht, Verpackung, Versicherung (max. 1 x pro Transaktion und MWSt.-Satz)
        StringBuilder_dn.AppendLine
        (
        '140;' //140-01
        + GetVatPercent("Sales Invoice Header") + ';' //140-02
        + '0' + ';' //140-03
        //+ CONVERTSTR(FORMAT(CustInvoiceDisc."Discount %",0,'<Sign><Integer><Decimals><Comma,,>'),',','.') + ';' //140-03
        + '0' + ';' //140-04
        //+ CONVERTSTR(FORMAT("Sales Invoice Header"."Invoice Discount Amount",0,'<Sign><Integer><Decimals><Comma,,>'),',','.') + ';' //140-04
        + ';;;;;;;;;' //140-05 - 140-13
        );

        //jetzt die Rechnungszeilen senden
        SalesInvoiceLine.RESET();
        SalesInvoiceLine.SETRANGE("Document No.", "Sales Invoice Header"."No.");
        SalesInvoiceLine.SETRANGE(Type, SalesInvoiceLine.Type::Item);

        IF SalesInvoiceLine.FINDSET() THEN
            REPEAT
                SendInvoiceLine(SalesInvoiceLine);
            UNTIL SalesInvoiceLine.NEXT = 0;

        //Satzart 900: Belegsummen (1 x pro Transaktion)
        StringBuilder_dn.AppendLine
        (
        '900;' //900-01
        + CONVERTSTR(FORMAT("Sales Invoice Header"."Amount Including VAT", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-02
        + CONVERTSTR(FORMAT("Sales Invoice Header"."Amount Including VAT" - "Sales Invoice Header".Amount, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-03
        + CONVERTSTR(FORMAT("Sales Invoice Header".Amount + "Sales Invoice Header"."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-04
        + CONVERTSTR(FORMAT("Sales Invoice Header".Amount, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-05
        + CONVERTSTR(FORMAT("Sales Invoice Header".Amount + "Sales Invoice Header"."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-06
        + CONVERTSTR(FORMAT("Sales Invoice Header"."Invoice Discount Amount" * -1, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-07
        + ';;' //900-08 - 900-09
        );

        IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN BEGIN
            //Satzart 913: Zu-/Abschläge auf Belegebene (1 x pro Abschlagsart)
            StringBuilder_dn.AppendLine
            (
            '913;' //913-01
            + 'A;' //913-02
            + 'DI;' //913-03
            + '1;' //913-04
            + GetVatPercent("Sales Invoice Header") + ';' //913-05
            + CONVERTSTR(FORMAT(CustInvoiceDisc."Discount %", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-06
            + CONVERTSTR(FORMAT("Sales Invoice Header"."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-07
            + ';;' //913-08 - 913-09
            + CONVERTSTR(FORMAT("Sales Invoice Header".Amount + "Sales Invoice Header"."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-10
            + 'Vereinbarter Rabatt;' //913-11
            + ';' //913-12
            );
        END;

        //DI03 >>>
        IF (stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::REWE) AND ("Sales Invoice Header"."Invoice Discount Amount" <> 0) THEN BEGIN
            //Satzart 913: Zu-/Abschläge auf Belegebene (1 x pro Abschlagsart)
            StringBuilder_dn.AppendLine
            (
            '913;' //913-01
            + 'A;' //913-02
            + 'DI;' //913-03
            + '1;' //913-04
            + GetVatPercent("Sales Invoice Header") + ';' //913-05
            + CONVERTSTR(FORMAT(CustInvoiceDisc."Discount %", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-06
            + CONVERTSTR(FORMAT("Sales Invoice Header"."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-07
            + ';;' //913-08 - 913-09
            + CONVERTSTR(FORMAT("Sales Invoice Header".Amount + "Sales Invoice Header"."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-10
            + 'Vereinbarter Rabatt;' //913-11
            + ';' //913-12
            );
        END;
        //DI03 <<<

        Rechnungslistenendbetrag := Rechnungslistenendbetrag + "Sales Invoice Header"."Amount Including VAT";
        MwStListenendbetrag := MwStListenendbetrag + ("Sales Invoice Header"."Amount Including VAT" - "Sales Invoice Header".Amount);

        //Satzart 901: MWSt.-Angaben (1 x pro Transaktion und MWSt.-Satz)
        // nur erforderlich falls mehrer MWSt. Sätze pro Rechnung vorhanden sind...

        //Rechnung als gesendet protokollieren
        stratEdiProtocol.INIT();
        stratEdiProtocol."Document Type" := stratEdiProtocol."Document Type"::Invoice;
        stratEdiProtocol."Document No." := SalesInvoiceHeader."No.";
        stratEdiProtocol."Document Direction" := stratEdiProtocol."Document Direction"::Ausgehend;
        stratEdiProtocol.Status := stratEdiProtocol.Status::Posted;
        stratEdiProtocol."List No." := Rechnungslistennummer;
        stratEdiProtocol."Central Payer No." := CentralPayerCustomer."No.";
        stratEdiProtocol."Edi Version" := Versionsnummer;
        stratEdiProtocol.Protocol := 'EANCOM_REWE';
        IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN
            stratEdiProtocol.Protocol := 'EANCOM_EDEKA';
        stratEdiProtocol.INSERT;
        SalesInvoiceCounter := SalesInvoiceCounter + 1;
    end;

    local procedure SendInvoiceLine(SalesInvoiceLine_par: Record "113")
    var
        Item_lrec: Record "Item";
        SalesInvoiceLine: Record "113";
        UnitOfMeasureCode: Code[3];
    begin
        IF NOT Item_lrec.GET(SalesInvoiceLine_par."No.") THEN;
        UnitOfMeasureCode := 'PCE';
        IF COPYSTR(SalesInvoiceLine_par."Unit of Measure", 1, 2) = 'KG' THEN
            UnitOfMeasureCode := 'KGM';

        //Satzart 500: Rechnungsposition (n-mal pro Transaktion / 1 x pro Artikel)
        StringBuilder_dn.AppendLine
        (
        '500;' //500-01
        + FORMAT(SalesInvoiceLine_par."Line No.") + ';' //500-02
        + ';' //500-03
        + Item_lrec.GTIN + ';' //500-04
        + Item_lrec."No." + ';' //500-05
        + ';' //500-06
        //+ Item_lrec."Product Group Code" + ';' //500-07 TODO: REMOVED
        + SalesInvoiceLine_par.Description + ';' //500-08
        + SalesInvoiceLine_par."Description 2" + ';' //500-09
        + ';;' //500-10 - 500-11
        + CONVERTSTR(FORMAT(SalesInvoiceLine_par.Quantity, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-12
        + ';;' //500-13 - 500-14
        + CONVERTSTR(FORMAT(SalesInvoiceLine_par."VAT %", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-15
        + CONVERTSTR(FORMAT(SalesInvoiceLine_par."Unit Price", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-16
        + ';;;;;' //500-17 - 500-21
        + UnitOfMeasureCode + ';' // 500-22 'PCE'= Stück, 'KGM' = Kilogramm
        //+  CONVERTSTR(FORMAT(SalesInvoiceLine_par.Amount,0,'<Sign><Integer><Decimals><Comma,,>'),',','.')  + ';' //500-23
        + CONVERTSTR(FORMAT(SalesInvoiceLine_par."Line Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-23
        + ';' //500-24
        + CONVERTSTR(FORMAT(SalesInvoiceLine_par."Line Discount Amount" * -1, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-25
        + ';;;;;;;;;;;' //500-26 - 500-36
        + 'N;' //500-37 - Konditionssperre
        );

        //Satzart 513: Artikelzuschläge/-rabatte (max. 1 x pro Artikel und Abschlagsart / -stufe)
        IF SalesInvoiceLine_par."Line Discount %" > 0 THEN BEGIN
            StringBuilder_dn.AppendLine
            (
            '513;' //513-01
            + 'A;' //513-02
            + 'DI;' //513-03
            + '1;' //513-04
            + '5.00;' //513-05
            + FORMAT(SalesInvoiceLine_par."Line Discount %") + ';' //513-06
            + CONVERTSTR(FORMAT(SalesInvoiceLine_par."Line Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //513-07
            + ';;;;;' //500-08 - 500-12
            )
        END;

        //Satzart 530: Artikeltextsatz (max. 5 pro Belegposition)
        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceLine_par."Document No.");
        SalesInvoiceLine.SETRANGE("Attached to Line No.", SalesInvoiceLine_par."Line No.");
        SalesInvoiceLine.SETRANGE(Type, SalesInvoiceLine.Type::" ");
        IF SalesInvoiceLine.FINDSET THEN
            REPEAT
                StringBuilder_dn.AppendLine
                (
                '530;' //530-01
                + 'INF;' //530-02
                + SalesInvoiceLine_par.Description + ';' //530-03
                + ';' //530-04
                )
UNTIL SalesInvoiceLine.NEXT = 0;
    end;

    local procedure SendCrMemoDocument(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record "Customer";
        ExternalDocumentNo: Code[35];
        SalesCrMemoLine: Record "115";
        stratEdiProtocol: Record "50004";
        Vertragsnummer: Text[50];
        CustInvoiceDisc: Record "19";
    begin
        //*****************************************
        //Eine Gutschrift ist eine Transaktion
        //*****************************************

        //zunächst prüfen, ob diese Gutschrift nicht
        //schon gesendet wurde.
        stratEdiProtocol.RESET();
        stratEdiProtocol.SETRANGE("Document Type", stratEdiProtocol."Document Type"::"Credit Memo");
        stratEdiProtocol.SETRANGE("Document No.", SalesCrMemoHeader."No.");
        stratEdiProtocol.SETRANGE("Document Direction", stratEdiProtocol."Document Direction"::Ausgehend);
        stratEdiProtocol.SETRANGE(Status, stratEdiProtocol.Status::Posted);
        IF (stratEdiProtocol.FINDSET) THEN
            EXIT; //Gutschrift wurde bereits gesendet

        IF NOT CompanyInformation.GET() THEN
            CompanyInformation.INIT;

        //Satzart 100: Transaktionskopf (1 x pro Transaktion)
        NachrichtenReferenz := SalesCrMemoHeader."No."; //TODO: Ist die Rechnungsnummer die korrekte Referenz für die Transaktion?
        ArtDerTransaktion := '381'; //380=Rechnung, 381=Gutschrift

        SpecialFiller := '';
        CASE stratEdiSetup."stratEDI Export Specifics" OF
            stratEdiSetup."stratEDI Export Specifics"::EDEKA,
          stratEdiSetup."stratEDI Export Specifics"::REWE:
                SpecialFiller := 'BA';
        END;

        SpecialFiller2 := '';
        //IF (SalesCrMemoHeader."Applies-to Doc. Type" = SalesCrMemoHeader."Applies-to Doc. Type"::Invoice) AND (SalesCrMemoHeader."Applies-to Doc. No." <> '') THEN
        SpecialFiller2 := 'KOR';

        StringBuilder_dn.AppendLine
        (
        '100;' //100-01
        + FORMAT(NachrichtenReferenz) + ';' //100-02
        + 'INVOIC;D;96A;UN;EAN008;' //100-03 - 100-07
        + ArtDerTransaktion + ';' //100-08
        + ';' //100-09
        + SalesCrMemoHeader."No." + ';' //100-10
        + GetYYYYMMDD(SalesCrMemoHeader."Document Date") + ';' //100-11
        + ';;;;' //100-12 - //100-15
        + SpecialFiller + ';' //100-16
        + SpecialFiller2 + ';' //100-17
        );

        Vertragsnummer := '';
        IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN
            Vertragsnummer := '20';

        //Satzart 111: Referenzen zur Transaktion (max. 1 x pro Transaktion)
        ExternalDocumentNo := SalesCrMemoHeader."External Document No.";
        StringBuilder_dn.AppendLine
        (
        '111;' //111-01
        + ';;;;' //111-02 - 111-05
        + ExternalDocumentNo + ';' //111-06
        + GetYYYYMMDD(SalesCrMemoHeader."Document Date") + ';' //111-07
        + SalesCrMemoHeader."No." + ';' //111-08
        + GetYYYYMMDD(SalesCrMemoHeader."Document Date") + ';' //111-09
        + GetYYYYMMDD(ShipmentDate) + ';' //111-10
        //+ GetYYYYMMDD("Sales Invoice Header"."Shipment Date") + ';' //111-10
        + ShipmentNo + ';' //111-11
        + GetYYYYMMDD(SalesCrMemoHeader."Document Date") + ';' //111-12
        + FORMAT(Rechnungslistennummer) + ';' //111-13
        + GetYYYYMMDD(TODAY) + ';' //111-14
        + Vertragsnummer + ';' //111-15
        + ';;;;;;' //111-16 - //100-21
        );

        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'SU;' //119-02
        + ILNIdSender + ';' //119-03
        + CompanyInformation.Name + ';' //119-04
        + CompanyInformation."Name 2" + ';' //119-05
        + ';' //119-06
        + CompanyInformation.Address + ';' //119-07
        + CompanyInformation."Address 2" + ';' //119-08
        + ';' //119-09
        + CompanyInformation."Post Code" + ';' //119-10
        + CompanyInformation.City + ';' //119-11
        + CompanyInformation."Country/Region Code" + ';' //119-12
        + ';;' //119-13 - 119-14
        + CompanyInformation."VAT Registration No." + ';' //119-15
        + ';;;;;;;' //119-16 - 119-22
        );
        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET(SalesCrMemoHeader."Sell-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'BY;' //119-02
        + Customer.GLN + ';' //119-03
        + SalesCrMemoHeader."Sell-to Customer Name" + ';' //119-04
        + SalesCrMemoHeader."Sell-to Customer Name 2" + ';' //119-05
        + ';' //119-06
        + SalesCrMemoHeader."Sell-to Address" + ';' //119-07
        + SalesCrMemoHeader."Sell-to Address 2" + ';' //119-08
        + ';' //119-09
        + SalesCrMemoHeader."Sell-to Post Code" + ';' //119-10
        + SalesCrMemoHeader."Sell-to City" + ';' //119-11
        + SalesCrMemoHeader."Sell-to Country/Region Code" + ';' //119-12
        + ';;;;;;;;;;' //119-13 - 119-22
        );
        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET(SalesCrMemoHeader."Bill-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'IV;' //119-02
        + Customer.GLN + ';' //119-03
        + SalesCrMemoHeader."Bill-to Name" + ';' //119-04
        + SalesCrMemoHeader."Bill-to Name 2" + ';' //119-05
        + ';' //119-06
        + SalesCrMemoHeader."Bill-to Address" + ';' //119-07
        + SalesCrMemoHeader."Bill-to Address 2" + ';' //119-08
        + ';' //119-09
        + SalesCrMemoHeader."Bill-to Post Code" + ';' //119-10
        + SalesCrMemoHeader."Bill-to City" + ';' //119-11
        + SalesCrMemoHeader."Bill-to Country/Region Code" + ';' //119-12
        + ';;;;;;;;;;' //119-13 - 119-22
        );
        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET(SalesCrMemoHeader."Sell-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'DP;' //119-02
        + Customer.GLN + ';' //119-03
        + SalesCrMemoHeader."Ship-to Name" + ';' //119-04
        + SalesCrMemoHeader."Ship-to Name 2" + ';' //119-05
        + ';' //119-06
        + SalesCrMemoHeader."Ship-to Address" + ';' //119-07
        + SalesCrMemoHeader."Ship-to Address 2" + ';' //119-08
        + ';' //119-09
        + SalesCrMemoHeader."Ship-to Post Code" + ';' //119-10
        + SalesCrMemoHeader."Ship-to City" + ';' //119-11
        + SalesCrMemoHeader."Ship-to Country/Region Code" + ';' //119-12
        + ';;;;;;;;;;' //119-13 - 119-22
        );

        //Satzart 120: Währung, MwSt.-Satz, Zahlungsbedingungen (max. 1 x pro Transaktion)
        StringBuilder_dn.AppendLine
        (
        '120;' //120-01
        + 'EUR' + ';' //120-02
        + GetVatPercentCrMemo(SalesCrMemoHeader) + ';' //120-03
        + ';;;;;;;;;;;;;;' //120-04 - 120-17
        );

        // //Satzart 130: Textsatz (max. 10 pro Transaktion)
        // StringBuilder_dn.AppendLine
        // (
        // '130;' //130-01
        // + 'SUR' + ';' //130-02
        // + TXT001 + ';' //130-03
        // + ';' //130-04
        // );

        //Satzart 140: Skonto, Fracht, Verpackung, Versicherung (max. 1 x pro Transaktion und MWSt.-Satz)
        StringBuilder_dn.AppendLine
        (
        '140;' //140-01
        + GetVatPercentCrMemo(SalesCrMemoHeader) + ';' //120-03
        + '0' + ';' //140-03
        + '0' + ';' //140-04
        + ';;;;;;;;;' //140-05 - 140-13
        );

        //Debitoren Rabatt holen
        CustInvoiceDisc.RESET;
        CustInvoiceDisc.SETRANGE(Code, SalesCrMemoHeader."Invoice Disc. Code");
        CustInvoiceDisc.SETFILTER("Minimum Amount", '<=%1', SalesCrMemoHeader.Amount);
        IF NOT CustInvoiceDisc.FINDLAST THEN
            CustInvoiceDisc.INIT;

        //jetzt die Rechnungszeilen senden
        SalesCrMemoLine.RESET();
        SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SETRANGE(Type, SalesCrMemoLine.Type::Item);

        IF SalesCrMemoLine.FINDSET() THEN
            REPEAT
                SendCrMemoLine(SalesCrMemoLine);
            UNTIL SalesCrMemoLine.NEXT = 0;

        //zum Schluss die Summen berechnen
        SalesCrMemoHeader.CALCFIELDS("Amount Including VAT", "Amount Including VAT", Amount, "Invoice Discount Amount");

        //Satzart 900: Belegsummen (1 x pro Transaktion)
        StringBuilder_dn.AppendLine
        (
        '900;' //900-01
        + CONVERTSTR(FORMAT(SalesCrMemoHeader."Amount Including VAT", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-02
        + CONVERTSTR(FORMAT(SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-03
        + CONVERTSTR(FORMAT(SalesCrMemoHeader.Amount + SalesCrMemoHeader."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-04
        + CONVERTSTR(FORMAT(SalesCrMemoHeader.Amount, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-05
        + CONVERTSTR(FORMAT(SalesCrMemoHeader.Amount + SalesCrMemoHeader."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-06
        + CONVERTSTR(FORMAT(SalesCrMemoHeader."Invoice Discount Amount" * -1, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //900-07
        + ';;' //900-08 - 900-09
        );

        IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN BEGIN
            IF SalesCrMemoHeader."Invoice Discount Amount" > 0 THEN BEGIN
                //Satzart 913: Zu-/Abschläge auf Belegebene (1 x pro Abschlagsart)
                StringBuilder_dn.AppendLine
                (
                '913;' //913-01
                + 'A;' //913-02
                + 'DI;' //913-03
                + '1;' //913-04
                + GetVatPercentCrMemo(SalesCrMemoHeader) + ';' //913-05
                + CONVERTSTR(FORMAT(CustInvoiceDisc."Discount %", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-06
                + CONVERTSTR(FORMAT(SalesCrMemoHeader."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-07
                + ';;' //913-08 - 913-09
                + CONVERTSTR(FORMAT(SalesCrMemoHeader.Amount + SalesCrMemoHeader."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-10
                + 'Vereinbarter Rabatt;' //913-11
                + ';' //913-12
                );
            END;
        END;

        //DI03 >>>
        IF (stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::REWE) AND (SalesCrMemoHeader."Invoice Discount Amount" <> 0) THEN BEGIN
            IF SalesCrMemoHeader."Invoice Discount Amount" > 0 THEN BEGIN
                //Satzart 913: Zu-/Abschläge auf Belegebene (1 x pro Abschlagsart)
                StringBuilder_dn.AppendLine
                (
                '913;' //913-01
                + 'A;' //913-02
                + 'DI;' //913-03
                + '1;' //913-04
                + GetVatPercentCrMemo(SalesCrMemoHeader) + ';' //913-05
                + CONVERTSTR(FORMAT(CustInvoiceDisc."Discount %", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-06
                + CONVERTSTR(FORMAT(SalesCrMemoHeader."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-07
                + ';;' //913-08 - 913-09
                + CONVERTSTR(FORMAT(SalesCrMemoHeader.Amount + SalesCrMemoHeader."Invoice Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //913-10
                + 'Vereinbarter Rabatt;' //913-11
                + ';' //913-12
                );
            END;
        END;
        //DI03 <<<

        Rechnungslistenendbetrag := Rechnungslistenendbetrag - SalesCrMemoHeader."Amount Including VAT";
        MwStListenendbetrag := MwStListenendbetrag - (SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount);

        //Satzart 901: MWSt.-Angaben (1 x pro Transaktion und MWSt.-Satz)
        // nur erforderlich falls mehrer MWSt. Sätze pro Rechnung vorhanden sind...

        //Rechnung als gesendet protokollieren
        stratEdiProtocol.INIT();
        stratEdiProtocol."Document Type" := stratEdiProtocol."Document Type"::"Credit Memo";
        stratEdiProtocol."Document No." := SalesCrMemoHeader."No.";
        stratEdiProtocol."Document Direction" := stratEdiProtocol."Document Direction"::Ausgehend;
        stratEdiProtocol.Status := stratEdiProtocol.Status::Posted;
        stratEdiProtocol."List No." := Rechnungslistennummer;
        stratEdiProtocol."Central Payer No." := CentralPayerCustomer."No.";
        stratEdiProtocol."Edi Version" := Versionsnummer;
        stratEdiProtocol.Protocol := 'EANCOM_REWE';
        IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN
            stratEdiProtocol.Protocol := 'EANCOM_EDEKA';
        stratEdiProtocol.INSERT;
        SalesInvoiceCounter := SalesInvoiceCounter + 1;
    end;

    local procedure SendCrMemoLine(SalesCrMemoLine_par: Record "115")
    var
        Item_lrec: Record "Item";
        SalesInvoiceLine: Record "113";
        UnitOfMeasureCode: Code[3];
    begin
        IF NOT Item_lrec.GET(SalesCrMemoLine_par."No.") THEN;

        // Feld 500-22 TODO: 'PCE'= Stück, 'KGM' = Kilogramm
        UnitOfMeasureCode := 'PCE';
        IF COPYSTR(SalesCrMemoLine_par."Unit of Measure", 1, 2) = 'KG' THEN
            UnitOfMeasureCode := 'KGM';

        //Satzart 500: Rechnungsposition (n-mal pro Transaktion / 1 x pro Artikel)
        StringBuilder_dn.AppendLine
        (
        '500;' //500-01
        + FORMAT(SalesCrMemoLine_par."Line No.") + ';' //500-02
        + ';' //500-03
        + Item_lrec.GTIN + ';' //500-04
        + Item_lrec."No." + ';' //500-05
        + ';' //500-06
        // + Item_lrec."Product Group Code" + ';' //500-07 TODO: REMOVED
        + SalesCrMemoLine_par.Description + ';' //500-08
        + SalesCrMemoLine_par."Description 2" + ';' //500-09
        + ';;' //500-10 - 500-11
        + CONVERTSTR(FORMAT(SalesCrMemoLine_par.Quantity, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-12
        + ';;' //500-13 - 500-14
        + CONVERTSTR(FORMAT(SalesCrMemoLine_par."VAT %", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-15
        + CONVERTSTR(FORMAT(SalesCrMemoLine_par."Unit Price", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-16
        + ';;;;;' //500-17 - 500-21
        + UnitOfMeasureCode + ';' // 500-22 'PCE'= Stück, 'KGM' = Kilogramm
        + CONVERTSTR(FORMAT(SalesCrMemoLine_par."Line Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-23
        + ';' //500-24
        + CONVERTSTR(FORMAT(SalesCrMemoLine_par."Line Discount Amount", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-25
        + ';;;;;;;;;;;' //500-26 - 500-36
        + 'N;' //500-37 - Konditionssperre
        );

        //Satzart 513: Artikelzuschläge/-rabatte (max. 1 x pro Artikel und Abschlagsart / -stufe)
        IF SalesCrMemoLine_par."Line Discount %" > 0 THEN BEGIN
            StringBuilder_dn.AppendLine
            (
            '513;' //513-01
            + 'A;' //513-02
            + 'DI;' //513-03
            + '1;' //513-04
            + '5.00;' //513-05
            + FORMAT(SalesCrMemoLine_par."Line Discount %") + ';' //513-06
            + CONVERTSTR(FORMAT(SalesCrMemoLine_par."Line Discount Amount"), ',', '.') + ';' //513-07
            + ';;;;;' //500-08 - 500-12
            )
        END;

        //Satzart 530: Artikeltextsatz (max. 5 pro Belegposition)
        SalesCrMemoLine_par.RESET;
        SalesCrMemoLine_par.SETRANGE("Document No.", SalesCrMemoLine_par."Document No.");
        SalesCrMemoLine_par.SETRANGE("Attached to Line No.", SalesCrMemoLine_par."Line No.");
        SalesCrMemoLine_par.SETRANGE(Type, SalesInvoiceLine.Type::" ");
        IF SalesCrMemoLine_par.FINDSET THEN
            REPEAT
                StringBuilder_dn.AppendLine
                (
                '530;' //530-01
                + 'INF;' //530-02
                + SalesCrMemoLine_par.Description + ';' //530-03
                + ';' //530-04
                )
UNTIL SalesCrMemoLine_par.NEXT = 0;
    end;

    local procedure GetVatPercent(SalesInvoiceHeader: Record "Sales Invoice Header"): Text
    var
        SalesInvoiceLine: Record "113";
    begin
        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETRANGE("Document No.", "Sales Invoice Header"."No.");
        SalesInvoiceLine.SETRANGE(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SETFILTER("VAT %", '>%1', 0);
        IF SalesInvoiceLine.FINDFIRST() THEN
            EXIT(CONVERTSTR(FORMAT(SalesInvoiceLine."VAT %", 0, '<Precision,2:2><Standard Format,0>'), ',', '.'));

        EXIT('0.00');
    end;

    local procedure GetVatPercentCrMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Text
    var
        SalesCrMemoLine: Record "115";
    begin
        SalesCrMemoLine.RESET;
        SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SETRANGE(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.SETFILTER("VAT %", '>%1', 0);
        IF SalesCrMemoLine.FINDFIRST() THEN
            EXIT(CONVERTSTR(FORMAT(SalesCrMemoLine."VAT %", 0, '<Precision,2:2><Standard Format,0>'), ',', '.'));

        EXIT('0.00');
    end;
}

