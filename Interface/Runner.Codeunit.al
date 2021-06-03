Codeunit 89001 "PTE Cosmos Runner"
{
    Access = Internal;

    var
        TypeHelper: Codeunit "Type Helper";

    procedure SendToCosmos(var DataSet: Record "PTE Cosmos Dataset"; var Definition: Record "PTE Cosmos Dataset Definition")
    var
        Dlg: Dialog;
        DT: DateTime;
    begin
        dt := CurrentDateTime;
        Dlg.Open('Sync. Data #1#################\#2#################');
        if Definition.FindSet() then
            repeat
                Dlg.Update(1, Definition."Table ID");
                Dlg.Update(2, CurrentDateTime - dt);
                SendDataDirectlyToCosmos(Definition."Table ID", Definition.SourceTableView, DataSet);
            until Definition.Next() = 0;
        Dlg.Close();
    end;

    procedure SendToCosmos(var DataSet: Record "PTE Cosmos Dataset"; Tables: Dictionary of [Integer, Text])
    var
        Table: Integer;
        View: Text;
    begin
        foreach Table in Tables.Keys do begin
            Tables.get(Table, View);
            SendDataToCosmos(Table, View, DataSet);
        end;
    end;

    local procedure SendDataDirectlyToCosmos(TableID: Integer; View: Text; var DataSet: Record "PTE Cosmos Dataset")
    var
        CosmosSetup: Record "PTE Cosmos Setup";
        ListOfData: List of [JsonObject];
        Data: JsonObject;
    begin
        CosmosSetup.Get();
        DataSet.GetDataSetAsJson(TableID, View, ListOfData);
        foreach Data in ListOfData do begin
            if ListOfData.Count > 10 then
                sleep(3000);/////////// TODO
            CallCosmosApi(Data, DataSet);
        end;
    end;

    local procedure CallCosmosApi(RequestObj: JsonObject; var DataSet: Record "PTE Cosmos Dataset");
    var
        CosmosSetup: Record "PTE Cosmos Setup";
        Client: HttpClient;
        Content: HttpContent;
        RequestContent: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Request: Text;
        MyText: Text;
        InStr: InStream;
    begin
        CosmosSetup.Get();
        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri('https://' + CosmosSetup."Database Name" + '.documents.azure.com/dbs/' + CosmosSetup."Database Name"
                                            + '/colls/' + DataSet.ContainerName + '/docs');
        RequestMessage.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Authorization', GetAuthorizationString(DataSet.ContainerName));
        Headers.Add('x-ms-version', '2018-12-31');
        Headers.Add('x-ms-date', TypeHelper.GetCurrUTCDateTimeAsText().ToLower());
        Headers.Add('x-ms-documentdb-partitionkey', '["v1.0"]');
        Headers.Add('Accept', 'application/json');

        Request := Format(RequestObj);

        GetRequestContent(Request, RequestContent);
        RequestMessage.Content := RequestContent;
        Client.Timeout(300000);
        Client.Send(RequestMessage, ResponseMessage);
        Headers := ResponseMessage.Headers;
        Content := ResponseMessage.Content;

        if not ResponseMessage.IsSuccessStatusCode then begin
            Content.ReadAs(MyText);
            Error(MyText);
        end;
    end;

    local procedure GetAuthorizationString(ContainerName: Text[50]): Text
    var
        CosmosSetup: Record "PTE Cosmos Setup";
        EncryptionMgt: Codeunit "Cryptography Management";
        input, KeyedHash, inputString : Text;
        NewLine: Text[1];
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        CosmosSetup.Get();
        NewLine[1] := 10;
        inputString := 'post' + NewLine + 'docs' + NewLine + 'dbs/pvs-admin/colls/' + ContainerName + NewLine
                            + TypeHelper.GetCurrUTCDateTimeAsText().ToLower() + NewLine + '' + NewLine;
        KeyedHash := EncryptionMgt.GenerateBase64KeyedHashAsBase64String(inputString, CosmosSetup."Access Key", HashAlgorithmType::SHA256);
        input := 'type=master&ver=1.0&sig=' + KeyedHash;
        exit(TypeHelper.UrlEncode(input));
    end;

    local procedure SendDataToCosmos(TableID: Integer; View: Text; var DataSet: Record "PTE Cosmos Dataset")
    var
        CosmosSetup: Record "PTE Cosmos Setup";
        CosmosParameters: JsonObject;
        CosmosLogin: JsonObject;
        ListOfData: List of [JsonObject];
        Data: JsonObject;
    begin
        CosmosSetup.Get();

        CosmosLogin.Add('DatabaseName', CosmosSetup."Database Name");
        CosmosLogin.Add('accessKey', CosmosSetup."Access Key");
        CosmosLogin.Add('businessCentralUser', CosmosSetup."User-ID (API)");
        CosmosLogin.Add('businessCentralKey', CosmosSetup."Web Service Access Key (API)");

        CosmosParameters.Add('versionNo', DataSet."Version No.");
        CosmosParameters.Add('containerName', DataSet.ContainerName);
        CosmosParameters.Add('endPointUri', 'https://' + CosmosSetup."Database Name" + '.documents.azure.com:443/');
        CosmosParameters.Add('Login', CosmosLogin);

        if Dataset."Use API" then begin

            CosmosParameters.Add('tenandId', CosmosSetup.GetTenantID());
            CosmosParameters.Add('companyId', CosmosSetup.GetCompanyId());
            CosmosParameters.Add('sandBoxName', CosmosSetup.GetSandboxName());
            CosmosParameters.Add('apiPublisher', 'cosmos');
            CosmosParameters.Add('apiGroup', 'cosmos');
            CosmosParameters.Add('apiVersion', 'v1.0');
            CosmosParameters.Add('apiEndpoint', 'cosmosRecords');
            CosmosParameters.Add('tableId', TableID);
            CosmosParameters.Add('sourceTableView', '');
            CallWebService(CosmosSetup.GetEndpoint(), CosmosParameters);
        end else begin
            DataSet.GetDataSetAsJson(TableID, View, ListOfData);
            foreach Data in ListOfData do begin
                CosmosParameters.Add('DataSet', Data);
                CallWebService(CosmosSetup.GetEndpoint(), CosmosParameters);
                CosmosParameters.Remove('DataSet');
            end;

        end;
    end;

    local procedure CallWebService(Endpoint: Text; RequestObj: JsonObject);
    var
        Client: HttpClient;
        Content: HttpContent;
        RequestContent: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Request: Text;
        MyText: Text;
        InStr: InStream;
    begin
        //   CosmosSetup.Get;
        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(Endpoint + 'ReadBusinessCentralData');
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');

        Request := Format(RequestObj);

        GetRequestContent(Request, RequestContent);
        RequestMessage.Content := RequestContent;
        client.Timeout(300000);
        Client.Send(RequestMessage, ResponseMessage);
        Headers := ResponseMessage.Headers;
        Content := ResponseMessage.Content;

        if not ResponseMessage.IsSuccessStatusCode then begin
            Content.ReadAs(MyText);
            Error(MyText);
        end else begin
            Content.ReadAs(InStr);
            InStr.Read(MyText);
            if MyText.ToUpper().Contains('ERROR') then
                Message(MyText);
        end;
    end;

    local procedure GetRequestContent(Value: Text; var RequestContent: HttpContent);
    var
        RequestHeaders: HttpHeaders;
    begin
        RequestContent.WriteFrom(Value);
        RequestContent.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/json');
    end;
}
