namespace RiskManagement;
using { API_BUSINESS_PARTNER as external } from '../srv/external/API_BUSINESS_PARTNER';

entity Risks
{
    key ID : UUID;
    title : String(100);
    prioi : String(5);
    descr : String(100);
    impact : Integer;
    criticality : Integer;
    miti : Association to one Mitigations;
    supplier : Association to one external.A_BusinessPartner;
}

entity Mitigations
{
    key ID : UUID;
    createdAT : String(100);
    createdBy : String(100);
    description : String(100);
    owner : String(100);
    timeline : String(100);
    risks : Association to many Risks on risks.miti = $self;
}
