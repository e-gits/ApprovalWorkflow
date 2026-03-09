table 50255 "Sales Analysis Buffer"
{
    TableType = Temporary;
    Caption = 'Sales Analysis Buffer';

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(2; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }


        field(4; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(6; "Total Quantity"; Decimal)
        {
            Caption = 'Total Quantity';
        }
        field(7; "Total Line Amount"; Decimal)
        {
            Caption = 'Total Line Amount';
        }
    }

    keys
    {
        key(PK; "Customer No.", "Item No.", "Document Type", "Posting Date")
        {
            Clustered = true;
        }
    }
}
