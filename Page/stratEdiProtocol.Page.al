page 50071 "stratEdi Protocol"
{
    Caption = 'stratEdi Protocol';
    PageType = List;
    SourceTable = "stratEdi Protocol";
    SourceTableView = SORTING("List No.")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Protocol; Protocol)
                {
                }
                field("List No."; "List No.")
                {
                }
                field("Central Payer No."; "Central Payer No.")
                {
                }
                field("Document Type"; "Document Type")
                {
                }
                field("Document No."; "Document No.")
                {
                }
                field(Status; Status)
                {
                }
                field("Document Direction"; "Document Direction")
                {
                }
                field("Edi Version"; "Edi Version")
                {
                }
                field("Posted Date"; "Posted Date")
                {
                }
                field("Posted Time"; "Posted Time")
                {
                }
                field("Edi File Name"; "Edi File Name")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(BelegStornieren)
            {
                Caption = 'EDI stornieren';
                Image = ReopenCancelled;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.RENAME("Document Type", "Document No.", Status::Canceled, "List No.");
                end;
            }
        }
    }
}

