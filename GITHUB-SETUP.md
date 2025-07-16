# GitHub Repository Setup Guide

## 🚀 Stap-voor-stap GitHub Setup

### Stap 1: GitHub Repository Aanmaken
1. Ga naar [GitHub.com](https://github.com) en log in
2. Klik op **"New repository"** (groene knop)
3. Repository settings:
   - **Repository name**: `email-security-monitor`
   - **Description**: `Professional email security monitoring tool for Dutch municipalities`
   - **Visibility**: Publiek (of privé naar voorkeur)
   - **Initialize**: ❌ NIET aanvinken (we hebben al bestanden)
4. Klik **"Create repository"**

### Stap 2: Lokale Git Setup
Open command prompt/terminal in de applicatie directory:

```bash
# Navigeer naar project directory
cd C:\Software\email-security-monitor

# Git repository initialiseren
git init

# Staging area configureren
git add .gitignore
git add package.json
git add server-simple.js
git add renderer.js
git add index.html
git add styles.css
git add assets/
git add *.md
git add LICENSE

# Eerste commit
git commit -m "Initial commit: Email Security Monitor v1.0.0

- Complete email security monitoring application
- Real-time DNS analysis (SPF, DMARC, DKIM, MX)
- Dutch municipality focus with local logos
- Responsive web interface
- Automatic monitoring capabilities
- JSON export functionality
- Production ready with comprehensive documentation"

# GitHub remote toevoegen (vervang jouw-username!)
git remote add origin https://github.com/jouw-username/email-security-monitor.git

# Push naar GitHub
git branch -M main
git push -u origin main
```

### Stap 3: Repository Settings op GitHub
1. **About sectie** (rechtsboven op GitHub page):
   - **Description**: `Professional email security monitoring tool for Dutch municipalities`
   - **Website**: Jouw demo URL (optioneel)
   - **Topics**: `email-security`, `dns`, `spf`, `dmarc`, `netherlands`, `municipalities`, `nodejs`, `monitoring`

2. **Repository features** activeren:
   - ✅ Issues
   - ✅ Wiki  
   - ✅ Discussions
   - ✅ Projects

3. **Branch protection** (Settings → Branches):
   - ✅ Require pull request reviews before merging
   - ✅ Require status checks to pass before merging

### Stap 4: GitHub Pages Setup (Optioneel)
Voor demo website:
1. Ga naar **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: **main** 
4. Folder: **/ (root)**
5. Klik **Save**

Demo URL wordt: `https://jouw-username.github.io/email-security-monitor`

### Stap 5: Issues Templates
Maak `.github/ISSUE_TEMPLATE/` directory en voeg templates toe:

**Bug Report Template** (`.github/ISSUE_TEMPLATE/bug_report.md`):
```yaml
---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: 'bug'
assignees: ''
---

**Bug Description**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected Behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
 - OS: [e.g. Windows 10, Ubuntu 20.04]
 - Browser [e.g. Chrome 95, Firefox 94]
 - Node.js version [e.g. 18.12.0]

**Additional Context**
Any other information about the problem.
```

### Stap 6: Automatische Releases (GitHub Actions)
Maak `.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: npm install
      
    - name: Run tests
      run: npm test
      
    - name: Create Release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: ${{ github.ref }}
        release_name: Release ${{ github.ref }}
        draft: false
        prerelease: false
```

### Stap 7: README Update
Vervang `jouw-username` in README-GITHUB.md met je echte GitHub username:

```bash
# In je teksteditor:
# Zoek en vervang "jouw-username" → "echte-github-username"

# Kopieer GitHub README
cp README-GITHUB.md README.md

# Commit wijzigingen
git add README.md
git commit -m "Update README with correct GitHub username"
git push
```

## 📋 Post-Setup Checklist

### Repository Configuratie
- [ ] Repository aangemaakt op GitHub
- [ ] Lokale git repository geïnitialiseerd  
- [ ] Eerste commit en push voltooid
- [ ] README.md bijgewerkt met correcte usernames
- [ ] Repository beschrijving en topics ingesteld
- [ ] License bestand toegevoegd

### GitHub Features
- [ ] Issues enabled voor bug tracking
- [ ] Discussions enabled voor community
- [ ] Branch protection rules ingesteld
- [ ] Issue templates toegevoegd
- [ ] GitHub Actions workflow geconfigureerd (optioneel)
- [ ] GitHub Pages setup (optioneel)

### Documentatie
- [ ] CONTRIBUTING.md voor contributors
- [ ] LICENSE voor legal clarity
- [ ] Alle .md bestanden zijn toegevoegd
- [ ] Screenshots toegevoegd aan docs/ directory (optioneel)

### Code Kwaliteit  
- [ ] .gitignore configuratie correct
- [ ] Package.json dependencies opgeschoond
- [ ] Geen gevoelige informatie in repository
- [ ] Code comments en documentatie up-to-date

## 🎯 Volgende Stappen

### Direct na setup:
1. **Test de repository**: Clone op een andere locatie en test `npm install && npm start`
2. **Voeg screenshots toe**: Maak `docs/` directory met screenshots
3. **Eerste release**: Tag versie 1.0.0 en maak eerste GitHub release
4. **Invite collaborators**: Voeg teamleden toe indien van toepassing

### Voor productie gebruik:
1. **Demo website**: Setup GitHub Pages of deploy naar externe hosting
2. **CI/CD pipeline**: Uitbreiden van GitHub Actions voor automated testing
3. **Security scan**: Dependabot en security advisories activeren
4. **Community guidelines**: CODE_OF_CONDUCT.md toevoegen

## 🔗 Nuttige Commands

```bash
# Status controleren
git status

# Nieuwe wijzigingen committen
git add .
git commit -m "Beschrijving van wijzigingen"
git push

# Nieuwe feature branch
git checkout -b feature/nieuwe-functie
git push -u origin feature/nieuwe-functie

# Tag voor release
git tag v1.0.0
git push origin v1.0.0

# Repository klonen (voor testen)
git clone https://github.com/jouw-username/email-security-monitor.git
```

## 🎉 Success!

Na het voltooien van deze stappen heb je:
- ✅ **Professional GitHub repository** 
- ✅ **Complete documentatie**
- ✅ **Contribution guidelines**
- ✅ **Issue tracking setup**
- ✅ **Automated workflows**
- ✅ **Production-ready codebase**

Je Email Security Monitor is nu klaar voor gebruik door de Nederlandse gemeente community! 🇳🇱