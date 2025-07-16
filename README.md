# Email Security Monitor

Een web-applicatie voor het monitoren van email beveiliging van Email-domeinen.

## 🚀 Quick Start

```bash
# Installeer dependencies
npm install

# Start development server
node server-simple.js

# Open applicatie
open http://localhost:3000
```

## 📋 Features

- ✅ **Real-time DNS Lookups** - SPF, DMARC, DKIM, MX record analyse
- ✅ **Gemeente Focus** - Voorgedefinieerde Nederlandse gemeente domeinen
- ✅ **Visual Status** - Kleurgecodeerde status indicators met logo's
- ✅ **Auto Monitoring** - Configureerbare automatische controle intervals
- ✅ **Professional Scoring** - 0-100 punten scoring systeem
- ✅ **Export Functionality** - JSON export voor compliance rapportage
- ✅ **Responsive Design** - Desktop, tablet en mobile ondersteuning

## 🏗️ Tech Stack

### Frontend
- **Vanilla JavaScript** ES6+ met modern browser APIs
- **CSS3** Grid/Flexbox responsive layout
- **Fetch API** voor HTTP requests
- **Unicode/SVG Icons** voor visual indicators

### Backend  
- **Node.js 18+** runtime environment
- **Express.js 4.18+** web framework
- **Built-in DNS module** voor DNS lookups
- **CORS enabled** voor cross-origin requests

### Architecture
```
┌─────────────────┐    HTTP/JSON    ┌──────────────────┐
│   Browser       │ ←────────────→  │  Express Server  │
│   (Frontend)    │                 │   (Backend)      │
└─────────────────┘                 └──────────────────┘
                                           │
                                           ▼
                                    ┌──────────────────┐
                                    │   DNS Servers    │
                                    │  (External APIs) │
                                    └──────────────────┘
```

## 📁 Project Structure

```
email-security-monitor/
├── assets/                 # Logo's en static assets
│   ├── Weert.png          # Gemeente logo's
│   ├── Someren.svg
│   └── asten.svg
├── server-simple.js       # Express backend server
├── index.html            # Main HTML template
├── styles.css            # CSS styling
├── renderer.js           # Frontend JavaScript
├── package.json          # Dependencies & scripts
├── DOCUMENTATIE.md       # Volledige documentatie
├── SNELSTART.md         # Quick start guide
└── README.md            # Dit bestand
```

## 🔧 Development

### Prerequisites
- Node.js 18.0+ 
- NPM 8.0+
- Modern browser (Chrome 90+, Firefox 88+, Safari 14+)

### Installation
```bash
# Clone repository
git clone <repository-url>
cd email-security-monitor

# Install dependencies
npm install

# Start development server
npm start
# of: node server-simple.js
```

### Environment Variables
```bash
# Optioneel: Custom port
PORT=3001 node server-simple.js

# Debug mode
DEBUG=true node server-simple.js
```

## 🏛️ Gemeente Configuration

### Default Domains
```javascript
const defaultDomains = [
    { domain: 'venlo.nl', tags: ['gemeente', 'limburg'] },
    { domain: 'roermond.nl', tags: ['gemeente', 'limburg'] },
    { domain: 'weert.nl', tags: ['gemeente', 'limburg'] },
    { domain: 'nederweert.nl', tags: ['gemeente', 'limburg'] },
    { domain: 'someren.nl', tags: ['gemeente', 'noord-brabant'] },
    { domain: 'asten.nl', tags: ['gemeente', 'noord-brabant'] },
    { domain: 'ictnml.nl', tags: ['ict', 'business'] }
];
```

### Adding New Gemeente Logos
1. Plaats logo in `assets/` directory
2. Update `getLogoUrl()` function in `renderer.js`:

```javascript
const localLogos = {
    'nieuwe-gemeente.nl': 'assets/nieuwe-gemeente.png',
    // ... existing logos
};
```

## 🔌 API Reference

### DNS Lookup Endpoint
```
GET /api/dns-lookup?domain={domain}&type={type}
```

**Parameters:**
- `domain` (string): Domain name to check
- `type` (string): Record type (SPF, DMARC, DKIM, MX, BIMI, MTA-STS, TLS-RPT)

**Response:**
```json
{
  "success": true,
  "record": "v=spf1 include:_spf.google.com ~all"
}
```

### Supported Record Types
- **SPF**: Sender Policy Framework (`v=spf1...`)
- **DMARC**: Domain-based Message Authentication (`v=DMARC1...`) 
- **DKIM**: DomainKeys Identified Mail (public key records)
- **MX**: Mail Exchange servers
- **BIMI**: Brand Indicators for Message Identification
- **MTA-STS**: Mail Transfer Agent Strict Transport Security
- **TLS-RPT**: TLS Reporting policy

## 📊 Scoring Algorithm

### SPF Analysis
```javascript
// Base score: 70 points
let score = 70;

// Policy modifiers
if (record.includes('-all')) score += 30;      // Strict policy
else if (record.includes('~all')) score += 20; // Soft fail
else if (record.includes('+all')) score -= 40; // Unsafe

// DNS lookup count penalty
const lookups = countDNSLookups(record);
if (lookups > 10) score -= 30;
else if (lookups > 8) score -= 10;
```

### DMARC Analysis  
```javascript
// Base score: 60 points
let score = 60;

// Policy strength
if (record.includes('p=reject')) score += 40;
else if (record.includes('p=quarantine')) score += 20;
else if (record.includes('p=none')) score += 5;

// Reporting setup
if (record.includes('rua=')) score += 15;  // Aggregate reports
if (record.includes('ruf=')) score += 10;  // Forensic reports
```

## 🎨 UI Components

### Domain Overview Item
```html
<div class="domain-overview-item">
    <div class="domain-logo-container">
        <img src="assets/gemeente.png" class="domain-logo" />
    </div>
    <div class="domain-overview-info">
        <div class="domain-overview-name">gemeente.nl</div>
        <div class="domain-overview-tags">
            <span class="domain-tag">gemeente</span>
        </div>
    </div>
    <div class="domain-overview-status">
        <div class="domain-overview-score">85</div>
        <div class="status-indicator-dot good"></div>
    </div>
</div>
```

### Status Classes
- `.good` - Green (80-100 points)
- `.warning` - Orange (60-79 points)  
- `.error` - Red (0-59 points)
- `.pending` - Gray (not checked)

## 🔄 Auto-Check Implementation

```javascript
class AutoChecker {
    constructor(interval = 60) {
        this.interval = interval * 60 * 1000; // Convert to ms
        this.timer = null;
    }
    
    start() {
        this.timer = setInterval(() => {
            if (!this.isChecking) {
                this.checkAllDomains();
            }
        }, this.interval);
    }
    
    stop() {
        if (this.timer) {
            clearInterval(this.timer);
            this.timer = null;
        }
    }
}
```

## 🧪 Testing

### Manual Testing
```bash
# Test DNS endpoint directly
curl "http://localhost:3000/api/dns-lookup?domain=google.com&type=SPF"

# Test static assets
curl "http://localhost:3000/assets/asten.svg"
```

### Browser Testing
```javascript
// Console testing
await fetch('/api/dns-lookup?domain=test.com&type=SPF')
    .then(r => r.json())
    .then(console.log);

// Performance testing  
console.time('checkDomain');
await checkDomain('gemeente.nl');
console.timeEnd('checkDomain');
```

## 📦 Deployment

### Production Build
```bash
# Install production dependencies only
npm install --production

# Start with process manager
npm install -g pm2
pm2 start server-simple.js --name email-monitor
pm2 startup
pm2 save
```

### Docker Deployment
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["node", "server-simple.js"]
```

### Environment Setup
```bash
# Production environment
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# Optional: Custom DNS servers
DNS_SERVERS=8.8.8.8,1.1.1.1
```

## 🐛 Debugging

### Common Issues
```javascript
// DNS resolution failures
console.log('Testing DNS:', await require('dns').promises.resolve4('google.com'));

// CORS issues  
app.use(cors({ origin: '*', credentials: true }));

// Logo loading issues
app.use('/assets', express.static('assets', {
    setHeaders: (res, path) => {
        if (path.endsWith('.svg')) {
            res.setHeader('Content-Type', 'image/svg+xml');
        }
    }
}));
```

### Performance Monitoring
```javascript
// Memory usage
console.log(process.memoryUsage());

// DNS lookup timing
console.time('dns-lookup');
const result = await dns.resolveTxt(domain);
console.timeEnd('dns-lookup');
```

## 🤝 Contributing

### Development Workflow
1. Fork repository
2. Create feature branch: `git checkout -b feature/nieuwe-functie`
3. Commit changes: `git commit -am 'Add nieuwe functie'`
4. Push branch: `git push origin feature/nieuwe-functie`
5. Submit Pull Request

### Code Style
- Use ES6+ syntax
- 4-space indentation
- Descriptive variable names
- Comment complex logic
- Follow existing patterns

### Adding New Features
1. **Frontend**: Update `renderer.js` and `styles.css`
2. **Backend**: Extend `server-simple.js` API endpoints
3. **Documentation**: Update relevant .md files
4. **Testing**: Verify cross-browser compatibility

## 📄 License

MIT License - see LICENSE file for details.

## 🏆 Acknowledgments

- **Nederlandse Gemeenten** - Voor requirements en feedback
- **DuckDuckGo** - Voor favicon API service  
- **Node.js Community** - Voor excellent DNS libraries
- **MDN Web Docs** - Voor frontend development reference

---

**Developed with ❤️ for Dutch municipalities and IT professionals**