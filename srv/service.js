const cds = require('@sap/cds');

module.exports = cds.service.impl(async function() {
    const { BusinessPartners } = this.entities;
    const BPsrv = await cds.connect.to('API_BUSINESS_PARTNER');

    // 1. Handler for direct BusinessPartner calls (Value Help)
    this.on('READ', BusinessPartners, async (req) => {
        // BPsrv.transaction(req) ensures the user's role/identity is passed to the external service
        return await BPsrv.transaction(req).send({
            query: req.query
        });
    });

    // 2. Handler for Risks to fetch associated Business Partner data
    this.on('READ', 'Risks', async (req, next) => {
        /* Step A: Execute the default logic to get Risks from local DB.
           The 'next()' function respects the @restrict annotations in service.cds.
           If a user is NOT a RiskViewer or RiskManager, this will throw a 403 error automatically.
        */
        const res = await next();

        /* Step B: Security and Data Check. 
           We only attempt to attach Business Partners if the local read was successful.
        */
        if (Array.isArray(res)) {
            await Promise.all(res.map(risk => _attachBP(risk, req)));
        } else if (res) {
            await _attachBP(res, req);
        }

        return res;
    });

    async function _attachBP(risk, req) {
        if (risk.supplier_BusinessPartner) {
            try {
                const bp = await BPsrv.transaction(req).send({
                    query: SELECT.from(BusinessPartners)
                                 .where({ BusinessPartner: risk.supplier_BusinessPartner })
                                 .columns('BusinessPartnerFullName', 'BusinessPartnerIsBlocked')
                });
                risk.supplier = bp[0];
            } catch (e) {
                console.error("Error fetching Business Partner from Sandbox:", e.message);
                // We leave risk.supplier empty rather than crashing the whole app
            }
        }
    }
});