page 89020 "PTE Cosmos Dataset"
{
    Caption = 'Dataset';
    PageType = Card;
    SourceTable = "PTE Cosmos Dataset";
    Extensible = false;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Name; Rec.Description) { ApplicationArea = All; }
                field(ContainerName; Rec.ContainerName) { ApplicationArea = All; }
                field("Version No."; Rec."Version No.") { ApplicationArea = All; }
                field("Use API"; Rec."Use API") { ApplicationArea = All; }
            }
            part(Definition; "PTE Cosmos Dataset Definition")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Sync)
            {
                Caption = 'Synchronize';
                ApplicationArea = All;
                Image = SwitchCompanies;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Definition: Record "PTE Cosmos Dataset Definition" temporary;
                begin
                    CurrPage.Definition.Page.GetDefinition(Definition);
                    Rec.Sync(Definition);
                end;
            }
        }
    }
}