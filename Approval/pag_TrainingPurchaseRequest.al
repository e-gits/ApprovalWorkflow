page 50250 "Training Purchase Request"
{
    Caption = 'Training Purchase Request';
    PageType = Document;
    SourceTable = "Training Purchase Header";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = PageEditable;

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the training purchase request.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }

                field("Requester User ID"; Rec."Requester User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created the request.';
                }

                field("Request Date"; Rec."Request Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the request was created.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the approval status of the request.';
                    StyleExpr = StatusStyleExpr;
                }

                field("Training Provider"; Rec."Training Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the training provider.';
                }

                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor number for the training provider.';
                }

                field("Training Title"; Rec."Training Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the title of the training.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the training.';
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

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of the training request.';
                }
            }

            part(Lines; "Training Purchase Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
                Editable = PageEditable;
            }

            group("Approval Information")
            {
                Caption = 'Approval Information';
                Visible = Rec.Status <> Rec.Status::Open;

                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who approved the request.';
                }

                field("Approved Date"; Rec."Approved Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the request was approved.';
                }

                field("Rejected By"; Rec."Rejected By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who rejected the request.';
                }

                field("Rejected Date"; Rec."Rejected Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the request was rejected.';
                }

                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason for rejection.';
                    MultiLine = true;
                    Editable = Rec.Status = Rec.Status::"Pending Approval";
                }

                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the purchase order created from this request.';
                }
            }
        }
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
                PromotedIsBig = true;
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
                PromotedIsBig = true;
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
                PromotedIsBig = true;
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

            action(Reopen)
            {
                Caption = 'Reopen';
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Enabled = (Rec.Status = Rec.Status::Rejected) and IsApprover;

                trigger OnAction()
                var
                    TrainingMgt: Codeunit "Training Request Management";
                begin
                    TrainingMgt.Reopen(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(ViewPurchaseOrder)
            {
                Caption = 'View Purchase Order';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Enabled = Rec."Purchase Order No." <> '';

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header"; //record variable of purchase header
                begin
                    if Rec."Purchase Order No." <> '' then begin
                        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, Rec."Purchase Order No.");
                        Page.Run(Page::"Purchase Order", PurchaseHeader);
                    end;
                end;

                //“Get the Purchase Header where Document Type = Order and No. = this Purchase Order No.”
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetControlVisibility();
    end;

    trigger OnOpenPage()
    begin
        SetControlVisibility();
    end;

    var
        PageEditable: Boolean;
        IsApprover: Boolean;
        StatusStyleExpr: Text;

    local procedure SetControlVisibility()
    var
        UserSetup: Record "User Setup";
    begin
        PageEditable := Rec.IsEditable();
//able to call Rec here becasue procedure is defined on same table as Rec
        IsApprover := false;
        if UserSetup.Get(UserId) then
            IsApprover := UserSetup."Training Approver";

        // status color



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
