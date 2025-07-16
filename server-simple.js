const express = require('express');
const dns = require('dns').promises;
const path = require('path');
const { exec } = require('child_process');

const app = express();
const PORT = 3000;

// Serve static files
app.use(express.static('.'));
app.use('/assets', express.static('assets'));

// DNS lookup endpoint
app.get('/api/dns-lookup', async (req, res) => {
    const { domain, type } = req.query;
    
    try {
        let record = null;
        let queryDomain = domain;
        
        switch(type) {
            case 'DMARC':
                queryDomain = `_dmarc.${domain}`;
                break;
            case 'MTA-STS':
                queryDomain = `_mta-sts.${domain}`;
                break;
            case 'TLS-RPT':
                queryDomain = `_smtp._tls.${domain}`;
                break;
        }
        
        if (type === 'MX') {
            const mxRecords = await dns.resolveMx(domain);
            record = mxRecords.map(mx => `${mx.priority} ${mx.exchange}`);
        } else if (type === 'DKIM') {
            const selectors = ['default', 'selector1', 'selector2', 'google', 'k1'];
            for (const selector of selectors) {
                try {
                    const dkimDomain = `${selector}._domainkey.${domain}`;
                    const records = await dns.resolveTxt(dkimDomain);
                    if (records.length > 0 && records[0].join('').includes('k=rsa')) {
                        record = records[0].join('');
                        break;
                    }
                } catch (error) {
                    continue;
                }
            }
        } else {
            const txtRecords = await dns.resolveTxt(queryDomain);
            const prefixes = {
                'SPF': 'v=spf1',
                'DMARC': 'v=DMARC1',
                'BIMI': 'v=BIMI1',
                'MTA-STS': 'v=STSv1',
                'TLS-RPT': 'v=TLSRPTv1'
            };
            
            const prefix = prefixes[type];
            if (prefix) {
                for (const txtRecord of txtRecords) {
                    const recordStr = txtRecord.join('');
                    if (recordStr.toLowerCase().startsWith(prefix.toLowerCase())) {
                        record = recordStr;
                        break;
                    }
                }
            }
        }
        
        res.json({ success: true, record });
    } catch (error) {
        res.json({ success: false, error: error.message, record: null });
    }
});

app.listen(PORT, () => {
    console.log(`Email Security Monitor running on http://localhost:${PORT}`);
    console.log('Open your browser and go to the URL above');
});
