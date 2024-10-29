report 50086 "EDI Orders List"
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
            RequestFilterFields = SendToKirnDate;

            trigger OnAfterGetRecord()
            var
                SalesLine_lrec: Record "Sales Line";
            begin

                ShowOutputNotReceived := TRUE;
                IsReceived := FALSE;

                IF ShowOnlyNotReceived THEN BEGIN
                    //dies betrifft nur Aufträge, die
                    //auch gesendet wurden

                    ShowOutputNotReceived := FALSE;

                    IF NOT ("Sales Header".SendToKirnDate = 0D) THEN BEGIN
                        IsReceived := TRUE;
                        SalesLine_lrec.RESET;
                        SalesLine_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
                        SalesLine_lrec.SETRANGE("Document No.", "Sales Header"."No.");
                        SalesLine_lrec.SETRANGE(Type, SalesLine_lrec.Type::Item);
                        SalesLine_lrec.SETRANGE(SalesLine_lrec."EDI Receive Date", 0D);

                        IF SalesLine_lrec.FINDFIRST() THEN BEGIN
                            //es wurde zu dem Auftrag mind. eine Zeile gefunden,
                            //die noch nicht geliefert wurde
                            ShowOutputNotReceived := TRUE;
                            IsReceived := FALSE;
                        END;
                    END;
                END ELSE BEGIN
                    IF NOT ("Sales Header".SendToKirnDate = 0D) THEN BEGIN
                        IsReceived := TRUE;
                        SalesLine_lrec.RESET;
                        SalesLine_lrec.SETRANGE("Document Type", SalesLine_lrec."Document Type"::Order);
                        SalesLine_lrec.SETRANGE("Document No.", "Sales Header"."No.");
                        SalesLine_lrec.SETRANGE(Type, SalesLine_lrec.Type::Item);
                        SalesLine_lrec.SETRANGE(SalesLine_lrec."EDI Receive Date", 0D);

                        IF SalesLine_lrec.FINDFIRST() THEN BEGIN
                            //es wurde zu dem Auftrag mind. eine Zeile gefunden,
                            //die noch nicht geliefert wurde
                            IsReceived := FALSE;
                        END;
                    END;
                END;

                IF (ShowOnlyNotReceived AND IsReceived = FALSE) OR (ShowOnlyNotReceived = FALSE) THEN BEGIN

                    RowNo := RowNo + 1;

                    EnterCell(RowNo, 1, FORMAT("Sales Header"."Order Date"), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Date);
                    EnterCell(RowNo, 2, "Sales Header"."Sell-to Customer No.", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                    EnterCell(RowNo, 3, "Sales Header"."No.", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                    EnterCell(RowNo, 4, "Sales Header"."Sell-to Customer Name", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                    EnterCell(RowNo, 5, "Sales Header"."Sell-to Address", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                    EnterCell(RowNo, 6, "Sales Header"."Sell-to Post Code", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                    EnterCell(RowNo, 7, "Sales Header"."Sell-to City", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                    EnterCell(RowNo, 8, FORMAT("Sales Header".SendToKirnDate), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Date);
                    EnterCell(RowNo, 9, FORMAT("Sales Header".SendToKirnTime), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Time);
                    IF IsReceived THEN
                        EnterCell(RowNo, 10, 'JA', FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text)
                    ELSE
                        EnterCell(RowNo, 10, 'NEIN', FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);

                END;
            end;

            trigger OnPostDataItem()
            begin
                ExcelBuffer.CreateBook(ServerFileName, 'EDI-Protokoll');
                ExcelBuffer.WriteSheet('TheHEADER', COMPANYNAME, USERID);
                ExcelBuffer.CloseBook;
                ExcelBuffer.OpenExcel;
                // ExcelBuffer.GiveUserControl;
                ExcelBuffer.DELETEALL;
            end;

            trigger OnPreDataItem()
            begin
                // ------------------------------
                // Excel Überschriften erstellen
                // ------------------------------
                EnterCell(1, 1, 'Auftrag Datum', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 2, 'Verk. an Deb-Nr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 3, 'Auftrag Nummer', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 4, 'Verk. an Name', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 5, 'Verk. an Adresse', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 6, 'Plz', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 7, 'Verk. an Ort', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 8, 'Gesendet am', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 9, 'Gesendet um', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(1, 10, 'Zurück', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);

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
                field(ShowOnlyNotReceived; ShowOnlyNotReceived)
                {
                    Caption = 'Nur Aufträge die noch nicht zurückgesendet wurden.';
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
        ShowOnlyNotReceived := FALSE;
    end;

    var
        ExcelBuffer: Record "370" temporary;
        ShowOnlyNotReceived: Boolean;
        ShowOutputNotReceived: Boolean;
        IsReceived: Boolean;
        ServerFileName: Text;
        RowNo: Integer;

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
        ServerFileName := NewFileName;
    end;
}

