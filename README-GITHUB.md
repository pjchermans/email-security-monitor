# Email Security Monitor

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org/)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)](https://nodejs.org/)

Een professionele web-applicatie voor het monitoren van email beveiliging van Email-domeinen.

![Email Security Monitor Screenshot](docs/screenshot.png)

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/jouw-username/email-security-monitor.git
cd email-security-monitor

# Installeer dependencies
npm install

# Start applicatie
npm start

# Open in browser
open http://localhost:3000
```

## ✨ Features

- 🛡️ **Real-time DNS Analysis** - SPF, DMARC, DKIM, MX record monitoring
- 🏛️ **Nederlandse Gemeenten Focus** - Voorgedefinieerde gemeente domeinen
- 📊 **Visual Dashboard** - Kleurgecodeerde status met gemeente logo's
- ⏰ **Automatische Monitoring** - Configureerbare controle intervallen
- 📈 **Professional Scoring** - 0-100 punten scoring systeem
- 📋 **Export Functionaliteit** - JSON export voor compliance
- 📱 **Responsive Design** - Desktop, tablet en mobile ondersteuning

## 📖 Documentatie

- **[📚 Volledige Documentatie](DOCUMENTATIE.md)** - Complete gebruikers- en beheerdersgids
- **[⚡ Snelstart Gids](SNELSTART.md)** - 5-minuten setup & gebruik
- **[🚀 Deployment Guide](DEPLOYMENT.md)** - Productie deployment instructies
- **[🔧 Developer Docs](README.md)** - Technische documentatie

## 🏛️ Nederlandse Gemeenten

### Ondersteunde Gemeenten
- **Limburg**: Venlo, Roermond, Weert, Nederweert
- **Noord-Brabant**: Someren, Asten
- **Business**: ICT NML

### Gemeente Logo's
De applicatie bevat officiële logo's voor:
- Gemeente Weert (`assets/Weert.png`)
- Gemeente Someren (`assets/Someren.svg`) 
- Gemeente Asten (`assets/asten.svg`)

## 🔧 Technische Stack

- **Frontend**: Vanilla JavaScript ES6+, CSS3 Grid/Flexbox
- **Backend**: Node.js 18+, Express.js 4.18+
- **DNS**: Native Node.js DNS module met intelligent caching
- **Assets**: SVG/PNG logo support met fallback systeem

## 📊 Screenshots

### Dashboard Overzicht
![Dashboard](docs/dashboard.png)

### Detail Analyse
![Detail View](docs/detail.png)

### Gemeente Logo's
![Logos](docs/logos.png)

## 🚀 Installation & Usage

### Vereisten
- Node.js 18.0 of hoger
- NPM 8.0 of hoger
- Moderne browser (Chrome 90+, Firefox 88+, Safari 14+)

### Development Setup
```bash
# Repository clonen
git clone https://github.com/jouw-username/email-security-monitor.git
cd email-security-monitor

# Dependencies installeren
npm install

# Development server starten
npm run dev
# of: node server-simple.js

# Applicatie openen
open http://localhost:3000
```

### Production Deployment
```bash
# Production dependencies
npm install --production

# PM2 installeren (aanbevolen)
npm install -g pm2

# Applicatie starten
pm2 start server-simple.js --name email-monitor

# Auto-start configureren
pm2 startup
pm2 save
```

Zie [DEPLOYMENT.md](DEPLOYMENT.md) voor uitgebreide deployment instructies.

## 📋 Usage

### Basis Gebruik
1. **Start applicatie** en open http://localhost:3000
2. **Bekijk dashboard** met voorgedefinieerde gemeente domeinen
3. **Klik "Controleer Alle"** om DNS analyse te starten
4. **Interpreteer status**: 🟢 Goed (80-100), 🟠 Waarschuwing (60-79), 🔴 Problemen (0-59)
5. **Klik op domein** voor gedetailleerde analyse

### Geavanceerd Gebruik
- **Automatische monitoring**: Configureer in instellingen sectie
- **Nieuwe domeinen**: Voeg toe via "Nieuw Domein Toevoegen"
- **Data export**: Gebruik "Export Data" voor compliance
- **Logo's**: Plaats custom logo's in `assets/` directory

## 🤝 Contributing

We verwelkomen bijdragen! Zie [CONTRIBUTING.md](CONTRIBUTING.md) voor details.

### Development Workflow
1. Fork het project
2. Creëer feature branch (`git checkout -b feature/nieuwe-functie`)
3. Commit wijzigingen (`git commit -am 'Add nieuwe functie'`)
4. Push naar branch (`git push origin feature/nieuwe-functie`)
5. Open een Pull Request

### Code Style
- ES6+ JavaScript syntax
- 4-space indentation
- Descriptieve variabele namen
- Comments voor complexe logic

## 📄 License

Dit project is gelicenseerd onder de MIT License - zie het [LICENSE](LICENSE) bestand voor details.

## 🙏 Acknowledgments

- **Nederlandse Gemeenten** - Voor requirements en feedback
- **DuckDuckGo** - Voor favicon API service
- **Node.js Community** - Voor DNS libraries
- **Contributors** - Zie [CONTRIBUTORS.md](CONTRIBUTORS.md)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/jouw-username/email-security-monitor/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jouw-username/email-security-monitor/discussions)
- **Documentation**: [Volledige Docs](DOCUMENTATIE.md)

## 🔗 Links

- **Live Demo**: [https://email-monitor-demo.nl](https://email-monitor-demo.nl)
- **Documentation**: [https://docs.email-monitor.nl](https://docs.email-monitor.nl)
- **Status Page**: [https://status.email-monitor.nl](https://status.email-monitor.nl)

---

**Developed with ❤️ for Dutch municipalities and IT professionals**

[![GitHub stars](https://img.shields.io/github/stars/jouw-username/email-security-monitor.svg?style=social&label=Star)](https://github.com/jouw-username/email-security-monitor)
[![GitHub forks](https://img.shields.io/github/forks/jouw-username/email-security-monitor.svg?style=social&label=Fork)](https://github.com/jouw-username/email-security-monitor/fork)