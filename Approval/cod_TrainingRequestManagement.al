codeunit 50250 "Training Request Management"
{


    procedure SendForApproval(var TrainingHeader: Record "Training Purchase Header")
    var
        TrainingLine: Record "Training Purchase Line";
    begin

        TrainingHeader.TestField("Training Provider");
        TrainingHeader.TestField("Training Title");
        TrainingHeader.TestField("Start Date");
        TrainingHeader.TestField("Vendor No.");


        TrainingLine.SetRange("Document No.", TrainingHeader."No.");
        if not TrainingLine.FindFirst() then
            Error('You must add at least one line before sending for approval.');


        if TrainingHeader.Status <> TrainingHeader.Status::Open then
            Error('Only requests with status Open can be sent for approval.');


        TrainingHeader.Status := TrainingHeader.Status::"Pending Approval";
        TrainingHeader.Modify();

        Message('Training request %1 has been sent for approval.', TrainingHeader."No.");
    end;

    procedure Approve(var TrainingHeader: Record "Training Purchase Header")
    var
        UserSetup: Record "User Setup";
    begin

        if not UserSetup.Get(UserId) then
            Error('User setup not found for current user.');

        if not UserSetup."Training Approver" then
            Error('You do not have permission to approve training requests.');


        if TrainingHeader.Status <> TrainingHeader.Status::"Pending Approval" then
            Error('Only requests with status Pending Approval can be approved.');


        TrainingHeader.Status := TrainingHeader.Status::Approved;
        TrainingHeader."Approved By" := UserId;
        TrainingHeader."Approved Date" := CurrentDateTime;
        TrainingHeader.Modify();


        CreatePurchaseOrder(TrainingHeader);

        Message('Training request %1 has been approved and Purchase Order %2 has been created.',
            TrainingHeader."No.", TrainingHeader."Purchase Order No.");
    end;

    procedure Reject(var TrainingHeader: Record "Training Purchase Header")
    var
        UserSetup: Record "User Setup";
        RejectionReason: Text[250];
    begin

        if not UserSetup.Get(UserId) then
            Error('User setup not found for current user.');

        if not UserSetup."Training Approver" then
            Error('You do not have permission to reject training requests.');

        if TrainingHeader.Status <> TrainingHeader.Status::"Pending Approval" then
            Error('Only requests with status Pending Approval can be rejected.');


        RejectionReason := TrainingHeader."Rejection Reason";
        if not Confirm('Do you want to reject this training request?', false) then
            exit;


        TrainingHeader.Status := TrainingHeader.Status::Rejected;
        TrainingHeader."Rejected By" := UserId;
        TrainingHeader."Rejected Date" := CurrentDateTime;
        TrainingHeader.Modify();

        Message('Training request %1 has been rejected.', TrainingHeader."No.");
    end;

    procedure Reopen(var TrainingHeader: Record "Training Purchase Header")
    var
        UserSetup: Record "User Setup";
    begin

        if not UserSetup.Get(UserId) then
            Error('User setup not found for current user.');

        if not UserSetup."Training Approver" then
            Error('You do not have permission to reopen training requests.');


        if TrainingHeader.Status <> TrainingHeader.Status::Rejected then
            Error('Only rejected requests can be reopened.');


        TrainingHeader.Status := TrainingHeader.Status::Open;
        Clear(TrainingHeader."Rejected By");
        Clear(TrainingHeader."Rejected Date");
        TrainingHeader."Rejection Reason" := '';
        TrainingHeader.Modify();

        Message('Training request %1 has been reopened.', TrainingHeader."No.");
    end;

    local procedure CreatePurchaseOrder(var TrainingHeader: Record "Training Purchase Header")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TrainingLine: Record "Training Purchase Line";
        LineNo: Integer;
    begin

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Insert(true);

        PurchaseHeader.Validate("Buy-from Vendor No.", TrainingHeader."Vendor No.");
        // Set Buy-from Vendor No. to whatever "Vendor No" is stored in my Training Header, 
        //and run all the OnValidate logic for that field

        PurchaseHeader.Validate("Order Date", Today);

        PurchaseHeader."Posting Date" := Today;
        PurchaseHeader."Expected Receipt Date" := TrainingHeader."Start Date";

        PurchaseHeader.Modify();

        TrainingLine.SetRange("Document No.", TrainingHeader."No.");
        if TrainingLine.FindSet() then begin
            LineNo := 10000;
            repeat

                PurchaseLine.Init();
                PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                PurchaseLine."Document No." := PurchaseHeader."No.";
                PurchaseLine."Line No." := LineNo;

                PurchaseLine.Insert(true);

                //direct assignment through insert skips business logic on validate
                //No. is generated by the OnInsert trigger and is not known until after Insert(true)
                PurchaseLine.Validate(Type, TrainingLine.Type);
                PurchaseLine.Validate("No.", TrainingLine."No.");
                PurchaseLine.Validate(Description, TrainingLine.Description);
                PurchaseLine.Validate(Quantity, TrainingLine.Quantity);
                PurchaseLine.Validate("Direct Unit Cost", TrainingLine."Unit Cost");




                if TrainingLine."Employee No." <> '' then
                    PurchaseLine.Description := PurchaseLine.Description +
                        ' - Employee: ' + TrainingLine."Employee No.";

                PurchaseLine.Modify();

                LineNo += 10000;
            until TrainingLine.Next() = 0;
        end;


        TrainingHeader."Purchase Order No." := PurchaseHeader."No.";
        TrainingHeader.Modify();

        Commit();
    end;
}

