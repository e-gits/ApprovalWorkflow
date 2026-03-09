codeunit 50251 "Sales Control Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    // local procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; SkipCheckReleaseRestrictions: Boolean)
    local procedure CheckQuantityOnRelease(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        BlockedReason: Text[250];
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine.Quantity > 100 then begin
                    BlockedReason := StrSubstNo('Line %1: Quantity %2 exceeds maximum 100', SalesLine."Line No.", SalesLine.Quantity);
                    LogBlockedAction(SalesHeader."No.", BlockedReason);
                    ShowNotification();
                    Error(BlockedReason);
                end;
            until SalesLine.Next() = 0;
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]

 //local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean)

    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        TotalAmount: Decimal;
        BlockedReason: Text[250];
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                TotalAmount += SalesLine."Line Amount";
                //if i were to put := and there was any available amount before it woulds had been reassigned 
            until SalesLine.Next() = 0;

        if TotalAmount > 5000 then begin
            BlockedReason := StrSubstNo('Total amount %1 exceeds maximum 5000', TotalAmount);
            LogBlockedAction(SalesHeader."No.", BlockedReason);
            ShowNotification();
            Error(BlockedReason);
        end;
    end;

    local procedure LogBlockedAction(DocumentNo: Code[20]; Reason: Text[250])
    //whn clld AL takes first argument and assigns to DocumentNo
   //                    scnd arg and assigns to Reason (line 45)
    var
        Log: Record "Sales Release Log";
    begin
        Log.Init();
        Log."Document No." := DocumentNo;
        Log."User ID" := CopyStr(UserId(), 1, 50);
        Log."Date/Time" := CurrentDateTime();
        Log."Blocked Reason" := CopyStr(Reason, 1, 250); //Value inside Reason is being copied into "Blocked Reason"
        Log.Insert();
        Commit();

        //BlockedReason (event variable)>Reason (procedure parameter)>"Blocked Reason" (table field)


    end;

    local procedure ShowNotification()
    var
        Notif: Notification;
    begin
        Notif.Message := 'Per me teper informacion, mund te kontrollohen Sale Release Logs';
        Notif.Send();
    end;

    
}
