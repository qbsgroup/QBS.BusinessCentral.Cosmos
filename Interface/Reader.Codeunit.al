codeunit 89002 "PTE Cosmos Reader"
{
    Access = Public;

    procedure GetDataWithVersion(Version: Text; ContainerName: Text);
    var
        Result: JsonObject;
    begin
        Result := RunCosmos(StrSubstNo('SELECT * FROM c where c.versionNo = ''%1''', Version), ContainerName);
        GetDataFromObject(Result);
    end;

    internal procedure RunCosmos(CosmosQuery: text; ContainerName: Text) Result: JsonObject
    var
        JsonBuffer: Record "JSON Buffer" temporary;
    begin
        Result := RunCosmos(CosmosQuery, JsonBuffer, ContainerName);
    end;

    internal procedure RunCosmos(CosmosQuery: text; var JsonBuffer: Record "JSON Buffer"; ContainerName: Text) Result: JsonObject
    var
        Setup: Record "PTE Cosmos Setup";
        url: Text;
    begin
        Setup.Get();
        url := 'https://' + Setup."Database Name" + '.documents.azure.com/dbs/' + Setup."Database Name" + '/colls/' + ContainerName + '/docs';
        CosmosQuery := StrSubstNo('{"query": "%1" }', CosmosQuery);
        Result := CallWebService(url, CosmosQuery, ContainerName, Setup."Database Name");
        JsonBuffer.ReadFromText(format(Result));
    end;

    local procedure GenerateMasterKey(verb: Text; resourceId: text; resourceType: text; var UTCDateText: Text): Text
    var
        CryptoMgt: Codeunit "Cryptography Management";
        TypeHelper: Codeunit "Type Helper";
        keyType: Text;
        tokenVersion: Text;
        masterKey: Text;
        result: Text;
        ch: Text[2];
    begin
        ch[1] := 13;
        ch[2] := 10;
        keyType := 'master';
        tokenVersion := '1.0';
        masterKey := 'your master key';
        UTCDateText := TypeHelper.GetCurrUTCDateTimeAsText(); //'Fri, 20 Nov 2020 09:55:44 GMT'; //

        result := LOWERCASE(verb) + format(ch[2]) +
                    LOWERCASE(resourceType) + format(ch[2]) +
                    (resourceId) + format(ch[2]) +
                    LOWERCASE(UTCDateText) + format(ch[2]) + '' + format(ch[2]);
        result := CryptoMgt.GenerateBase64KeyedHashAsBase64String(result, masterKey, 2);
        result := 'type%3D' + keyType + '%26ver%3D' + tokenVersion + '%26sig%3D' + TypeHelper.urlEncode(result);
        exit(result);
    end;


    local procedure CallWebService(url: Text; CosmosQuery: text; ContainerName: Text; DatabaseName: Text) Result: JsonObject
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        Headers2: HttpHeaders;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        continueToken: Text;
        ResponseText: Text;
        verb: Text;
        resourceId: text;
        resourceType: text;
        MasterKey: Text;
        UTCDateText: Text;
        ResponseHeaders: array[10] of text;
    begin
        verb := 'POST';
        resourceId := 'dbs/' + DatabaseName + '/colls/' + ContainerName;
        resourceType := 'docs';

        MasterKey := GenerateMasterKey(verb, resourceId, resourceType, UTCDateText);

        RequestMessage.SetRequestUri(url);
        RequestMessage.Method(verb);
        RequestMessage.GetHeaders(Headers2);

        Content.WriteFrom(CosmosQuery);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/query+json');

        Headers.Remove('x-ms-date');
        Headers.Add('x-ms-date', UTCDateText);

        Headers.Remove('x-ms-version');
        Headers.Add('x-ms-version', '2018-12-31');

        // if continueToken <> '' then begin
        //     Headers.Remove('x-ms-continuation');
        //     Headers.Add('x-ms-continuation', continueToken);
        // end;

        Headers.Remove('x-ms-documentdb-isquery');
        Headers.Add('x-ms-documentdb-isquery', 'true');

        Headers.Remove('x-ms-documentdb-query-enablecrosspartition');
        Headers.Add('x-ms-documentdb-query-enablecrosspartition', 'true');

        Headers2.Remove('authorization');
        Headers2.Add('authorization', MasterKey);

        RequestMessage.Content := Content;
        if not Client.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content().ReadAs(ResponseText);
            error('The web service returned an error message:\' +
                      'Status code: %1' +
                      'Description: %2',
                      ResponseMessage.HttpStatusCode,
                      ResponseText);
        end;
        Headers := ResponseMessage.Headers;
        if Headers.Contains('x-ms-continuation') then begin
            Headers.GetValues('x-ms-continuation', ResponseHeaders);
            continueToken := ResponseHeaders[1];
        end;// else
            // continueToken := '';


        ResponseMessage.Content().ReadAs(ResponseText);
        Result.ReadFrom(ResponseText);
        exit(Result);
    end;

    local procedure GetDataFromObject(Object: JsonObject): Text;
    var
        Documents: JsonArray;
        DocumentToken: JsonToken;
    begin
        Object.Get('Documents', DocumentToken);
        Documents := DocumentToken.AsArray();
        Clear(DocumentToken);
        foreach DocumentToken in Documents do
            GetDataFromDocument(DocumentToken.AsObject());
    end;

    local procedure GetDataFromDocument(Document: JsonObject)
    var
        jsonResultToken: JsonToken;
        MyValue: JsonValue;
    begin
        Document.Get('tableId', jsonResultToken);
        MyValue := jsonResultToken.AsValue();
        SaveData(MyValue.AsInteger(), Document);
    end;

    local procedure SaveData(TableId: Integer; jsonresult: JsonObject)
    var
        RecRef: RecordRef;
        DataList: JsonArray;
        Data: JsonToken;
    begin
        //RecRef.Open(TableId, true);
        RecRef.Open(TableId);

        jsonresult.Get('data', Data);
        DataList := Data.AsArray();
        Clear(Data);
        foreach Data in DataList do
            SaveRecordRef(RecRef, Data);

    end;

    local procedure SaveRecordRef(var RecRef: RecordRef; Data: JsonToken)
    var
        Fld: Record Field;
        FldRef: FieldRef;
        DataObject: JsonObject;
        DataField: JsonToken;
        MyValue: JsonValue;
        MyKey: Text;
    begin
        DataObject := Data.AsObject();
        RecRef.Init();
        Fld.SetRange(TableNo, RecRef.Number);
        Fld.SetRange(Class, Fld.Class::Normal);
        Fld.SetRange(ObsoleteState, Fld.ObsoleteState::No);

        foreach MyKey in DataObject.Keys do begin
            DataObject.Get(MyKey, DataField);
            MyValue := DataField.AsValue();
            Fld.SetRange(FieldName, MyKey);
            if Fld.FindFirst() then begin
                FldRef := RecRef.Field(Fld."No.");
                case FldRef.Type of
                    FldRef.Type::Boolean:
                        FldRef.Value(MyValue.AsBoolean());
                    FldRef.Type::Option, FldRef.Type::Integer, FldRef.Type::BigInteger:
                        FldRef.Value(MyValue.AsBigInteger());
                    FldRef.Type::Text, FldRef.Type::Code:
                        FldRef.Value(MyValue.AsText());
                    FldRef.Type::Decimal:
                        FldRef.Value(MyValue.AsDecimal());
                    FldRef.Type::Date:
                        FldRef.Value(MyValue.AsDate());
                    FldRef.Type::DateTime:
                        FldRef.Value(MyValue.AsDateTime());
                    FldRef.Type::Time:
                        FldRef.Value(MyValue.AsTime());
                end;
            end;
        end;
        if RecRef.Insert() then;
        //Message(Format(RecRef));

    end;

}