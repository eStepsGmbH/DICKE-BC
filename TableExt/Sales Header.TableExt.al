tableextension 50045 tableextension50045 extends "Sales Header"
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


        //Unsupported feature: Code Modification on ""Sell-to Customer Name"(Field 79).OnValidate".

        //trigger OnValidate()
        //Parameters and return type have not been exported.
        //>>>> ORIGINAL CODE:
        //begin
        /*
        VALIDATE("Sell-to Customer No.",Customer.GetCustNo("Sell-to Customer Name"));
        */
        //end;
        //>>>> MODIFIED CODE:
        //begin
        /*
        VALIDATE("Sell-to Customer No.",Customer.GetCustNo("Sell-to Customer Name"));
        GetShippingTime(FIELDNO("Sell-to Customer Name"));
        */
        //end;


        //Unsupported feature: Code Modification on ""Sell-to Contact No."(Field 5052).OnLookup".

        //trigger "(Field 5052)()
        //Parameters and return type have not been exported.
        //>>>> ORIGINAL CODE:
        //begin
        /*
        IF "Sell-to Customer No." <> '' THEN
          IF Cont.GET("Sell-to Contact No.") THEN
            Cont.SETRANGE("Company No.",Cont."Company No.")
        #4..16
        IF PAGE.RUNMODAL(0,Cont) = ACTION::LookupOK THEN BEGIN
          xRec := Rec;
          VALIDATE("Sell-to Contact No.",Cont."No.");
        END;
        */
        //end;
        //>>>> MODIFIED CODE:
        //begin
        /*
        #1..19
          IF ("Document Type" = "Document Type"::Quote) AND ("Sell-to Customer No." = '') THEN
            IF CONFIRM(SelectCustomerTemplateQst,FALSE) THEN
              IF PAGE.RUNMODAL(0,CustomerTemplate) = ACTION::LookupOK THEN
                VALIDATE("Sell-to Customer Template Code",CustomerTemplate.Code);
        END;
        */
        //end;
        field(50000; "Header Text Code"; Code[10])
        {
            Caption = 'Auftragskopftext';
            TableRelation = "Standard Text".Code;

            trigger OnValidate()
            begin
                HeaderText.INIT;
                HeaderText.SETRANGE(Type, Rec."Document Type");
                HeaderText.SETRANGE("No.", Rec."No.");

                IF Rec."Header Text Code" <> '' THEN BEGIN

                    StanText.INIT;
                    StanText.SETRANGE(Code);
                    StanText.SETRANGE(Code, Rec."Header Text Code");

                    ExtText.INIT;
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
                        UNTIL (ExtText.NEXT = 0);

                        //    MESSAGE('Auftragskopftext wurde hinterlegt !');
                    END;
                END
                ELSE BEGIN

                    HeaderText.DELETEALL();
                    //  MESSAGE('Auftragskopftext wurde entfernt !');
                END;
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
                //DICKE >>>
                IF Rec."Source Company" = COMPANYNAME THEN
                    ERROR(CompanySelectErr);
                //DICKE <<<
            end;
        }
        field(50077; "Source Order No."; Code[20])
        {
            Caption = 'No.';
        }
    }


    //Unsupported feature: Code Insertion (VariableCollection) on "OnDelete".

    //trigger (Variable: ArchiveManagement)()
    //Parameters and return type have not been exported.
    //begin
    /*
    */
    //end;


    //Unsupported feature: Code Modification on "OnDelete".

    //trigger OnDelete()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    IF NOT UserSetupMgt.CheckRespCenter(0,"Responsibility Center") THEN
      ERROR(
        Text022,
    #4..29
    VALIDATE("Applies-to ID",'');
    VALIDATE("Incoming Document Entry No.",0);

    ApprovalsMgmt.DeleteApprovalEntry(Rec);
    SalesLine.RESET;
    SalesLine.LOCKTABLE;

    #37..59
       (SalesCrMemoHeaderPrepmt."No." <> '')
    THEN
      MESSAGE(PostedDocsToPrintCreatedMsg);
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..32
    ApprovalsMgmt.DeleteApprovalEntries(RECORDID);
    #34..62
    */
    //end;


    //Unsupported feature: Code Modification on "OnInsert".

    //trigger OnInsert()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    InitInsert;
    InsertMode := TRUE;

    SetSellToCustomerFromFilter;

    IF GetFilterContNo <> '' THEN
      VALIDATE("Sell-to Contact No.",GetFilterContNo);

    "Doc. No. Occurrence" := ArchiveManagement.GetNextOccurrenceNo(DATABASE::"Sales Header","Document Type","No.");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..7
    */
    //end;

    //Unsupported feature: Variable Insertion (Variable: ArchiveManagement) (VariableCollection) on "InitRecord(PROCEDURE 10)".



    //Unsupported feature: Code Modification on "InitRecord(PROCEDURE 10)".

    //procedure InitRecord();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    SalesSetup.GET;

    CASE "Document Type" OF
    #4..42
      BEGIN
      "Shipment Date" := WORKDATE;
      "Order Date" := WORKDATE;
    END;
    IF "Document Type" = "Document Type"::"Return Order" THEN
      "Order Date" := WORKDATE;
    #49..68
    UpdateOutboundWhseHandlingTime;

    "Responsibility Center" := UserSetupMgt.GetRespCenter(0,"Responsibility Center");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..45

    // Dicke >>>
      IF COPYSTR(UPPERCASE(COMPANYNAME),1,7) = 'MÜNNICH' THEN BEGIN
        "Shipment Date" := DWY2DATE(5,DATE2DWY(WORKDATE,2),DATE2DMY(WORKDATE,3));
        "Promised Delivery Date" := "Shipment Date" + 3;
        "Requested Delivery Date" := "Shipment Date" + 3;
        "Due Date" := "Shipment Date" + 3;
      END;

      IF "Document Type" = "Document Type"::Order THEN BEGIN
        IF COPYSTR(UPPERCASE(COMPANYNAME),1,7) <> 'MÜNNICH' THEN BEGIN
          // Warenausgangsdatum = Auftragsdatum + 1 Tag
          // Zuges. Lieferdatum = Auftragsdatum + 2 Tage
          "Shipment Date Shipping Agent" := GetDate("Order Date",1);
          "Promised Delivery Date" := GetDate("Order Date",2);
          // Für VUO ergänzt
          "Shipment Date" := "Shipment Date Shipping Agent";
          "Requested Delivery Date" := "Promised Delivery Date";
        END;
      END;
    // Dicke <<<

    #46..71
    "Doc. No. Occurrence" := ArchiveManagement.GetNextOccurrenceNo(DATABASE::"Sales Header","Document Type","No.");
    */
    //end;

    //Unsupported feature: Property Deletion (Local) on "SynchronizeAsmHeader(PROCEDURE 56)".


    local procedure "**Dicke**"()
    begin
    end;

    local procedure GetDate(StartDate: Date; NumberofDays: Integer): Date
    var
        DateRec: Record "2000000007";
    begin
        // Dicke >>>
        WITH DateRec DO BEGIN
            SETRANGE("Period Type", "Period Type"::Date);
            SETRANGE("Period No.", 1, 5);
            "Period Start" := StartDate;
            DateRec.NEXT(NumberofDays);
            EXIT("Period Start");
        END;
        // Dicke <<<
    end;

    var
        CustomerTemplate: Record "5105";

    var
        ArchiveManagement: Codeunit "5063";

    var
        SelectCustomerTemplateQst: Label 'Do you want to select the customer template?';
        HeaderText: Record "50000";
        ExtText: Record "280";
        StanText: Record "7";
        CompanySelectErr: Label 'Own Company can not selected!';
}

