codeunit 89009 "PTE Cosmos API Mgt."
{
    Access = Internal;
    procedure GetDataAsJson(CosmosAPI: Record "PTE Cosmos API"; var Data: list of [JsonObject])
    var
        Fld: Record Field;
        RecRef: RecordRef;
        FldRef: FieldRef;
        DataSet: JsonObject;
        ResultArray: JsonArray;
        Result: JsonObject;
        Value: JsonValue;
        Token: JsonToken;
        StartingDateTime: DateTime;
        i: Integer;
    begin
        StartingDateTime := CurrentDateTime;
        RecRef.Open(CosmosAPI.TableID);
        RecRef.SetView(CosmosAPI.SourceTableView);
        if RecRef.FindSet() then
            repeat
                i += 1;
                Clear(Result);
                Fld.SetRange(TableNo, CosmosAPI.TableID);
                Fld.SetRange(ObsoleteState, Fld.ObsoleteState::No);
                fld.SetRange("No.", 1, 2000000000 - 1);
                fld.SetRange(Class, Fld.Class::Normal);
                Fld.FindSet();
                repeat
                    FldRef := RecRef.Field(Fld."No.");
                    Value := GetFieldValue(FldRef);
                    Token := Value.AsToken();
                    Result.Add(Fld.FieldName, Token);
                until Fld.Next() = 0;
                ResultArray.Add(Result);
                if (CosmosAPI."Max. Dataset Size" > 0) and (i > CosmosAPI."Max. Dataset Size" - 1) then begin
                    Data.Add(WrapResultInDataSet(CosmosAPI, RecRef, ResultArray));
                    Clear(ResultArray);
                    i := 0;
                end;
            until RecRef.Next() = 0;
        Data.Add(WrapResultInDataSet(CosmosAPI, RecRef, ResultArray));
    end;

    local procedure WrapResultInDataSet(CosmosAPI: Record "PTE Cosmos API"; RecRef: RecordRef; ResultArray: JsonArray) Result: JsonObject;
    begin
        Result.Add('id', CreateGuid());
        Result.add('tableId', CosmosAPI.TableID);
        Result.Add('versionNo', CosmosAPI.Version);
        Result.Add('sourceTableView', CosmosAPI.SourceTableView);
        Result.Add('tableCaption', RecRef.Caption);
        Result.Add('data', ResultArray);
        Result.Add('timeStamp', CurrentDateTime);
    end;

    local procedure GetFieldValue(var FldRef: FieldRef) Value: JsonValue
    var
        Bool: Boolean;
        BigInt: BigInteger;
        Txt: Text;
        Dte: Date;
        DteTime: DateTime;
        Dec: Decimal;
        Tme: Time;
    begin
        case FldRef.Type of
            FldRef.Type::BigInteger, FldRef.Type::Integer, FldRef.Type::Option:
                begin
                    BigInt := FldRef.Value;
                    Value.SetValue(BigInt);
                end;
            FldRef.Type::Boolean:
                begin
                    Bool := FldRef.Value;
                    Value.SetValue(Bool);
                end;
            FldRef.Type::Code, FldRef.Type::Text:
                begin
                    Txt := FldRef.Value;
                    Value.SetValue(Txt);
                end;
            FldRef.Type::Date:
                begin
                    Dte := FldRef.Value;
                    Value.SetValue(Dte);
                end;
            FldRef.Type::DateTime:
                begin
                    DteTime := FldRef.Value;
                    Value.SetValue(DteTime);
                end;
            FldRef.Type::Decimal, FldRef.Type::Duration:
                begin
                    Dec := FldRef.Value;
                    Value.SetValue(Dec);
                end;
            FldRef.Type::Time:
                begin
                    Tme := FldRef.Value;
                    Value.SetValue(Tme);
                end;
        end;
    end;
}