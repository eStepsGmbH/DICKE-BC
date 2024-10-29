pageextension 50030 pageextension50030 extends "Customer List"
{
    //  --------------------------------------------------------------------------------
    //  Dicke
    //  --------------------------------------------------------------------------------
    //  - Felder "Bill-to Customer No.", "Address" und "City" hinzugefügt.
    //  - Feld 50070 "Export Dischinger" hinzugefügt.
    //  - Feld 50071 "Location Entry for Dischinger" hinzugefügt.
    //  - Feld 50072 "Extended Text" hinzugefügt.
    //  - Feld 50073 "Central Payer" hinzugefügt.
    //  - Feld    90 "GLN" hinzugefügt.

    //Unsupported feature: Property Insertion (RefreshOnActivate) on ""Customer List"(Page 22)".

    layout
    {
        addlast(content)
        {
            field(Address; Rec.Address)
            {
                ApplicationArea = Basic, Suite;
            }
            field(City; Rec.City)
            {
                ApplicationArea = Basic, Suite;
            }
            field("Export Dischinger"; Rec."Export Dischinger")
            {
                Visible = false;
            }
            field("Location for Dischinger"; Rec."Location for Dischinger")
            {
                Visible = false;
            }
            field("Bill-to Customer No."; Rec."Bill-to Customer No.")
            {
            }
            field("Extended Text"; Rec."Extended Text")
            {
                Visible = false;
            }
            field("Central Payer"; Rec."Central Payer")
            {
            }
            field(GLN; Rec.GLN)
            {
            }
        }
    }
    actions
    {


        //Unsupported feature: Code Modification on "CreateApprovalWorkflow(Action 15).OnAction".

        //trigger OnAction()
        //Parameters and return type have not been exported.
        //>>>> ORIGINAL CODE:
        //begin
        /*
        PAGE.RUNMODAL(PAGE::"Cust. Approval WF Setup Wizard");
        SetWorkflowManagementEnabledState;
        */
        //end;
        //>>>> MODIFIED CODE:
        //begin
        /*
        PAGE.RUNMODAL(PAGE::"Cust. Approval WF Setup Wizard");
        */
        //end;


        //Unsupported feature: Code Modification on "ManageApprovalWorkflows(Action 13).OnAction".

        //trigger OnAction()
        //Parameters and return type have not been exported.
        //>>>> ORIGINAL CODE:
        //begin
        /*
        WorkflowManagement.NavigateToWorkflows(DATABASE::Customer,EventFilter);
        SetWorkflowManagementEnabledState;
        */
        //end;
        //>>>> MODIFIED CODE:
        //begin
        /*
        WorkflowManagement.NavigateToWorkflows(DATABASE::Customer,EventFilter);
        */
        //end;
    }


    //Unsupported feature: Code Modification on "OnAfterGetCurrRecord".

    //trigger OnAfterGetCurrRecord()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    SetSocialListeningFactboxVisibility;

    CRMIsCoupledToRecord :=
      CRMCouplingManagement.IsRecordCoupledToCRM(RECORDID) AND CRMIntegrationEnabled;
    OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RECORDID);

    CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(RECORDID);
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #1..7

    SetWorkflowManagementEnabledState;
    */
    //end;
}

