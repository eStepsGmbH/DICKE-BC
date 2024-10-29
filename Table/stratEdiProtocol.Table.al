table 50004 "stratEdi Protocol"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------

    Caption = 'stratEdi Protokoll';

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Invoice,Cr. Memo,Order,Shipment';
            OptionMembers = Invoice,"Credit Memo","Order",Shipment;
        }
        field(2; "Document No."; Code[30])
        {
            Caption = 'Belegnr.';
        }
        field(3; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Posted,Canceled';
            OptionMembers = Posted,Canceled;
        }
        field(4; "Document Direction"; Option)
        {
            Caption = 'Belegrichtung';
            OptionCaption = 'Incoming,Outgoing';
            OptionMembers = Eingehend,Ausgehend;
        }
        field(5; "Edi Version"; Code[20])
        {
            Caption = 'Edi Version';
        }
        field(6; "List No."; Code[10])
        {
            Caption = 'Listen Nummer';
        }
        field(7; "Posted Date"; Date)
        {
            Caption = 'Sendedatum';
        }
        field(8; "Posted Time"; Time)
        {
            Caption = 'Sendezeit';
        }
        field(9; "Edi File Name"; Text[100])
        {
            Caption = 'Edi Dateiname';
        }
        field(10; "Receive Date"; Date)
        {
            Caption = 'Empfangsdatum';
        }
        field(11; "Receive Time"; Time)
        {
            Caption = 'Empfagszeit';
        }
        field(12; "Central Payer No."; Code[20])
        {
            Caption = 'Zentralregulierer';
            TableRelation = Customer."No." WHERE("Is Central Payer" = CONST(true));
        }
        field(13; Protocol; Text[30])
        {
            Caption = 'Protokoll';
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", Status, "List No.")
        {
            Clustered = true;
        }
        key(Key2; "List No.")
        {
        }
    }
}

