Table 89001 "PTE Cosmos API Endpoint"
{
    Caption = 'Endpoint';
    LookupPageId = "PTE Cosmos API Endpoint";
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10]) { DataClassification = ToBeClassified; }
        field(2; Endpoint; Text[250]) { DataClassification = ToBeClassified; }
    }

    keys { key(Key1; "Code") { Clustered = true; } }

    fieldgroups { fieldgroup(DropDown; "Code", Endpoint) { } }
}

