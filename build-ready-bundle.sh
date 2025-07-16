                error: error.message
            };
        }
    }

    async dnsLookup(domain, recordType) {
        if (window.electronAPI) {
            const result = await window.electronAPI.dnsLookup(domain, recordType);
            return result.success ? result.record : null;
        }
        return null;
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

        const newId = Math.max(...this.domains.map(d => d.id), 0) + 1;
        this.domains.push({
            id: newId,
            domain,
            tags,
            lastChecked: null,
            status: 'pending'
        });

        domainInput.value = '';
        tagsInput.value = '';
        
        this.renderDomains();
        this.updateStats();
    }

    removeDomain(id) {
        this.domains = this.domains.filter(d => d.id !== id);
        const domainToRemove = this.domains.find(d => d.id === id);
        if (domainToRemove) {
            delete this.checkResults[domainToRemove.domain];
        }
        this.renderDomains();
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
        }
    }

    renderDomains() {
        const container = document.getElementById('domainsList');
        
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

        container.innerHTML = this.domains.map(domain => this.renderDomainCard(domain)).join('');
        
        this.domains.forEach(domain => {
            const removeBtn = document.getElementById(`remove-${domain.id}`);
            const checkBtn = document.getElementById(`check-${domain.id}`);
            
            if (removeBtn) {
                removeBtn.addEventListener('click', () => this.removeDomain(domain.id));
            }
            if (checkBtn) {
                checkBtn.addEventListener('click', () => this.checkSingleDomain(domain.domain));
            }
        });
    }

    renderDomainCard(domain) {
        const result = this.checkResults[domain.domain];
        const scoreClass = result ? (result.overallScore >= 80 ? 'good' : result.overallScore >= 60 ? 'warning' : 'error') : '';
        
        return `
            <div class="domain-card">
                <div class="domain-header">
                    <div class="domain-info">
                        <div class="domain-name">${domain.domain}</div>
                        <div class="domain-meta">
                            <span>${domain.lastChecked ? 
                                `Laatste controle: ${new Date(domain.lastChecked).toLocaleString('nl-NL')}` : 
                                'Nog niet gecontroleerd'
                            }</span>
                            ${domain.tags.length > 0 ? `
                                <div class="domain-tags">
                                    ${domain.tags.map(tag => `<span class="domain-tag">${tag}</span>`).join('')}
                                </div>
                            ` : ''}
                        </div>
                    </div>
                    ${result ? `
                        <div class="domain-score">
                            <div class="score-number ${scoreClass}">${result.overallScore}</div>
                            <div class="score-label">/100</div>
                        </div>
                    ` : ''}
                    <div class="domain-actions">
                        <button id="check-${domain.id}" class="btn btn-primary btn-small">
                            <span class="btn-icon">🔄</span>
                            Check
                        </button>
                        <button id="remove-${domain.id}" class="btn btn-danger btn-small">
                            <span class="btn-icon">🗑️</span>
                        </button>
                    </div>
                </div>
                
                ${result ? `
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
                ` : `
                    <div class="loading">
                        <div>Klik op "Check" om dit domein te controleren</div>
                    </div>
                `}
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
                            ${record.analysis.issues.slice(0, 2).map(issue => `• ${issue}`).join('<br>')}
                        </div>
                    ` : ''}
                </div>
            `;
        }
    }

    async checkSingleDomain(domain) {
        await this.checkDomain(domain);
        this.updateDomainCard(domain);
        this.updateStats();
    }

    updateDomainCard(domain) {
        this.renderDomains();
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
}

document.addEventListener('DOMContentLoaded', () => {
    new EmailSecurityMonitor();
});

# ============================================================================
# BUILD-ALL.JS - Master build script
# ============================================================================
# BESTAND: build-all.js
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const colors = {
    reset: '\x1b[0m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m'
};

function log(message, color = 'blue') {
    console.log(`${colors[color]}[INFO]${colors.reset} ${message}`);
}

function success(message) {
    console.log(`${colors.green}[SUCCESS]${colors.reset} ${message}`);
}

function error(message) {
    console.log(`${colors.red}[ERROR]${colors.reset} ${message}`);
}

function warning(message) {
    console.log(`${colors.yellow}[WARNING]${colors.reset} ${message}`);
}

async function cleanBuildDirs() {
    log('Cleaning build directories...');
    const dirs = ['dist-portable', 'portable-folder', 'single-exe'];
    
    for (const dir of dirs) {
        if (fs.existsSync(dir)) {
            fs.rmSync(dir, { recursive: true, force: true });
        }
        fs.mkdirSync(dir, { recursive: true });
    }
    
    success('Build directories cleaned');
}

async function buildElectronPortable() {
    log('Building Electron Portable...');
    
    try {
        execSync('npx electron-builder --win portable --x64', { 
            stdio: 'inherit',
            env: { ...process.env, NODE_ENV: 'production' }
        });
        
        success('Electron Portable build completed');
    } catch (err) {
        error(`Electron build failed: ${err.message}`);
        throw err;
    }
}

async function buildPKGSingle() {
    log('Building PKG Single Executable...');
    
    try {
        // Create standalone server
        const serverCode = `
const express = require('express');
const cors = require('cors');
const dns = require('dns').promises;
const path = require('path');
const { exec } = require('child_process');

const app = express();
app.use(cors());
app.use(express.static(path.join(__dirname, 'public')));

const PORT = process.env.PORT || 3000;

app.get('/api/dns-lookup', async (req, res) => {
  const { domain, type } = req.query;
  
  try {
    let record = null;
    let queryDomain = domain;
    
    switch(type) {
      case 'DMARC':
        queryDomain = \`_dmarc.\${domain}\`;
        break;
      case 'MTA-STS':
        queryDomain = \`_mta-sts.\${domain}\`;
        break;
      case 'TLS-RPT':
        queryDomain = \`_smtp._tls.\${domain}\`;
        break;
    }
    
    if (type === 'MX') {
      const mxRecords = await dns.resolveMx(domain);
      record = mxRecords.map(mx => \`\${mx.priority} \${mx.exchange}\`);
    } else if (type === 'DKIM') {
      const selectors = ['default', 'selector1', 'selector2', 'google', 'k1'];
      for (const selector of selectors) {
        try {
          const dkimDomain = \`\${selector}._domainkey.\${domain}\`;
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

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(\`Email Security Monitor running on http://localhost:\${PORT}\`);
  const start = (process.platform == 'darwin'? 'open': process.platform == 'win32'? 'start': 'xdg-open');
  exec(\`\${start} http://localhost:\${PORT}\`);
});
`;

        fs.mkdirSync('single-exe/public', { recursive: true });
        fs.writeFileSync('single-exe/server-standalone.js', serverCode);
        
        // Create package.json for PKG
        const pkgConfig = {
            name: 'email-monitor-single',
            version: '1.0.0',
            main: 'server-standalone.js',
            bin: 'server-standalone.js',
            pkg: {
                targets: ['node18-win-x64'],
                assets: ['public/**/*']
            },
            dependencies: {
                express: '^4.18.2',
                cors: '^2.8.5'
            }
        };
        
        fs.writeFileSync('single-exe/package.json', JSON.stringify(pkgConfig, null, 2));
        
        // Copy web assets
        const filesToCopy = ['index.html', 'styles.css', 'renderer.js'];
        for (const file of filesToCopy) {
            if (fs.existsSync(file)) {
                fs.copyFileSync(file, `single-exe/public/${file}`);
            }
        }
        
        // Build PKG
        process.chdir('single-exe');
        execSync('npm install --production', { stdio: 'inherit' });
        execSync('npx pkg . --out-path ../dist-portable', { stdio: 'inherit' });
        process.chdir('..');
        
        success('PKG Single Executable completed');
    } catch (err) {
        error(`PKG build failed: ${err.message}`);
        throw err;
    }
}

async function buildFolderPackage() {
    log('Building Portable Folder Package...');
    
    try {
        const folderPath = 'portable-folder/EmailMonitor-Portable';
        fs.mkdirSync(`${folderPath}/data`, { recursive: true });
        
        // Copy application files
        const filesToCopy = ['main.js', 'preload.js', 'renderer.js', 'index.html', 'styles.css', 'package.json'];
        
        for (const file of filesToCopy) {
            if (fs.existsSync(file)) {
                fs.copyFileSync(file, `${folderPath}/${file}`);
            }
        }
        
        // Create Windows launcher
        const windowsLauncher = `@echo off
title Email Security Monitor - Portable
cls
echo.
echo ========================================
echo  Email Security Monitor - Portable
echo ========================================
echo.

node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Node.js not found!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

if not exist node_modules (
    echo Installing dependencies...
    npm install --production
)

echo Starting Email Security Monitor...
npm start

pause`;

        fs.writeFileSync(`${folderPath}/start-windows.bat`, windowsLauncher);
        
        // Create Linux launcher
        const linuxLauncher = `#!/bin/bash
clear
echo "========================================"
echo " Email Security Monitor - Portable"
echo "========================================"
echo ""

if ! command -v node &> /dev/null; then
    echo "Error: Node.js not found!"
    echo "Please install Node.js from https://nodejs.org/"
    read -p "Press Enter to exit..."
    exit 1
fi

if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install --production
fi

echo "Starting Email Security Monitor..."
npm start

read -p "Press Enter to exit..."`;

        fs.writeFileSync(`${folderPath}/start-linux.sh`, linuxLauncher);
        fs.chmodSync(`${folderPath}/start-linux.sh`, '755');
        
        // Create README
        const readme = `Email Security Monitor - Portable Edition
==========================================

QUICK START:
Windows: Double-click "start-windows.bat"
Linux:   Run "./start-linux.sh"

REQUIREMENTS:
- Node.js 18+ (https://nodejs.org/)

FEATURES:
✅ No installation required
✅ Portable between computers
✅ Real DNS lookups
✅ Data stored in local "data" folder
✅ Professional interface

For more information, see the main documentation.`;

        fs.writeFileSync(`${folderPath}/README.txt`, readme);
        
        success('Portable Folder Package completed');
    } catch (err) {
        error(`Folder package build failed: ${err.message}`);
        throw err;
    }
}

async function createDocumentation() {
    log('Creating documentation...');
    
    const readme = `# Email Security Monitor - Complete Portable Suite

## 🚀 Quick Start

Choose your preferred version:

### 1. Electron Portable (Recommended)
- Download: \`EmailMonitor-Electron-Portable-1.0.0.exe\`
- Size: ~80MB
- Requirements: None
- Usage: Double-click to run

### 2. PKG Single Executable
- Download: \`email-monitor-single-win.exe\`
- Size: ~50MB  
- Requirements: None
- Usage: Run executable, browser opens automatically

### 3. Folder Package
- Download: \`EmailMonitor-Folder-Portable.zip\`
- Size: ~5MB
- Requirements: Node.js 18+
- Usage: Extract and run start script

## 📊 Features

✅ **Real DNS Lookups** - Live SPF, DMARC, DKIM, MX analysis
✅ **Dutch Municipality Focus** - Pre-loaded with common domains
✅ **Professional Scoring** - 0-100 security assessment
✅ **Export Capabilities** - JSON reports for compliance
✅ **Portable Data** - Take your settings anywhere
✅ **No Installation** - Ready to run immediately

## 🏛️ Perfect for Dutch Municipalities

Pre-configured with domains like:
- venlo.nl, roermond.nl, weert.nl
- nederweert.nl, someren.nl, asten.nl
- Plus custom business domains

## 🔧 System Requirements

- **Windows**: 10/11 (x64)
- **Linux**: Ubuntu 18.04+ (x64)
- **Internet**: Required for DNS lookups
- **RAM**: 4GB minimum
- **Storage**: 100MB free space

## 📞 Support

For issues or questions, check the console output for detailed error messages.
All versions include comprehensive logging for troubleshooting.

Built with ❤️ for Dutch IT professionals and municipalities.`;

    fs.writeFileSync('dist-portable/README.md', readme);
    
    // Create universal launcher
    const launcher = `@echo off
title Email Security Monitor - Universal Launcher
cls
echo.
echo ================================================================
echo  Email Security Monitor - Choose Your Version
echo ================================================================
echo.
echo 1. Electron Portable (Recommended) - Native desktop app
echo 2. PKG Single Executable - Web interface
echo 3. Folder Package - Full source code
echo.
echo 0. Exit
echo.
set /p choice="Choose version (0-3): "

if "%choice%"=="1" (
    if exist "EmailMonitor-Electron-Portable-1.0.0.exe" (
        start "" "EmailMonitor-Electron-Portable-1.0.0.exe"
        echo Electron version started!
    ) else (
        echo ERROR: Electron executable not found!
    )
) else if "%choice%"=="2" (
    if exist "email-monitor-single-win.exe" (
        start "" "email-monitor-single-win.exe"
        echo PKG version started! Browser should open automatically.
    ) else (
        echo ERROR: PKG executable not found!
    )
) else if "%choice%"=="3" (
    echo Please extract the folder package first and run the start script
) else if "%choice%"=="0" (
    exit /b 0
) else (
    echo Invalid choice!
)

pause`;

    fs.writeFileSync('dist-portable/launch-universal.bat', launcher);
    
    success('Documentation created');
}

async function main() {
    console.log('\n================================================================');
    console.log(' Email Security Monitor - Complete Build Process');
    console.log('================================================================\n');
    
    try {
        await cleanBuildDirs();
        await buildElectronPortable();
        await buildPKGSingle();
        await buildFolderPackage();
        await createDocumentation();
        
        console.log('\n' + '='.repeat(64));
        success('🎉 Complete build finished!');
        console.log('='.repeat(64));
        
        console.log('\n📁 Files created in dist-portable/:');
        const files = fs.readdirSync('dist-portable');
        files.forEach(file => {
            const stats = fs.statSync(`dist-portable/${file}`);
            const size = (stats.size / 1024 / 1024).toFixed(1);
            console.log(`   ${file} (${size}MB)`);
        });
        
        console.log('\n🚀 Ready to distribute!');
        console.log('\n📖 Next steps:');
        console.log('   1. Test: launch-universal.bat');
        console.log('   2. Distribute: Copy dist-portable/ folder');
        console.log('   3. Documentation: README.md');
        
    } catch (error) {
        error(`Build failed: ${error.message}`);
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = { main };

# ============================================================================
# TEST-DNS.JS - Test DNS functionality
# ============================================================================
# BESTAND: test-dns.js
const dns = require('dns').promises;

async function testDNS() {
    console.log('Testing DNS functionality...');
    
    const testDomains = ['google.com', 'microsoft.com', 'github.com'];
    
    for (const domain of testDomains) {
        console.log(`\\nTesting ${domain}:`);
        
        try {
            // Test MX
            const mx = await dns.resolveMx(domain);
            console.log(`  MX: ${mx.length} records found`);
            
            // Test TXT (for SPF)
            const txt = await dns.resolveTxt(domain);
            const spf = txt.find(record => record.join('').startsWith('v=spf1'));
            console.log(`  SPF: ${spf ? 'Found' : 'Not found'}`);
            
            // Test DMARC
            try {
                const dmarc = await dns.resolveTxt(`_dmarc.${domain}`);
                const dmarcRecord = dmarc.find(record => record.join('').startsWith('v=DMARC1'));
                console.log(`  DMARC: ${dmarcRecord ? 'Found' : 'Not found'}`);
            } catch (error) {
                console.log(`  DMARC: Not found`);
            }
            
        } catch (error) {
            console.log(`  Error: ${error.message}`);
        }
    }
    
    console.log('\\n✅ DNS test completed!');
}

if (require.main === module) {
    testDNS();
}

module.exports = { testDNS };

# ============================================================================
# SETUP INSTRUCTIONS - Complete Quick Start Guide
# ============================================================================
# BESTAND: QUICK-START.md

# Email Security Monitor - Build-Ready Bundle
# ==========================================

## 🚀 QUICK START (5 minutes total)

### Step 1: Extract All Files (1 minute)
Create a new folder and copy all the content above into these files:
- package.json
- main.js  
- preload.js
- index.html
- styles.css
- renderer.js
- build-all.js
- test-dns.js

### Step 2: Install Dependencies (2 minutes)
```bash
npm install
```

### Step 3: Test DNS (Optional - 30 seconds)
```bash
npm test
```

### Step 4: Build All Versions (2 minutes)
```bash
npm run build-all
```

### Step 5: Test & Distribute
```bash
# Test the universal launcher
cd dist-portable
launch-universal.bat
```

## 📦 What You Get

After running `npm run build-all`, you'll have:

```
dist-portable/
├── EmailMonitor-Electron-Portable-1.0.0.exe    # ~80MB - Best for end users
├── email-monitor-single-win.exe                 # ~50MB - Web interface
├── portable-folder/EmailMonitor-Portable/       # ~5MB - Full source
├── launch-universal.bat                         # Universal launcher
└── README.md                                    # Documentation
```

### Email Security Monitor - Complete Build-Ready Bundle
# =====================================================
# 
# Dit is een complete, build-klare bundel van Email Security Monitor
# Alle bestanden zijn inbegrepen voor directe gebruik
#
# QUICK START:
# 1. Kopieer deze hele content naar een nieuwe folder
# 2. Run: npm install
# 3. Run: npm run build-all
# 4. Klaar! Portable executables in dist-portable/

# ============================================================================
# PACKAGE.JSON - Main configuration
# ============================================================================
# BESTAND: package.json
{
  "name": "email-security-monitor-complete",
  "version": "1.0.0",
  "description": "Complete Portable Suite - DNS Email Security Monitor",
  "main": "main.js",
  "homepage": "https://github.com/email-security-monitor",
  "author": {
    "name": "Email Security Monitor Team",
    "email": "info@emailsecuritymonitor.com"
  },
  "license": "MIT",
  "scripts": {
    "start": "electron .",
    "dev": "electron . --dev",
    "build-all": "node build-all.js",
    "build-electron": "electron-builder --win portable --x64",
    "build-pkg": "node build-pkg.js",
    "build-folder": "node build-folder.js",
    "clean": "rimraf dist-portable portable-folder single-exe",
    "test": "node test-dns.js",
    "postinstall": "echo 'Dependencies installed! Run: npm run build-all'"
  },
  "keywords": [
    "email", "security", "dns", "spf", "dmarc", "dkim", 
    "portable", "desktop", "monitoring", "gemeente", "compliance"
  ],
  "devDependencies": {
    "electron": "^28.0.0",
    "electron-builder": "^24.6.4",
    "pkg": "^5.8.1",
    "rimraf": "^5.0.5",
    "archiver": "^6.0.1"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  },
  "build": {
    "appId": "com.emailmonitor.portable",
    "productName": "Email Security Monitor",
    "directories": {
      "output": "dist-portable"
    },
    "files": [
      "main.js",
      "preload.js",
      "renderer.js",
      "index.html",
      "styles.css",
      "assets/**/*"
    ],
    "win": {
      "target": "portable",
      "icon": "assets/icon.ico",
      "artifactName": "EmailMonitor-Electron-Portable-${version}.exe"
    },
    "linux": {
      "target": "AppImage",
      "icon": "assets/icon.png",
      "artifactName": "EmailMonitor-Electron-Portable-${version}.AppImage"
    }
  }
}

# ============================================================================
# MAIN.JS - Electron hoofdproces
# ============================================================================
# BESTAND: main.js
const { app, BrowserWindow, ipcMain, Menu, dialog } = require('electron');
const path = require('path');
const fs = require('fs');
const dns = require('dns').promises;

let mainWindow;
const isPortable = process.env.PORTABLE || process.argv.includes('--portable');
const userDataPath = isPortable ? 
  path.join(path.dirname(process.execPath), 'data') : 
  app.getPath('userData');

if (isPortable && !fs.existsSync(userDataPath)) {
  fs.mkdirSync(userDataPath, { recursive: true });
}

if (isPortable) {
  app.setPath('userData', userDataPath);
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    },
    icon: path.join(__dirname, 'assets', 'icon.png'),
    show: false,
    title: 'Email Security Monitor' + (isPortable ? ' - Portable' : '')
  });

  mainWindow.loadFile('index.html');
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
  });

  createMenu();
}

function createMenu() {
  const template = [
    {
      label: 'File',
      submenu: [
        {
          label: 'Export Results',
          accelerator: 'CmdOrCtrl+E',
          click: () => mainWindow.webContents.send('export-data')
        },
        { type: 'separator' },
        {
          label: 'Exit',
          accelerator: 'CmdOrCtrl+Q',
          click: () => app.quit()
        }
      ]
    },
    {
      label: 'Tools',
      submenu: [
        {
          label: 'Check All Domains',
          accelerator: 'F5',
          click: () => mainWindow.webContents.send('check-all-domains')
        },
        {
          label: 'Add Domain',
          accelerator: 'CmdOrCtrl+N',
          click: () => mainWindow.webContents.send('add-domain')
        }
      ]
    },
    {
      label: 'Help',
      submenu: [
        {
          label: 'About',
          click: () => {
            dialog.showMessageBox(mainWindow, {
              type: 'info',
              title: 'About Email Security Monitor',
              message: 'Email Security Monitor v1.0.0',
              detail: 'DNS Email Security Analysis Tool\\nBuilt for Dutch municipalities and IT professionals'
            });
          }
        }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

// DNS Lookup Handler met caching
const dnsCache = new Map();
const CACHE_TTL = 300000; // 5 minuten

ipcMain.handle('dns-lookup', async (event, domain, recordType) => {
  const cacheKey = `${domain}-${recordType}`;
  const cached = dnsCache.get(cacheKey);
  
  if (cached && (Date.now() - cached.timestamp) < CACHE_TTL) {
    return cached.result;
  }

  try {
    let result = null;
    let queryDomain = domain;
    
    switch(recordType) {
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
    
    if (recordType === 'MX') {
      const mxRecords = await dns.resolveMx(domain);
      result = mxRecords.map(mx => `${mx.priority} ${mx.exchange}`);
    } else if (recordType === 'DKIM') {
      result = await checkDKIMSelectors(domain);
    } else {
      const txtRecords = await dns.resolveTxt(queryDomain);
      result = findSpecificTXTRecord(txtRecords, recordType);
    }
    
    const response = { success: true, record: result };
    dnsCache.set(cacheKey, { result: response, timestamp: Date.now() });
    return response;
    
  } catch (error) {
    const response = { success: false, error: error.message, record: null };
    dnsCache.set(cacheKey, { result: response, timestamp: Date.now() - (CACHE_TTL - 30000) });
    return response;
  }
});

function findSpecificTXTRecord(txtRecords, recordType) {
  const prefixes = {
    'SPF': 'v=spf1',
    'DMARC': 'v=DMARC1',
    'BIMI': 'v=BIMI1',
    'MTA-STS': 'v=STSv1',
    'TLS-RPT': 'v=TLSRPTv1'
  };
  
  const prefix = prefixes[recordType];
  if (!prefix) return null;
  
  for (const record of txtRecords) {
    const recordStr = record.join('');
    if (recordStr.toLowerCase().startsWith(prefix.toLowerCase())) {
      return recordStr;
    }
  }
  return null;
}

async function checkDKIMSelectors(domain) {
  const selectors = ['default', 'selector1', 'selector2', 'google', 'k1', 's1', 'dkim'];
  
  for (const selector of selectors) {
    try {
      const dkimDomain = `${selector}._domainkey.${domain}`;
      const txtRecords = await dns.resolveTxt(dkimDomain);
      
      for (const record of txtRecords) {
        const recordStr = record.join('');
        if (recordStr.includes('k=rsa') || recordStr.includes('p=')) {
          return recordStr;
        }
      }
    } catch (error) {
      continue;
    }
  }
  return null;
}

ipcMain.handle('export-data', async (event, data) => {
  try {
    const { filePath } = await dialog.showSaveDialog(mainWindow, {
      defaultPath: `email-security-report-${new Date().toISOString().split('T')[0]}.json`,
      filters: [
        { name: 'JSON Files', extensions: ['json'] },
        { name: 'All Files', extensions: ['*'] }
      ]
    });
    
    if (filePath) {
      fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
      return { success: true, path: filePath };
    }
    return { success: false, cancelled: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

# ============================================================================
# PRELOAD.JS - Veilige communicatie
# ============================================================================
# BESTAND: preload.js
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  dnsLookup: (domain, recordType) => 
    ipcRenderer.invoke('dns-lookup', domain, recordType),
  
  exportData: (data) => 
    ipcRenderer.invoke('export-data', data),
  
  onExportData: (callback) => 
    ipcRenderer.on('export-data', callback),
  onCheckAllDomains: (callback) => 
    ipcRenderer.on('check-all-domains', callback),
  onAddDomain: (callback) => 
    ipcRenderer.on('add-domain', callback),
  
  platform: process.platform,
  version: process.versions.electron
});

# ============================================================================
# INDEX.HTML - Frontend interface
# ============================================================================
# BESTAND: index.html
<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Security Monitor</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div id="app">
        <header class="header">
            <div class="header-content">
                <div class="logo">
                    <div class="logo-icon">🛡️</div>
                    <h1>Email Security Monitor</h1>
                </div>
                <div class="header-actions">
                    <div class="status-indicator">
                        <span class="status-dot active"></span>
                        <span>Live DNS</span>
                    </div>
                    <button id="checkAllBtn" class="btn btn-primary">
                        <span class="btn-icon">🔄</span>
                        Controleer Alle
                    </button>
                </div>
            </div>
        </header>

        <main class="main">
            <div class="sidebar">
                <div class="sidebar-section">
                    <h3>Domein Toevoegen</h3>
                    <div class="add-domain-form">
                        <input type="text" id="domainInput" placeholder="example.com" />
                        <input type="text" id="tagsInput" placeholder="Tags (komma gescheiden)" />
                        <button id="addDomainBtn" class="btn btn-success">
                            <span class="btn-icon">➕</span>
                            Toevoegen
                        </button>
                    </div>
                </div>

                <div class="sidebar-section">
                    <h3>Statistieken</h3>
                    <div class="stats">
                        <div class="stat-item">
                            <span class="stat-label">Totaal</span>
                            <span class="stat-value" id="totalDomains">7</span>
                        </div>
                        <div class="stat-item good">
                            <span class="stat-label">Goed</span>
                            <span class="stat-value" id="goodDomains">0</span>
                        </div>
                        <div class="stat-item warning">
                            <span class="stat-label">Waarschuwing</span>
                            <span class="stat-value" id="warningDomains">0</span>
                        </div>
                        <div class="stat-item error">
                            <span class="stat-label">Problemen</span>
                            <span class="stat-value" id="errorDomains">0</span>
                        </div>
                    </div>
                </div>

                <div class="sidebar-section">
                    <h3>Instellingen</h3>
                    <div class="settings">
                        <label>
                            <input type="checkbox" id="autoCheck" checked />
                            Auto-controle
                        </label>
                        <label>
                            Interval (min):
                            <input type="number" id="checkInterval" value="60" min="5" max="1440" />
                        </label>
                    </div>
                </div>
            </div>

            <div class="content">
                <div id="domainsList" class="domains-list">
                    <!-- Domeinen worden hier dynamisch toegevoegd -->
                </div>
            </div>
        </main>
    </div>

    <script src="renderer.js"></script>
</body>
</html>

# ============================================================================
# STYLES.CSS - Modern styling
# ============================================================================
# BESTAND: styles.css
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: #f5f5f5;
    color: #333;
    overflow: hidden;
}

#app {
    height: 100vh;
    display: flex;
    flex-direction: column;
}

/* Header */
.header {
    background: white;
    border-bottom: 1px solid #e1e5e9;
    padding: 16px 24px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo {
    display: flex;
    align-items: center;
    gap: 12px;
}

.logo-icon {
    font-size: 28px;
}

.logo h1 {
    font-size: 24px;
    font-weight: 600;
    color: #1f2937;
}

.header-actions {
    display: flex;
    align-items: center;
    gap: 16px;
}

.status-indicator {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    color: #6b7280;
}

.status-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #10b981;
    box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.3);
}

/* Main Layout */
.main {
    flex: 1;
    display: flex;
    overflow: hidden;
}

.sidebar {
    width: 300px;
    background: white;
    border-right: 1px solid #e1e5e9;
    padding: 20px;
    overflow-y: auto;
}

.content {
    flex: 1;
    padding: 20px;
    overflow-y: auto;
}

/* Sidebar */
.sidebar-section {
    margin-bottom: 32px;
}

.sidebar-section h3 {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 16px;
    color: #374151;
}

.add-domain-form {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.add-domain-form input {
    padding: 12px;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    font-size: 14px;
}

.add-domain-form input:focus {
    outline: none;
    border-color: #4f46e5;
    box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

/* Buttons */
.btn {
    padding: 12px 20px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.2s;
}

.btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.btn-primary {
    background: #4f46e5;
    color: white;
}

.btn-success {
    background: #10b981;
    color: white;
}

.btn-danger {
    background: #ef4444;
    color: white;
}

.btn-icon {
    font-size: 16px;
}

/* Stats */
.stats {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.stat-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px;
    background: #f9fafb;
    border-radius: 8px;
    border-left: 4px solid #6b7280;
}

.stat-item.good {
    border-left-color: #10b981;
}

.stat-item.warning {
    border-left-color: #f59e0b;
}

.stat-item.error {
    border-left-color: #ef4444;
}

.stat-label {
    font-size: 14px;
    color: #6b7280;
}

.stat-value {
    font-size: 18px;
    font-weight: 600;
    color: #374151;
}

/* Settings */
.settings {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.settings label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    color: #374151;
}

.settings input[type="number"] {
    width: 80px;
    padding: 6px;
    border: 1px solid #d1d5db;
    border-radius: 4px;
    margin-left: 8px;
}

/* Domain Cards */
.domains-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.domain-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    border: 1px solid #e1e5e9;
}

.domain-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 20px;
}

.domain-info {
    flex: 1;
}

.domain-name {
    font-size: 20px;
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 8px;
}

.domain-meta {
    display: flex;
    align-items: center;
    gap: 16px;
    font-size: 14px;
    color: #6b7280;
}

.domain-tags {
    display: flex;
    gap: 6px;
}

.domain-tag {
    padding: 4px 8px;
    background: #f3f4f6;
    border-radius: 12px;
    font-size: 12px;
    color: #374151;
}

.domain-score {
    text-align: right;
}

.score-number {
    font-size: 36px;
    font-weight: 700;
    line-height: 1;
}

.score-number.good { color: #10b981; }
.score-number.warning { color: #f59e0b; }
.score-number.error { color: #ef4444; }

.score-label {
    font-size: 14px;
    color: #6b7280;
}

.domain-actions {
    display: flex;
    gap: 8px;
}

.btn-small {
    padding: 8px 12px;
    font-size: 12px;
}

/* Progress Bar */
.progress-bar {
    width: 100%;
    height: 8px;
    background: #f3f4f6;
    border-radius: 4px;
    overflow: hidden;
    margin: 16px 0;
}

.progress-fill {
    height: 100%;
    border-radius: 4px;
    transition: width 0.3s ease;
}

.progress-fill.good { background: linear-gradient(90deg, #10b981, #059669); }
.progress-fill.warning { background: linear-gradient(90deg, #f59e0b, #d97706); }
.progress-fill.error { background: linear-gradient(90deg, #ef4444, #dc2626); }

/* DNS Records */
.dns-records {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 16px;
    margin-top: 20px;
}

.dns-record {
    background: #f9fafb;
    border-radius: 8px;
    padding: 16px;
}

.dns-record-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 12px;
}

.dns-record-icon {
    font-size: 16px;
}

.dns-record-title {
    font-weight: 600;
    font-size: 14px;
}

.dns-record-score {
    margin-left: auto;
    font-size: 12px;
    font-weight: 600;
}

.dns-record-content {
    font-size: 12px;
    color: #6b7280;
    word-break: break-all;
    margin-bottom: 8px;
}

.dns-record-issues {
    font-size: 11px;
    color: #ef4444;
}

/* Loading */
.loading {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px;
    color: #6b7280;
    flex-direction: column;
}

.spinner {
    width: 20px;
    height: 20px;
    border: 2px solid #f3f4f6;
    border-top: 2px solid #4f46e5;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-bottom: 12px;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* Responsive */
@media (max-width: 1024px) {
    .main {
        flex-direction: column;
    }
    
    .sidebar {
        width: 100%;
        height: auto;
        max-height: 300px;
    }
    
    .dns-records {
        grid-template-columns: 1fr;
    }
}

# ============================================================================
# RENDERER.JS - Frontend JavaScript
# ============================================================================
# BESTAND: renderer.js
class EmailSecurityMonitor {
    constructor() {
        this.domains = [
            { id: 1, domain: 'venlo.nl', tags: ['gemeente', 'limburg'], lastChecked: null, status: 'pending' },
            { id: 2, domain: 'roermond.nl', tags: ['gemeente', 'limburg'], lastChecked: null, status: 'pending' },
            { id: 3, domain: 'weert.nl', tags: ['gemeente', 'limburg'], lastChecked: null, status: 'pending' },
            { id: 4, domain: 'nederweert.nl', tags: ['gemeente', 'limburg'], lastChecked: null, status: 'pending' },
            { id: 5, domain: 'someren.nl', tags: ['gemeente', 'noord-brabant'], lastChecked: null, status: 'pending' },
            { id: 6, domain: 'asten.nl', tags: ['gemeente', 'noord-brabant'], lastChecked: null, status: 'pending' },
            { id: 7, domain: 'ictnml.nl', tags: ['ict', 'business'], lastChecked: null, status: 'pending' }
        ];
        this.checkResults = {};
        this.isChecking = false;
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.renderDomains();
        this.updateStats();
        
        if (window.electronAPI) {
            window.electronAPI.onCheckAllDomains(() => this.checkAllDomains());
            window.electronAPI.onAddDomain(() => this.focusAddDomain());
            window.electronAPI.onExportData(() => this.exportData());
        }
    }

    setupEventListeners() {
        document.getElementById('checkAllBtn').addEventListener('click', () => this.checkAllDomains());
        document.getElementById('addDomainBtn').addEventListener('click', () => this.addDomain());
        
        document.getElementById('domainInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.addDomain();
        });
        document.getElementById('tagsInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.addDomain();
        });
    }

    async checkAllDomains() {
        if (this.isChecking) return;
        
        this.isChecking = true;
        this.updateCheckButton(true);

        for (const domain of this.domains) {
            await this.checkDomain(domain.domain);
            this.updateDomainCard(domain.domain);
            this.updateStats();
        }

        this.isChecking = false;
        this.updateCheckButton(false);
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
                error: error.