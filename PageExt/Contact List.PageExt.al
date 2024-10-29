pageextension 50059 pageextension50059 extends "Contact List"
{
    layout
    {
        addafter("Business Relation")
        {
            field("Organizational Level Code"; "Organizational Level Code")
            {
            }
            field("Salutation Code"; "Salutation Code")
            {
            }
            field("Partner No."; "Partner No.")
            {
            }
            field("Partner Name"; GetPartnerName())
            {
                Caption = 'Partner Name';
            }
        }
    }
}

