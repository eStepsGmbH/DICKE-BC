report 50079 "Sales Line List"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Objekt erstellt.

    Caption = 'Sales Line List';
    ProcessingOnly = true;

    dataset
    {
        dataitem(DataItem50070; Table37)
        {
            DataItemTableView = SORTING(Type, No., Variant Code, Drop Shipment, Location Code, Document Type, Shipment Date)
                                WHERE(Type = CONST(Item));
            RequestFilterFields = "Shipment Date", "Document No.", "No.", "Sell-to Customer No.", "Purchasing Code";

            trigger OnAfterGetRecord()
            begin
                IF VendorNo_req <> '' THEN BEGIN
                    IF Item.GET("Sales Line"."No.") THEN BEGIN
                        IF Item."Vendor No." <> VendorNo_req THEN
                            CurrReport.SKIP;
                    END;
                END;

                IF ItemNo <> "Sales Line"."No." THEN
                    CurrQty := 0;

                CurrQty := CurrQty + "Sales Line".Quantity;

                ItemNo := "Sales Line"."No.";

                RowNo := RowNo + 1;
                EnterCell(RowNo, 1, "Sales Line"."No.", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 2, "Sales Line".Description, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 3, FORMAT("Sales Line".Quantity), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                EnterCell(RowNo, 4, FORMAT(CurrQty), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                EnterCell(RowNo, 5, FORMAT("Sales Line"."Unit of Measure Code"), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 6, FORMAT("Sales Line"."Sell-to Customer No."), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 7, "Sales Line"."Document No.", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 8, FORMAT("Sales Line"."Line No."), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Number);
                EnterCell(RowNo, 9, "Sales Line"."Purchasing Code", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 10, "Sales Line"."Special Order Purchase No.", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
                EnterCell(RowNo, 11, FORMAT("Sales Line"."Shipment Date"), FALSE, FALSE, '', ExcelBuffer."Cell Type"::Date);
                EnterCell(RowNo, 12, VendorNo_req, FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
            end;

            trigger OnPostDataItem()
            begin
                IF NOT OpenExcel THEN
                    MESSAGE(ErrOpenExcel + GETLASTERRORTEXT);

                ExcelBuffer.DELETEALL;
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
                    Caption = 'Options';
                    field(Kreditor; VendorNo_req)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Export VUO';
                        TableRelation = Vendor;
                        ToolTip = 'Specifies the date from which the report or batch job processes information.';
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
        IF VendorNo_req <> '' THEN
            VendorFilterDescription := STRSUBSTNO('Kreditor: %1', VendorNo_req);


        // ------------------------------
        // Excel Überschriften erstellen
        // ------------------------------
        EnterCell(1, 1, 'Artikelnr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 2, 'Artikelbezeichnung', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 3, 'Auftragsmenge', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 4, 'Lfd. Menge', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 5, 'Einheitencode', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 6, 'Verk. an Debitor', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 7, 'Auftragsnr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 8, 'Auftragszeile', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 9, 'Einkaufscode', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 10, 'Bestellnr.', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 11, 'WA-Datum', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(1, 12, 'Kreditor', TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        RowNo := 1;
    end;

    var
        ExcelBuffer: Record "370" temporary;
        Item: Record "Item";
        CurrQty: Decimal;
        ItemNo: Code[20];
        VendorNo_req: Code[20];
        VendorFilterDescription: Text[100];
        ServerFileNameExcel: Text;
        RowNo: Integer;
        ErrOpenExcel: Label 'Es ist ein Fehler augetreten:';

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
        ExcelBuffer.CreateBook(ServerFileNameExcel, 'Verkaufauftragsübersicht');
        ExcelBuffer.WriteSheet('TheHEADER', COMPANYNAME, USERID);
        ExcelBuffer.CloseBook;
        ExcelBuffer.OpenExcel;
        ExcelBuffer.GiveUserControl;
    end;
}

