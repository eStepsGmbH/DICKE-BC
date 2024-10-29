report 55073 "FL Berechnung RungeVA"
{
    // 
    // wa01   23.01.08 wa/dse  Ermittlung von Berechnungswerten für RungeVA
    // 
    // wa02   11.11.19 wa/dse  Feld "Externe Document No." mit "Externe Versand ID" getauscht
    // 
    // wa03   26.10.23 mum/pel SC2300340 -Field "Externe Versand ID" converted into FlowField
    //                                   -"Posting Date" filter period
    // 
    // ----------------------------------------------------------------------------------------
    // Filter für Tabelle = Sales Invoice Line
    // ReqFilterFields = Posting Date,Type,Location Code,Shelf No. VA
    // ----------------------------------------------------------------------------------------
    // Filter für Tabelle = Item Ledger Entry
    // ReqFilterFields = Posting Date
    // ----------------------------------------------------------------------------------------
    DefaultLayout = RDLC;
    RDLCLayout = './FLBerechnungRungeVA.rdlc';


    dataset
    {
        dataitem("Sales Invoice Line"; "Sales Invoice Line")
        {
            RequestFilterFields = Type, "Location Code";
            column(V_Lagerzeitraum; I_AbrZeit1)
            {
            }
            column(V_Lagergewicht_Verkauf; Item_Lagergewicht)
            {
            }
            column(V_Lagergewicht_Zugang; Item_Lagergewicht1)
            {
            }
            column(V_Lagergewicht_Abgang; Item_Lagergewicht2)
            {
            }
            column(V_Lagergewicht_Umlagerung; Item_Lagergewicht3)
            {
            }
            column(V_Lagergewicht_Gutschrift; Item_Lagergewicht4)
            {
            }
            column(V_Lagergewicht_Saldo; Item_Lagergewicht4 + Item_Lagergewicht3 + Item_Lagergewicht2 + Item_Lagergewicht1 + Item_Lagergewicht)
            {
            }
            column(CompInfo_R_Picture; CompInfo_R.Picture)
            {
            }
            column(CompInfo_R_Amtsgericht; 'Amtsgericht ')
            {
            }
            column(CompInfo_R_Name; CompInfo_R.Name)
            {
            }
            column(CompInfo_R_Address; CompInfo_R.Address)
            {
            }
            column(CompInfo_R_PostCode; CompInfo_R."Post Code")
            {
            }
            column(CompInfo_R_City; CompInfo_R.City)
            {
            }
            column(CompInfo_R_HomePage; 'inet: ' + CompInfo_R."Home Page")
            {
            }
            column("CompInfo_R_Geschäftsführer"; 'Geschäftsführer: ')
            {
            }
            column(CompInfo_R_Zusatztext; '')
            {
            }
            column("CompInfo_R_Banküberschift"; Text021)
            {
            }
            column(CompInfo_R_BankName; CompInfo_R."Bank Name")
            {
            }
            column(CompInfo_R_IBAN; 'IBAN: ' + CompInfo_R.IBAN)
            {
            }
            column(CompInfo_R_SWIFTCode; 'BIC: ' + CompInfo_R."SWIFT Code")
            {
            }
            column(CompInfo_R_USTID; 'Ust.-ID: ' + CompInfo_R."VAT Registration No.")
            {
            }
            column(CompInfo_R_Steuernummer; 'Steuer-Nr.: ' + CompInfo_R."Registration No.")
            {
            }
            column(companyname; COMPANYNAME)
            {
            }
            column(Today; FORMAT(TODAY, 0, 4))
            {
            }
            column(Seite; CurrReport.PAGENO)
            {
            }
            column(USERID; USERID)
            {
            }
            column(Logo1; CompInfo_R.Picture)
            {
            }
            column(T_Abrechnungsinfo_Kopf; Text001)
            {
            }
            column(T_Buchungszeitraum; Text002)
            {
            }
            column(T_Postentyp; Text003)
            {
            }
            column(T_Standortcode; Text004)
            {
            }
            column(V_AbrText; AbrText)
            {
            }
            column(V_F_AbrZeit; F_AbrZeit)
            {
            }
            column(V_F_Type; F_Type)
            {
            }
            column(V_F_LocCode; F_LocCode)
            {
            }
            column(T_Normalversand; Text005)
            {
            }
            column(T_AktVABO; Text006)
            {
            }
            column(T_AktVWO; Text007)
            {
            }
            column(T_AktVAKO; Text008)
            {
            }
            column(T_Auslieferung; Text009)
            {
            }
            column(T_Exemplar; Text010)
            {
            }
            column(T_VPE; Text011)
            {
            }
            column(T_Rechnung; Text012)
            {
            }
            column(T_Gewicht; Text013)
            {
            }
            column(V_Su_Auslieferung; SummePosten)
            {
            }
            column(V_Su_Auslieferung1; Akt_SummePosten[1])
            {
            }
            column(V_Su_Auslieferung2; Akt_SummePosten[2])
            {
            }
            column(V_Su_Auslieferung3; Akt_SummePosten[3])
            {
            }
            column(V_Su_Exp; SummeExp)
            {
            }
            column(V_Su_Exp1; Akt_SummeExp[1])
            {
            }
            column(V_su_Exp2; Akt_SummeExp[2])
            {
            }
            column(V_Su_Exp3; Akt_SummeExp[3])
            {
            }
            column(V_Su_VP; SummeVP)
            {
            }
            column(V_Su_VP1; Akt_SummeVP[1])
            {
            }
            column(V_Su_VP2; Akt_SummeVP[2])
            {
            }
            column(V_Su_VP3; Akt_SummeVP[3])
            {
            }
            column(V_Su_RG; SummeRG)
            {
            }
            column(V_Su_RG1; Akt_SummeRG[1])
            {
            }
            column(V_Su_RG2; Akt_SummeRG[2])
            {
            }
            column(V_Su_RG3; Akt_SummeRG[3])
            {
            }
            column(V_Su_LG; Lagergewicht)
            {
            }
            column(V_Su_LG1; Akt_Lagergewicht[1])
            {
            }
            column(V_Su_LG2; Akt_Lagergewicht[2])
            {
            }
            column(V_Su_LG3; Akt_Lagergewicht[3])
            {
            }
            column(T_Lagerzeitraum; Text014)
            {
                AutoCalcField = true;
            }
            column(T_Verkauf; Text015)
            {
            }
            column(T_Zugang; Text016)
            {
            }
            column(T_Abgang; Text017)
            {
            }
            column(T_Umlagerung; Text018)
            {
            }
            column(T_Gutschrift; Text019)
            {
            }
            column(T_Saldo; Text020)
            {
            }

            trigger OnAfterGetRecord()
            begin

                // wa03 >>>
                //"Sales Invoice Line".CALCFIELDS("Externe Versand ID");
                // wa03 <<<

                DLG.UPDATE(1, "Sales Invoice Line"."Document No.");

                Akt_Num := 0;
                Akt_Bereich := '';
                //Akt_Bereich := COPYSTR("Sales Invoice Line"."Externe Versand ID",1,3);

                IF Akt_Bereich = 'ABO' THEN
                    Akt_Num := 1;

                IF Akt_Bereich = 'AKT' THEN
                    Akt_Num := 2;

                IF Akt_Bereich = 'AKO' THEN
                    Akt_Num := 3;

                IF Akt_Num = 0 THEN BEGIN
                    Normalversand;
                END;

                IF Akt_Num <> 0 THEN BEGIN
                    Aktionsversand;
                END;
            end;

            trigger OnPreDataItem()
            begin

                // Firmendaten laden
                CompInfo_R.GET;

                // wa03 >>>
                IF PostingDatePeriodFilter <> 0D THEN BEGIN
                    "Sales Invoice Line".SETRANGE("Posting Date", PeriodStart, PeriodEnd);
                END;
                // wa03 <<<

                //SalesInvoiceLineFilter := "Sales Invoice Line".GETFILTERS;
            end;
        }
        dataitem(DataItem50070; Table32)
        {
            DataItemTableView = SORTING("Item No.", Entry Type, Location Code, Posting Date, Document Type);
            RequestFilterFields = "Posting Date";
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group("<Control1140001>")
                {
                    Caption = 'Optionen';
                    field("<Control1140006>"; AbrText)
                    {
                        Caption = 'Abrechnungs-Text';
                    }
                    field(LGS; LGS)
                    {
                        Caption = 'Lagergewichts-Statistik';
                    }
                    field("Posting Date Period Filter"; PostingDatePeriodFilter)
                    {
                        Caption = 'Posting Date';

                        trigger OnValidate()
                        begin

                            PeriodStart := CALCDATE('<-CM>', PostingDatePeriodFilter);
                            PeriodEnd := CALCDATE('<CM>', PostingDatePeriodFilter);
                        end;
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
    begin
        DLG.OPEN('VK-RG :  #1###########\' + 'Anzahl: #3########' +
                   'Artikel : #2###########\');

        //RecLogo1.GET('1');
        // RecLogo1.CALCFIELDS(Logo1);

        SummePosten := 0;
        SummeExp := 0;
        SummeVP := 0;
        SummeRG := 0;

        T := 1;
        REPEAT
            Akt_SummePosten[T] := 0;
            Akt_SummeExp[T] := 0;
            Akt_SummeVP[T] := 0;
            Akt_SummeRG[T] := 0;
            T += 1;
        UNTIL T = 3;


        F_AbrZeit := "Sales Invoice Line".GETFILTER("Posting Date");
        F_Type := "Sales Invoice Line".GETFILTER(Type);
        F_LocCode := "Sales Invoice Line".GETFILTER("Location Code");
        //F_RegNr := "Sales Invoice Line".GETFILTER("Shelf No. VA");
        //F_ExtDocNr := "Sales Invoice Line".GETFILTER("Externe Versand ID");

        I_AbrZeit := "Item Ledger Entry".GETFILTER("Posting Date");
        I_AbrZeit1 := '01.01.09..' + COPYSTR(I_AbrZeit, 11, 8);

        // wa03 >>>
        IF PostingDatePeriodFilter <> 0D THEN BEGIN
            F_AbrZeit := FORMAT(PeriodStart) + '..' + FORMAT(PeriodEnd);
            I_AbrZeit := F_AbrZeit;
            I_AbrZeit1 := F_AbrZeit;
        END;
        // wa03 <<<

        CompInfo_R.GET;
        CompInfo_R.CALCFIELDS(CompInfo_R.Picture);

        Lagergewichte_Summen();
    end;

    var
        SummePosten: Decimal;
        SummeExp: Decimal;
        SummeVP: Decimal;
        SummeRG: Decimal;
        Akt_Bereich: Text[30];
        Akt_Num: Integer;
        Akt_SummePosten: array[3] of Decimal;
        Akt_SummeExp: array[3] of Decimal;
        Akt_SummeVP: array[3] of Decimal;
        Akt_SummeRG: array[3] of Decimal;
        Akt_RGNR: array[3] of Code[20];
        Akt_RGNR1: array[3] of Code[20];
        Akt_Lagergewicht: array[3] of Decimal;
        RGNR: Code[20];
        RGNR1: Code[20];
        AbrZR: Date;
        AbrText: Text[250];
        SalesInvoiceLineFilter: Text[250];
        F_AbrZeit: Text[50];
        F_Type: Text[50];
        F_LocCode: Text[50];
        F_RegNr: Text[50];
        F_ExtDocNr: Text[50];
        I_AbrZeit: Text[50];
        I_AbrZeit1: Text[50];
        Artikelgewicht: Decimal;
        Artikelmenge: Decimal;
        Lagergewicht: Decimal;
        Item_Artikelgewicht: Decimal;
        Item_Lagermenge: Decimal;
        Item_Lagergewicht: Decimal;
        ItemF_LocCode: Text[50];
        ItemF_RegNr: Text[50];
        Item_Lagermenge1: Decimal;
        REC_Item: Record "Item";
        Rec_ItemLedgerEntry: Record "32";
        DLG: Dialog;
        Item_Belegart: Text[30];
        Item_Postenart: Code[30];
        Item_Lagergewicht1: Decimal;
        Item_Lagergewicht2: Decimal;
        Item_Lagergewicht3: Decimal;
        Item_Lagergewicht4: Decimal;
        LGS: Boolean;
        T: Integer;
        CompInfo_R: Record "Company Information";
        BSN_PHG: Text[50];
        Text001: Label 'Abrechnungsinformation für Impetus Vertriebsservice';
        Text002: Label 'Buchungszeitraum:';
        Text003: Label 'Postentyp:';
        Text004: Label 'Standortcode:';
        Text005: Label 'Normalversand';
        Text006: Label 'Akt-V.ABO';
        Text007: Label 'Akt-V.Wo.';
        Text008: Label 'Akt-V.AKO';
        Text009: Label 'Summe Auslieferungspositionen:';
        Text010: Label 'Summe Exemplar:';
        Text011: Label 'Summe Verpackungseinheiten:';
        Text012: Label 'Summe Rechnungen:';
        Text013: Label 'Summe Gewicht in KG:';
        Text014: Label 'Lagerzeitraum:';
        Text015: Label 'Artikel-Lager-Gewicht Verkauf KG:';
        Text016: Label 'Artikel-Lager-Gewicht Zugang in KG:';
        Text017: Label 'Artikel-Lager-Gewicht Abgang in KG:';
        Text018: Label 'Artikel-Lager-Gewicht Umlagerung in KG:';
        Text019: Label 'Artikel-Lager-Gewicht Gutschrift  in KG:';
        Text020: Label 'Saldo Artikel-Lager-Gewicht  in KG:';
        MyDate: Date;
        Text021: Label 'Bankverbindung:';
        PostingDatePeriodFilter: Date;
        PeriodStart: Date;
        PeriodEnd: Date;

    [Scope('Internal')]
    procedure Normalversand()
    begin
        // SummePosten :=SummePosten+1;

        IF "Sales Invoice Line"."Units per Parcel" = 1 THEN BEGIN
            SummeExp := SummeExp + "Sales Invoice Line".Quantity / "Sales Invoice Line"."Units per Parcel";
            SummePosten := SummePosten + 1;
        END;


        IF "Sales Invoice Line"."Units per Parcel" > 1 THEN BEGIN
            SummeVP := SummeVP + "Sales Invoice Line".Quantity / "Sales Invoice Line"."Units per Parcel";
            SummePosten := SummePosten + 1;
        END;


        // Ermitteln des Gewichtes je Verkaufzeile
        Artikelgewicht := "Sales Invoice Line"."Net Weight";
        IF Artikelgewicht > 0 THEN BEGIN
            Artikelmenge := "Sales Invoice Line".Quantity;
            Lagergewicht := Lagergewicht + ROUND(((Artikelgewicht / 1000) * Artikelmenge), 0.001, '=');
        END;


        // Ermitteln der Anzahl Rechnungen
        RGNR := "Sales Invoice Line"."Document No.";
        IF RGNR1 <> RGNR THEN BEGIN
            SummeRG := SummeRG + 1;
            RGNR1 := RGNR;
            DLG.UPDATE(3, SummeRG);
        END;
    end;

    [Scope('Internal')]
    procedure Aktionsversand()
    begin
        // Akt_SummePosten :=Akt_SummePosten+1;

        Akt_Num := 0;
        Akt_Bereich := '';
        //Akt_Bereich := COPYSTR("Sales Invoice Line"."Externe Versand ID",1,3);

        IF Akt_Bereich = 'ABO' THEN
            Akt_Num := 1;

        IF Akt_Bereich = 'AKT' THEN
            Akt_Num := 2;

        IF Akt_Bereich = 'AKO' THEN
            Akt_Num := 3;

        //IF Akt_Num = 0 THEN BEGIN
        //   MESSAGE('Falsche Aktionsnummer :' + '%1' + 'in Beleg :' + '%2',
        //      "Sales Invoice Line"."Externe Versand ID","Sales Invoice Line"."Document No.");
        //   EXIT;
        //END;

        IF "Sales Invoice Line"."Units per Parcel" = 1 THEN BEGIN
            Akt_SummeExp[Akt_Num] := Akt_SummeExp[Akt_Num] + "Sales Invoice Line".Quantity / "Sales Invoice Line"."Units per Parcel";
            Akt_SummePosten[Akt_Num] := Akt_SummePosten[Akt_Num] + 1;
        END;

        IF "Sales Invoice Line"."Units per Parcel" > 1 THEN BEGIN
            Akt_SummeVP[Akt_Num] := Akt_SummeVP[Akt_Num] + "Sales Invoice Line".Quantity / "Sales Invoice Line"."Units per Parcel";
            Akt_SummePosten[Akt_Num] := Akt_SummePosten[Akt_Num] + 1;
        END;

        // Ermitteln des Gewichtes je Verkaufzeile
        Artikelgewicht := "Sales Invoice Line"."Net Weight";
        IF Artikelgewicht > 0 THEN BEGIN
            Artikelmenge := "Sales Invoice Line".Quantity;
            Akt_Lagergewicht[Akt_Num] := Akt_Lagergewicht[Akt_Num] + ROUND(((Artikelgewicht / 1000) * Artikelmenge), 0.001, '=');
        END;

        // Ermitteln der Anzahl Rechnungen
        Akt_RGNR[Akt_Num] := "Sales Invoice Line"."Document No.";
        IF Akt_RGNR1[Akt_Num] <> Akt_RGNR[Akt_Num] THEN BEGIN
            Akt_SummeRG[Akt_Num] := Akt_SummeRG[Akt_Num] + 1;
            Akt_RGNR1[Akt_Num] := Akt_RGNR[Akt_Num];
        END;
    end;

    local procedure Lagergewichte_Summen()
    begin

        //REC_Item.SETFILTER(Standardlagerort,F_LocCode);
        //REC_Item.SETFILTER("Shelf No. VA",F_RegNr);

        IF REC_Item.FINDSET THEN BEGIN
            REPEAT
                DLG.UPDATE(2, REC_Item."No.");
                Item_Artikelgewicht := REC_Item."Net Weight";
                Lagergewichte_Summen1();
            UNTIL REC_Item.NEXT = 0;
        END;
    end;

    local procedure Lagergewichte_Summen1()
    begin
        Rec_ItemLedgerEntry.RESET;

        Rec_ItemLedgerEntry.SETFILTER("Posting Date", I_AbrZeit);
        Rec_ItemLedgerEntry.SETRANGE("Item No.", REC_Item."No.");
        Rec_ItemLedgerEntry.SETRANGE("Location Code", F_LocCode);

        Rec_ItemLedgerEntry.SETRANGE("Document Type", Rec_ItemLedgerEntry."Document Type"::"Sales Shipment");
        Rec_ItemLedgerEntry.CALCSUMS(Quantity);
        Item_Lagermenge1 := Rec_ItemLedgerEntry.Quantity;
        Item_Lagergewicht := Item_Lagergewicht + ROUND(((Item_Artikelgewicht / 1000) * Item_Lagermenge1), 0.001, '=');
        Rec_ItemLedgerEntry.SETRANGE("Document Type");

        Rec_ItemLedgerEntry.SETRANGE("Document Type", Rec_ItemLedgerEntry."Document Type"::"Sales Credit Memo");
        Rec_ItemLedgerEntry.CALCSUMS(Quantity);
        Item_Lagermenge1 := Rec_ItemLedgerEntry.Quantity;
        Item_Lagergewicht4 := Item_Lagergewicht4 + (Item_Artikelgewicht / 1000) * Item_Lagermenge1;
        Rec_ItemLedgerEntry.SETRANGE("Document Type");

        Rec_ItemLedgerEntry.SETRANGE("Entry Type", Rec_ItemLedgerEntry."Entry Type"::"Positive Adjmt.");
        Rec_ItemLedgerEntry.CALCSUMS(Quantity);
        Item_Lagermenge1 := Rec_ItemLedgerEntry.Quantity;
        Item_Lagergewicht1 := Item_Lagergewicht1 + (Item_Artikelgewicht / 1000) * Item_Lagermenge1;
        Rec_ItemLedgerEntry.SETRANGE("Entry Type");

        Rec_ItemLedgerEntry.SETRANGE("Entry Type", Rec_ItemLedgerEntry."Entry Type"::"Negative Adjmt.");
        Rec_ItemLedgerEntry.CALCSUMS(Quantity);
        Item_Lagermenge1 := Rec_ItemLedgerEntry.Quantity;
        Item_Lagergewicht2 := Item_Lagergewicht2 + (Item_Artikelgewicht / 1000) * Item_Lagermenge1;
        Rec_ItemLedgerEntry.SETRANGE("Entry Type");

        Rec_ItemLedgerEntry.SETRANGE("Entry Type", Rec_ItemLedgerEntry."Entry Type"::Transfer);
        Rec_ItemLedgerEntry.CALCSUMS(Quantity);
        Item_Lagermenge1 := Rec_ItemLedgerEntry.Quantity;
        Item_Lagergewicht3 := Item_Lagergewicht3 + (Item_Artikelgewicht / 1000) * Item_Lagermenge1;
        Rec_ItemLedgerEntry.SETRANGE("Entry Type");
    end;
}

