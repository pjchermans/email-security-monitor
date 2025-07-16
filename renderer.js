class EmailSecurityMonitor {
    constructor() {
        this.domains = [
            { id: 1, domain: 'venlo.nl', tags: ['gemeente', 'limburg'], lastChecked: null, status: 'pending', logo: 'https://icons.duckduckgo.com/ip3/venlo.nl.ico' },
            { id: 2, domain: 'roermond.nl', tags: ['gemeente', 'limburg'], lastChecked: null, status: 'pending', logo: 'https://icons.duckduckgo.com/ip3/roermond.nl.ico' },
            { id: 3, domain: 'weert.nl', tags: ['gemeente', 'limburg'], lastChecked: null, status: 'pending', logo: 'assets/Weert.png' },
            { id: 4, domain: 'nederweert.nl', tags: ['gemeente', 'limburg'], lastChecked: null, status: 'pending', logo: 'https://icons.duckduckgo.com/ip3/nederweert.nl.ico' },
            { id: 5, domain: 'someren.nl', tags: ['gemeente', 'noord-brabant'], lastChecked: null, status: 'pending', logo: 'assets/Someren.svg' },
            { id: 6, domain: 'asten.nl', tags: ['gemeente', 'noord-brabant'], lastChecked: null, status: 'pending', logo: 'assets/asten.svg' },
            { id: 7, domain: 'ictnml.nl', tags: ['ict', 'business'], lastChecked: null, status: 'pending', logo: 'https://icons.duckduckgo.com/ip3/ictnml.nl.ico' }
        ];
        this.checkResults = {};
        this.isChecking = false;
        this.currentMode = 'overview'; // 'overview' or 'detail'
        this.currentDomain = null;
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.renderOverview();
        this.updateStats();
        this.initializeAutoCheck();
        
        if (window.electronAPI) {
            window.electronAPI.onCheckAllDomains(() => this.checkAllDomains());
            window.electronAPI.onAddDomain(() => this.focusAddDomain());
            window.electronAPI.onExportData(() => this.exportData());
        }
    }

    setupEventListeners() {
        document.getElementById('checkAllBtn').addEventListener('click', () => this.checkAllDomains());
        document.getElementById('addDomainBtn').addEventListener('click', () => this.addDomain());
        document.getElementById('backToOverviewBtn').addEventListener('click', () => this.showOverview());
        document.getElementById('checkSingleBtn').addEventListener('click', () => this.checkCurrentDomain());
        
        document.getElementById('domainInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.addDomain();
        });
        document.getElementById('tagsInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.addDomain();
        });
    }

    showOverview() {
        this.currentMode = 'overview';
        document.getElementById('overviewMode').style.display = 'flex';
        document.getElementById('detailMode').style.display = 'none';
        this.renderOverview();
    }

    showDetail(domain) {
        this.currentMode = 'detail';
        this.currentDomain = domain;
        document.getElementById('overviewMode').style.display = 'none';
        document.getElementById('detailMode').style.display = 'flex';
        document.getElementById('detailDomainName').textContent = domain;
        this.renderDetail(domain);
    }

    async checkAllDomains() {
        if (this.isChecking) return;
        
        this.isChecking = true;
        this.updateCheckButton(true);

        for (const domain of this.domains) {
            await this.checkDomain(domain.domain);
            if (this.currentMode === 'overview') {
                this.renderOverview();
            } else if (this.currentDomain === domain.domain) {
                this.renderDetail(domain.domain);
            }
            this.updateStats();
        }

        this.isChecking = false;
        this.updateCheckButton(false);
    }

    async checkCurrentDomain() {
        if (!this.currentDomain || this.isChecking) return;
        
        this.isChecking = true;
        this.updateCheckSingleButton(true);
        
        await this.checkDomain(this.currentDomain);
        this.renderDetail(this.currentDomain);
        this.updateStats();
        
        this.isChecking = false;
        this.updateCheckSingleButton(false);
    }

    async checkDomain(domain) {
        try {
            const [spf, dmarc, dkim, mx, bimi, mtaSts, tlsRpt] = await Promise.all([
                this.dnsLookup(domain, 'SPF'),
                this.dnsLookup(domain, 'DMARC'),
                this.dnsLookup(domain, 'DKIM'),
                this.dnsLookup(domain, 'MX'),
                this.dnsLookup(domain, 'BIMI'),
                this.dnsLookup(domain, 'MTA-STS'),
                this.dnsLookup(domain, 'TLS-RPT')
            ]);

            const spfAnalysis = this.analyzeSPF(spf);
            const dmarcAnalysis = this.analyzeDMARC(dmarc);
            
            const overallScore = Math.round((spfAnalysis.score + dmarcAnalysis.score) / 2);
            
            this.checkResults[domain] = {
                domain,
                timestamp: new Date().toISOString(),
                overallScore,
                records: {
                    spf: { record: spf, analysis: spfAnalysis },
                    dmarc: { record: dmarc, analysis: dmarcAnalysis },
                    dkim: { record: dkim, hasRecord: !!dkim },
                    mx: { records: mx, count: mx?.length || 0 },
                    bimi: { record: bimi, hasRecord: !!bimi },
                    mtaSts: { record: mtaSts, hasRecord: !!mtaSts },
                    tlsRpt: { record: tlsRpt, hasRecord: !!tlsRpt }
                },
                status: overallScore >= 80 ? 'good' : overallScore >= 60 ? 'warning' : 'error'
            };

            const domainObj = this.domains.find(d => d.domain === domain);
            if (domainObj) {
                domainObj.lastChecked = new Date();
                domainObj.status = this.checkResults[domain].status;
            }

        } catch (error) {
            console.error(`Check failed for ${domain}:`, error);
            this.checkResults[domain] = {
                domain,
                timestamp: new Date().toISOString(),
                overallScore: 0,
                status: 'error',
                error: error.message
            };
        }
    }

    async dnsLookup(domain, recordType) {
        if (window.electronAPI) {
            const result = await window.electronAPI.dnsLookup(domain, recordType);
            return result.success ? result.record : null;
        } else {
            try {
                const response = await fetch(`/api/dns-lookup?domain=${encodeURIComponent(domain)}&type=${encodeURIComponent(recordType)}`);
                const data = await response.json();
                return data.success ? data.record : null;
            } catch (error) {
                console.error('DNS lookup failed:', error);
                return null;
            }
        }
    }

    analyzeSPF(spfRecord) {
        if (!spfRecord) return { 
            score: 0, 
            issues: ['Geen SPF record gevonden'], 
            recommendations: ['Voeg een SPF record toe'] 
        };
        
        const issues = [];
        const recommendations = [];
        let score = 70;

        if (spfRecord.includes('~all')) {
            score += 20;
        } else if (spfRecord.includes('-all')) {
            score += 30;
        } else if (spfRecord.includes('+all')) {
            issues.push('Gebruik van +all is zeer onveilig');
            recommendations.push('Wijzig +all naar ~all of -all');
            score -= 40;
        } else {
            issues.push('Geen expliciete all-mechanisme');
            recommendations.push('Voeg ~all of -all toe aan het einde');
            score -= 10;
        }

        const includes = (spfRecord.match(/include:/g) || []).length;
        const redirects = (spfRecord.match(/redirect=/g) || []).length;
        const exists = (spfRecord.match(/exists:/g) || []).length;
        const totalLookups = includes + redirects + exists;

        if (totalLookups > 10) {
            issues.push(`Te veel DNS lookups (${totalLookups}/10)`);
            recommendations.push('Verminder het aantal include-mechanismen');
            score -= 30;
        } else if (totalLookups > 8) {
            issues.push(`Bijna te veel DNS lookups (${totalLookups}/10)`);
            recommendations.push('Overweeg consolidatie van include-mechanismen');
            score -= 10;
        }

        return { score: Math.max(0, Math.min(100, score)), issues, recommendations };
    }

    analyzeDMARC(dmarcRecord) {
        if (!dmarcRecord) return { 
            score: 0, 
            issues: ['Geen DMARC record gevonden'], 
            recommendations: ['Implementeer een DMARC policy'] 
        };
        
        const issues = [];
        const recommendations = [];
        let score = 60;

        if (dmarcRecord.includes('p=reject')) {
            score += 40;
        } else if (dmarcRecord.includes('p=quarantine')) {
            score += 20;
            recommendations.push('Overweeg upgrade naar p=reject voor maximale beveiliging');
        } else if (dmarcRecord.includes('p=none')) {
            score += 5;
            issues.push('DMARC policy staat op "none"');
            recommendations.push('Upgrade naar p=quarantine of p=reject');
        }

        if (dmarcRecord.includes('rua=')) {
            score += 15;
        } else {
            issues.push('Geen aggregate reporting ingesteld');
            recommendations.push('Voeg rua= toe voor aggregate reports');
        }

        if (dmarcRecord.includes('ruf=')) {
            score += 10;
        } else {
            recommendations.push('Overweeg ruf= voor forensic reports');
        }

        const pctMatch = dmarcRecord.match(/pct=(\d+)/);
        if (pctMatch) {
            const pct = parseInt(pctMatch[1]);
            if (pct < 100) {
                issues.push(`DMARC percentage op ${pct}%`);
                recommendations.push('Verhoog pct naar 100% voor volledige dekking');
            }
        }

        return { score: Math.max(0, Math.min(100, score)), issues, recommendations };
    }

    addDomain() {
        const domainInput = document.getElementById('domainInput');
        const tagsInput = document.getElementById('tagsInput');
        
        const domain = domainInput.value.trim().toLowerCase();
        const tags = tagsInput.value.split(',').map(t => t.trim()).filter(t => t);
        
        if (!domain || this.domains.find(d => d.domain === domain)) {
            return;
        }

        // Check for local logo first, then fallback to DuckDuckGo
        const logoUrl = this.getLogoUrl(domain);

        const newId = Math.max(...this.domains.map(d => d.id), 0) + 1;
        this.domains.push({
            id: newId,
            domain,
            tags,
            lastChecked: null,
            status: 'pending',
            logo: logoUrl
        });

        domainInput.value = '';
        tagsInput.value = '';
        
        this.renderOverview();
        this.updateStats();
    }

    getLogoUrl(domain) {
        // Check for local logos first
        const localLogos = {
            'weert.nl': 'assets/Weert.png',
            'someren.nl': 'assets/Someren.svg',
            'asten.nl': 'assets/asten.svg'
        };
        
        if (localLogos[domain]) {
            return localLogos[domain];
        }
        
        // Fallback to DuckDuckGo favicon service
        return `https://icons.duckduckgo.com/ip3/${domain}.ico`;
    }

    removeDomain(id) {
        this.domains = this.domains.filter(d => d.id !== id);
        const domainToRemove = this.domains.find(d => d.id === id);
        if (domainToRemove) {
            delete this.checkResults[domainToRemove.domain];
        }
        this.renderOverview();
        this.updateStats();
    }

    focusAddDomain() {
        document.getElementById('domainInput').focus();
    }

    async exportData() {
        const exportData = {
            domains: this.domains,
            results: this.checkResults,
            exportDate: new Date().toISOString(),
            version: '1.0.0'
        };

        if (window.electronAPI) {
            const result = await window.electronAPI.exportData(exportData);
            if (result.success && !result.cancelled) {
                console.log(`Data exported to: ${result.path}`);
            }
        } else {
            const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `email-security-report-${new Date().toISOString().split('T')[0]}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }
    }

    renderOverview() {
        const container = document.getElementById('domainsOverviewList');
        
        if (this.domains.length === 0) {
            container.innerHTML = `
                <div class="loading">
                    <div style="font-size: 48px; margin-bottom: 16px;">📧</div>
                    <h3>Geen domeinen toegevoegd</h3>
                    <p>Voeg domeinen toe om hun email beveiliging te controleren</p>
                </div>
            `;
            return;
        }

        container.innerHTML = this.domains.map(domain => this.renderOverviewItem(domain)).join('');
        
        // Add event listeners for domain clicks
        this.domains.forEach(domain => {
            const element = document.getElementById(`domain-${domain.id}`);
            if (element) {
                element.addEventListener('click', () => this.showDetail(domain.domain));
            }
        });
    }

    renderOverviewItem(domain) {
        const result = this.checkResults[domain.domain];
        let statusClass = 'pending';
        let scoreText = '—';
        
        if (result) {
            statusClass = result.status;
            scoreText = result.overallScore;
        }
        
        const logoHtml = domain.logo ? 
            `<img src="${domain.logo}" alt="${domain.domain} logo" class="domain-logo" onerror="this.style.display='none'" />` : 
            `<div class="domain-logo-placeholder">
                <span class="domain-logo-icon">${domain.tags.includes('gemeente') ? '🏛️' : '🏢'}</span>
            </div>`;
        
        return `
            <div class="domain-overview-item" id="domain-${domain.id}">
                <div class="domain-logo-container">
                    ${logoHtml}
                </div>
                <div class="domain-overview-info">
                    <div class="domain-overview-name">${domain.domain}</div>
                    <div class="domain-overview-tags">
                        ${domain.tags.map(tag => `<span class="domain-tag">${tag}</span>`).join('')}
                    </div>
                    <div class="domain-overview-meta">
                        ${domain.lastChecked ? 
                            `Laatste check: ${new Date(domain.lastChecked).toLocaleString('nl-NL')}` : 
                            'Nog niet gecontroleerd'
                        }
                    </div>
                </div>
                <div class="domain-overview-status">
                    <div class="domain-overview-score">${scoreText}</div>
                    <div class="status-indicator-dot ${statusClass}"></div>
                </div>
            </div>
        `;
    }

    renderDetail(domain) {
        const result = this.checkResults[domain];
        const container = document.getElementById('domainDetail');
        
        if (!result) {
            container.innerHTML = `
                <div class="loading">
                    <div style="font-size: 48px; margin-bottom: 16px;">📧</div>
                    <h3>Geen gegevens beschikbaar</h3>
                    <p>Klik op "Controleer" om dit domein te analyseren</p>
                </div>
            `;
            return;
        }

        const scoreClass = result.overallScore >= 80 ? 'good' : result.overallScore >= 60 ? 'warning' : 'error';
        
        container.innerHTML = `
            <div class="domain-detail-header">
                <div class="domain-detail-info">
                    <div class="domain-detail-name">${domain}</div>
                    <div class="domain-detail-meta">
                        <span>Laatste controle: ${new Date(result.timestamp).toLocaleString('nl-NL')}</span>
                    </div>
                </div>
                <div class="domain-detail-score">
                    <div class="score-number ${scoreClass}">${result.overallScore}</div>
                    <div class="score-label">/100</div>
                </div>
            </div>
            
            <div class="progress-bar">
                <div class="progress-fill ${scoreClass}" style="width: ${result.overallScore}%"></div>
            </div>
            
            <div class="dns-records">
                ${this.renderDNSRecord('SPF', '📧', result.records.spf)}
                ${this.renderDNSRecord('DMARC', '🛡️', result.records.dmarc)}
                ${this.renderDNSRecord('DKIM', '🔑', result.records.dkim, true)}
                ${this.renderDNSRecord('MX', '🖥️', result.records.mx, true)}
                ${this.renderDNSRecord('BIMI', '🖼️', result.records.bimi, true)}
                ${this.renderDNSRecord('MTA-STS', '🔒', result.records.mtaSts, true)}
            </div>
        `;
    }

    renderDNSRecord(name, icon, record, isSimple = false) {
        if (isSimple) {
            const hasRecord = record.hasRecord || (record.records && record.records.length > 0);
            return `
                <div class="dns-record">
                    <div class="dns-record-header">
                        <span class="dns-record-icon">${icon}</span>
                        <span class="dns-record-title">${name}</span>
                        <span class="dns-record-score ${hasRecord ? 'good' : 'error'}">
                            ${hasRecord ? '✅' : '❌'}
                        </span>
                    </div>
                    <div class="dns-record-content">
                        ${hasRecord ? 
                            (record.records ? record.records.slice(0, 2).join(', ') : 'Gevonden') : 
                            'Niet gevonden'
                        }
                    </div>
                </div>
            `;
        } else {
            const scoreClass = record.analysis.score >= 80 ? 'good' : record.analysis.score >= 60 ? 'warning' : 'error';
            return `
                <div class="dns-record">
                    <div class="dns-record-header">
                        <span class="dns-record-icon">${icon}</span>
                        <span class="dns-record-title">${name}</span>
                        <span class="dns-record-score ${scoreClass}">
                            ${record.analysis.score}/100
                        </span>
                    </div>
                    <div class="dns-record-content">
                        ${record.record || 'Geen record'}
                    </div>
                    ${record.analysis.issues.length > 0 ? `
                        <div class="dns-record-issues">
                            ${record.analysis.issues.slice(0, 3).map(issue => `• ${issue}`).join('<br>')}
                        </div>
                    ` : ''}
                </div>
            `;
        }
    }

    updateStats() {
        const total = this.domains.length;
        const results = Object.values(this.checkResults);
        
        const good = results.filter(r => r.status === 'good').length;
        const warning = results.filter(r => r.status === 'warning').length;
        const error = results.filter(r => r.status === 'error').length;

        document.getElementById('totalDomains').textContent = total;
        document.getElementById('goodDomains').textContent = good;
        document.getElementById('warningDomains').textContent = warning;
        document.getElementById('errorDomains').textContent = error;
    }

    updateCheckButton(isChecking) {
        const btn = document.getElementById('checkAllBtn');
        if (isChecking) {
            btn.innerHTML = '<div class="spinner"></div>Controleren...';
            btn.disabled = true;
        } else {
            btn.innerHTML = '<span class="btn-icon">🔄</span>Controleer Alle';
            btn.disabled = false;
        }
    }

    updateCheckSingleButton(isChecking) {
        const btn = document.getElementById('checkSingleBtn');
        if (isChecking) {
            btn.innerHTML = '<div class="spinner"></div>Controleren...';
            btn.disabled = true;
        } else {
            btn.innerHTML = '<span class="btn-icon">🔄</span>Controleer';
            btn.disabled = false;
        }
    }

    // Auto-check functionality
    initializeAutoCheck() {
        this.autoCheckTimer = null;
        this.autoCheckInterval = 60; // minutes
        
        // Add event listeners after DOM is ready
        setTimeout(() => {
            const exportBtn = document.getElementById('exportDataBtn');
            if (exportBtn) {
                exportBtn.addEventListener('click', () => this.exportData());
            }
            
            const autoCheckbox = document.getElementById('autoCheck');
            if (autoCheckbox) {
                autoCheckbox.addEventListener('change', (e) => {
                    this.toggleAutoCheck(e.target.checked);
                });
            }
            
            const intervalInput = document.getElementById('checkInterval');
            if (intervalInput) {
                intervalInput.addEventListener('change', (e) => {
                    this.updateCheckInterval(parseInt(e.target.value));
                });
            }
        }, 100);
    }

    toggleAutoCheck(enabled) {
        if (enabled) {
            this.startAutoCheck();
        } else {
            this.stopAutoCheck();
        }
    }

    startAutoCheck() {
        this.stopAutoCheck(); // Clear existing timer
        
        const intervalMs = this.autoCheckInterval * 60 * 1000; // Convert to milliseconds
        
        this.autoCheckTimer = setInterval(() => {
            if (!this.isChecking) {
                console.log('Auto-check: Starting scheduled domain check');
                this.checkAllDomains();
            }
        }, intervalMs);
        
        console.log(`Auto-check started: ${this.autoCheckInterval} minutes interval`);
    }

    stopAutoCheck() {
        if (this.autoCheckTimer) {
            clearInterval(this.autoCheckTimer);
            this.autoCheckTimer = null;
            console.log('Auto-check stopped');
        }
    }

    updateCheckInterval(minutes) {
        if (minutes >= 5 && minutes <= 1440) { // 5 minutes to 24 hours
            this.autoCheckInterval = minutes;
            
            // Restart auto-check with new interval if it's enabled
            const autoCheckbox = document.getElementById('autoCheck');
            if (autoCheckbox && autoCheckbox.checked) {
                this.startAutoCheck();
            }
            
            console.log(`Check interval updated to: ${minutes} minutes`);
        }
    }
}

document.addEventListener('DOMContentLoaded', () => {
    new EmailSecurityMonitor();
});