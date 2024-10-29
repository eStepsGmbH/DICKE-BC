report 50094 "Order CSV Export"
{
    Caption = 'CSV Export';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.")
                                WHERE("Document Type" = CONST(Order));
            RequestFilterFields = "No.", "Sell-to Customer No.";
            RequestFilterHeading = 'Sales Order';
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"),
                               "Document No." = FIELD("No.");
                DataItemLinkReference = "Sales Header";
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");

                trigger OnAfterGetRecord()
                var
                    Customer: Record "Customer";
                    Item: Record "Item";
                    SalesHeader: Record "Sales Header";
                begin
                    //DICKE >>>
                    //Auftragszeile in die Datei eintragen

                    IF "Sales Line".Type = "Sales Line".Type::Item THEN BEGIN

                        SalesHeader.GET("Sales Line"."Document Type", "Sales Line"."Document No.");
                        Customer.GET(SalesHeader."Sell-to Customer No.");
                        Item.GET("Sales Line"."No.");

                        StringBuilder_dn.AppendLine
                        (
                        '7000050;"Schlemmermeyer GmbH Co. KG";"";'
                        + Customer.Branch + ';'
                        + SalesHeader."External Document No." + ';'
                        + '"' + FORMAT(SalesHeader."Promised Delivery Date") + '";'
                        + '"' + FORMAT(SalesHeader."Document Date") + '";'
                        + FORMAT(DATE2DWY(SalesHeader."Document Date", 2)) + ';'
                        + Item."Search Description" + ';'
                        + '"' + "Sales Line"."No." + '";'
                        + '"' + "Sales Line".Description + '";'
                        + '"' + "Sales Line"."Description 2" + '";'
                        + ';'
                        + FORMAT("Sales Line".Quantity) + ';'
                        + '"";""'
                        );

                    END;
                    //DICKE <<<
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
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
        tempFileName: Text;
        ToFile: Text;
    begin

        tempFileName := FileManagement.ServerTempFileName('.csv');

        StreamWriter_dn := StreamWriter_dn.StreamWriter(tempFileName);
        StreamWriter_dn.WriteLine(StringBuilder_dn.ToString());
        StreamWriter_dn.Close();

        ToFile := 'LieferAvis.csv';
        DOWNLOAD(tempFileName, 'CSV Datei speichern', 'C:\', 'CSV Datei(*.csv)|*.csv', ToFile);
        FileManagement.DeleteServerFile(tempFileName);
    end;

    trigger OnPreReport()
    begin
        CreateCsvDocument();
    end;

    var
        StringBuilder_dn: DotNet StringBuilder;
        String_dn: DotNet String;
        DateTime_dn: DotNet DateTime;
        StreamWriter_dn: DotNet StreamWriter;
        TextLine: Text;
        FileManagement: Codeunit "419";

    local procedure CreateCsvDocument()
    begin
        StringBuilder_dn := StringBuilder_dn.StringBuilder();
        StringBuilder_dn.Clear();

        StringBuilder_dn.AppendLine
        (
        '"Unser Konto";"Firma";"Ihr Konto";"Filiale";"Bestell-Nr.";"Liefer-Datum";"Bestell-Datum";"Woche";"Artikel";"Ihr-Artikel";"Bezeichnung";"Inhalt";"Bes-Menge";"Liefer-Menge";"Status";"PLUKD"'
        );
    end;
}

