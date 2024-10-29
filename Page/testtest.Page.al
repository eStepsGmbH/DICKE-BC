page 50010 "test test"
{
    PageType = List;
    SourceTable = "Permission Range";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type"; Rec."Object Type")
                {
                }
                field(Index; Rec.Index)
                {
                }
                field(From; Rec.From)
                {
                }
                field("To"; Rec."To")
                {
                }
                field("Read Permission"; Rec."Read Permission")
                {
                }
                field("Insert Permission"; Rec."Insert Permission")
                {
                }
                field("Modify Permission"; Rec."Modify Permission")
                {
                }
                field("Delete Permission"; Rec."Delete Permission")
                {
                }
                field("Execute Permission"; Rec."Execute Permission")
                {
                }
                field("Limited Usage Permission"; Rec."Limited Usage Permission")
                {
                }
            }
        }
    }

    actions
    {
    }
}

