page 50070 "Sales Invoice Lines DIC"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Page erstellt (wird u.a. über die Page 9080 aufgerufen).

    Caption = 'Sales Invoice Lines DIC';
    Editable = false;
    PageType = List;
    SourceTable = "Sales Invoice Line";
    SourceTableView = WHERE(Type = CONST(Item));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    Visible = false;
                }
                field(DocNo; DocNo)
                {
                    Caption = 'Document No.';
                    Style = Strong;
                    StyleExpr = TRUE;
                    TableRelation = "Sales Invoice Header";
                }
                field("Document No."; "Document No.")
                {
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                }
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {
                }
                field("Location Code"; "Location Code")
                {
                }
                field("Posting Group"; "Posting Group")
                {
                }
                field("Shipment Date"; "Shipment Date")
                {
                }
                field(Description; Description)
                {
                }
                field("Description 2"; "Description 2")
                {
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                }
                field(Quantity; Quantity)
                {
                }
                field("Unit Price"; "Unit Price")
                {
                }
                field("Unit Cost (LCY)"; "Unit Cost (LCY)")
                {
                }
                field("VAT %"; "VAT %")
                {
                }
                field("Line Discount %"; "Line Discount %")
                {
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                }
                field(Amount; Amount)
                {
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                }
                field("Gross Weight"; "Gross Weight")
                {
                }
                field("Net Weight"; "Net Weight")
                {
                }
                field("Units per Parcel"; "Units per Parcel")
                {
                }
                field("Unit Volume"; "Unit Volume")
                {
                }
                field("Appl.-to Item Entry"; "Appl.-to Item Entry")
                {
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                }
                field("Customer Price Group"; "Customer Price Group")
                {
                }
                field("Job No."; "Job No.")
                {
                }
                field("Work Type Code"; "Work Type Code")
                {
                }
                field("Shipment No."; "Shipment No.")
                {
                }
                field("Shipment Line No."; "Shipment Line No.")
                {
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                }
                field("Inv. Discount Amount"; "Inv. Discount Amount")
                {
                }
                field("Drop Shipment"; "Drop Shipment")
                {
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                }
                field("VAT Calculation Type"; "VAT Calculation Type")
                {
                }
                field("Transaction Type"; "Transaction Type")
                {
                }
                field("Transport Method"; "Transport Method")
                {
                }
                field("Attached to Line No."; "Attached to Line No.")
                {
                }
                field("Exit Point"; "Exit Point")
                {
                }
                field("Transaction Specification"; "Transaction Specification")
                {
                }
                field("Tax Category"; "Tax Category")
                {
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                }
                field("Tax Liable"; "Tax Liable")
                {
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                }
                field("VAT Clause Code"; "VAT Clause Code")
                {
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                }
                field("Blanket Order No."; "Blanket Order No.")
                {
                }
                field("Blanket Order Line No."; "Blanket Order Line No.")
                {
                }
                field("VAT Base Amount"; "VAT Base Amount")
                {
                }
                field("Unit Cost"; "Unit Cost")
                {
                }
                field("System-Created Entry"; "System-Created Entry")
                {
                }
                field("Line Amount"; "Line Amount")
                {
                }
                field("VAT Difference"; "VAT Difference")
                {
                }
                field("VAT Identifier"; "VAT Identifier")
                {
                }
                field("IC Partner Ref. Type"; "IC Partner Ref. Type")
                {
                }
                field("IC Partner Reference"; "IC Partner Reference")
                {
                }
                field("Prepayment Line"; "Prepayment Line")
                {
                }
                field("IC Partner Code"; "IC Partner Code")
                {
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field("Dimension Set ID"; "Dimension Set ID")
                {
                }
                field("Job Task No."; "Job Task No.")
                {
                }
                field("Job Contract Entry No."; "Job Contract Entry No.")
                {
                }
                field("Deferral Code"; "Deferral Code")
                {
                }
                field("Variant Code"; "Variant Code")
                {
                }
                field("Bin Code"; "Bin Code")
                {
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                }
                field("FA Posting Date"; "FA Posting Date")
                {
                }
                field("Depreciation Book Code"; "Depreciation Book Code")
                {
                }
                field("Depr. until FA Posting Date"; "Depr. until FA Posting Date")
                {
                }
                field("Duplicate in Depreciation Book"; "Duplicate in Depreciation Book")
                {
                }
                field("Use Duplication List"; "Use Duplication List")
                {
                }
                field("Responsibility Center"; "Responsibility Center")
                {
                }
                field("Cross-Reference No."; "Cross-Reference No.")
                {
                }
                field("Unit of Measure (Cross Ref.)"; "Unit of Measure (Cross Ref.)")
                {
                }
                field("Cross-Reference Type"; "Cross-Reference Type")
                {
                }
                field("Cross-Reference Type No."; "Cross-Reference Type No.")
                {
                }
                field("Item Category Code"; "Item Category Code")
                {
                }
                field(Nonstock; Nonstock)
                {
                }
                field("Purchasing Code"; "Purchasing Code")
                {
                }
                field("Appl.-from Item Entry"; "Appl.-from Item Entry")
                {
                }
                field("Return Reason Code"; "Return Reason Code")
                {
                }
                field("Allow Line Disc."; "Allow Line Disc.")
                {
                }
                field("Customer Disc. Group"; "Customer Disc. Group")
                {
                }
                field("Minimum Durability"; "Minimum Durability")
                {
                }
                field(Coli; Coli)
                {
                }
                field("Order No."; "Order No.")
                {
                }
                field("Order Line No."; "Order Line No.")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
        }
        area(processing)
        {
            group("F&unktion")
            {
                Caption = 'F&unctions';
                Image = "Action";
            }
            action("Beleg anzeigen")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Document';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Return';
                ToolTip = 'Show details for the posted invoice.';

                trigger OnAction()
                begin
                    IF SalesInvoiceHdr.GET("Document No.") THEN BEGIN
                        //PAGE.RUN(PAGE::"Posted Sales Invoice",SalesInvoiceHdr); TODO: ERROR
                        EXIT;
                    END;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IF IsFirstDocLine THEN
            DocNo := Rec."Document No."
        ELSE
            DocNo := '';
        // IF IsFirstDocLine THEN
        //  CurrPage."Document No.".UPDATEFONTBOLD := TRUE
        // ELSE
        //  Text := '';
    end;

    var
        SalesInvoiceHdr: Record "112";
        TempSalesInvLine: Record "113" temporary;
        DocNo: Code[20];

    local procedure IsFirstDocLine(): Boolean
    var
        SalesInvLine: Record "113";
    begin
        TempSalesInvLine.RESET;
        TempSalesInvLine.COPYFILTERS(Rec);
        TempSalesInvLine.SETRANGE("Document No.", "Document No.");
        IF NOT TempSalesInvLine.FIND('-') THEN BEGIN
            SalesInvLine.COPYFILTERS(Rec);
            SalesInvLine.SETRANGE("Document No.", "Document No.");
            SalesInvLine.FIND('-');
            TempSalesInvLine := SalesInvLine;
            TempSalesInvLine.INSERT;
        END;
        EXIT("Line No." = TempSalesInvLine."Line No.");
    end;


    procedure GetSelectedLine(var FromSalesInvLine: Record "113")
    begin
        FromSalesInvLine.COPY(Rec);
        CurrPage.SETSELECTIONFILTER(FromSalesInvLine);
    end;
}

