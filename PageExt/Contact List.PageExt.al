pageextension 50059 pageextension50059 extends "Contact List"
{
    layout
    {
        addafter("Business Relation")
        {
            field("Organizational Level Code"; Rec."Organizational Level Code")
            {
            }
            field("Salutation Code"; Rec."Salutation Code")
            {
            }
            field("Partner No."; Rec."Partner No.")
            {
            }
            field("Partner Name"; Rec.GetPartnerName())
            {
                Caption = 'Partner Name';
            }
        }
    }
}

