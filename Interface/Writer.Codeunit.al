codeunit 89003 "PTE Cosmos Writer"
{
    Access = Public;

    procedure SaveTestResult(Description: Text; ContainerName: Text; Tables: Dictionary of [Integer, Text])
    var
        DataSet: Record "PTE Cosmos Dataset";
    begin
        DataSet.Description := CopyStr(Description, 1, MaxStrLen(DataSet.Description));
        DataSet.ContainerName := CopyStr(ContainerName, 1, MaxStrLen(DataSet.ContainerName));
        DataSet.Insert();

        DataSet.Sync(Tables);
    end;
}