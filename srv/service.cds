using { RiskManagement as my } from '../db/schema.cds';
using { API_BUSINESS_PARTNER as external } from './external/API_BUSINESS_PARTNER';

@path : '/service/RiskManagementService'
service RiskManagementService
{
    @cds.redirection.target
    @odata.draft.enabled
    // 1. Apply restrictions to Risks
    entity Risks as projection on my.Risks
    annotate Risks with @(restrict: [
        { grant: [ 'READ' ], to: [ 'RiskViewer' ] },
        { grant: [ '*' ],    to: [ 'RiskManager' ] }
    ]);
    // changes made for testing commit
    @cds.redirection.target
    @odata.draft.enabled
    // 2. Apply restrictions to Mitigations
    entity Mitigations as projection on my.Mitigations
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

annotate RiskManagementService with @requires :
[
    'authenticated-user'
];