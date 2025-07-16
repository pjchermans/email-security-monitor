# Contributing to Email Security Monitor

Bedankt voor je interesse in het bijdragen aan Email Security Monitor! 🎉

## 🤝 Hoe bijdragen?

### Voor je begint
- Lees de [Code of Conduct](CODE_OF_CONDUCT.md)
- Check de [Issues](https://github.com/jouw-username/email-security-monitor/issues) voor bestaande bugs/features
- Bekijk de [Project Documentation](DOCUMENTATIE.md)

### Types bijdragen die we verwelkomen
- 🐛 **Bug reports** en fixes
- ✨ **Nieuwe features** voor email security monitoring
- 📚 **Documentatie** verbeteringen
- 🏛️ **Nederlandse gemeente** logo's en configuraties
- 🌐 **Vertalingen** naar andere talen
- 🎨 **UI/UX** verbeteringen
- ⚡ **Performance** optimalisaties

## 🚀 Development Setup

### Prerequisites
- Node.js 18.0+
- NPM 8.0+
- Git
- Modern browser voor testing

### Local Development
```bash
# Fork en clone het project
git clone https://github.com/jouw-username/email-security-monitor.git
cd email-security-monitor

# Dependencies installeren
npm install

# Development server starten
npm run dev

# Open in browser
open http://localhost:3000
```

### Project Structuur
```
email-security-monitor/
├── assets/              # Logo's en static assets
├── docs/               # Documentation en screenshots
├── server-simple.js    # Express backend
├── renderer.js         # Frontend JavaScript
├── styles.css          # CSS styling
├── index.html          # Main HTML template
└── package.json        # Dependencies en scripts
```

## 🐛 Bug Reports

### Voor het rapporteren van een bug
1. **Check bestaande issues** - Is de bug al gerapporteerd?
2. **Reproduceer de bug** - Kan je de bug consistent reproduceren?
3. **Gather information** - Welke browser, OS, Node.js versie?

### Bug Report Template
```markdown
**Bug Beschrijving**
Een korte beschrijving van wat er mis gaat.

**Reproductie Stappen**
1. Ga naar '...'
2. Klik op '....'
3. Scroll naar beneden '....'
4. Zie error

**Verwacht Gedrag**
Wat je verwachtte dat er zou gebeuren.

**Screenshots**
Indien van toepassing, voeg screenshots toe.

**Environment (vul in):**
 - OS: [bijv. Windows 10, Ubuntu 20.04]
 - Browser [bijv. Chrome 95, Firefox 94]
 - Node.js versie [bijv. 18.12.0]
 - App versie [bijv. 1.0.0]

**Extra Context**
Andere relevante informatie over het probleem.
```

## ✨ Feature Requests

### Voor het voorstellen van nieuwe features
1. **Check roadmap** - Staat het al op de planning?
2. **Beschrijf use case** - Waarom is deze feature nuttig?
3. **Consider scope** - Past het bij de project doelen?

### Feature Request Template
```markdown
**Feature Beschrijving**
Een korte beschrijving van de gewenste feature.

**Problem Statement**
Welk probleem lost deze feature op?

**Proposed Solution**
Hoe zou je deze feature implementeren?

**Alternatives Considered**
Andere oplossingen die je hebt overwogen.

**Additional Context**
Screenshots, mockups, of andere relevante informatie.
```

## 🔧 Pull Requests

### Pull Request Proces
1. **Fork** het repository
2. **Maak feature branch** vanaf main: `git checkout -b feature/nieuwe-functie`
3. **Implementeer wijzigingen** met tests
4. **Test thoroughly** in verschillende browsers
5. **Update documentatie** indien nodig
6. **Commit met duidelijke messages**
7. **Push** naar je fork: `git push origin feature/nieuwe-functie`
8. **Open Pull Request** met beschrijving

### Pull Request Checklist
- [ ] Code volgt project style guidelines
- [ ] Changes zijn getest in Chrome, Firefox, Safari
- [ ] Documentatie is bijgewerkt indien nodig
- [ ] Commit messages zijn duidelijk en beschrijvend
- [ ] Nieuwe features hebben appropriate tests
- [ ] Breaking changes zijn gedocumenteerd

### Code Style Guidelines

#### JavaScript
```javascript
// ✅ Good
const domainName = 'gemeente.nl';
const isValidDomain = domain => domain.includes('.');

// ❌ Avoid
var domain_name = 'gemeente.nl';
function isValidDomain(domain) {
    if (domain.includes('.')) {
        return true;
    } else {
        return false;
    }
}
```

#### CSS
```css
/* ✅ Good */
.domain-card {
    display: flex;
    align-items: center;
    gap: 16px;
}

/* ❌ Avoid */
.domainCard {
    display:flex;
    align-items:center;
    gap:16px;
}
```

#### HTML
```html
<!-- ✅ Good -->
<div class="domain-overview-item" id="domain-1">
    <img src="assets/logo.png" alt="Gemeente logo" class="domain-logo" />
</div>

<!-- ❌ Avoid -->
<div class="domain-overview-item" id="domain-1">
    <img src="assets/logo.png" class="domain-logo">
</div>
```

## 🏛️ Nederlandse Gemeente Bijdragen

### Nieuwe Gemeente Toevoegen
1. **Logo toevoegen** in `assets/` directory
2. **Update domain lijst** in `renderer.js`
3. **Test logo loading** in verschillende browsers
4. **Documenteer nieuwe gemeente** in README

### Logo Requirements
- **Formaten**: PNG, SVG (voorkeur), ICO
- **Grootte**: 48x48px tot 256x256px
- **Kwaliteit**: Hoge resolutie, transparante achtergrond
- **Rechten**: Zorg voor juiste usage rights

### Gemeente Configuration
```javascript
// Toevoegen in renderer.js
const localLogos = {
    'nieuwe-gemeente.nl': 'assets/nieuwe-gemeente.png',
    // ... bestaande logo's
};

// Toevoegen aan default domains
{ 
    id: 8, 
    domain: 'nieuwe-gemeente.nl', 
    tags: ['gemeente', 'provincie'], 
    lastChecked: null, 
    status: 'pending', 
    logo: 'assets/nieuwe-gemeente.png' 
}
```

## 📚 Documentatie Bijdragen

### Types documentatie bijdragen
- **README verbeteringen** - Duidelijkere instructies
- **Code comments** - Betere code documentatie  
- **API documentatie** - Endpoint beschrijvingen
- **Troubleshooting guides** - Oplossingen voor common issues
- **Best practices** - Email security recommendations

### Documentatie Guidelines
- Gebruik duidelijke, eenvoudige taal
- Voeg code examples toe waar mogelijk
- Test alle instructies op fresh system
- Update screenshots bij UI changes
- Houdt documentatie up-to-date met code changes

## 🧪 Testing

### Testing Requirements
- **Browser testing**: Chrome, Firefox, Safari minimum
- **Responsive testing**: Desktop, tablet, mobile
- **DNS testing**: Test met verschillende domeinen
- **Error handling**: Test error scenarios
- **Performance**: Check memory/CPU usage

### Manual Testing Checklist
- [ ] Alle voorgedefinieerde domeinen laden correct
- [ ] DNS lookups functioneren voor SPF, DMARC, DKIM
- [ ] Logo's laden correct (met fallbacks)
- [ ] Automatische monitoring werkt
- [ ] Export functionaliteit werkt
- [ ] Responsive design op verschillende schermen
- [ ] Error handling bij failed DNS lookups

## 🎯 Development Priorities

### High Priority
- 🐛 **Bug fixes** voor bestaande functionaliteit
- 🏛️ **Nederlandse gemeente** ondersteuning
- 📊 **DNS analysis** verbeteringen
- 🔐 **Security** enhancements

### Medium Priority
- ✨ **UI/UX** verbeteringen
- ⚡ **Performance** optimalisaties
- 📱 **Mobile** experience improvements
- 🌐 **Internationalization** support

### Future Considerations
- 📈 **Advanced reporting** features
- 🔄 **Real-time notifications**
- 🗄️ **Database integration**
- 🌍 **Multi-language** support

## 📋 Release Process

### Versioning
We gebruiken [Semantic Versioning](https://semver.org/):
- **MAJOR** version: Incompatible API changes
- **MINOR** version: Backwards-compatible functionality
- **PATCH** version: Backwards-compatible bug fixes

### Release Checklist
- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version number bumped
- [ ] Git tag created
- [ ] Release notes written

## 💬 Community

### Communication Channels
- **GitHub Issues** - Bug reports en feature requests
- **GitHub Discussions** - Algemene discussies
- **Pull Requests** - Code reviews en feedback

### Getting Help
- Check de [Documentation](DOCUMENTATIE.md)
- Search [existing issues](https://github.com/jouw-username/email-security-monitor/issues)
- Ask in [GitHub Discussions](https://github.com/jouw-username/email-security-monitor/discussions)

## 🏆 Recognition

Contributors die significante bijdragen leveren worden:
- Toegevoegd aan [CONTRIBUTORS.md](CONTRIBUTORS.md)
- Vermeld in release notes
- Gegeven maintainer privileges (bij consistent bijdragen)

## 📞 Contact

Voor vragen over contributing:
- Open een [GitHub Discussion](https://github.com/jouw-username/email-security-monitor/discussions)
- Tag @maintainers in een issue
- Email: contribute@email-monitor.nl

---

**Bedankt voor je bijdrage aan Email Security Monitor! 🇳🇱**