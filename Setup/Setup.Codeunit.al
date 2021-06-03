codeunit 89000 "PTE Cosmos Setup"
{
    TableNo = "PTE Cosmos Setup";
    Access = Internal;

    trigger OnRun()
    begin
        if not Rec.Get() then
            Rec.Insert();

        Rec."Database Name" := 'your datamasename';
        Rec."Access Key" := 'your accesskey';
        Rec."User-ID (API)" := 'your user-id';
        Rec."Web Service Access Key (API)" := 'your web service access key';
        CreateAPIEndpoints();
        Rec."API Endpoint Code" := 'AZURE';
        Rec."Extension Prefix" := 'PTE';
        Rec.Modify();
    end;

    local procedure CreateAPIEndpoints()
    var
        Endpoint: Record "PTE Cosmos API Endpoint";
    begin
        if not Endpoint.Get('AZURE') then begin
            Endpoint.Code := 'AZURE';
            Endpoint.Endpoint := 'https://' + 'your azure function' + '.azurewebsites.net/api/';
            Endpoint.Insert();
        end;
    end;
}