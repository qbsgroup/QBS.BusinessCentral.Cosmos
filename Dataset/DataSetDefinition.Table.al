Table 89021 "PTE Cosmos Dataset Definition"
{
    Caption = 'Dataset Definition';
    TableType = Temporary;
    Extensible = false;
    Access = Internal;
    fields
    {
        field(1; "Line No."; Integer) { DataClassification = ToBeClassified; }
        field(3; Description; Text[30]) { DataClassification = ToBeClassified; }
        field(2; "Table ID"; Integer) { DataClassification = ToBeClassified; }
        field(5; "SourceTableView"; Text[2048]) { DataClassification = ToBeClassified; }
        field(10; "No. of Records"; Integer) { DataClassification = ToBeClassified; }
    }

    keys { key(Key1; "Line No.") { Clustered = true; } }

}

