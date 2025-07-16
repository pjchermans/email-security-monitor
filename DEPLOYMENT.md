# Email Security Monitor - Deployment Guide

## 🚀 Productie Deployment

### Server Vereisten

#### Minimale Specificaties
- **CPU**: 2 cores, 2.0GHz
- **RAM**: 4GB (2GB vrij voor applicatie)
- **Storage**: 10GB vrije ruimte
- **Network**: Stabiele internetverbinding
- **OS**: Ubuntu 20.04+, CentOS 8+, Windows Server 2019+

#### Aanbevolen Specificaties
- **CPU**: 4 cores, 2.5GHz
- **RAM**: 8GB (4GB vrij voor applicatie)
- **Storage**: 50GB SSD
- **Network**: Redundante internetverbinding
- **OS**: Ubuntu 22.04 LTS

---

## 🐧 Linux Deployment (Ubuntu/CentOS)

### Stap 1: Server Voorbereiding
```bash
# Systeem updaten
sudo apt update && sudo apt upgrade -y

# Firewall configureren
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 3000/tcp    # Applicatie
sudo ufw enable

# Gebruiker aanmaken voor applicatie
sudo adduser emailmonitor
sudo usermod -aG sudo emailmonitor
```

### Stap 2: Node.js Installeren
```bash
# NodeSource repository toevoegen
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Node.js installeren
sudo apt-get install -y nodejs

# Versie verificeren
node --version
npm --version
```

### Stap 3: Applicatie Deployment
```bash
# Naar applicatie gebruiker wisselen
su - emailmonitor

# Applicatie directory aanmaken
mkdir -p /home/emailmonitor/email-security-monitor
cd /home/emailmonitor/email-security-monitor

# Applicatie bestanden kopiëren (via SCP, Git, etc.)
scp -r user@source:/path/to/app/* .

# Dependencies installeren
npm install --production

# Permissies instellen
chmod +x *.js
```

### Stap 4: PM2 Process Manager
```bash
# PM2 globaal installeren
sudo npm install -g pm2

# Applicatie starten met PM2
pm2 start server-simple.js --name "email-monitor"

# Auto-start bij reboot
pm2 startup
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u emailmonitor --hp /home/emailmonitor

# Configuratie opslaan
pm2 save

# Status controleren
pm2 status
pm2 logs email-monitor
```

---

## 🔧 Maintenance & Updates

### Performance Tuning
```javascript
// server-simple.js optimalisaties
const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
    for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
    }
    
    cluster.on('exit', (worker, code, signal) => {
        console.log(`Worker ${worker.process.pid} died`);
        cluster.fork();
    });
} else {
    // Worker process - start the actual server
    require('./server-simple.js');
}

// DNS caching optimalisatie
const NodeCache = require('node-cache');
const dnsCache = new NodeCache({ 
    stdTTL: 300,      // 5 minuten TTL
    checkperiod: 320, // Cleanup elke 5+ minuten
    maxKeys: 1000     // Maximum cached entries
});

// Connection pooling
const http = require('http');
const agent = new http.Agent({
    keepAlive: true,
    maxSockets: 10,
    maxFreeSockets: 2,
    timeout: 60000
});
```

### Health Checks
```bash
#!/bin/bash
# health-check.sh
HOST="localhost:3000"
TIMEOUT=10

# HTTP health check
if curl -f -m $TIMEOUT "http://$HOST/" > /dev/null 2>&1; then
    echo "✅ HTTP check passed"
else
    echo "❌ HTTP check failed"
    # Restart service
    pm2 restart email-monitor
    exit 1
fi

# API endpoint check
if curl -f -m $TIMEOUT "http://$HOST/api/dns-lookup?domain=google.com&type=SPF" > /dev/null 2>&1; then
    echo "✅ API check passed"
else
    echo "❌ API check failed"
    pm2 restart email-monitor
    exit 1
fi

# Memory check
MEM_USAGE=$(ps -o pid,ppid,%mem,cmd -C node | grep email-monitor | awk '{print $3}')
if (( $(echo "$MEM_USAGE > 80" | bc -l) )); then
    echo "⚠️ High memory usage: $MEM_USAGE%"
    pm2 restart email-monitor
fi

echo "✅ All health checks passed"
```

### Automated Deployment Script
```bash
#!/bin/bash
# deploy.sh
set -e

APP_DIR="/home/emailmonitor/email-security-monitor"
BACKUP_DIR="/backup/email-monitor"
GIT_REPO="https://github.com/your-org/email-security-monitor.git"

echo "🚀 Starting deployment process..."

# Pre-deployment backup
echo "📦 Creating backup..."
./backup.sh

# Health check before deployment
echo "🏥 Pre-deployment health check..."
if ! ./health-check.sh; then
    echo "❌ Pre-deployment health check failed - aborting"
    exit 1
fi

# Download nieuwe versie
echo "⬇️ Downloading new version..."
cd /tmp
git clone $GIT_REPO email-monitor-new

# Dependencies check
echo "📋 Checking dependencies..."
cd email-monitor-new
npm install --production --dry-run

# Stop services gracefully
echo "🛑 Stopping services..."
pm2 stop email-monitor

# Deploy nieuwe code
echo "📁 Deploying new code..."
cp -r /tmp/email-monitor-new/* $APP_DIR/
cd $APP_DIR

# Install/update dependencies
echo "📦 Installing dependencies..."
npm install --production

# Update file permissions
echo "🔐 Setting permissions..."
chown -R emailmonitor:emailmonitor $APP_DIR
chmod +x *.js

# Start services
echo "▶️ Starting services..."
pm2 start email-monitor

# Wait for startup
sleep 10

# Post-deployment health check
echo "🏥 Post-deployment health check..."
if ./health-check.sh; then
    echo "✅ Deployment successful!"
    # Cleanup
    rm -rf /tmp/email-monitor-new
else
    echo "❌ Post-deployment health check failed - rolling back"
    # Rollback procedure here
    exit 1
fi

echo "🎉 Deployment completed successfully!"
```

---

## 📋 Production Checklist

### Pre-Deployment
- [ ] Server specifications voldoen aan minimale vereisten
- [ ] Node.js 18+ geïnstalleerd en getest
- [ ] Firewall configuratie voltooid
- [ ] SSL certificaten geïnstalleerd (indien HTTPS)
- [ ] DNS records voor domein geconfigureerd
- [ ] Backup strategie geïmplementeerd

### Deployment
- [ ] Applicatie bestanden geüpload naar server
- [ ] Dependencies geïnstalleerd (`npm install --production`)
- [ ] PM2 process manager geconfigureerd
- [ ] Auto-start bij reboot ingesteld
- [ ] Reverse proxy geconfigureerd (nginx/IIS)
- [ ] Security headers geïmplementeerd

### Post-Deployment
- [ ] Health checks uitgevoerd
- [ ] API endpoints getest
- [ ] DNS lookups functioneren correct
- [ ] Logo's laden correct
- [ ] Auto-check functionaliteit getest
- [ ] Export functionaliteit getest
- [ ] Performance monitoring actief

---

## 🚨 Disaster Recovery

### Recovery Time Objectives
- **RTO (Recovery Time Objective)**: 4 uur
- **RPO (Recovery Point Objective)**: 24 uur
- **MTTR (Mean Time To Recovery)**: 2 uur

### Support Levels

#### Level 1: Basic Issues
- Service restart
- Basic configuration wijzigingen
- Log file analyse
- Health check failures

#### Level 2: Advanced Issues
- Performance problemen
- Security incidents
- Complex configuratie wijzigingen

#### Level 3: Critical Issues
- System architecture wijzigingen
- Disaster recovery
- Major security incidents

---

**Deployment Guide v1.0.0**  
**Laatste Update**: Juli 2025  
**Geldig voor**: Email Security Monitor v1.0.0+