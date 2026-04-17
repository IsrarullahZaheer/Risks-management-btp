using { RiskManagement as my } from '../db/schema.cds';
using { API_BUSINESS_PARTNER as external } from './external/API_BUSINESS_PARTNER';

@path    : '/service/RiskManagementService'
@requires: 'authenticated-user'
service RiskManagementService
{
    @cds.redirection.target
    @odata.draft.enabled
    entity Risks as projection on my.Risks;

    annotate Risks with @(restrict: [
        { grant: [ 'READ' ], to: [ 'RiskViewer' ] },
        { grant: [ '*' ],    to: [ 'RiskManager' ] }
    ]);

    @cds.redirection.target
    @odata.draft.enabled
    entity Mitigations as projection on my.Mitigations;

    annotate Mitigations with @(restrict: [
        { grant: [ 'READ' ], to: [ 'RiskViewer' ] },
        { grant: [ '*' ],    to: [ 'RiskManager' ] }
    ]);

    @readonly
    entity BusinessPartners as projection on external.A_BusinessPartner {
        key BusinessPartner,
        Customer,
        Supplier,
        BusinessPartnerCategory,
        BusinessPartnerFullName,
        BusinessPartnerIsBlocked
    };
}