report 50078 "Create Purchase Price List1"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  jau: Objekt kann jederzeit gelöscht werden!

    ProcessingOnly = true;

    dataset
    {
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
        IF PurchasePrice.COUNT > 0 THEN
            ERROR(FORMAT(PurchasePrice.COUNT));

        IF Item.FINDSET THEN
            REPEAT
                IF Item."Vendor No." <> '' THEN BEGIN
                    IF Item."Standard Cost" <> 0 THEN BEGIN
                        IF Vendor.GET(Item."Vendor No.") THEN BEGIN
                            PurchasePrice.INIT;
                            PurchasePrice.VALIDATE("Item No.", Item."No.");
                            PurchasePrice.VALIDATE("Vendor No.", Item."Vendor No.");
                            PurchasePrice."Direct Unit Cost" := Item."Standard Cost";
                            PurchasePrice.VALIDATE("Starting Date", 20150101D);
                            PurchasePrice."Unit of Measure Code" := Item."Base Unit of Measure";
                            PurchasePrice.INSERT;
                            i += 1;
                        END;
                    END;
                END;
            UNTIL Item.NEXT = 0;
        MESSAGE('fertig! Es wurden %1 Einträge erzeugt.', i);
    end;

    var
        PurchasePrice: Record "7012";
        Item: Record "Item";
        Vendor: Record "Vendor";
        i: Integer;
}

