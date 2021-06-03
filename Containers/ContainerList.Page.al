page 89010 "PTE Cosmos Container List"
{
    Caption = 'Containers';
    PageType = ListPart;
    SourceTable = "PTE Cosmos Container";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        Container: Record "PTE Cosmos Container";
                    begin
                        Container := Rec;
                        Container.Insert();
                        Container.SetRecFilter();
                        Page.RunModal(Page::"PTE Cosmos Container Card", Container);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(New)
            {
                Caption = 'New';
                Image = New;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction();
                begin
                    Rec.CreateNewContainer();
                    Rec.DeleteAll();
                    Rec.GetContainers();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetContainers();
    end;
}