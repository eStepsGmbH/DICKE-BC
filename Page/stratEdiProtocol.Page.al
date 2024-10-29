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
                field(Protocol; Rec.Protocol)
                {
                }
                field("List No."; Rec."List No.")
                {
                }
                field("Central Payer No."; Rec."Central Payer No.")
                {
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Document No."; Rec."Document No.")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Document Direction"; Rec."Document Direction")
                {
                }
                field("Edi Version"; Rec."Edi Version")
                {
                }
                field("Posted Date"; Rec."Posted Date")
                {
                }
                field("Posted Time"; Rec."Posted Time")
                {
                }
                field("Edi File Name"; Rec."Edi File Name")
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
                    Rec.RENAME(Rec."Document Type", Rec."Document No.", Rec.Status::Canceled, Rec."List No.");
                end;
            }
        }
    }
}

