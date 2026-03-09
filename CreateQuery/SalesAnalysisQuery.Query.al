query 50254 "Sales Analysis Query"

{


    QueryType = Normal;
    Caption = 'Sales Analysis Query';


    elements
    {
        dataitem(Sales_Header; "Sales Header")
        {
            filter(Filter_Document_Type; "Document Type")
            {
            }
            filter(Filter_Posting_Date; "Posting Date")
            {
            }

            dataitem(Sales_Line; "Sales Line")
            {

                //"Matches records where the Document Type in this table equals the Document Type in Sales_Header"
                //Document No. in this table equals the No.in Sales Header
                DataItemLink = "Document Type" = Sales_Header."Document Type",
                               "Document No." = Sales_Header."No.";
                SqlJoinType = InnerJoin;

                column(Document_Type; "Document Type")
                {
                }
                column(Posting_Date; "Posting Date")
                {
                }
                column(Customer_No; "Sell-to Customer No.")
                {
                }
                column(Item_No; "No.")
                {
                }
                column(Total_Quantity; Quantity)
                {
                    Method = Sum;
                }
                column(Total_Line_Amount; "Line Amount")
                {
                    Method = Sum;
                }

                dataitem(Customer; Customer)
                {
                    DataItemLink = "No." = Sales_Line."Sell-to Customer No.";
                    SqlJoinType = InnerJoin;
                    //Matches records where the "No." in this table equals the "Sell to cusotmer No." in Sales Line.                   

                    column(Customer_Name; Name)
                    {
                    }
                }
            }
        }
    }
}
