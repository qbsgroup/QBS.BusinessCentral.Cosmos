Page 89000 "PTE Cosmos Setup"
{
    Caption = 'Datamanagement Setup';
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "PTE Cosmos Setup";
    UsageCategory = Administration;
    Extensible = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Database Name"; Rec."Database Name") { ApplicationArea = All; }
                field("Access Key"; Rec."Access Key") { ApplicationArea = All; }
                field("User-ID (API)"; Rec."User-ID (API)") { ApplicationArea = All; }
                field("Web Service Access Key (API)"; Rec."Web Service Access Key (API)") { ApplicationArea = All; }
                field("API Endpoint Code"; Rec."API Endpoint Code") { ApplicationArea = All; }
                field("Company Id"; Rec."Company Id") { ApplicationArea = All; }
                field("Extension Prefix"; Rec."Extension Prefix") { ApplicationArea = All; }
            }
            group(Information)
            {
                Caption = 'Information';
                field(GetEndpoint; Rec.GetEndpoint()) { ApplicationArea = All; Caption = 'Endpoint'; }
                field(GetTenantID; Rec.GetTenantID()) { ApplicationArea = All; Caption = 'Tenant ID'; }
                field(GetSandboxName; Rec.GetSandboxName()) { ApplicationArea = All; Caption = 'Sandbox Name'; }
                field(GetCompanyId; Rec.GetCompanyId()) { ApplicationArea = All; Caption = 'Sandbox Id (This Company)'; }

            }
        }
        area(FactBoxes)
        {
            part(Containers; "PTE Cosmos Container List") { ApplicationArea = All; }

        }

    }
    actions
    {
        area(Creation)
        {
            action(NewContainer)
            {
                Caption = 'New Container';
                Image = New;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction();
                var
                    Container: Record "PTE Cosmos Container";
                begin
                    Container.CreateNewContainer();
                end;
            }

        }
        area(Navigation)
        {
            action(Endpoints)
            {
                Caption = 'Endpoints';
                ApplicationArea = All;
                Image = LinkAccount;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "PTE Cosmos API Endpoint";
            }
        }
        area(processing)
        {
            action(DefaultSetup)
            {
                Caption = 'Default Setup';
                ApplicationArea = All;
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.GetDefaultSetup();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.GetDefaultSetup();
    end;
}

