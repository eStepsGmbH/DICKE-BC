page 50004 "Sales Line Quick Entry"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Page erstellt.
    //  - DIC01   26.04.2023  Add Fields: - "Shipment Date"
    //                                    - "Promised Delivery Date"
    //                                    - "Coli"

    AutoSplitKey = true;
    Caption = 'Sales Line Quick Entry';
    DataCaptionExpression = SetPageCaption;
    PageType = ListPlus;
    SourceTable = "Sales Line Quick Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; "Document No.")
                {
                    QuickEntry = false;
                }
                field("Item No."; "Item No.")
                {
                }
                field(Quantity; Quantity)
                {
                    DecimalPlaces = 2 : 3;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    QuickEntry = false;
                }
                field(Description; Description)
                {
                    QuickEntry = false;
                }
                field("Minimum Durability"; "Minimum Durability")
                {
                }
                field("Shipment Date"; "Shipment Date")
                {
                }
                field("Promised Delivery Date"; "Promised Delivery Date")
                {
                }
                field(Coli; Coli)
                {
                }
                field("External Document No."; "External Document No.")
                {
                }
                field("Order No."; "Order No.")
                {
                }
                field("<Description 1>"; Description)
                {
                }
                field("Description 2"; "Description 2")
                {
                    ShowCaption = false;
                }

            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("F&unktion")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(AddLinesToOrder)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Add Lines';
                    Image = ReleaseDoc;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = New;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    //The property 'PromotedOnly' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedOnly = true;
                    ShortCutKey = 'F12';
                    ToolTip = 'Hiermit können Sie die erfassten Zeilen in den VK-Auftrag übernehmen.';

                    trigger OnAction()
                    begin
                        IF AddLinesToSalesOrder(Rec) THEN
                            CurrPage.CLOSE;
                    end;
                }
                action("Referenzen auswählen")
                {
                    Caption = 'Referenzen auswählen';
                    Image = Change;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+F12';

                    trigger OnAction()
                    begin
                        SalesLineRefQuickEntry.SetSalesHeader(SalesHeader);
                        SalesLineRefQuickEntry.RUNMODAL;
                        CLEAR(SalesLineRefQuickEntry);
                    end;
                }
                action("Lieferzeilen von Mandant holen")
                {
                    Caption = 'Get Shipment Lines from other Company';
                    Ellipsis = true;
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+F11';

                    trigger OnAction()
                    begin
                        IF AddShipLinesFromOtherCompany(Rec) THEN
                            CurrPage.UPDATE;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SETRANGE("User ID", USERID);
        Rec.SETRANGE("Document No.", SalesHeader."No.");
        CurrPage.UPDATE(FALSE);
    end;

    var
        SalesHeader: Record "Sales Header";
        SalesLineRefQuickEntry: Page "50005";
        CustomerNo: Code[20];
        ShipmentCode: Code[10];

    local procedure SetPageCaption(): Text[100]
    begin
        EXIT(STRSUBSTNO('%1  %2 - %3 - %4', "Document No.", SalesHeader."Sell-to Customer Name", SalesHeader."Sell-to Address", SalesHeader."Sell-to City"));
    end;

    [Scope('Internal')]
    procedure SetSalesHeader(var NewSalesHeader: Record "Sales Header")
    begin
        NewSalesHeader.TESTFIELD("Document Type", SalesHeader."Document Type"::Order);
        NewSalesHeader.TESTFIELD("No.");
        NewSalesHeader.TESTFIELD("Sell-to Customer No.");
        SalesHeader := NewSalesHeader;
    end;
}

