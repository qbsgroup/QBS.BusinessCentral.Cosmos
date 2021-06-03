Page 89021 "PTE Cosmos Dataset Definition"
{
    Caption = 'Dataset Definition';
    PageType = ListPart;
    SourceTableTemporary = true;
    SourceTable = "PTE Cosmos Dataset Definition";
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Table ID"; Rec."Table ID") { ApplicationArea = All; }
                field(SourceTableView; Rec.SourceTableView) { ApplicationArea = All; }
                field("No. of Records"; Rec."No. of Records") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(GetExtensionTables)
            {
                Caption = 'Get Extension tables';
                ApplicationArea = All;
                Image = Table;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Setup: Record "PTE Cosmos Setup";
                    Obj: Record AllObj;
                    RecRef: RecordRef;
                    Dlg: Dialog;
                begin
                    Setup.Get();
                    Setup.TestField("Extension Prefix");
                    Rec.DeleteAll();
                    Dlg.Open('#1#################################');
                    Dlg.Update(1, 'Searching for Objects...');
                    Obj.SetRange("Object Type", Obj."Object Type"::Table);
                    Obj.SetFilter("Object Name", Setup."Extension Prefix" + '*');
                    Obj.FindSet();
                    repeat
                        Dlg.Update(1, Obj."Object Name");
                        RecRef.Open(Obj."Object ID");
                        if not RecRef.IsEmpty then begin
                            Rec."Line No." += 10000;
                            Rec."Table ID" := Obj."Object ID";
                            Rec.Description := Obj."Object Name";
                            rec."No. of Records" := RecRef.Count();
                            Rec.Insert();
                        end;
                        RecRef.Close();
                    until Obj.Next() = 0;
                end;
            }

            action(GetConfigurationPackage)
            {
                Caption = 'Get tables from configuration package';
                ApplicationArea = All;
                Image = Table;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ConfigPackage: Record "Config. Package";
                    ConfigPackageTable: Record "Config. Package Table";
                    Obj: Record AllObj;
                    RecRef: RecordRef;
                    Dlg: Dialog;
                begin
                    if page.RunModal(0, ConfigPackage) = action::LookupOK then begin
                        ConfigPackageTable.SetRange("Package Code", ConfigPackage.Code);
                        if ConfigPackage.FindFirst() then begin
                            ConfigPackageTable.SetRange("Package Code", ConfigPackage.Code);
                            Dlg.Open('#1#################################');
                            Dlg.Update(1, 'Searching for Objects...');
                            if ConfigPackageTable.FindSet() then
                                repeat
                                    Obj.SetRange("Object Type", Obj."Object Type"::Table);
                                    Obj.SetRange("Object ID", ConfigPackageTable."Table ID");
                                    if Obj.FindFirst() then
                                        repeat
                                            Dlg.Update(1, Obj."Object Name");
                                            RecRef.Open(Obj."Object ID");
                                            if not RecRef.IsEmpty then begin
                                                if not (Obj."Object ID" in [6010346]) then begin
                                                    Rec."Line No." += 10000;
                                                    Rec."Table ID" := Obj."Object ID";
                                                    Rec.Description := Obj."Object Name";
                                                    rec."No. of Records" := RecRef.Count();
                                                    rec.SourceTableView := addSourceView(Rec."Table ID");
                                                    Rec.Insert();
                                                end;
                                            end;
                                            RecRef.Close();
                                        until Obj.Next() = 0;
                                until ConfigPackageTable.Next() = 0;
                        end;
                    end;

                end;
            }
        }
    }

    procedure addSourceView(inID: Integer): Text
    begin
        case inID of
            18, 23, 27:
                begin
                    exit('WHERE(No.=FILTER(PTE*))');
                end;
        end;

    end;

    procedure GetDefinition(var Definition: Record "PTE Cosmos Dataset Definition")
    begin
        Definition.Copy(Rec, true);
        Definition.FindFirst();
    end;
}
