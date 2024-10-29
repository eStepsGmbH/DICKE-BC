tableextension 50055 tableextension50055 extends "Sales Header Archive"
{
    //  --------------------------------------------------------------------------------
    //  No.   SC-No.    Date     Sign   Description
    //  --------------------------------------------------------------------------------
    //  DI01            24.07.18 est.uk Add field: "Shipment Date Shipping Agent" (Date)
    fields
    {
        field(50075; "Shipment Date Shipping Agent"; Date)
        {
            Caption = 'Warenausgangsdatum Zusteller';
        }
        field(50076; "Source Company"; Text[100])
        {
            Caption = 'Source Company';
            TableRelation = Company.Name;
        }
        field(50077; "Source Order No."; Code[20])
        {
            Caption = 'No.';
        }
    }
}

