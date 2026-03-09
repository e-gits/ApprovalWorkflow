table 50251 "Training Purchase Line"
{
    Caption = 'Training Purchase Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "Training Purchase Header";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        field(3; Type; Enum "Purchase Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "No." := '';
                Description := '';
                Quantity := 0;
                "Unit Cost" := 0;
            end;
        }

        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation =
            if (Type = const("G/L Account")) "G/L Account"
            else
            if (Type = const(Item)) Item;


            trigger OnValidate()
            var
                Item: Record Item;
                GLAccount: Record "G/L Account";
            begin
                case Type of
                    Type::Item:
                        if Item.Get("No.") then begin
                            Description := Item.Description;
                            "Unit Cost" := Item."Unit Cost";
                        end;
                    Type::"G/L Account":
                        if GLAccount.Get("No.") then
                            Description := GLAccount.Name;
                end;
            end;
        }

        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Amount := Quantity * "Unit Cost";
            end;
        }

        field(7; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;

            trigger OnValidate()
            begin
                Amount := Quantity * "Unit Cost";
            end;
        }

        field(8; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = false;
        }

        field(9; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            DataClassification = CustomerContent;
            TableRelation = Employee;
        }

        field(10; "Employee Name"; Text[100])
        {
            Caption = 'Employee Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Employee."First Name" where("No." = field("Employee No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        GetTrainingHeader();
    end;

    trigger OnModify()
    begin
        GetTrainingHeader();
    end;

    trigger OnDelete()
    begin
        GetTrainingHeader();
    end;

    var
        TrainingHeader: Record "Training Purchase Header";

    local procedure GetTrainingHeader()
    begin
        if "Document No." <> '' then
            if not TrainingHeader.Get("Document No.") then
                Error('Training Purchase Header %1 does not exist.', "Document No.");
    end;
}
