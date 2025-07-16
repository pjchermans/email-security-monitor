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