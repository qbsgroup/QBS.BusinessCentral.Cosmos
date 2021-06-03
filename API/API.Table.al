table 89009 "PTE Cosmos API"
{
    Caption = 'API';
    DataClassification = ToBeClassified;
    TableType = Temporary;
    Extensible = false;
    Access = Internal;
    fields
    {
        field(1; TableID; Integer) { DataClassification = SystemMetadata; }
        Field(2; SourceTableView; Text[2048]) { DataClassification = SystemMetadata; }
        field(3; "Version"; Text[10]) { DataClassification = SystemMetadata; }
        field(4; Description; Text[50]) { DataClassification = SystemMetadata; }
        field(5; ContainerName; Text[50]) { DataClassification = SystemMetadata; }
        field(6; "Max. Dataset Size"; Integer) { DataClassification = SystemMetadata; }
    }

    keys { key(PK; TableID) { Clustered = true; } }
    procedure GetDataAsJson(): JsonObject
    var
        APIMgt: Codeunit "PTE Cosmos API Mgt.";
        ListOfData: list of [JsonObject];
        Data: JsonObject;
    begin
        APIMgt.GetDataAsJson(Rec, ListOfData);
        foreach Data in ListOfData do
            exit(Data);
    end;

    procedure GetDataAsJson(var Data: list of [JsonObject])
    var
        APIMgt: Codeunit "PTE Cosmos API Mgt.";
    begin
        APIMgt.GetDataAsJson(Rec, Data);
    end;

}