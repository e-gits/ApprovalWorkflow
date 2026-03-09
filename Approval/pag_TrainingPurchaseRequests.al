page 50251 "Training Purchase Requests"
{
    Caption = 'Training Purchase Requests';
    PageType = List;
    SourceTable = "Training Purchase Header";
    CardPageId = "Training Purchase Request";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Requests)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the training purchase request.';
                }

                field("Request Date"; Rec."Request Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the request was created.';
                }

                field("Requester User ID"; Rec."Requester User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created the request.';
                }

                field("Training Provider"; Rec."Training Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the training provider.';
                }

                field("Training Title"; Rec."Training Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the title of the training.';
                }

                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start date of the training.';
                }

                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end date of the training.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the approval status of the request.';
                    StyleExpr = StatusStyleExpr;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of the training request.';
                }

                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the purchase order created from this request.';
                }
            }
        }

        // area(FactBoxes)
        //{
        // systempart(Links; Links)
        // {
        //     ApplicationArea = All;
        //}
        //systempart(Notes; Notes)
        //{
        //  ApplicationArea = All;
        // }
        //  }
    }

    actions
    {
        area(Processing)
        {
            action(SendForApproval)
            {
                Caption = 'Send for Approval';
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Enabled = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                var
                    TrainingMgt: Codeunit "Training Request Management";
                begin
                    TrainingMgt.SendForApproval(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(Approve)
            {
                Caption = 'Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Enabled = (Rec.Status = Rec.Status::"Pending Approval") and IsApprover;

                trigger OnAction()
                var
                    TrainingMgt: Codeunit "Training Request Management";
                begin
                    TrainingMgt.Approve(Rec);
                    CurrPage.Update(false);
                end;
            }


            action(Reject)
            {
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Enabled = (Rec.Status = Rec.Status::"Pending Approval") and IsApprover;

                trigger OnAction()
                var
                    TrainingMgt: Codeunit "Training Request Management";
                begin
                    TrainingMgt.Reject(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(ViewPurchaseOrder)
            {
                Caption = 'View Purchase Order';
                Image = Document;
                ApplicationArea = All;
                Enabled = Rec."Purchase Order No." <> '';

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    if Rec."Purchase Order No." <> '' then begin
                        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, Rec."Purchase Order No.");
                        Page.Run(Page::"Purchase Order", PurchaseHeader);
                    end;
                end;
            }


        }



    }

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        IsApprover := false;
        if UserSetup.Get(UserId) then
            IsApprover := UserSetup."Training Approver";
    end;

    var
        IsApprover: Boolean;
        StatusStyleExpr: Text;

    local procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Open:
                StatusStyleExpr := 'Standard';
            Rec.Status::"Pending Approval":
                StatusStyleExpr := 'Ambiguous';
            Rec.Status::Approved:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Rejected:
                StatusStyleExpr := 'Unfavorable';
        end;
    end;
}
