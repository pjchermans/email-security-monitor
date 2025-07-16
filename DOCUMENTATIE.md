# Email Security Monitor - Documentatie & Handleiding

## 📋 Inhoudsopgave

1. [Overzicht](#overzicht)
2. [Installatie](#installatie)
3. [Gebruik](#gebruik)
4. [Functionaliteiten](#functionaliteiten)
5. [Technische Specificaties](#technische-specificaties)
6. [Beheer & Onderhoud](#beheer--onderhoud)
7. [Troubleshooting](#troubleshooting)
8. [Bijlagen](#bijlagen)

---

## 🛡️ Overzicht

### Wat is Email Security Monitor?

Email Security Monitor is om de email beveiliging van domeinen te monitoren en analyseren. De applicatie voert real-time DNS lookups uit en beoordeelt de implementatie van email beveiligingsprotocollen.

### Hoofdfuncties

- **Real-time DNS Analyse** - Live controle van SPF, DMARC, DKIM, MX records
- **Gemeente-specifieke Interface** - Voorgedefinieerde Nederlandse gemeente domeinen
- **Visuele Status Indicatoren** - Kleurgecodeerde status met gemeente logo's
- **Automatische Monitoring** - Instelbare automatische controle intervallen
- **Professionele Rapportage** - Gedetailleerde scoring en aanbevelingen
- **Export Functionaliteit** - JSON export voor compliance rapportage

### Doelgroep

- **Nederlandse Gemeenten** - IT-afdelingen en beleidsmedewerkers
- **ICT Service Providers** - Beheerders van gemeente infrastructuur
- **Compliance Officers** - Voor email security audits
- **IT Professionals** - Email beveiliging specialisten

---

## 🚀 Installatie

### Systeemvereisten

#### Minimale Vereisten
- **Besturingssysteem**: Windows 10/11, Linux Ubuntu 18.04+, macOS 10.14+
- **RAM**: 4GB minimum
- **Schijfruimte**: 500MB vrije ruimte
- **Internetverbinding**: Vereist voor DNS lookups
- **Browser**: Chrome 90+, Firefox 88+, Safari 14+, Edge 90+

#### Software Vereisten
- **Node.js**: Versie 18.0 of hoger
- **NPM**: Versie 8.0 of hoger (automatisch meegeleverd met Node.js)

### Installatie Stappen

#### Stap 1: Node.js Installeren
1. Download Node.js van [https://nodejs.org/](https://nodejs.org/)
2. Kies de LTS versie (aanbevolen)
3. Voer de installer uit en volg de instructies
4. Verificeer installatie:
   ```bash
   node --version
   npm --version
   ```

#### Stap 2: Applicatie Installeren
1. Download of kloon de applicatie bestanden
2. Open een terminal/command prompt
3. Navigeer naar de applicatie directory:
   ```bash
   cd /pad/naar/email-security-monitor
   ```
4. Installeer afhankelijkheden:
   ```bash
   npm install
   ```

#### Stap 3: Applicatie Starten
1. Start de server:
   ```bash
   node server-simple.js
   ```
2. Open een webbrowser
3. Ga naar: `http://localhost:3000`
4. De applicatie is nu beschikbaar

### Alternatieve Start Methoden

#### Windows Batch Script
```batch
@echo off
cd /d "C:\\pad\\naar\\email-security-monitor"
node server-simple.js
pause
```

#### Linux/Mac Shell Script
```bash
#!/bin/bash
cd "/pad/naar/email-security-monitor"
node server-simple.js
```

---

## 📖 Gebruik

### Eerste Gebruik

#### Interface Overzicht
Bij het opstarten ziet u:

1. **Header** - Logo, titel en hoofdcontroles
2. **Statistieken Overzicht** - Totaal, goed, waarschuwing, problemen
3. **Instellingen** - Automatische controle en export opties
4. **Domein Toevoegen** - Nieuwe domeinen invoeren
5. **Domein Overzicht** - Lijst met alle domeinen en hun status

#### Voorgedefinieerde Domeinen
De applicatie start met 7 voorgedefinieerde gemeente domeinen:
- **venlo.nl** (Gemeente Limburg)
- **roermond.nl** (Gemeente Limburg)  
- **weert.nl** (Gemeente Limburg)
- **nederweert.nl** (Gemeente Limburg)
- **someren.nl** (Gemeente Noord-Brabant)
- **asten.nl** (Gemeente Noord-Brabant)
- **ictnml.nl** (ICT Business)

### Basis Functies

#### 1. Domeinen Controleren

**Alle Domeinen Controleren:**
1. Klik op de knop **"Controleer Alle"** in de header
2. De applicatie voert DNS lookups uit voor alle domeinen
3. Status indicators worden real-time bijgewerkt
4. Wacht tot alle controles voltooid zijn

**Individueel Domein Controleren:**
1. Klik op een domein naam of status bolletje
2. U komt in de detail weergave
3. Klik op **"Controleer"** voor dit specifieke domein
4. Bekijk gedetailleerde resultaten

#### 2. Status Interpretatie

**Status Indicatoren:**
- 🟢 **Groen (Goed)**: Score 80-100, excellente beveiliging
- 🟠 **Oranje (Waarschuwing)**: Score 60-79, verbetering mogelijk
- 🔴 **Rood (Problemen)**: Score 0-59, actie vereist
- ⚫ **Grijs (Pending)**: Nog niet gecontroleerd

**Score Berekening:**
- Gebaseerd op SPF en DMARC record analyse
- Gemiddelde van beide scores (0-100 punten)
- Rekening houdend met best practices

#### 3. Nieuwe Domeinen Toevoegen

1. Scroll naar **"Nieuw Domein Toevoegen"**
2. Voer domeinnaam in (bijv. `gemeente.nl`)
3. Voeg optionele tags toe (bijv. `gemeente, groningen`)
4. Klik op **"Toevoegen"**
5. Het domein verschijnt in het overzicht

### Geavanceerde Functies

#### 1. Automatische Monitoring

**Instellen:**
1. Vink **"Automatische controle"** aan
2. Stel gewenst interval in (5-1440 minuten)
3. De applicatie controleert automatisch alle domeinen

**Voordelen:**
- Continue monitoring van email beveiliging
- Vroege detectie van configuratie wijzigingen
- Automatische status updates

#### 2. Detail Analyse

**Toegang tot Details:**
1. Klik op een domein naam of status indicator
2. Bekijk gedetailleerde DNS record informatie
3. Lees specifieke aanbevelingen per record type

**Beschikbare Analyses:**
- **SPF Records** - Sender Policy Framework
- **DMARC Records** - Domain-based Message Authentication
- **DKIM Records** - DomainKeys Identified Mail
- **MX Records** - Mail Exchange servers
- **BIMI Records** - Brand Indicators for Message Identification
- **MTA-STS Records** - Mail Transfer Agent Strict Transport Security

#### 3. Data Export

**Export Proces:**
1. Klik op **"Export Data"** in de instellingen
2. Kies opslaglocatie voor JSON bestand
3. Bestand bevat alle domein data en resultaten

**Export Inhoud:**
- Alle domeinen en configuraties
- Laatst bekende DNS records
- Historische scores en timestamps
- Versie informatie

---

## 🔧 Functionaliteiten

### DNS Record Analyse

#### SPF (Sender Policy Framework)
**Wat wordt gecontroleerd:**
- Aanwezigheid van SPF record
- All-mechanisme configuratie (`~all`, `-all`, `+all`)
- Aantal DNS lookups (maximaal 10)
- Include-mechanismen optimalisatie

**Scoring Criteria:**
- **Base Score**: 70 punten
- **+30 punten**: Strict policy (`-all`)
- **+20 punten**: Soft fail policy (`~all`)
- **-40 punten**: Onveilige configuratie (`+all`)
- **-30 punten**: Te veel DNS lookups (>10)

#### DMARC (Domain-based Message Authentication)
**Wat wordt gecontroleerd:**
- Aanwezigheid van DMARC record
- Policy configuratie (`p=reject`, `p=quarantine`, `p=none`)
- Aggregate reporting setup (`rua=`)
- Forensic reporting setup (`ruf=`)
- Policy percentage (`pct=`)

**Scoring Criteria:**
- **Base Score**: 60 punten
- **+40 punten**: Reject policy (`p=reject`)
- **+20 punten**: Quarantine policy (`p=quarantine`)
- **+5 punten**: Monitor policy (`p=none`)
- **+15 punten**: Aggregate reporting ingesteld
- **+10 punten**: Forensic reporting ingesteld

### Visuele Interface

#### Logo Systeem
**Gemeente Logo's:**
- Officiële logo's voor Weert, Someren, Asten (lokaal opgeslagen)
- Dynamische favicon's voor andere domeinen
- Fallback iconen (🏛️ gemeente, 🏢 bedrijf)

**Logo Beheer:**
- Lokale logo's in `assets/` directory
- Automatische detectie en laden
- Graceful fallback bij load errors

#### Responsive Design
**Ondersteunde Schermformaten:**
- **Desktop**: 1200px+ (volledig grid layout)
- **Tablet**: 768-1199px (aangepaste kolommen)
- **Mobile**: <768px (gestapelde layout)

### Automatisering

#### Auto-Check Functionaliteit
**Configuratie:**
- Interval: 5 minuten tot 24 uur
- Alleen bij inactieve gebruiker
- Real-time status updates
- Console logging voor debugging

**Implementatie:**
```javascript
// Auto-check wordt gestart
setInterval(() => {
    if (!this.isChecking) {
        this.checkAllDomains();
    }
}, intervalMs);
```

---

## ⚙️ Technische Specificaties

### Architectuur

#### Frontend
- **Framework**: Vanilla JavaScript ES6+
- **Styling**: Custom CSS3 met CSS Grid/Flexbox
- **Responsive**: Mobile-first approach
- **Icons**: Unicode emoji's en SVG assets

#### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js 4.18+
- **DNS**: Node.js built-in DNS module
- **CORS**: Enabled voor alle origins

#### Data Storage
- **Runtime**: In-memory object storage
- **Persistence**: Geen database, session-based
- **Export**: JSON format voor externe opslag

### API Endpoints

#### DNS Lookup API
```
GET /api/dns-lookup?domain={domain}&type={type}
```

**Parameters:**
- `domain`: Te controleren domeinnaam
- `type`: Record type (SPF, DMARC, DKIM, MX, BIMI, MTA-STS, TLS-RPT)

**Response Format:**
```json
{
  "success": true,
  "record": "v=spf1 include:_spf.google.com ~all"
}
```

#### Static Assets
```
GET /assets/{filename}
```
Serveert lokale logo's en andere assets.

### DNS Record Processing

#### Record Type Mapping
```javascript
const queryDomains = {
    'SPF': domain,                    // Direct TXT lookup
    'DMARC': `_dmarc.${domain}`,     // DMARC subdomain
    'MTA-STS': `_mta-sts.${domain}`, // MTA-STS subdomain
    'TLS-RPT': `_smtp._tls.${domain}`, // TLS-RPT subdomain
    'MX': domain,                     // MX record lookup
    'DKIM': `{selector}._domainkey.${domain}` // Multiple selectors
};
```

#### DKIM Selector Detection
De applicatie test automatisch common DKIM selectors:
- `default._domainkey.{domain}`
- `selector1._domainkey.{domain}`
- `selector2._domainkey.{domain}`
- `google._domainkey.{domain}`
- `k1._domainkey.{domain}`
- `s1._domainkey.{domain}`
- `dkim._domainkey.{domain}`

### Caching Strategie

#### DNS Cache
- **TTL**: 5 minuten (300.000ms)
- **Storage**: JavaScript Map object
- **Key Format**: `{domain}-{recordType}`
- **Cleanup**: Automatic op basis van timestamp

```javascript
const dnsCache = new Map();
const CACHE_TTL = 300000; // 5 minuten
```

---

## 🔧 Beheer & Onderhoud

### Dagelijks Gebruik

#### Monitoring Routine
1. **Ochtend Check** - Bekijk overall status alle domeinen
2. **Probleem Identificatie** - Focus op rode/oranje statussen
3. **Detail Analyse** - Onderzoek specifieke DNS issues
4. **Actie Planning** - Plan DNS configuratie wijzigingen

#### Wekelijkse Taken
1. **Export Data** - Backup van alle domein resultaten
2. **Trend Analyse** - Vergelijk scores over tijd
3. **Nieuwe Domeinen** - Voeg nieuwe gemeenten toe indien nodig
4. **Logo Updates** - Ververs gemeente logo's bij rebranding

### Systeem Onderhoud

#### Server Beheer
**Opstarten:**
```bash
# Handmatig starten
node server-simple.js

# Met PM2 (production)
npm install -g pm2
pm2 start server-simple.js --name "email-monitor"
pm2 startup
pm2 save
```

**Monitoring:**
```bash
# Server status controleren
netstat -an | grep :3000

# Process monitoring
ps aux | grep node

# Log monitoring
tail -f /var/log/email-monitor.log
```

#### Updates en Patches
1. **Backup maken** van huidige configuratie
2. **Download nieuwe versie** van de applicatie
3. **Stop de server** gracefully
4. **Vervang bestanden** (behoud assets/ directory)
5. **Update dependencies**: `npm install`
6. **Restart server** en test functionaliteit

### Logo Beheer

#### Nieuwe Logo's Toevoegen
1. **Plaats logo bestand** in `assets/` directory
2. **Ondersteunde formaten**: PNG, SVG, ICO
3. **Aanbevolen grootte**: 48x48px tot 256x256px
4. **Update configuratie** in `renderer.js`:

```javascript
const localLogos = {
    'nieuw-domein.nl': 'assets/nieuw-logo.png',
    // ... bestaande logo's
};
```

#### Logo Optimalisatie
- **SVG**: Voorkeur voor vectorlogo's (schaalbaar)
- **PNG**: Gebruik transparante achtergrond
- **Compressie**: Optimaliseer bestandsgrootte
- **Naming**: Gebruik duidelijke bestandsnamen

### Performance Optimalisatie

#### Frontend Optimalisatie
```javascript
// Debounce voor frequent updates
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Batch DOM updates
requestAnimationFrame(() => {
    // Multiple DOM updates hier
});
```

#### Backend Optimalisatie
```javascript
// DNS lookup timeout
const dns = require('dns').promises;
dns.setDefaultResultOrder('ipv4first');

// Connection pooling voor HTTP requests
const http = require('http');
const agent = new http.Agent({
    keepAlive: true,
    maxSockets: 10
});
```

---

## 🛠️ Troubleshooting

### Veelvoorkomende Problemen

#### 1. Server Start Problemen

**Symptoom**: Server start niet op
**Mogelijke Oorzaken:**
- Node.js niet geïnstalleerd
- Poort 3000 al in gebruik
- Insufficient permissions

**Oplossingen:**
```bash
# Node.js versie controleren
node --version

# Poort beschikbaarheid controleren
netstat -an | grep :3000
lsof -i :3000

# Alternatieve poort gebruiken
PORT=3001 node server-simple.js

# Permissions controleren (Linux/Mac)
sudo chown -R $USER:$USER /pad/naar/applicatie
chmod +x start-script.sh
```

#### 2. DNS Lookup Failures

**Symptoom**: Alle DNS lookups falen
**Mogelijke Oorzaken:**
- Geen internetverbinding
- DNS server problemen
- Firewall blokkering

**Oplossingen:**
```bash
# Internet connectiviteit testen
ping google.com

# DNS resolution testen
nslookup google.com
dig google.com

# Alternative DNS servers proberen
# In renderer.js:
const dns = require('dns');
dns.setServers(['8.8.8.8', '1.1.1.1']);
```

#### 3. Logo Loading Issues

**Symptoom**: Logo's laden niet
**Mogelijke Oorzaken:**
- Assets directory niet gevonden
- Incorrect bestandspaden
- MIME type problemen

**Oplossingen:**
```javascript
// Debugging logo paths
console.log('Logo URL:', logoUrl);

// Check bestand bestaat
const fs = require('fs');
if (fs.existsSync('assets/logo.png')) {
    console.log('Logo bestand gevonden');
}

// Server configuratie verificeren
app.use('/assets', express.static('assets', {
    setHeaders: (res, path) => {
        if (path.endsWith('.svg')) {
            res.setHeader('Content-Type', 'image/svg+xml');
        }
    }
}));
```

#### 4. Browser Compatibility

**Symptoom**: Interface werkt niet in bepaalde browsers
**Mogelijke Oorzaken:**
- Verouderde browser versie
- JavaScript disabled
- CORS issues

**Oplossingen:**
- **Update browser** naar nieuwste versie
- **Enable JavaScript** in browser settings
- **Whitelist localhost** in browser security settings
- **Use incognito mode** om cache issues uit te sluiten

#### 5. Performance Issues

**Symptoom**: Langzame responses of timeouts
**Mogelijke Oorzaken:**
- Veel domeinen tegelijk controleren
- Langzame DNS servers
- Memory leaks

**Oplossingen:**
```javascript
// Concurrent requests limiteren
const maxConcurrent = 5;
const chunks = _.chunk(domains, maxConcurrent);

for (const chunk of chunks) {
    await Promise.all(chunk.map(domain => 
        this.checkDomain(domain)
    ));
}

// Memory monitoring
console.log('Memory usage:', process.memoryUsage());

// DNS timeout instellen
const timeoutMs = 5000;
Promise.race([
    dns.resolveTxt(domain),
    new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Timeout')), timeoutMs)
    )
]);
```

### Error Logs & Debugging

#### Browser Console
```javascript
// Debug mode activeren
localStorage.setItem('debug', 'true');

// DNS lookup debugging
window.debugDNS = true;

// Performance monitoring
console.time('domainCheck');
// ... operatie
console.timeEnd('domainCheck');
```

#### Server Logging
```javascript
// Request logging middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
    next();
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(500).json({ error: 'Internal server error' });
});
```

### Recovery Procedures

#### Data Recovery
Als domein data verloren gaat:
1. **Check laatste export** bestanden
2. **Reconstruct vanuit logs** indien beschikbaar
3. **Handmatig re-add** kritieke domeinen
4. **Re-run checks** voor alle domeinen

#### System Recovery
Bij complete system failure:
1. **Fresh install** van Node.js
2. **Re-download** applicatie bestanden
3. **Restore assets** directory met logo's
4. **Import previous exports** indien beschikbaar
5. **Test all functionality** systematisch

---

## 📚 Bijlagen

### Bijlage A: DNS Record Referentie

#### SPF Record Syntax
```
v=spf1 include:_spf.google.com ip4:192.168.1.0/24 ~all
```

**Componenten:**
- `v=spf1` - SPF versie indicator
- `include:domain` - Include andere SPF records
- `ip4:range` - Geautoriseerde IPv4 adressen
- `ip6:range` - Geautoriseerde IPv6 adressen
- `a` - A record van domein
- `mx` - MX records van domein
- `all` - All-mechanisme (+ -allow, ~softfail, -deny)

#### DMARC Record Syntax
```
v=DMARC1; p=reject; rua=mailto:dmarc@domain.com; pct=100;
```

**Parameters:**
- `v=DMARC1` - DMARC versie
- `p=policy` - Policy (none, quarantine, reject)
- `rua=mailto:` - Aggregate reports email
- `ruf=mailto:` - Forensic reports email
- `pct=percentage` - Policy percentage (0-100)
- `sp=subdomain_policy` - Subdomain policy

#### DKIM Record Example
```
v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC...
```

### Bijlage B: Scoring Matrix

#### SPF Scoring
| Configuratie | Score Modifier | Rationale |
|-------------|----------------|-----------|
| Base SPF Record | +70 | Basis implementatie |
| Hard Fail (-all) | +30 | Beste beveiliging |
| Soft Fail (~all) | +20 | Goede beveiliging |
| Neutral (+all) | -40 | Onveilig |
| >10 DNS Lookups | -30 | Performance impact |
| 8-10 DNS Lookups | -10 | Waarschuwing |

#### DMARC Scoring
| Configuratie | Score Modifier | Rationale |
|-------------|----------------|-----------|
| Base DMARC Record | +60 | Basis implementatie |
| Policy: Reject | +40 | Maximale beveiliging |
| Policy: Quarantine | +20 | Goede beveiliging |
| Policy: None | +5 | Monitoring mode |
| Aggregate Reporting | +15 | Observability |
| Forensic Reporting | +10 | Detail monitoring |

### Bijlage C: Best Practices

#### Email Security Best Practices

**SPF Configuration:**
1. Start met restrictieve policy
2. Monitor DMARC reports
3. Geleidelijk verscherpen naar `-all`
4. Minimaliseer DNS lookups
5. Documenteer alle email bronnen

**DMARC Implementation:**
1. Begin met `p=none` voor monitoring
2. Analyseer aggregate reports
3. Upgrade naar `p=quarantine`
4. Uiteindelijk naar `p=reject`
5. Implementeer voor alle subdomains

**DKIM Setup:**
1. Gebruik sterke keys (2048-bit RSA)
2. Roteer keys regelmatig
3. Implementeer voor alle sending services
4. Test signature verification

#### Municipality Specific Advice

**Gemeente Email Security:**
- Implementeer strikte policies voor officiële communicatie
- Gebruik BIMI voor brand protection
- Monitor phishing aanvallen actief
- Train personeel in email security awareness
- Documenteer alle wijzigingen voor compliance

### Bijlage D: Compliance & Rapportage

#### Rapportage Templates

**Wekelijkse Status Report:**
```
Email Security Monitor - Week {week_number}

OVERZICHT:
- Totaal domeinen: {total}
- Goed (80-100): {good_count} ({good_percentage}%)
- Waarschuwing (60-79): {warning_count} ({warning_percentage}%)
- Problemen (0-59): {error_count} ({error_percentage}%)

ACTIEPUNTEN:
1. {action_item_1}
2. {action_item_2}
3. {action_item_3}

VOLGENDE WEEK:
- {next_week_priority_1}
- {next_week_priority_2}
```

**Maandelijkse Compliance Report:**
```
Email Security Compliance - {month} {year}

EXECUTIEVE SAMENVATTING:
- Algemene security posture: {overall_status}
- Belangrijkste risico's: {top_risks}
- Verbeteringen: {improvements}

TECHNISCHE DETAILS:
- SPF implementatie: {spf_coverage}%
- DMARC implementatie: {dmarc_coverage}%
- DKIM implementatie: {dkim_coverage}%

AANBEVELINGEN:
1. {recommendation_1}
2. {recommendation_2}
3. {recommendation_3}
```

### Bijlage E: API Reference

#### Complete API Documentation

**Endpoint: GET /api/dns-lookup**

*Request Parameters:*
```
domain (string, required): Domain name to check
type (string, required): Record type to lookup
```

*Supported Record Types:*
- SPF: Sender Policy Framework records
- DMARC: Domain-based Message Authentication records  
- DKIM: DomainKeys Identified Mail records
- MX: Mail Exchange records
- BIMI: Brand Indicators for Message Identification
- MTA-STS: Mail Transfer Agent Strict Transport Security
- TLS-RPT: TLS Reporting records

*Response Format:*
```json
{
  "success": boolean,
  "record": string|array|null,
  "error": string (only if success=false)
}
```

*Example Requests:*
```
GET /api/dns-lookup?domain=example.com&type=SPF
GET /api/dns-lookup?domain=gemeente.nl&type=DMARC
```

*Example Responses:*
```json
// Successful SPF lookup
{
  "success": true,
  "record": "v=spf1 include:_spf.google.com ~all"
}

// Failed lookup
{
  "success": false,
  "record": null,
  "error": "DNS resolution failed"
}

// MX record response
{
  "success": true,
  "record": ["10 mx1.example.com", "20 mx2.example.com"]
}
```

---

## 📞 Support & Contact

### Technische Ondersteuning
Voor technische vragen over de Email Security Monitor:

**GitHub Repository**: [Link naar repository]
**Documentatie**: Deze handleiding
**Issue Tracking**: GitHub Issues sectie

### Gemeente Specifieke Ondersteuning
Voor vragen over gemeente email security implementatie:

**Best Practices**: Zie Bijlage C
**Compliance**: Zie Bijlage D  
**Trainingen**: Neem contact op met uw ICT leverancier

### Feature Requests
Voor nieuwe functionaliteiten of verbeteringen:

1. Check bestaande GitHub Issues
2. Creëer nieuwe Issue met feature request template
3. Beschrijf use case en business value
4. Tag met 'enhancement' label

---

## 📄 Licentie & Copyright

**Email Security Monitor v1.0.0**

Copyright (c) 2025 Email Security Monitor Team

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

**Versie**: 1.0.0  
**Laatste Update**: Juli 2025  
**Auteur**: Email Security Monitor Development Team  
**Doelgroep**: Nederlandse Gemeenten & ICT Professionals