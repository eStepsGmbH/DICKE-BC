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
                field(Company; Company)
                {
                }
                field(Location; Location)
                {
                }
                field(Pickup; Pickup)
                {
                }
                field("Shipment No."; "Shipment No.")
                {
                }
                field("Customer No."; "Customer No.")
                {
                }
                field("Customer Name"; "Customer Name")
                {
                }
                field(Address; Address)
                {
                }
                field("Post Code"; "Post Code")
                {
                }
                field(City; City)
                {
                }
                field(Package; Package)
                {
                }
                field(Quantity; Quantity)
                {
                }
                field(Route; Route)
                {
                }
                field(Day; Day)
                {
                    Visible = false;
                }
            }
        }
    }
}

