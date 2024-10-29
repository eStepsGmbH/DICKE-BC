table 50000 "DIC Header Text"
{
    fields
    {
        field(1; Type; Option)
        {
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(2; "No."; Code[20])
        {
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FIELD(Type));
        }
        field(3; "Line No."; Integer)
        {
        }
        field(4; Text; Text[50])
        {
        }
    }
    keys
    {
        key(Key1; Type, "No.", "Line No.")
        {
            Clustered = true;
        }
    }
}

