tableextension 50053 tableextension50053 extends Contact
{

    //Unsupported feature: Property Modification (Permissions) on "Contact(Table 5050)".

    fields
    {
        modify(Image)
        {
            Caption = 'Image';
        }
        field(50000; "Partner No."; Code[20])
        {
            CalcFormula = Lookup("Contact Business Relation"."No." WHERE("Contact No." = FIELD("Company No.")));
            Caption = 'Partner Nr.';
            FieldClass = FlowField;

            trigger OnLookup()
            var
                ContactBusinessRelation: Record "5054";
                Customer: Record "18";
                Vendor: Record "23";
            begin
                ContactBusinessRelation.RESET;
                ContactBusinessRelation.SETRANGE("Contact No.", "Company No.");
                IF ContactBusinessRelation.FINDFIRST THEN
                    IF ContactBusinessRelation."Link to Table" = ContactBusinessRelation."Link to Table"::Customer THEN BEGIN
                        IF Customer.GET(ContactBusinessRelation."No.") THEN
                            PAGE.RUN(21, Customer)
                        ELSE
                            ERROR('Debitor mit der Nummer %1 existiert nicht.', ContactBusinessRelation."No.");
                    END;
                IF ContactBusinessRelation."Link to Table" = ContactBusinessRelation."Link to Table"::Vendor THEN BEGIN
                    IF Vendor.GET(ContactBusinessRelation."No.") THEN
                        PAGE.RUN(26, Vendor)
                    ELSE
                        ERROR('Kreditor mit der Nummer %1 existiert nicht.', ContactBusinessRelation."No.");
                END;
            end;
        }
    }
    procedure GetCustomerNo("Contact No.": Code[20]): Code[20]
    var
        Contact: Record "5050";
        ContactBusinessRelation: Record "5054";
    begin
        IF Contact.GET("Contact No.") THEN BEGIN
            ContactBusinessRelation.RESET;
            IF Contact.Type = Contact.Type::Company THEN BEGIN
                ContactBusinessRelation.SETRANGE("Contact No.", "Contact No.");
                IF ContactBusinessRelation.FINDFIRST THEN
                    EXIT(ContactBusinessRelation."No.");
            END;
            IF Contact.Type = Contact.Type::Person THEN BEGIN
                ContactBusinessRelation.SETRANGE("Contact No.", Contact."Company No.");
                IF ContactBusinessRelation.FINDFIRST THEN
                    EXIT(ContactBusinessRelation."No.");
            END;
        END;
    end;

    procedure GetPartnerName(): Text[50]
    var
        Customer: Record "18";
        Vendor: Record "23";
    begin
        IF Customer.GET("Partner No.") THEN
            EXIT(Customer.Name);
        IF Vendor.GET("Partner No.") THEN
            EXIT(Vendor."No.");
    end;
}

