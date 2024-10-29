pageextension 50108 pageextension50108 extends "Sales Order List"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Felder eingeblendet:
    //  - "Last Shipping No."
    //  - "VUO Creation Date"

    //Unsupported feature: Property Insertion (RefreshOnActivate) on ""Sales Order List"(Page 9305)".

    layout
    {
        addafter("Ship-to Code")
        {
            field("Last Shipping No."; Rec."Last Shipping No.")
            {
            }
            field("VUO Creation Date"; Rec."VUO Creation Date")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
    actions
    {
        addlast("processing")
        {
            action("Csv Export")
            {
                Caption = 'Csv Export';
                Ellipsis = true;
                Image = ExportReceipt;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //RunObject = Report 50094; TODO: REPORTS MISSING
                ToolTip = 'Exportiert die Auftragszeilen in eine CSV Datei, die den Vorgaben des Kunden Schlemmermeyer entspricht.';
            }
        }
    }


    //Unsupported feature: Code Modification on "ShowHeader(PROCEDURE 6)".

    //procedure ShowHeader();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    IF SkipLinesWithoutVAT AND (CashFlowManagement.GetTaxAmountFromSalesOrder(Rec) = 0) THEN
      EXIT(FALSE);

    EXIT(TRUE);
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    IF NOT SkipLinesWithoutVAT THEN
      EXIT(TRUE);

    EXIT(CashFlowManagement.GetTaxAmountFromSalesOrder(Rec) <> 0);
    */
    //end;
}

