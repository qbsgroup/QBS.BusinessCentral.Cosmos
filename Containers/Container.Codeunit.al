codeunit 89010 "PTE Cosmos Container Mgt."
{
    TableNo = "PTE Cosmos Container";
    Access = Internal;

    trigger OnRun()
    var
        CosmosSetup: Record "PTE Cosmos Setup";
        Login: JsonObject;
        Request: JsonObject;
        Result: JsonObject;
        Names: JsonToken;
        Value: JsonValue;
        ListOfContainers: JsonArray;
    begin
        CosmosSetup.Get();
        Login.Add('DatabaseName', CosmosSetup."Database Name");
        Login.Add('accessKey', CosmosSetup."Access Key");
        Request.Add('Login', Login);
        Result := CallWebService(CosmosSetup.GetEndpoint(), Request);
        Result.Get('Name', Names);
        ListOfContainers := Names.AsArray();
        foreach Names in ListOfContainers do begin
            Value := Names.AsValue();
            Rec.Name := Value.AsText();
            Rec.Insert();
        end;
    end;

    local procedure CallWebService(Endpoint: Text; RequestObj: JsonObject) Result: JsonObject;
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
        RequestMessage.SetRequestUri(Endpoint + 'GetCosmosContainers');
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
            Result.ReadFrom(MyText);
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