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

const dnsCache = new Map();
const CACHE_TTL = 300000;

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