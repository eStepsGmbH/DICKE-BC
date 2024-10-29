// codeunit 104010 "Test Item References"
// {

//     trigger OnRun()
//     var
//         Item: Record "Item";
//         SalesPrice: Record "7002";
//         ItemCrossReference: Record "Item Cross Reference";
//     begin

//         ItemCrossReference.DELETEALL;
//         SalesPrice.RESET;
//         SalesPrice.SETCURRENTKEY("Sales Type", "Sales Code", "Item No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
//         SalesPrice.SETRANGE("Sales Type", SalesPrice."Sales Type"::Customer);

//         // SalesLine.SETCURRENTKEY("Document Type","Sell-to Customer No.","Shipment No.");
//         // SalesLine.SETRANGE("Document Type",SalesLine."Document Type"::Order);
//         // // SalesLine.SETRANGE("Sell-to Customer No.",'00001');
//         // SalesLine.SETRANGE(Type,SalesLine.Type::Item);
//         SalesPrice.SETFILTER("Item No.", '<>%1', '');
//         IF SalesPrice.FINDSET THEN
//             REPEAT
//                 ItemCrossReference.INIT;
//                 ItemCrossReference."Item No." := SalesPrice."Item No.";
//                 Item.GET(SalesPrice."Item No.");
//                 IF Item."Sales Unit of Measure" = '' THEN
//                     ItemCrossReference."Unit of Measure" := Item."Base Unit of Measure"
//                 ELSE
//                     ItemCrossReference."Unit of Measure" := Item."Sales Unit of Measure";
//                 ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::Customer;
//                 ItemCrossReference."Cross-Reference Type No." := SalesPrice."Sales Code";
//                 ItemCrossReference."Cross-Reference No." := SalesPrice."Item No.";
//                 ItemCrossReference.Description := Item.Description;
//                 IF ItemCrossReference.INSERT(TRUE) THEN;
//             UNTIL SalesPrice.NEXT = 0;

//         MESSAGE('Fertig!');
//     end;
// }

