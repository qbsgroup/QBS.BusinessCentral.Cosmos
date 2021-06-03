table 89010 "PTE Cosmos Container"
{
    Caption = 'Container';
    DataClassification = ToBeClassified;
    TableType = Temporary;
    Extensible = false;
    Access = Internal;
    fields
    {
        field(1; "Name"; Text[50]) { DataClassification = ToBeClassified; }
    }

    keys { key(PK; "Name") { Clustered = true; } }

    procedure GetContainers()
    var
        ContainerMgt: Codeunit "PTE Cosmos Container Mgt.";
    begin
        ContainerMgt.Run(Rec);
    end;

    procedure CreateNewContainer()
    var
        DataSet: Record "PTE Cosmos Dataset";
    begin
        DataSet.ContainerName := 'ContainerName';
        DataSet."Version No." := 'v1.0';
        DataSet.Insert();
        Page.RunModal(Page::"PTE Cosmos Dataset", DataSet);
    end;
}