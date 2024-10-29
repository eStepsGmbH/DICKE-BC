report 50081 "Load Option Strings"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Report erstellt.

    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem(Field; "Field")
        {
            DataItemTableView = SORTING(TableNo, "No.")
                                WHERE(Type = CONST(Option));
            column(Field_TableNo; TableNo)
            {
            }
            column(Field__No__; "No.")
            {
            }
            column(Field_TableName; TableName)
            {
            }
            column(Field_Type; Type)
            {
            }
            column(gtxtoutString; gtxtoutString)
            {
            }
            column(Field_TableNoCaption; FIELDCAPTION(TableNo))
            {
            }
            column(Field__No__Caption; FIELDCAPTION("No."))
            {
            }
            column(Field_TableNameCaption; FIELDCAPTION(TableName))
            {
            }
            column(Field_TypeCaption; FIELDCAPTION(Type))
            {
            }

            trigger OnAfterGetRecord()
            begin

                gtxtString := '';
                gtxtoutString := '';
                gintSQLVal := 0;

                CLEAR(OptionStrings);
                OptionStrings.TableNo := TableNo;
                OptionStrings."No." := "No.";
                OptionStrings.TableName := TableName;
                OptionStrings.FieldName := FieldName;
                OptionStrings."Field Caption" := "Field Caption";

                //Get the option string
                gtxtString := gfunOptionValues(TableNo, "No.");

                //Send copy to report output
                gtxtoutString := gtxtString;

                //Loop through full option string and assign each value to incrementing SQL value
                WHILE STRLEN(gtxtString) <> 0 DO BEGIN

                    gintoptionLength := STRPOS(gtxtString, ',');
                    IF gintoptionLength = 0 THEN BEGIN
                        gtxtOptionValue := gtxtString;
                        gtxtString := DELSTR(gtxtString, 1, STRLEN(gtxtString));
                    END ELSE BEGIN
                        gtxtOptionValue := COPYSTR(gtxtString, 1, gintoptionLength);
                        gtxtOptionValue := DELCHR(gtxtOptionValue, '=', ',');
                        IF gtxtOptionValue = ' ' THEN
                            gtxtOptionValue := '';
                        gtxtString := DELSTR(gtxtString, 1, gintoptionLength);
                    END;

                    OptionStrings.OptionString := gtxtOptionValue;
                    OptionStrings.FieldInteger := gintSQLVal;
                    OptionStrings.INSERT;
                    gintSQLVal += 1;
                END;
            end;

            trigger OnPreDataItem()
            begin

                OptionStrings.DELETEALL;
                Field.SETFILTER(TableNo, '18|23|27|32|5802|7002|7004|7012|7014');
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

    trigger OnPostReport()
    begin
        MESSAGE(MsgFinish);
    end;

    var
        OptionStrings: Record "50003";
        gtxtString: Text;
        gtxtoutString: Text;
        gtxtOptionValue: Text;
        gintSQLVal: Integer;
        gintoptionLength: Integer;
        gintoptionLengthTotal: Integer;
        MsgFinish: Label 'Process finished!';

    [Scope('Internal')]
    procedure gfunOptionValues(TableNum: Integer; FieldNum: Integer): Text
    var
        lrecordRef: RecordRef;
        lfieldRef: FieldRef;
        loptionString: Text;
    begin
        CLEAR(loptionString);
        CLEAR(lfieldRef);
        lrecordRef.OPEN(TableNum);
        lfieldRef := lrecordRef.FIELD(FieldNum);
        loptionString := lfieldRef.OPTIONCAPTION;
        lrecordRef.CLOSE;
        EXIT(loptionString);
    end;
}

