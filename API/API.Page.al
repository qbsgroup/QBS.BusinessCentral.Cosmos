page 89009 "PTE Cosmos API"
{
    PageType = API;
    APIPublisher = 'cosmos';
    APIGroup = 'cosmos';
    APIVersion = 'v1.0';
    EntityName = 'cosmosRecord';
    EntitySetName = 'cosmosRecords';
    SourceTable = "PTE Cosmos API";
    SourceTableTemporary = true;
    DelayedInsert = true;
    Caption = 'CosmosAPI';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Extensible = false;
    layout
    {
        area(content)
        {
            repeater(repeater)
            {
                field(tableId; Rec.TableID) { }
                field(versionNo; Rec.Version) { }
                field(sourceTableView; Rec.SourceTableView) { }
                field(description; Rec.Description) { }
                field(containerName; Rec.ContainerName) { }
                field(jsonResult; JsonResult) { }

            }
        }
    }
    var
        JsonResult: Text;

    trigger OnAfterGetRecord()
    var
        AllObj: Record AllObj;
    begin
        Rec.Version := CopyStr(Rec.GetFilter(Version), 1, 10);
        Rec.SourceTableView := CopyStr(Rec.GetFilter(SourceTableView), 1, 2048);
        Rec.Description := CopyStr(Rec.GetFilter(Description), 1, 50);
        Rec.ContainerName := CopyStr(Rec.GetFilter(ContainerName), 1, 50);
        Rec.TestField(Version);
        Evaluate(Rec.TableID, Rec.GetFilter(TableID));
        Rec.TestField(TableID);
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetRange("Object ID", Rec.TableID);
        if not AllObj.IsEmpty then
            JsonResult := Format(Rec.GetDataAsJson())
        else
            Error('No such table...');
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(true)
    end;
}