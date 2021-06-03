page 89001 "PTE Cosmos API Endpoint"
{
    Caption = 'Endpoints';
    PageType = List;
    SourceTable = "PTE Cosmos API Endpoint";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Endpoint; Rec.Endpoint) { ApplicationArea = All; }
            }
        }
    }
}