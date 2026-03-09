page 50256 "Sales Analysis"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "Sales Analysis Buffer";
    SourceTableTemporary = true;
    Caption = 'Sales Analysis';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                }
                field("Total Line Amount"; Rec."Total Line Amount")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 2;
                }
            }
        }
    }


    trigger OnOpenPage()
    begin
        LoadQueryData();
    end;

    local procedure LoadQueryData()
    var
        SalesAnalysisQuery: Query "Sales Analysis Query";
    begin


        SalesAnalysisQuery.Open();
        while SalesAnalysisQuery.Read() do begin
            Rec.Init();
            Rec."Customer No." := SalesAnalysisQuery.Customer_No;
            Rec."Customer Name" := SalesAnalysisQuery.Customer_Name;
            Rec."Item No." := SalesAnalysisQuery.Item_No;
            Rec."Document Type" := SalesAnalysisQuery.Document_Type;
            Rec."Posting Date" := SalesAnalysisQuery.Posting_Date;
            Rec."Total Quantity" := SalesAnalysisQuery.Total_Quantity;
            Rec."Total Line Amount" := SalesAnalysisQuery.Total_Line_Amount;
            Rec.Insert();
        end;
        SalesAnalysisQuery.Close();

    end;
}
