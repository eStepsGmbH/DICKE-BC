codeunit 70001 TransferData
{

    trigger OnRun()
    var
        Customer: Record "Customer";
    begin

        IF TableDataTransfer_.FINDSET THEN
            REPEAT
                TransferData(TableDataTransfer_.TableFrom, TableDataTransfer_.TableTo);
            UNTIL TableDataTransfer_.NEXT = 0;

        MESSAGE('fertig');
    end;

    var
        DestRecRef: RecordRef;
        SourceRecRef: RecordRef;
        FieldRefSource: FieldRef;
        FldRef: FieldRef;
        TempField: Record "2000000041" temporary;
        FieldsToTransfer: Record "2000000026" temporary;
        FieldsSource: Record "2000000041";
        FieldsTarget: Record "2000000041";
        TableDataTransfer_: Record "79010";
        TransferVendorFrom40_lrec: Record "79000";
        TransferCustomerFrom40_lrec: Record "79001";
        TransferItemFrom40_lrec: Record "79002";
        TransferRecord: Boolean;

    local procedure TransferData(SourceTableID: Integer; TargetTableID: Integer)
    begin
        CLEAR(SourceRecRef);
        CLEAR(DestRecRef);
        FieldsToTransfer.DELETEALL;
        FieldsSource.RESET;
        FieldsSource.SETRANGE(TableNo, SourceTableID);
        FieldsSource.SETRANGE(Class, FieldsSource.Class::Normal);
        FieldsSource.SETRANGE(Enabled, TRUE);
        IF FieldsSource.FINDSET THEN
            REPEAT
                IF FieldsTarget.GET(TargetTableID, FieldsSource."No.") THEN // does the field exists in target table
                    IF (FieldsTarget.Class = FieldsSource.Class) AND
                        (FieldsTarget.Type = FieldsSource.Type) THEN BEGIN    // do I want to transfer the field. Add more test if needed..
                        FieldsToTransfer.Number := FieldsSource."No.";       // if so fill the field number into the fieldlist table
                        FieldsToTransfer.INSERT;
                    END;
            UNTIL FieldsSource.NEXT = 0;
        IF FieldsToTransfer.ISEMPTY THEN
            EXIT;   // No fields to the transferred

        SourceRecRef.OPEN(SourceTableID, FALSE, COMPANYNAME);

        DestRecRef.OPEN(TargetTableID, FALSE, COMPANYNAME);
        DestRecRef.DELETEALL; //jau
        IF SourceRecRef.FINDSET THEN
            REPEAT

                //Soll der Datensatz übernommen werden? >>>
                TransferRecord := TRUE;
                IF TargetTableID = 18 THEN BEGIN
                    FieldRefSource := SourceRecRef.FIELDINDEX(1);
                    IF NOT TransferCustomerFrom40_lrec.GET(FORMAT(FieldRefSource.VALUE)) THEN
                        TransferRecord := FALSE;
                END;
                IF TargetTableID = 23 THEN BEGIN
                    FieldRefSource := SourceRecRef.FIELDINDEX(1);
                    IF NOT TransferVendorFrom40_lrec.GET(FORMAT(FieldRefSource.VALUE)) THEN
                        TransferRecord := FALSE;
                END;
                IF TargetTableID = 27 THEN BEGIN
                    FieldRefSource := SourceRecRef.FIELDINDEX(1);
                    IF NOT TransferItemFrom40_lrec.GET(FORMAT(FieldRefSource.VALUE)) THEN
                        TransferRecord := FALSE;
                END;
                // <<<

                FieldsToTransfer.FINDSET;
                REPEAT     // Assign all fields
                    FldRef := DestRecRef.FIELD(FieldsToTransfer.Number);
                    FldRef.VALUE := SourceRecRef.FIELD(FieldsToTransfer.Number).VALUE;
                UNTIL FieldsToTransfer.NEXT = 0;

                IF TransferRecord THEN    //jau
                    DestRecRef.INSERT;                   // Insert then record

            UNTIL SourceRecRef.NEXT = 0;

        SourceRecRef.CLOSE;
        DestRecRef.CLOSE;
    end;
}

