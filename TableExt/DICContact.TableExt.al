tableextension 50053 "DIC Contact" extends Contact
{
    fields
    {
        field(50000; "Partner No."; Code[20])
        {
            CalcFormula = Lookup("Contact Business Relation"."No." WHERE("Contact No." = FIELD("Company No.")));
            Caption = 'Partner Nr.';
            FieldClass = FlowField;

            trigger OnLookup()
            var
                ContactBusinessRelation: Record "Contact Business Relation";
                Customer: Record "Customer";
                Vendor: Record "Vendor";
            begin
                ContactBusinessRelation.RESET();
                ContactBusinessRelation.SETRANGE("Contact No.", "Company No.");
                IF ContactBusinessRelation.FINDFIRST() THEN
                    IF ContactBusinessRelation."Link to Table" = ContactBusinessRelation."Link to Table"::Customer THEN
                        IF Customer.GET(ContactBusinessRelation."No.") THEN
                            PAGE.RUN(Page::"Customer Card", Customer)
                        ELSE
                            ERROR('Debitor mit der Nummer %1 existiert nicht.', ContactBusinessRelation."No.");
                IF ContactBusinessRelation."Link to Table" = ContactBusinessRelation."Link to Table"::Vendor THEN
                    IF Vendor.GET(ContactBusinessRelation."No.") THEN
                        PAGE.RUN(Page::"Vendor Card", Vendor)
                    ELSE
                        ERROR('Kreditor mit der Nummer %1 existiert nicht.', ContactBusinessRelation."No.");
            end;
        }
    }
    procedure GetCustomerNo("Contact No.": Code[20]): Code[20]
    var
        Contact: Record "5050";
        ContactBusinessRelation: Record "5054";
    begin
        IF Contact.GET("Contact No.") THEN BEGIN
            ContactBusinessRelation.RESET();
            IF Contact.Type = Contact.Type::Company THEN BEGIN
                ContactBusinessRelation.SETRANGE("Contact No.", "Contact No.");
                IF ContactBusinessRelation.FINDFIRST() THEN
                    EXIT(ContactBusinessRelation."No.");
            END;
            IF Contact.Type = Contact.Type::Person THEN BEGIN
                ContactBusinessRelation.SETRANGE("Contact No.", Contact."Company No.");
                IF ContactBusinessRelation.FINDFIRST() THEN
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

