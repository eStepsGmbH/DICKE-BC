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
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
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
                field("Document No."; Rec."Document No.")
                {
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                }
                field(Type; Rec.Type)
                {
                }
                field("No."; Rec."No.")
                {
                }
                field("Location Code"; Rec."Location Code")
                {
                }
                field("Posting Group"; Rec."Posting Group")
                {
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Description 2"; Rec."Description 2")
                {
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Unit Price"; Rec."Unit Price")
                {
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                }
                field("VAT %"; Rec."VAT %")
                {
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                }
                field(Amount; Rec.Amount)
                {
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                }
                field("Gross Weight"; Rec."Gross Weight")
                {
                }
                field("Net Weight"; Rec."Net Weight")
                {
                }
                field("Units per Parcel"; Rec."Units per Parcel")
                {
                }
                field("Unit Volume"; Rec."Unit Volume")
                {
                }
                field("Appl.-to Item Entry"; Rec."Appl.-to Item Entry")
                {
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {
                }
                field("Job No."; Rec."Job No.")
                {
                }
                field("Work Type Code"; Rec."Work Type Code")
                {
                }
                field("Shipment No."; Rec."Shipment No.")
                {
                }
                field("Shipment Line No."; Rec."Shipment Line No.")
                {
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                }
                field("Inv. Discount Amount"; Rec."Inv. Discount Amount")
                {
                }
                field("Drop Shipment"; Rec."Drop Shipment")
                {
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                }
                field("VAT Calculation Type"; Rec."VAT Calculation Type")
                {
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                }
                field("Transport Method"; Rec."Transport Method")
                {
                }
                field("Attached to Line No."; Rec."Attached to Line No.")
                {
                }
                field("Exit Point"; Rec."Exit Point")
                {
                }
                field("Transaction Specification"; Rec."Transaction Specification")
                {
                }
                field("Tax Category"; Rec."Tax Category")
                {
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                }
                field("Tax Liable"; Rec."Tax Liable")
                {
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {
                }
                field("VAT Clause Code"; Rec."VAT Clause Code")
                {
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                }
                field("Blanket Order No."; Rec."Blanket Order No.")
                {
                }
                field("Blanket Order Line No."; Rec."Blanket Order Line No.")
                {
                }
                field("VAT Base Amount"; Rec."VAT Base Amount")
                {
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                }
                field("System-Created Entry"; Rec."System-Created Entry")
                {
                }
                field("Line Amount"; Rec."Line Amount")
                {
                }
                field("VAT Difference"; Rec."VAT Difference")
                {
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {
                }
                field("IC Partner Ref. Type"; Rec."IC Partner Ref. Type")
                {
                }
                field("IC Partner Reference"; Rec."IC Partner Reference")
                {
                }
                field("Prepayment Line"; Rec."Prepayment Line")
                {
                }
                field("IC Partner Code"; Rec."IC Partner Code")
                {
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                }
                field("Job Contract Entry No."; Rec."Job Contract Entry No.")
                {
                }
                field("Deferral Code"; Rec."Deferral Code")
                {
                }
                field("Variant Code"; Rec."Variant Code")
                {
                }
                field("Bin Code"; Rec."Bin Code")
                {
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                }
                field("FA Posting Date"; Rec."FA Posting Date")
                {
                }
                field("Depreciation Book Code"; Rec."Depreciation Book Code")
                {
                }
                field("Depr. until FA Posting Date"; Rec."Depr. until FA Posting Date")
                {
                }
                field("Duplicate in Depreciation Book"; Rec."Duplicate in Depreciation Book")
                {
                }
                field("Use Duplication List"; Rec."Use Duplication List")
                {
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                }
                field("Cross-Reference No."; Rec."Cross-Reference No.")
                {
                }
                field("Unit of Measure (Cross Ref.)"; Rec."Unit of Measure (Cross Ref.)")
                {
                }
                field("Cross-Reference Type"; Rec."Cross-Reference Type")
                {
                }
                field("Cross-Reference Type No."; Rec."Cross-Reference Type No.")
                {
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                }
                field(Nonstock; Rec.Nonstock)
                {
                }
                field("Purchasing Code"; Rec."Purchasing Code")
                {
                }
                field("Appl.-from Item Entry"; Rec."Appl.-from Item Entry")
                {
                }
                field("Return Reason Code"; Rec."Return Reason Code")
                {
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                }
                field("Customer Disc. Group"; Rec."Customer Disc. Group")
                {
                }
                field("Minimum Durability"; Rec."Minimum Durability")
                {
                }
                field(Coli; Rec.Coli)
                {
                }
                field("Order No."; Rec."Order No.")
                {
                }
                field("Order Line No."; Rec."Order Line No.")
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
                    IF SalesInvoiceHdr.GET(Rec."Document No.") THEN BEGIN
                        //PAGE.RUN(PAGE::"Posted Sales Invoice",SalesInvoiceHdr); TODO: ERROR
                        EXIT;
                    END;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IF IsFirstDocLine() THEN
            DocNo := Rec."Document No."
        ELSE
            DocNo := '';
        // IF IsFirstDocLine THEN
        //  CurrPage."Document No.".UPDATEFONTBOLD := TRUE
        // ELSE
        //  Text := '';
    end;

    var
        SalesInvoiceHdr: Record "Sales Invoice Header";
        TempSalesInvLine: Record "113" temporary;
        DocNo: Code[20];

    local procedure IsFirstDocLine(): Boolean
    var
        SalesInvLine: Record "113";
    begin
        TempSalesInvLine.RESET();
        TempSalesInvLine.COPYFILTERS(Rec);
        TempSalesInvLine.SETRANGE("Document No.", Rec."Document No.");
        IF NOT TempSalesInvLine.FIND('-') THEN BEGIN
            SalesInvLine.COPYFILTERS(Rec);
            SalesInvLine.SETRANGE("Document No.", Rec."Document No.");
            SalesInvLine.FIND('-');
            TempSalesInvLine := SalesInvLine;
            TempSalesInvLine.INSERT();
        END;
        EXIT(Rec."Line No." = TempSalesInvLine."Line No.");
    end;


    procedure GetSelectedLine(var FromSalesInvLine: Record "113")
    begin
        FromSalesInvLine.COPY(Rec);
        CurrPage.SETSELECTIONFILTER(FromSalesInvLine);
    end;
}

