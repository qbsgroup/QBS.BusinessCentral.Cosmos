page 89011 "PTE Cosmos Container Card"
{
    Caption = 'Container';
    PageType = Card;
    SourceTable = "PTE Cosmos Container";
    Extensible = false;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Query; Query)
                {
                    Caption = 'Query';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Lines.Page.SetQuery(Query);
                    end;
                }
            }
            part(Lines; "PTE Cosmos Container Data")
            {
                ApplicationArea = All;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Lines.Page.SetContainer(Rec.Name);
        Query := 'SELECT * FROM c where c.versionNo = ''v1.0''';
        CurrPage.Lines.Page.SetQuery(Query);
    end;

    var
        Query: Text;
}