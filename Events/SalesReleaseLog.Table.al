table 50253 "Sales Release Log"
{
    DataClassification = CustomerContent;
    Caption = 'Sales Release Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(3; "User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User ID';
        }
        field(4; "Date/Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Date/Time';
        }
        field(5; "Blocked Reason"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Blocked Reason';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(DocumentNo; "Document No.", "Date/Time")
        {
        } //without secondary keys BC would need to scan all the table filter by document No. and sort by date/time
    }
}
