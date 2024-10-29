page 50002 "Export Dischinger"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  Page erstellt.

    PageType = List;
    SourceTable = "Export Dischinger";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Company; Rec.Company)
                {
                }
                field(Location; Rec.Location)
                {
                }
                field(Pickup; Rec.Pickup)
                {
                }
                field("Shipment No."; Rec."Shipment No.")
                {
                }
                field("Customer No."; Rec."Customer No.")
                {
                }
                field("Customer Name"; Rec."Customer Name")
                {
                }
                field(Address; Rec.Address)
                {
                }
                field("Post Code"; Rec."Post Code")
                {
                }
                field(City; Rec.City)
                {
                }
                field(Package; Rec.Package)
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field(Route; Rec.Route)
                {
                }
                field(Day; Rec.Day)
                {
                    Visible = false;
                }
            }
        }
    }
}

