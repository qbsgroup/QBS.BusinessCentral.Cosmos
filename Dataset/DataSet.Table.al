table 89020 "PTE Cosmos Dataset"
{
    Caption = 'Dataset';
    TableType = Temporary;
    DataClassification = SystemMetadata;
    Extensible = false;
    //Access = Internal;
    fields
    {
        field(1; "Primary Key"; Code[1]) { DataClassification = SystemMetadata; }
        field(2; Description; Text[2048]) { DataClassification = SystemMetadata; }
        field(3; ContainerName; Text[50]) { DataClassification = SystemMetadata; }
        field(4; "Use API"; Boolean) { DataClassification = SystemMetadata; }
        field(5; "Version No."; Text[10]) { DataClassification = SystemMetadata; }
    }

    keys { key(PK; "Primary Key") { Clustered = true; } }

    procedure Sync(var Details: Record "PTE Cosmos Dataset Definition")
    var
        CosmosRunner: Codeunit "PTE Cosmos Runner";
    begin
        TestField(ContainerName);
        TestField("Version No.");
        CosmosRunner.SendToCosmos(Rec, Details);
    end;

    procedure Sync(Tables: Dictionary of [Integer, Text])
    var
        CosmosRunner: Codeunit "PTE Cosmos Runner";
    begin
        CosmosRunner.SendToCosmos(Rec, Tables);
    end;

    procedure GetDataSetAsJson(TableID: Integer; View: Text; var Data: List of [JsonObject])
    var
        CosmosAPI: Record "PTE Cosmos API";
    begin
        TestField(Description);
        TestField(ContainerName);
        CosmosAPI.TableID := TableID;
        CosmosAPI.Version := 'v1.0';
        CosmosAPI.SourceTableView := CopyStr(View, 1, 2048);
        CosmosAPI.Description := CopyStr(Description, 1, 50);
        CosmosAPI.ContainerName := ContainerName;
        CosmosAPI."Max. Dataset Size" := 80;
        CosmosAPI.GetDataAsJson(Data);
    end;

}