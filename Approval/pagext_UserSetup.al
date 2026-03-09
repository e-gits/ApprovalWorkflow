pageextension 50250 "User Setup Page Extension" extends "User Setup"
{
    layout
    {
        addafter("Allow Posting To")
        {
            field("Training Approver"; Rec."Training Approver")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the user can approve training purchase requests.';
            }
        }
    }
}
