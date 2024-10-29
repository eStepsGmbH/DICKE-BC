page 50005 "Sales Line Ref. Quick Entry"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Page erstellt.

    Caption = 'Sales Line Ref. Quick Entry';
    PageType = ListPlus;
    SourceTable = "Item Reference";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Selected; Rec.Selected)
                {
                }
                field("Cross-Reference No."; Rec."Reference No.")
                {
                }
                field("Item No."; Rec."Item No.")
                {
                    Visible = false;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Cross-Reference Type"; Rec."Reference Type")
                {
                    Visible = false;
                }
                field("Cross-Reference Type No."; Rec."Reference Type No.")
                {
                    Visible = false;
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
                action(AddLinesToQuickEntries)
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
                        Rec.SETRANGE(Selected, TRUE);
                        IF Rec.FINDSET() THEN BEGIN
                            SalesLineQuickEntry.SETRANGE("User ID", USERID);
                            SalesLineQuickEntry.SETRANGE("Document No.", SalesHeader."No.");
                            IF SalesLineQuickEntry.FINDLAST() THEN
                                ActualLineNo := SalesLineQuickEntry."Line No.";
                            REPEAT
                                ActualLineNo += 10000;
                                Item.GET(Rec."Item No.");
                                SalesLineQuickEntry.INIT();
                                SalesLineQuickEntry."Document No." := SalesHeader."No.";
                                SalesLineQuickEntry."User ID" := USERID;
                                SalesLineQuickEntry."Line No." := ActualLineNo;
                                SalesLineQuickEntry."Item No." := Rec."Item No.";
                                SalesLineQuickEntry.Description := Rec.Description;
                                SalesLineQuickEntry."Description 2" := Item."Description 2";
                                SalesLineQuickEntry.Quantity := 1;
                                SalesLineQuickEntry."Unit of Measure" := Rec."Unit of Measure";
                                SalesLineQuickEntry."Customer No." := SalesHeader."Sell-to Customer No.";
                                SalesLineQuickEntry.INSERT();
                            UNTIL Rec.NEXT() = 0;
                        END;
                        CurrPage.CLOSE();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin

        ItemCrossReference.SETRANGE("Reference Type", ItemCrossReference."Reference Type"::Customer);
        ItemCrossReference.SETRANGE("Reference Type No.", SalesHeader."Sell-to Customer No.");
        IF ItemCrossReference.FINDSET() THEN
            REPEAT
                Rec := ItemCrossReference;
                Rec.INSERT();
            UNTIL ItemCrossReference.NEXT() = 0;

        CurrPage.UPDATE(FALSE);
    end;

    var
        Item: Record "27";
        ItemCrossReference: Record "Item Reference";
        SalesHeader: Record "Sales Header";
        SalesLineQuickEntry: Record "Sales Line Quick Entry";
        ActualLineNo: Integer;

    local procedure SetPageCaption(): Text[100]
    begin
        EXIT(STRSUBSTNO('%1  %2 - %3 - %4', SalesHeader."No.", SalesHeader."Sell-to Customer Name", SalesHeader."Sell-to Address", SalesHeader."Sell-to City"));
    end;


    procedure SetSalesHeader(var NewSalesHeader: Record "Sales Header")
    begin
        NewSalesHeader.TESTFIELD("Document Type", SalesHeader."Document Type"::Order);
        NewSalesHeader.TESTFIELD("No.");
        NewSalesHeader.TESTFIELD("Sell-to Customer No.");
        SalesHeader := NewSalesHeader;
    end;
}

