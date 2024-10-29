report 50089 "Correct Value Entry"
{
    DefaultLayout = RDLC;
    RDLCLayout = './CorrectValueEntry.rdlc';
    Permissions = TableData "Value Entry" = rm;

    dataset
    {
        dataitem("Value Entry"; "Value Entry")
        {

            trigger OnAfterGetRecord()
            var
                SalesInvoiceHeader_lrec: Record "Sales Invoice Header";
                SalesShipmentHeader_lrec: Record "Sales Shipment Header";
                SalesCrMemoHeader_lrec: Record "Sales Cr.Memo Header";
                PurchInvHeader_lrec: Record "122";
                PurchRcptHeader_lrec: Record "120";
                PurchCrMemoHdr_lrec: Record "124";
            begin

                IF "Item Ledger Entry Type" = "Value Entry"."Item Ledger Entry Type"::Sale THEN BEGIN
                    CASE "Document Type" OF
                        "Document Type"::"Sales Invoice":
                            BEGIN
                                SalesInvoiceHeader_lrec.RESET;
                                SalesInvoiceHeader_lrec.SETRANGE("No.", "Value Entry"."Document No.");
                                IF (SalesInvoiceHeader_lrec.FINDFIRST) THEN BEGIN
                                    "Value Entry"."Source No. 2" := SalesInvoiceHeader_lrec."Sell-to Customer No.";
                                    "Value Entry".MODIFY();
                                END;
                            END;
                        "Document Type"::"Sales Shipment":
                            BEGIN
                                SalesShipmentHeader_lrec.RESET;
                                SalesShipmentHeader_lrec.SETRANGE("No.", "Value Entry"."Document No.");
                                IF (SalesShipmentHeader_lrec.FINDFIRST) THEN BEGIN
                                    "Value Entry"."Source No. 2" := SalesShipmentHeader_lrec."Sell-to Customer No.";
                                    "Value Entry".MODIFY();
                                END;
                            END;
                        "Document Type"::"Sales Credit Memo":
                            BEGIN
                                SalesCrMemoHeader_lrec.RESET;
                                SalesCrMemoHeader_lrec.SETRANGE("No.", "Value Entry"."Document No.");
                                IF (SalesCrMemoHeader_lrec.FINDFIRST) THEN BEGIN
                                    "Value Entry"."Source No. 2" := SalesCrMemoHeader_lrec."Sell-to Customer No.";
                                    "Value Entry".MODIFY();
                                END;
                            END;
                    END;
                END;

                IF "Item Ledger Entry Type" = "Value Entry"."Item Ledger Entry Type"::Purchase THEN BEGIN
                    CASE "Document Type" OF
                        "Document Type"::"Purchase Invoice":
                            BEGIN
                                PurchInvHeader_lrec.RESET;
                                PurchInvHeader_lrec.SETRANGE("No.", "Value Entry"."Document No.");
                                IF (PurchInvHeader_lrec.FINDFIRST) THEN BEGIN
                                    "Value Entry"."Source No. 2" := PurchInvHeader_lrec."Buy-from Vendor No.";
                                    "Value Entry".MODIFY();
                                END;
                            END;
                        "Document Type"::"Purchase Receipt":
                            BEGIN
                                PurchRcptHeader_lrec.RESET;
                                PurchRcptHeader_lrec.SETRANGE("No.", "Value Entry"."Document No.");
                                IF (PurchRcptHeader_lrec.FINDFIRST) THEN BEGIN
                                    "Value Entry"."Source No. 2" := PurchRcptHeader_lrec."Buy-from Vendor No.";
                                    "Value Entry".MODIFY();
                                END;
                            END;
                        "Document Type"::"Purchase Credit Memo":
                            BEGIN
                                PurchCrMemoHdr_lrec.RESET;
                                PurchCrMemoHdr_lrec.SETRANGE("No.", "Value Entry"."Document No.");
                                IF (PurchCrMemoHdr_lrec.FINDFIRST) THEN BEGIN
                                    "Value Entry"."Source No. 2" := PurchCrMemoHdr_lrec."Buy-from Vendor No.";
                                    "Value Entry".MODIFY();
                                END;
                            END;
                    END;
                END;
            end;

            trigger OnPostDataItem()
            begin
                MESSAGE('Änderungen sind durchgeführt.');
            end;
        }
    }
}

