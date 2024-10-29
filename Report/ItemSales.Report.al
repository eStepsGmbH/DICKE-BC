report 50018 "Item Sales"
{
    Caption = 'Item Sales';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            CalcFields = "Qty. on Sales Order";
            DataItemTableView = SORTING("No.")
                                ORDER(Ascending)
                                WHERE("Qty. on Sales Order" = FILTER(> 0));
            RequestFilterFields = "Date Filter", "No.", "Vendor No.";

            trigger OnAfterGetRecord()
            begin

                Item.CALCFIELDS("Qty. on Sales Order");

                AllItems_trec.INIT;
                AllItems_trec.TextKey := Item."No.";
                AllItems_trec.IntKey := 0;
                AllItems_trec.DecKey := 0;
                AllItems_trec.Text1 := Item.Description;
                AllItems_trec.Dec1 := Item."Qty. on Sales Order";
                AllItems_trec.Dec3 := AllItems_trec.Dec1 + AllItems_trec.Dec2;
                AllItems_trec.Dec4 := Item."Net Weight";
                AllItems_trec.Dec5 := AllItems_trec.Dec4 * AllItems_trec.Dec3;

                IF AllItems_trec.INSERT = FALSE THEN BEGIN
                    IF AllItems_trec.GET(Item."No.", 0, 0) THEN BEGIN
                        AllItems_trec.Dec1 := AllItems_trec.Dec1 + Item."Qty. on Sales Order";
                        AllItems_trec.Dec3 := AllItems_trec.Dec1 + AllItems_trec.Dec2;
                        AllItems_trec.Dec5 := AllItems_trec.Dec4 * AllItems_trec.Dec3;
                        AllItems_trec.MODIFY;
                    END;
                END;
            end;

            trigger OnPreDataItem()
            begin

                // -----------------------------
                // Excel Überschriften erstellen
                // -----------------------------
                IF ExportToExcel_req THEN BEGIN
                    RowNo := 1;
                    IF Company_option = 0 THEN BEGIN
                        EnterCell(RowNo, 1, 'Nr.', TRUE, FALSE, FALSE);
                        EnterCell(RowNo, 2, 'Beschreibung', TRUE, FALSE, FALSE);
                        EnterCell(RowNo, 3, 'Menge in Auftrag', TRUE, FALSE, FALSE);
                        EnterCell(RowNo, 4, 'Nettogewicht', TRUE, FALSE, FALSE);
                        EnterCell(RowNo, 5, 'Gesamtgewicht', TRUE, FALSE, FALSE);
                    END ELSE BEGIN
                        EnterCell(RowNo, 1, 'Nr.', TRUE, FALSE, FALSE);
                        EnterCell(RowNo, 2, 'Beschreibung', TRUE, FALSE, FALSE);
                        EnterCell(RowNo, 3, 'Menge in Auftrag Mandant 1', TRUE, FALSE, FALSE);
                        EnterCell(RowNo, 4, 'Menge in Auftrag Mandant 2', TRUE, FALSE, FALSE);
                        EnterCell(RowNo, 5, 'Gesamtmenge in Auftrag', TRUE, FALSE, FALSE);
                        EnterCell(RowNo, 6, 'Nettogewicht', TRUE, FALSE, FALSE);
                        EnterCell(RowNo, 7, 'Gesamtgewicht', TRUE, FALSE, FALSE);
                    END;
                END;
            end;
        }
        dataitem(Item2; Item)
        {
            DataItemTableView = SORTING("No.")
                                ORDER(Ascending)
                                WHERE("Qty. on Sales Order" = FILTER(> 0));

            trigger OnAfterGetRecord()
            begin

                Item2.CALCFIELDS("Qty. on Sales Order");

                AllItems_trec.INIT;
                AllItems_trec.TextKey := Item2."No.";
                AllItems_trec.IntKey := 0;
                AllItems_trec.DecKey := 0;
                AllItems_trec.Text1 := Item2.Description;
                AllItems_trec.Dec2 := Item2."Qty. on Sales Order";
                AllItems_trec.Dec3 := AllItems_trec.Dec1 + AllItems_trec.Dec2;
                AllItems_trec.Dec4 := Item2."Net Weight";
                AllItems_trec.Dec5 := AllItems_trec.Dec4 * AllItems_trec.Dec3;
                IF AllItems_trec.INSERT = FALSE THEN BEGIN
                    IF AllItems_trec.GET(Item2."No.", 0, 0) THEN BEGIN
                        AllItems_trec.Dec2 := AllItems_trec.Dec2 + Item2."Qty. on Sales Order";
                        AllItems_trec.Dec3 := AllItems_trec.Dec1 + AllItems_trec.Dec2;
                        AllItems_trec.Dec5 := AllItems_trec.Dec4 * AllItems_trec.Dec3;
                        AllItems_trec.MODIFY;
                    END;
                END;
            end;

            trigger OnPreDataItem()
            begin
                IF Company_option = 0 THEN
                    CurrReport.BREAK;

                IF Item2.CHANGECOMPANY(FORMAT(Company_option)) THEN
                    Item2.COPYFILTERS(Item);
            end;
        }
        dataitem(Ganzzahl; Integer)
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            begin

                IF Number = 1 THEN BEGIN
                    AllItems_trec.FIND('-');
                END ELSE BEGIN
                    IF AllItems_trec.NEXT = 0 THEN;
                END;

                IF ExportToExcel_req THEN BEGIN
                    IF Company_option = 0 THEN BEGIN
                        RowNo += 1;
                        EnterCell(RowNo, 1, AllItems_trec.TextKey, FALSE, FALSE, FALSE);
                        EnterCell(RowNo, 2, AllItems_trec.Text1, FALSE, FALSE, FALSE);
                        EnterCell(RowNo, 3, FORMAT(AllItems_trec.Dec1), FALSE, FALSE, FALSE);
                        EnterCell(RowNo, 4, FORMAT(AllItems_trec.Dec4), FALSE, FALSE, FALSE);
                        EnterCell(RowNo, 5, FORMAT(AllItems_trec.Dec5), FALSE, FALSE, FALSE);
                    END ELSE BEGIN
                        RowNo += 1;
                        EnterCell(RowNo, 1, AllItems_trec.TextKey, FALSE, FALSE, FALSE);
                        EnterCell(RowNo, 2, AllItems_trec.Text1, FALSE, FALSE, FALSE);
                        EnterCell(RowNo, 3, FORMAT(AllItems_trec.Dec1), FALSE, FALSE, FALSE);
                        EnterCell(RowNo, 4, FORMAT(AllItems_trec.Dec2), FALSE, FALSE, FALSE);
                        EnterCell(RowNo, 5, FORMAT(AllItems_trec.Dec3), FALSE, FALSE, FALSE);
                        EnterCell(RowNo, 6, FORMAT(AllItems_trec.Dec4), FALSE, FALSE, FALSE);
                        EnterCell(RowNo, 7, FORMAT(AllItems_trec.Dec5), FALSE, FALSE, FALSE);
                    END;
                END;
            end;

            trigger OnPreDataItem()
            begin

                // Gesamtsummen berechnen
                IF AllItems_trec.FIND('-') THEN
                    REPEAT
                        TotalQty_dec += AllItems_trec.Dec3;
                        TotalNet_dec += AllItems_trec.Dec4;
                        TotalWeight_dec := TotalQty_dec * TotalNet_dec;
                    UNTIL AllItems_trec.NEXT = 0;
                AllItems_trec.RESET;

                Ganzzahl.SETRANGE(Number, 1, AllItems_trec.COUNT);
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
                    field(CompanySelection; Company_option)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Export VUO';
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

    trigger OnPostReport()
    begin
        IF ExportToExcel_req THEN BEGIN
            IF NOT OpenExcel THEN
                MESSAGE(Text003 + GETLASTERRORTEXT);
        END;
        TempExcelBuffer.DELETEALL;
    end;

    trigger OnPreReport()
    begin
        ExportToExcel_req := TRUE;
    end;

    var
        Company_option: Option " ","Dicke Food","Dicke Gourmet Konzepte";
        ExportToExcel_req: Boolean;
        TempExcelBuffer: Record "370" temporary;
        RowNo: Integer;
        AllItems_trec: Record "50008" temporary;
        TotalQty_dec: Decimal;
        TotalNet_dec: Decimal;
        TotalWeight_dec: Decimal;
        Text001: Label 'Artikelmengen';
        Text002: Label 'Mandanten %1 ist identisch mit zusätzlich ausgewählten Mandant %2 !';
        Text003: Label 'Error detected: ';
        ServerFileNameExcel: Text;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; Italic: Boolean; UnderLine: Boolean)
    begin
        TempExcelBuffer.INIT;
        TempExcelBuffer.VALIDATE("Row No.", RowNo);
        TempExcelBuffer.VALIDATE("Column No.", ColumnNo);
        TempExcelBuffer."Cell Value as Text" := CellValue;
        TempExcelBuffer.Formula := '';
        TempExcelBuffer.Bold := Bold;
        TempExcelBuffer.Italic := Italic;
        TempExcelBuffer.Underline := UnderLine;
        TempExcelBuffer.INSERT;
    end;

    [TryFunction]
    local procedure OpenExcel()
    begin
        TempExcelBuffer.CreateBook(ServerFileNameExcel, 'VK-Statistik');
        TempExcelBuffer.WriteSheet(Text001, COMPANYNAME, USERID);
        TempExcelBuffer.CloseBook;
        TempExcelBuffer.OpenExcel;
        // TempExcelBuffer.GiveUserControl;
    end;
}

