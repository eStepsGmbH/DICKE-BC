report 50095 "EDI Shipment 45"
{
    //  --------------------------------------------------------------------------------
    //  No.   SC-No.    Date     Sign   Description
    //  --------------------------------------------------------------------------------
    //  DI01            24.07.18 est.uk Modify Shipment Infos.

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
                CentralPayerCustomer.RESET;
                CentralPayerCustomer.SETRANGE("No.", CustomerNoCentralPayer);

                //und abarbeiten
                IF CentralPayerCustomer.FINDFIRST THEN BEGIN
                    //neue EDI Datei anlegen
                    CreateDocumentList();
                    //Customer.SETRANGE("Central Payer",CentralPayerCustomer."No.");
                    //IF Customer.FINDSET THEN REPEAT
                    SalesShipmentHeader.RESET;
                    //TODO: Gehen die Dateien (Lieferavis) an einen Zentralregulierer
                    //SalesShipmentHeader.SETRANGE("Bill-to Customer No.",CentralPayerCustomer."No.");
                    //SalesShipmentHeader.SETFILTER("Posting Date",'>=%1',CALCDATE('-'+ FORMAT(ToleranceDays) + 'T',WORKDATE));
                    SalesShipmentHeader.SETRANGE("No.", SalesShipmentHeaderNo);
                    IF SalesShipmentHeader.FINDSET THEN
                        SendShipmentDocument(SalesShipmentHeader);
                    //UNTIL Customer.NEXT = 0;
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
                            stratEdiSetup.SETRANGE("EDI Document Type", stratEdiSetup."EDI Document Type"::Lieferavis);

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
        MESSAGE('Der stratEDI Export wurde erfolgreich durchgeführt.\Liste-Nr.: %1.\Anzahl Belege: %2', Lieferavislistennummer, SalesShipmentCounter);
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
        Lieferavislistennummer: Code[10];
        CentralPayerCustomer: Record "Customer";
        CompanyInformation: Record "Company Information";
        TXT001: Label 'Es bestehen Vereinbarungen, aus denen sich nachträgliche Entgeltminderungen ergeben können';
        NoSeriesManagement: Codeunit "396";
        ShipmentNo: Code[20];
        ShipmentDate: Date;
        Customer: Record "Customer";
        SalesShipmentCounter: Integer;
        ToleranceDays: Integer;
        CustomerNoCentralPayer: Code[20];
        NoCustomerFoundErr: Label 'Please select a Central payer';
        stratEdiSetup: Record "50005";
        SpecialFiller: Text[100];
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentHeaderNo: Code[20];

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
        ILNIdSender := CompanyInformation.GLN;
        ILNIdReceiver := CentralPayerCustomer.GLN;
        IF stratEdiSetup.GLN <> '' THEN
            ILNIdReceiver := stratEdiSetup.GLN;

        Versionsnummer := '4.5';
        Lieferavislistennummer := NoSeriesManagement.GetNextNo(stratEdiSetup."stratEDI List Nos.", WORKDATE, TRUE);
        Datenaustauschreferenz := FORMAT(DATE2DMY(TODAY, 3)) + FORMAT(DATE2DMY(TODAY, 2)) + FORMAT(DATE2DMY(TODAY, 1)); //TODO: Wie soll die Referenz aussehen
        SalesShipmentCounter := 0;

        StringBuilder_dn.AppendLine
        (
        '000;' //000-01
        + ILNIdSender + ';' //000-02
        + ILNIdReceiver + ';' //000-03
        + GetYYYYMMDD(TODAY) + ';' //000-04
        + GetHHMM() + ';' //000-05
        + Lieferavislistennummer + ';' //000-06
        + ';;;' //000-07 - 000-09 FÜR TESTÜBERTRAGUNG FELD 9 = 1 setzen!
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
        ServerTempFileName := STRSUBSTNO('StratEDI-LS-%1-%2-%3.inh', Lieferavislistennummer, CentralPayerCustomer."No.", Datenaustauschreferenz);
        //ServerTempFileName := FileManagement.ServerTempFileName('.inh');

        StreamWriter_dn := StreamWriter_dn.StreamWriter(stratEdiSetup."stratEDI Export Path" + ServerTempFileName);
        StreamWriter_dn.WriteLine(StringBuilder_dn.ToString());
        StreamWriter_dn.Close();

        //Protokoll Einträge ändern
        stratEdiProtocol.RESET();
        stratEdiProtocol.SETRANGE("List No.", Lieferavislistennummer);
        stratEdiProtocol.SETRANGE("Central Payer No.", CustomerNoCentralPayer);
        stratEdiProtocol.SETRANGE("Document Type", stratEdiProtocol."Document Type"::Shipment);
        stratEdiProtocol.SETRANGE("Document Direction", stratEdiProtocol."Document Direction"::Ausgehend);
        stratEdiProtocol.MODIFYALL("Posted Date", TODAY);
        stratEdiProtocol.MODIFYALL("Posted Time", TIME);
        stratEdiProtocol.MODIFYALL("Edi File Name", ServerTempFileName);
    end;

    local procedure SendShipmentDocument(SalesShipmentHeader: Record "Sales Shipment Header")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record "Customer";
        ExternalDocumentNo: Code[35];
        stratEdiProtocol: Record "50004";
        ShipmentDate: Date;
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        //*****************************************
        //Ein Lieferschein ist eine Transaktion
        //*****************************************

        //zunächst prüfen, ob dieser Lieferschein nicht schon gesendet wurde.
        stratEdiProtocol.RESET();
        stratEdiProtocol.SETRANGE("Document Type", stratEdiProtocol."Document Type"::Shipment);
        stratEdiProtocol.SETRANGE("Document No.", SalesShipmentHeader."Order No.");
        stratEdiProtocol.SETRANGE("Document Direction", stratEdiProtocol."Document Direction"::Ausgehend);
        stratEdiProtocol.SETRANGE(Status, stratEdiProtocol.Status::Posted);
        IF (stratEdiProtocol.FINDSET) THEN
            EXIT; //Lieferschein wurde bereits gesendet

        //SalesHeaderArchiv_lrec.RESET;
        //SalesHeaderArchiv_lrec.SETRANGE("Document Type", SalesHeaderArchiv_lrec."Document Type"::Order);
        //SalesHeaderArchiv_lrec.SETRANGE("No.",SalesShipmentHeader."Order No.");

        //ShipmentDate := SalesShipmentHeader."Shipment Date";

        //IF NOT SalesHeaderArchiv_lrec.FINDLAST THEN
        //  SalesHeaderArchiv_lrec.INIT;

        //IF (SalesHeaderArchiv_lrec.FINDLAST) AND (ShipmentDate = 0D) THEN REPEAT
        //ShipmentDate := SalesHeaderArchiv_lrec."Shipment Date";
        //  UNTIL (SalesHeaderArchiv_lrec.NEXT(-1) = 0) OR (ShipmentDate <> 0D);

        IF NOT CompanyInformation.GET() THEN
            CompanyInformation.INIT;

        //Satzart 100: Transaktionskopf (1 x pro Transaktion)
        NachrichtenReferenz := SalesShipmentHeader."Order No."; //TODO: Ist die Rechnungsnummer die korrekte Referenz für die Transaktion?
        ArtDerTransaktion := '351'; //351=Lieferavis

        SpecialFiller := '';
        CASE stratEdiSetup."stratEDI Export Specifics" OF
            stratEdiSetup."stratEDI Export Specifics"::EDEKA,
          stratEdiSetup."stratEDI Export Specifics"::REWE:
                SpecialFiller := 'BA';
        END;

        //IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN
        //  SpecialFiller := 'BA';

        ShipmentDate := SalesShipmentHeader."Shipment Date";
        IF SalesShipmentHeader."Promised Delivery Date" <> 0D THEN
            ShipmentDate := SalesShipmentHeader."Promised Delivery Date"; // (Zugesagtes Lieferdatum)


        StringBuilder_dn.AppendLine
        (
        '100;' //100-01
        + FORMAT(NachrichtenReferenz) + ';' //100-02
        + 'DESADV;D;96B;UN;;' //100-03 - 100-07
        + ArtDerTransaktion + ';' //100-08
        + ';' //100-09
        + SalesShipmentHeader."Order No." + ';' //100-10
        + GetYYYYMMDD(SalesShipmentHeader."Order Date") + ';' //100-11 Belegdatum (bei Dicke das Auftragsdatum)
        + ';;;;' //100-12 - //100-15
        + SpecialFiller + ';' //100-16
        );

        ShipmentNo := SalesShipmentHeader."Order No.";
        //ShipmentDate := SalesShipmentHeader."Shipment Date";
        //ShipmentDate := SalesHeaderArchiv_lrec."Shipment Date Shipping Agent";

        //Satzart 111: Referenzen zur Transaktion (max. 1 x pro Transaktion)
        SpecialFiller := '';
        IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN
            SpecialFiller := '20';

        ExternalDocumentNo := SalesShipmentHeader."External Document No.";
        StringBuilder_dn.AppendLine
        (
        '111;' //111-01
        + ';;;;' //111-02 - 111-05
        + ExternalDocumentNo + ';' //111-06
        + GetYYYYMMDD(SalesShipmentHeader."Order Date") + ';' //111-07 (Bestelldatum des Kunden)
        + SalesShipmentHeader."No." + ';' //111-08
        + GetYYYYMMDD(SalesShipmentHeader."Order Date") + ';' //111-09 (Internes Auftragsdatum)
        + GetYYYYMMDD(ShipmentDate) + ';' //111-10 (Lieferdatum)
        + ShipmentNo + ';' //111-11
        + GetYYYYMMDD(ShipmentDate) + ';' //111-12 (Lieferscheindatum)
        + FORMAT(Lieferavislistennummer) + ';' //111-13
        + GetYYYYMMDD(TODAY) + ';' //111-14
        + SpecialFiller + ';' //111-15
        + ';;;;;;' //111-16 - //100-21
        );

        StringBuilder_dn.AppendLine
        (
        '115;' //115-01
        + GetYYYYMMDD(SalesShipmentHeader."Promised Delivery Date")
        + ';;;;;;;;;;;;;;' //111-03 - 111-15
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
        Customer.GET(SalesShipmentHeader."Sell-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'BY;' //119-02
        + Customer.GLN + ';' //119-03
        + SalesShipmentHeader."Sell-to Customer Name" + ';' //119-04
        + SalesShipmentHeader."Sell-to Customer Name 2" + ';' //119-05
        + ';' //119-06
        + SalesShipmentHeader."Sell-to Address" + ';' //119-07
        + SalesShipmentHeader."Sell-to Address 2" + ';' //119-08
        + ';' //119-09
        + SalesShipmentHeader."Sell-to Post Code" + ';' //119-10
        + SalesShipmentHeader."Sell-to City" + ';' //119-11
        + SalesShipmentHeader."Sell-to Country/Region Code" + ';' //119-12
        + SalesShipmentHeader."Bill-to Customer No." + ';' //119-13
        + ';;;;;;;;;' //119-14 - 119-22
        );
        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET(SalesShipmentHeader."Bill-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'IV;' //119-02
        + Customer.GLN + ';' //119-03
        + SalesShipmentHeader."Bill-to Name" + ';' //119-04
        + SalesShipmentHeader."Bill-to Name 2" + ';' //119-05
        + ';' //119-06
        + SalesShipmentHeader."Bill-to Address" + ';' //119-07
        + SalesShipmentHeader."Bill-to Address 2" + ';' //119-08
        + ';' //119-09
        + SalesShipmentHeader."Bill-to Post Code" + ';' //119-10
        + SalesShipmentHeader."Bill-to City" + ';' //119-11
        + SalesShipmentHeader."Bill-to Country/Region Code" + ';' //119-12
        + SalesShipmentHeader."Bill-to Customer No." + ';' //119-13
        + ';;;;;;;;;' //119-14 - 119-22
        );

        //Satzart 119: ID + Adressen der beteiligten Partner (1 x pro Transaktion und Partner)
        Customer.GET(SalesShipmentHeader."Sell-to Customer No.");
        StringBuilder_dn.AppendLine
        (
        '119;' //119-01
        //"BY" = Kunde, "SU" = Lieferant, "IV" = Rechnungsempfänger, "DP" = Warenempfänger
        //"II" = Rechnungssteller (nur wenn abweichend vom Lieferant)
        + 'DP;' //119-02
        + Customer.GLN + ';' //119-03
        + SalesShipmentHeader."Ship-to Name" + ';' //119-04
        + SalesShipmentHeader."Ship-to Name 2" + ';' //119-05
        + ';' //119-06
        + SalesShipmentHeader."Ship-to Address" + ';' //119-07
        + SalesShipmentHeader."Ship-to Address 2" + ';' //119-08
        + ';' //119-09
        + SalesShipmentHeader."Ship-to Post Code" + ';' //119-10
        + SalesShipmentHeader."Ship-to City" + ';' //119-11
        + SalesShipmentHeader."Ship-to Country/Region Code" + ';' //119-12
        + ';;;;;;;;;;' //119-13 - 119-22
        );

        //jetzt die Lieferscheinzeilen senden
        SalesShipmentLine.RESET();
        SalesShipmentLine.SETRANGE("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SETRANGE(Type, SalesShipmentLine.Type::Item);

        IF SalesShipmentLine.FINDSET() THEN
            REPEAT
                SendShipmentLine(SalesShipmentLine);
            UNTIL SalesShipmentLine.NEXT = 0;

        //Satzart 901: MWSt.-Angaben (1 x pro Transaktion und MWSt.-Satz)
        // nur erforderlich falls mehrer MWSt. Sätze pro Rechnung vorhanden sind...

        //Lieferschein als gesendet protokollieren
        stratEdiProtocol.INIT();
        stratEdiProtocol."Document Type" := stratEdiProtocol."Document Type"::Shipment;
        stratEdiProtocol."Document No." := SalesShipmentHeader."Order No.";
        stratEdiProtocol."Document Direction" := stratEdiProtocol."Document Direction"::Ausgehend;
        stratEdiProtocol.Status := stratEdiProtocol.Status::Posted;
        stratEdiProtocol."List No." := Lieferavislistennummer;
        stratEdiProtocol."Central Payer No." := CentralPayerCustomer."No.";
        stratEdiProtocol."Edi Version" := Versionsnummer;
        stratEdiProtocol.Protocol := 'EANCOM_REWE';
        IF stratEdiSetup."stratEDI Export Specifics" = stratEdiSetup."stratEDI Export Specifics"::EDEKA THEN
            stratEdiProtocol.Protocol := 'EANCOM_EDEKA';
        stratEdiProtocol.INSERT;
        SalesShipmentCounter := SalesShipmentCounter + 1;
    end;

    local procedure SendShipmentLine(SalesShipmentLine_par: Record "Sales Shipment Line")
    var
        Item_lrec: Record "Item";
        SalesInvoiceLine: Record "113";
        UnitOfMeasureCode: Code[3];
    begin
        IF NOT Item_lrec.GET(SalesShipmentLine_par."No.") THEN;

        // Feld 500-22 TODO: 'PCE'= Stück, 'KGM' = Kilogramm
        UnitOfMeasureCode := 'PCE';
        IF COPYSTR(SalesShipmentLine_par."Unit of Measure", 1, 2) = 'KG' THEN
            UnitOfMeasureCode := 'KGM';

        //Satzart 500: Rechnungsposition (n-mal pro Transaktion / 1 x pro Artikel)
        StringBuilder_dn.AppendLine
        (
        '500;' //500-01
        + FORMAT(SalesShipmentLine_par."Line No.") + ';' //500-02
        + ';' //500-03
        + Item_lrec.GTIN + ';' //500-04
        + Item_lrec."No." + ';' //500-05
        + ';' //500-06
        // + Item_lrec."Product Group Code" + ';' //500-07 TODO: REMOVED
        + SalesShipmentLine_par.Description + ';' //500-08
        + SalesShipmentLine_par."Description 2" + ';' //500-09
        + ';;' //500-10 - 500-11
        + CONVERTSTR(FORMAT(SalesShipmentLine_par.Quantity, 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-12
        + ';;' //500-13 - 500-14
        + CONVERTSTR(FORMAT(SalesShipmentLine_par."VAT %", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-15
        + CONVERTSTR(FORMAT(SalesShipmentLine_par."Unit Price", 0, '<Sign><Integer><Decimals><Comma,,>'), ',', '.') + ';' //500-16
        + ';;;;;' //500-17 - 500-21
        + UnitOfMeasureCode + ';' // 500-22 TODO: 'PCE'= Stück, 'KGM' = Kilogramm
        //+  CONVERTSTR(FORMAT(SalesInvoiceLine_par.Amount,0,'<Sign><Integer><Decimals><Comma,,>'),',','.')  + ';' //500-23
        + ';' //500-23
        + ';' //500-24
        + ';' //500-25
        + ';;;;;;;;;;;' //500-26 - 500-36
        + 'N;' //500-37 - Konditionssperre
        );


        //Satzart 511: Position Referenz
        StringBuilder_dn.AppendLine
        (
        '511;' //511-01
        + ';;;;' //511-02 - 511-05
        + SalesShipmentHeader."External Document No." + ';' //511-06
        + ';'  //511-07
        + SalesShipmentHeader."Order No." + ';' //Interne Auftragsnummer 511-08
        + GetYYYYMMDD(SalesShipmentHeader."Order Date") + ';' //Internes Auftragsdatum 511-09 _____14.08
        + GetYYYYMMDD(SalesShipmentLine_par."Shipment Date") + ';' //Lieferdatum 511-10
        + SalesShipmentHeader."Order No." + ';' //Lieferscheinnummer 511-11
        + GetYYYYMMDD(SalesShipmentLine_par."Shipment Date") + ';' //Lieferscheindatum 511-12
        + ';;;;;;;;;' //511-13 - 511-21
        + SalesShipmentLine_par."External Document Pos. No." + ';' //Bestellpositionsnummer (des Kunden) 511-22
        + FORMAT(SalesShipmentLine_par."Line No.") + ';' //Lieferscheinpositionsnummer (des Lieferanten) 511-23
        + ';;;;;;;;;;' //511-24 - 511-33
        );

        //Satzart 580: Zusätzliche Pos. Informationen
        //StringBuilder_dn.AppendLine
        //(
        //'580;' //580-01
        //+ FORMAT(SalesShipmentLine_par."Line No.") + ';' //580-02
        //+ GetYYYYMMDD(SalesShipmentLine_par."Minimum Durability")+ ';' //580-03
        //+ GetYYYYMMDD(SalesShipmentLine_par."Minimum Durability")+ ';' //580-04
        //+ CONVERTSTR(FORMAT(SalesShipmentLine_par.Quantity,0,'<Sign><Integer><Decimals><Comma,,>'),',','.') + ';' //580-05
        //+ ';;;;;;;;;;;;;;;;;' //580-06 - 580-23
        //);
    end;

    [Scope('Internal')]
    procedure SendShipmentHeader(ShipmentHeaderNo_par: Code[20]; SellToCustomerNo_par: Code[20])
    begin
        SalesShipmentHeaderNo := ShipmentHeaderNo_par;
        CustomerNoCentralPayer := SellToCustomerNo_par;
        stratEdiSetup.RESET();
        stratEdiSetup.SETRANGE("EDI Document Type", stratEdiSetup."EDI Document Type"::Lieferavis);
        stratEdiSetup.SETRANGE("Customer No.", CustomerNoCentralPayer);
        IF NOT stratEdiSetup.FINDFIRST() THEN
            ERROR('In der stratEDI Einrichtung muss das Feld ''stratEDI Liste Nummern'' gepflegt sein.');
        CentralPayerCustomer.RESET;
        CentralPayerCustomer.SETRANGE("No.", CustomerNoCentralPayer);
        IF CentralPayerCustomer.FINDFIRST THEN BEGIN
            //neue EDI Datei anlegen
            CreateDocumentList();
            SalesShipmentHeader.RESET;
            SalesShipmentHeader.SETRANGE("No.", SalesShipmentHeaderNo);
            IF SalesShipmentHeader.FINDSET THEN
                SendShipmentDocument(SalesShipmentHeader);
            CloseDocumentList();
        END;
    end;
}

