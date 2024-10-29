table 50005 "stratEdi Setup"
{
    // est01  14.12.2021 Add DocumentType: "Liefer Avis"

    Caption = 'stratEdi Setup';
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = IF ("EDI Document Type" = FILTER(<> Lieferavis)) Customer WHERE("Is Central Payer" = CONST(true))
            ELSE IF ("EDI Document Type" = CONST(Lieferavis)) Customer;
        }
        field(2; "EDI Document Type"; Option)
        {
            Caption = 'EDI Belegart';
            OptionCaption = 'Rechnungen,Gutschriften,Rech. und Gutschr.,Aufträge,Lieferavis';
            OptionMembers = Rechnungen,Gutschriften,"Rech. und Gutschr.","Aufträge",Lieferavis;
        }
        field(3; "stratEDI List Nos."; Code[10])
        {
            Caption = 'Posted Shipment Nos.';
            TableRelation = "No. Series";
        }
        field(4; "stratEDI Tolerance Days"; Integer)
        {
            Caption = 'stratEDI Karenztage';
        }
        field(5; "stratEDI Export Path"; Text[250])
        {
            Caption = 'stratEDI Export Pfadangabe';
        }
        field(6; "stratEDI Export Specifics"; Option)
        {
            Caption = 'stratEDI Export Besonderheiten';
            OptionCaption = 'REWE,EDEKA,KIRN, ';
            OptionMembers = REWE,EDEKA,KIRN," ";
        }
        field(7; GLN; Code[13])
        {
            Caption = 'GLN';
            Numeric = true;

            trigger OnValidate()
            var
                GLNCalculator: Codeunit "1607";
            begin
                IF GLN <> '' THEN
                    GLNCalculator.AssertValidCheckDigit13(GLN);
            end;
        }
    }

    keys
    {
        key(Key1; "Customer No.", "EDI Document Type")
        {
            Clustered = true;
        }
    }
}

