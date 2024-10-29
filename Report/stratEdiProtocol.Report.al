report 50092 "stratEdi Protocol"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    DefaultLayout = RDLC;
    RDLCLayout = './stratEdiProtocol.rdlc';

    Caption = 'stratEdi Protokoll';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("stratEdi Protocol"; "stratEdi Protocol")
        {
            DataItemTableView = SORTING("Document Type", "Document No.", "Document Direction", Status)
                                ORDER(Ascending);
            RequestFilterFields = "Central Payer No.", "List No.", "Document Type";
            column(FORMAT_TODAY_0_4_; FORMAT(TODAY, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PAGENO)
            {
            }
            column(USERID; USERID)
            {
            }
            column(GlnBuyer; GlnBuyer)
            {
            }
            column(DocumentNo_stratEdiProtocol; "stratEdi Protocol"."Document No.")
            {
            }
            column(Status_stratEdiProtocol; "stratEdi Protocol".Status)
            {
            }
            column(DocumentDirection_stratEdiProtocol; "stratEdi Protocol"."Document Direction")
            {
            }
            column(EdiVersion_stratEdiProtocol; "stratEdi Protocol"."Edi Version")
            {
            }
            column(ListNo_stratEdiProtocol; "stratEdi Protocol"."List No.")
            {
            }
            column(PostedDate_stratEdiProtocol; "stratEdi Protocol"."Posted Date")
            {
            }
            column(PostedTime_stratEdiProtocol; "stratEdi Protocol"."Posted Time")
            {
            }
            column(EdiFileName_stratEdiProtocol; "stratEdi Protocol"."Edi File Name")
            {
            }
            column(CustomerCentralPayer_Name; CustomerCentralPayer.Name)
            {
            }
            column(CustomerCentralPayer_Address; CustomerCentralPayer.Address)
            {
            }
            column(CustomerCentralPayer_City; CustomerCentralPayer.City)
            {
            }
            column(CustomerCentralPayer_PostCode; CustomerCentralPayer."Post Code")
            {
            }
            column(Protocol_stratEdiProtocol; "stratEdi Protocol".Protocol)
            {
            }
            column(Name_CompanyInformation; CompanyInformation.Name)
            {
            }
            column(Address_CompanyInformation; CompanyInformation.Address)
            {
            }
            column(PostCode__CompanyInformation; CompanyInformation."Post Code")
            {
            }
            column(City__CompanyInformation; CompanyInformation.City)
            {
            }
            column(GLN__CompanyInformation; CompanyInformation.GLN)
            {
            }
            dataitem(MultiTemp; MultiTemp)
            {
                DataItemTableView = SORTING(TextKey, IntKey, DecKey)
                                    ORDER(Ascending);
                UseTemporary = true;
                column(SelltoCustomerNo_SalesInvoiceHeader; MultiTemp.Text1)
                {
                }
                column(SelltoCustomerName_SalesInvoiceHeader; MultiTemp.Text2)
                {
                }
                column(SelltoAddress_SalesInvoiceHeader; MultiTemp.Text3)
                {
                }
                column(SelltoCity_SalesInvoiceHeader; MultiTemp.Text4)
                {
                }
                column(SelltoPostCode_SalesInvoiceHeader; MultiTemp.Text5)
                {
                }
                column(SelltoCountryRegionCode_SalesInvoiceHeader; MultiTemp.Text6)
                {
                }
                column(ExternalDocumentNo_SalesInvoiceHeader; MultiTemp.Text7)
                {
                }
                column(Amount_SalesInvoiceHeader; MultiTemp.Dec1)
                {
                }
                column(AmountIncludingVAT_SalesInvoiceHeader; MultiTemp.Dec2)
                {
                }
                column(InvoiceDiscountAmount_SalesInvoiceHeader; MultiTemp.Dec3)
                {
                }

                trigger OnPreDataItem()
                begin
                    MultiTemp.RESET();
                    MultiTemp.SETRANGE(TextKey, TextKey_ltxt);
                    MultiTemp.SETRANGE(IntKey, IntKey_lint);
                end;
            }

            trigger OnAfterGetRecord()
            var
                SalesInvoiceHeader: Record "Sales Invoice Header";
                SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                SalesHeader: Record "Sales Header";
                Customer: Record "Customer";
            begin

                CASE "stratEdi Protocol"."Document Type" OF
                    "stratEdi Protocol"."Document Type"::Order:
                        BEGIN
                            IF SalesHeader.GET(SalesHeader."Document Type"::Order, "stratEdi Protocol"."Document No.") THEN BEGIN
                                SalesHeader.CALCFIELDS("Amount Including VAT", Amount, "Invoice Discount Amount");
                                IF Customer.GET(SalesHeader."Sell-to Customer No.") THEN
                                    GlnBuyer := Customer.GLN;
                                MultiTemp.INIT;
                                MultiTemp.TextKey := "stratEdi Protocol"."Document No.";
                                TextKey_ltxt := MultiTemp.TextKey;
                                DocumentTypeOption := "stratEdi Protocol"."Document Type";
                                MultiTemp.IntKey := DocumentTypeOption;
                                IntKey_lint := DocumentTypeOption;
                                MultiTemp.Text1 := SalesHeader."Sell-to Customer No.";
                                MultiTemp.Text2 := SalesHeader."Sell-to Customer Name";
                                MultiTemp.Text3 := SalesHeader."Sell-to Address";
                                MultiTemp.Text4 := SalesHeader."Sell-to City";
                                MultiTemp.Text5 := SalesHeader."Sell-to Post Code";
                                MultiTemp.Text6 := SalesHeader."Sell-to Country/Region Code";
                                MultiTemp.Text7 := SalesHeader."External Document No.";
                                SalesHeader.CALCFIELDS(Amount, "Amount Including VAT");
                                MultiTemp.Dec1 := SalesHeader.Amount;
                                MultiTemp.Dec2 := SalesHeader."Amount Including VAT";
                                MultiTemp.Dec3 := SalesHeader."Invoice Discount Amount";
                                MultiTemp.INSERT;
                            END;
                        END;

                    "stratEdi Protocol"."Document Type"::Invoice:
                        BEGIN
                            SalesInvoiceHeader.GET("stratEdi Protocol"."Document No.");
                            SalesInvoiceHeader.CALCFIELDS("Amount Including VAT", Amount, "Invoice Discount Amount");
                            IF Customer.GET(SalesInvoiceHeader."Sell-to Customer No.") THEN
                                GlnBuyer := Customer.GLN;
                            MultiTemp.INIT;
                            MultiTemp.TextKey := "stratEdi Protocol"."Document No.";
                            TextKey_ltxt := MultiTemp.TextKey;
                            DocumentTypeOption := "stratEdi Protocol"."Document Type";
                            MultiTemp.IntKey := DocumentTypeOption;
                            IntKey_lint := DocumentTypeOption;
                            MultiTemp.Text1 := SalesInvoiceHeader."Sell-to Customer No.";
                            MultiTemp.Text2 := SalesInvoiceHeader."Sell-to Customer Name";
                            MultiTemp.Text3 := SalesInvoiceHeader."Sell-to Address";
                            MultiTemp.Text4 := SalesInvoiceHeader."Sell-to City";
                            MultiTemp.Text5 := SalesInvoiceHeader."Sell-to Post Code";
                            MultiTemp.Text6 := SalesInvoiceHeader."Sell-to Country/Region Code";
                            MultiTemp.Text7 := SalesInvoiceHeader."External Document No.";
                            SalesInvoiceHeader.CALCFIELDS(Amount, "Amount Including VAT");
                            MultiTemp.Dec1 := SalesInvoiceHeader.Amount;
                            MultiTemp.Dec2 := SalesInvoiceHeader."Amount Including VAT";
                            MultiTemp.Dec3 := SalesInvoiceHeader."Invoice Discount Amount";
                            MultiTemp.INSERT;
                        END;

                    "stratEdi Protocol"."Document Type"::"Credit Memo":
                        BEGIN
                            SalesCrMemoHeader.GET("stratEdi Protocol"."Document No.");
                            IF Customer.GET(SalesCrMemoHeader."Sell-to Customer No.") THEN
                                GlnBuyer := Customer.GLN;
                            MultiTemp.INIT;
                            MultiTemp.TextKey := "stratEdi Protocol"."Document No.";
                            TextKey_ltxt := MultiTemp.TextKey;
                            DocumentTypeOption := "stratEdi Protocol"."Document Type";
                            MultiTemp.IntKey := DocumentTypeOption;
                            IntKey_lint := DocumentTypeOption;
                            MultiTemp.Text1 := SalesCrMemoHeader."Sell-to Customer No.";
                            MultiTemp.Text2 := SalesCrMemoHeader."Sell-to Customer Name";
                            MultiTemp.Text3 := SalesCrMemoHeader."Sell-to Address";
                            MultiTemp.Text4 := SalesCrMemoHeader."Sell-to City";
                            MultiTemp.Text5 := SalesCrMemoHeader."Sell-to Post Code";
                            MultiTemp.Text6 := SalesCrMemoHeader."Sell-to Country/Region Code";
                            MultiTemp.Text7 := SalesCrMemoHeader."External Document No.";
                            SalesCrMemoHeader.CALCFIELDS(Amount, "Amount Including VAT");
                            MultiTemp.Dec1 := SalesCrMemoHeader.Amount * -1;
                            MultiTemp.Dec2 := SalesCrMemoHeader."Amount Including VAT" * -1;
                            MultiTemp.INSERT;

                        END;
                END;

                IF CustomerCentralPayer.GET("stratEdi Protocol"."Central Payer No.") THEN;
            end;
        }
    }

    requestpage
    {

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

    trigger OnPreReport()
    begin
        CompanyInformation.GET;
    end;

    var
        GlnBuyer: Code[13];
        CustomerCentralPayer: Record "Customer";
        DocumentTypeOption: Integer;
        TextKey_ltxt: Text[100];
        IntKey_lint: Integer;
        CompanyInformation: Record "Company Information";
}

