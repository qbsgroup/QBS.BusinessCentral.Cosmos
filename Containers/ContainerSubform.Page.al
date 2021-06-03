page 89012 "PTE Cosmos Container Data"
{
    Caption = 'Data';
    SourceTable = "JSON Buffer";
    SourceTableTemporary = true;
    PageType = ListPart;
    Extensible = false;
    layout
    {
        area(Content)
        {
            repeater(fields)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Token type"; Rec."Token type") { ApplicationArea = All; }
                field(Value; Rec.Value) { ApplicationArea = All; }
                field(Path; Rec.Path) { ApplicationArea = All; }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action(RunCosmos)
            {
                Caption = 'Run';
                Image = Start;
                Promoted = true;
                ApplicationArea = all;
                trigger OnAction();
                var
                    Reader: Codeunit "PTE Cosmos Reader";
                begin
                    Rec.DeleteAll();
                    Reader.RunCosmos(CosmosQuery, Rec, ContainerName);
                end;
            }


        }
    }
    var
        CosmosQuery, ContainerName : Text;

    trigger OnOpenPage();
    begin
    end;

    procedure SetContainer(Value: Text)
    begin
        ContainerName := Value;
    end;

    procedure SetQuery(Value: Text)
    var
        Reader: Codeunit "PTE Cosmos Reader";
    begin
        CosmosQuery := Value;
        begin
            Rec.DeleteAll();
            Reader.RunCosmos(CosmosQuery, Rec, ContainerName);
            if not Rec.IsEmpty then
                Rec.FindFirst();
        end;
    end;
}