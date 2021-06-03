Table 89000 "PTE Cosmos Setup"
{
    Caption = 'Datamanagement Setup';
    Extensible = false;
    fields
    {
        field(1; "Primary Key"; Code[10]) { DataClassification = ToBeClassified; }
        field(2; "Database Name"; Text[30]) { DataClassification = ToBeClassified; }
        field(3; "Access Key"; Text[100]) { DataClassification = ToBeClassified; }
        field(10; "User-ID (API)"; Code[50]) { DataClassification = ToBeClassified; }
        field(11; "Web Service Access Key (API)"; Text[100]) { DataClassification = ToBeClassified; }
        field(15; "Extension Prefix"; Code[3]) { DataClassification = ToBeClassified; }
        field(18; "Company Id"; Text[30]) { DataClassification = ToBeClassified; }
        field(30; "API Endpoint Code"; Code[10]) { DataClassification = ToBeClassified; TableRelation = "PTE Cosmos API Endpoint"; }
    }

    keys { key(Key1; "Primary Key") { Clustered = true; } }
    procedure GetDefaultSetup()
    var
        CosmosSetup: Codeunit "PTE Cosmos Setup";
    begin
        CosmosSetup.Run(Rec);
    end;

    procedure GetTenantID(): Text
    var
        TenantInfo: Codeunit "Azure AD Tenant";
    begin
        exit(TenantInfo.GetAadTenantId());
    end;

    procedure GetSandboxName(): Text
    var
        Env: Codeunit "Environment Information";
    begin
        exit(Env.GetEnvironmentName());
    end;

    procedure GetEndpoint(): Text;
    var
        Endpoint: Record "PTE Cosmos API Endpoint";
    begin
        Endpoint.Get("API Endpoint Code");
        exit(Endpoint.Endpoint);
    end;

    procedure GetCompanyId(): Text
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName);
        exit(DelChr(Company.SystemId, '=', '{}'));
    end;
}

