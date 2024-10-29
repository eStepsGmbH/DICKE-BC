page 50006 "stratEdi Setup"
{
    PageType = List;
    SourceTable = "stratEdi Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.")
                {
                }
                field("EDI Document Type"; Rec."EDI Document Type")
                {
                }
                field("stratEDI List Nos."; Rec."stratEDI List Nos.")
                {
                }
                field("stratEDI Tolerance Days"; Rec."stratEDI Tolerance Days")
                {
                }
                field("stratEDI Export Path"; Rec."stratEDI Export Path")
                {
                }
                field("stratEDI Export Specifics"; Rec."stratEDI Export Specifics")
                {
                }
                field(GLN; Rec.GLN)
                {
                }
            }
        }
    }

    actions
    {
    }
}

