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

function logError(message) {
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
        logError(`Electron build failed: ${err.message}`);
        throw err;
    }
}

async function buildPKGSingle() {
    log('Building PKG Single Executable...');
    
    try {
        const serverCode = `const express = require('express');
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
});`;

        fs.mkdirSync('single-exe/public', { recursive: true });
        fs.writeFileSync('single-exe/server-standalone.js', serverCode);
        
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
        
        const filesToCopy = ['index.html', 'styles.css', 'renderer.js'];
        for (const file of filesToCopy) {
            if (fs.existsSync(file)) {
                fs.copyFileSync(file, `single-exe/public/${file}`);
            }
        }
        
        process.chdir('single-exe');
        execSync('npm install --production', { stdio: 'inherit' });
        execSync('npx pkg . --out-path ../dist-portable', { stdio: 'inherit' });
        process.chdir('..');
        
        success('PKG Single Executable completed');
    } catch (err) {
        logError(`PKG build failed: ${err.message}`);
        warning('PKG build failed, but Electron version will still work');
    }
}

async function buildFolderPackage() {
    log('Building Portable Folder Package...');
    
    try {
        const folderPath = 'portable-folder/EmailMonitor-Portable';
        fs.mkdirSync(`${folderPath}/data`, { recursive: true });
        
        const filesToCopy = ['main.js', 'preload.js', 'renderer.js', 'index.html', 'styles.css', 'package.json'];
        
        for (const file of filesToCopy) {
            if (fs.existsSync(file)) {
                fs.copyFileSync(file, `${folderPath}/${file}`);
            }
        }
        
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
        logError(`Folder package build failed: ${err.message}`);
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
- Download: Extract from \`portable-folder/\`
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

Built with ❤️ for Dutch IT professionals and municipalities.`;

    fs.writeFileSync('dist-portable/README.md', readme);
    
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
        console.log('   1. Test: cd dist-portable && launch-universal.bat');
        console.log('   2. Distribute: Copy dist-portable/ folder');
        console.log('   3. Documentation: README.md');
        
    } catch (err) {
        logError(`Build failed: ${err.message}`);
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = { main };