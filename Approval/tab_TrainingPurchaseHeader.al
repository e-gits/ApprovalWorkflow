table 50250 "Training Purchase Header"
{
    Caption = 'Training Purchase Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    NoSeriesMgt.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;
        }

        field(2; "Requester User ID"; Code[50])
        {
            Caption = 'Requester User ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            Editable = false;
        }

        field(3; "Request Date"; Date)
        {
            Caption = 'Request Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(4; "Training Provider"; Text[100])
        {
            Caption = 'Training Provider';
            DataClassification = CustomerContent;
        }

        field(5; "Training Title"; Text[100])
        {
            Caption = 'Training Title';
            DataClassification = CustomerContent;
        }

        field(6; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }

        field(7; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
        }

        field(8; Status; Enum "Training Request Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(9; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Training Purchase Line".Amount where("Document No." = field("No.")));
        }

        field(10; "Approved By"; Code[50])
        {
            Caption = 'Approved By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            Editable = false;
        }

        field(11; "Approved Date"; DateTime)
        {
            Caption = 'Approved Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(12; "Rejected By"; Code[50])
        {
            Caption = 'Rejected By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            Editable = false;
        }

        field(13; "Rejected Date"; DateTime)
        {
            Caption = 'Rejected Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(14; "Rejection Reason"; Text[250])
        {
            Caption = 'Rejection Reason';
            DataClassification = CustomerContent;
        }

        field(15; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order));
        }

        field(16; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }

        field(17; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
        }

        field(18; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Status; Status)
        {
        }
    }

    trigger OnInsert()
    begin
        if "No." = '' then begin
            NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", 0D, "No.", "No. Series");
        end;

        "Requester User ID" := UserId;
        "Request Date" := Today;
        Status := Status::Open;
    end;

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;

    local procedure GetNoSeriesCode(): Code[20]
    begin

        exit('TRN-REQ');
    end;

    procedure IsEditable(): Boolean
    begin
        exit(Status in [Status::Open, Status::Rejected]);
    end;

    procedure AssistEdit(OldTrainingHeader: Record "Training Purchase Header"): Boolean

    //create local variable of the same record type


    var
        TrainingHeader: Record "Training Purchase Header";

    //copy rec into training header, 
    //now TH contains the same data as Rec but its a separate variable whose fields can be passed as var param
    begin
        TrainingHeader := Rec; 

// InitSeries now writes the new No. and No,Series into TrainingHeader."No." and TrainingHeader."No. Series".
        NoSeriesMgt.InitSeries(GetNoSeriesCode(), OldTrainingHeader."No. Series", 0D, TrainingHeader."No.", TrainingHeader."No. Series");
        Rec := TrainingHeader;

// copy updated values back to rec
        exit(true);
    end;




}
