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
                field("Customer No."; "Customer No.")
                {
                }
                field("EDI Document Type"; "EDI Document Type")
                {
                }
                field("stratEDI List Nos."; "stratEDI List Nos.")
                {
                }
                field("stratEDI Tolerance Days"; "stratEDI Tolerance Days")
                {
                }
                field("stratEDI Export Path"; "stratEDI Export Path")
                {
                }
                field("stratEDI Export Specifics"; "stratEDI Export Specifics")
                {
                }
                field(GLN; GLN)
                {
                }
            }
        }
    }

    actions
    {
    }
}

