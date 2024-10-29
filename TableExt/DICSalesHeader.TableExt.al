tableextension 50045 "DIC Sales Header" extends "Sales Header"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Funktion "InitRecord" erweitert:
    //   Bei Mandant "Münnich" wird das Shipment-Date immer auf den
    //   kommenden Freitag gesetzt. Das Fälligkeitsdatum ist immer der
    //   Montag nach dem Shipment-Date.
    //  Lokale Funktion "GetDate" hinzugefügt.
    //  Automatische Feldvorbelegung:
    //   Warenausgangsdatum = Auftragsdatum + 1 Tag
    //   Zuges. Lieferdatum = Auftragsdatum + 2 Tage
    //  Felder von ID 50070 bis 50076 hinzugefügt.
    //  Property "DataCaptionFields": Add Fields: "Sell-to Address,Sell-to Address 2,Sell-to City"
    DataCaptionFields = "No.", "Sell-to Customer Name", "Sell-to Address", "Sell-to Address 2", "Sell-to City";
    fields
    {
        field(50000; "Header Text Code"; Code[10])
        {
            Caption = 'Auftragskopftext';
            TableRelation = "Standard Text".Code;

            trigger OnValidate()
            begin
                HeaderText.INIT();
                HeaderText.SETRANGE(Type, Rec."Document Type");
                HeaderText.SETRANGE("No.", Rec."No.");

                IF Rec."Header Text Code" <> '' THEN BEGIN
                    StanText.INIT();
                    StanText.SETRANGE(Code);
                    StanText.SETRANGE(Code, Rec."Header Text Code");
                    ExtText.INIT();
                    ExtText.SETRANGE("Table Name", 0);
                    ExtText.SETRANGE(ExtText."No.", Rec."Header Text Code");

                    IF StanText.FIND('-') THEN BEGIN
                        HeaderText.DELETEALL();
                        HeaderText.VALIDATE(HeaderText.Type, Rec."Document Type");
                        HeaderText.VALIDATE(HeaderText."No.", Rec."No.");
                        HeaderText.VALIDATE(HeaderText."Line No.", 1);
                        HeaderText.VALIDATE(HeaderText.Text, StanText.Description);
                        HeaderText.INSERT(TRUE);
                        REPEAT
                            HeaderText.VALIDATE(HeaderText.Type, Rec."Document Type");
                            HeaderText.VALIDATE(HeaderText."No.", Rec."No.");
                            HeaderText.VALIDATE(HeaderText."Line No.", ExtText."Line No.");
                            HeaderText.VALIDATE(HeaderText.Text, ExtText.Text);
                            HeaderText.INSERT(TRUE);
                        UNTIL (ExtText.NEXT() = 0);
                    END;
                END
                ELSE
                    HeaderText.DELETEALL();
            end;
        }
        field(50070; "VUO Creation Date"; Date)
        {
            Caption = 'VUO erstellt am';
        }
        field(50071; "Print Shipment Info On Invoice"; Boolean)
        {
            Caption = 'Drucken Lieferscheininfo';
            InitValue = true;
        }
        field(50072; SendToKirn; Boolean)
        {
            Caption = 'Daten an Kirn senden';
        }
        field(50073; SendToKirnDate; Date)
        {
            Caption = 'Daten an Kirn gesendet am';
        }
        field(50074; SendToKirnTime; Time)
        {
            Caption = 'Daten an Kirn gesendet um';
        }
        field(50075; "Shipment Date Shipping Agent"; Date)
        {
            Caption = 'Warenausgangsdatum Zusteller';
        }
        field(50076; "Source Company"; Text[100])
        {
            Caption = 'Source Company';
            TableRelation = Company.Name;

            trigger OnValidate()
            begin
                IF Rec."Source Company" = COMPANYNAME THEN
                    ERROR(CompanySelectErr);
            end;
        }
        field(50077; "Source Order No."; Code[20])
        {
            Caption = 'No.';
        }
    }

    var
        HeaderText: Record "DIC Header Text";
        ExtText: Record "Extended Text Line";
        StanText: Record "Standard Text";
        CompanySelectErr: Label 'Own Company can not selected!';
}

