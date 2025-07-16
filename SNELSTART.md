# Email Security Monitor - Snelstart Gids

## 🚀 Snelle Installatie (5 minuten)

### Stap 1: Node.js Installeren
1. Download van [nodejs.org](https://nodejs.org) (LTS versie)
2. Installeer en herstart computer indien nodig

### Stap 2: Applicatie Starten
1. Download de applicatie bestanden
2. Open command prompt/terminal in de applicatie map
3. Voer uit: `npm install`
4. Start server: `node server-simple.js`
5. Open browser naar: `http://localhost:3000`

---

## 📖 Snel Gebruik

### Dashboard Overzicht
- **Groene bolletjes** 🟢 = Uitstekende beveiliging (80-100 punten)
- **Oranje bolletjes** 🟠 = Verbetering mogelijk (60-79 punten)  
- **Rode bolletjes** 🔴 = Actie vereist (0-59 punten)
- **Grijze bolletjes** ⚫ = Nog niet gecontroleerd

### Basis Acties

#### Alle Domeinen Controleren
1. Klik **"Controleer Alle"** (blauw knop rechtsboven)
2. Wacht tot alle status bolletjes kleuren krijgen
3. Bekijk overzicht scores in de statistieken balk

#### Domein Details Bekijken
1. Klik op een domeinnaam of status bolletje
2. Bekijk gedetailleerde DNS records analyse
3. Lees specifieke aanbevelingen per record type
4. Klik **"Terug naar Overzicht"** om terug te gaan

#### Nieuw Domein Toevoegen
1. Scroll naar **"Nieuw Domein Toevoegen"**
2. Vul domeinnaam in (bijv. `gemeente.nl`)
3. Voeg tags toe (bijv. `gemeente, provincie`)
4. Klik **"Toevoegen"**

### Automatische Monitoring
1. Vink **"Automatische controle"** aan in instellingen
2. Stel interval in (aanbevolen: 60 minuten)
3. Applicatie controleert nu automatisch alle domeinen

### Data Exporteren
1. Klik **"Export Data"** in instellingen sectie
2. Kies opslaglocatie voor backup bestand
3. JSON bestand bevat alle resultaten voor rapportage

---

## ⚠️ Veelvoorkomende Problemen

### "Server start niet"
- Controleer of Node.js correct geïnstalleerd is: `node --version`
- Probeer andere poort: `PORT=3001 node server-simple.js`

### "DNS lookups falen"
- Controleer internetverbinding
- Probeer enkele domeinen handmatig: `nslookup google.com`

### "Logo's laden niet"
- Controleer of `assets/` map bestaat in applicatie directory
- Herstart server na toevoegen nieuwe logo's

---

## 📊 Score Interpretatie

### SPF Records (Sender Policy Framework)
- **90-100**: Perfecte SPF configuratie met strenge policy
- **70-89**: Goede configuratie, kleine optimalisaties mogelijk
- **50-69**: Basis implementatie, verbeteringen aanbevolen
- **0-49**: Problematische configuratie, directe actie vereist

### DMARC Records (Domain-based Message Authentication)
- **90-100**: Strenge DMARC policy met volledige rapportage
- **70-89**: Goede policy, rapportage kan verbeterd worden
- **50-69**: Basis DMARC, upgrade naar strengere policy
- **0-49**: Zwakke of ontbrekende DMARC configuratie

---

## 🏛️ Gemeente Specifieke Tips

### Voorgedefinieerde Domeinen
De applicatie start met 7 gemeente domeinen:
- **Limburg**: venlo.nl, roermond.nl, weert.nl, nederweert.nl
- **Noord-Brabant**: someren.nl, asten.nl
- **Business**: ictnml.nl

### Prioriteiten voor Gemeenten
1. **Rode statussen** - Directe actie vereist voor email beveiliging
2. **Oranje statussen** - Plan verbeteringen in komende maanden
3. **Groene statussen** - Behoud huidige goede configuratie

### Compliance Rapportage
- Exporteer data maandelijks voor compliance documentatie
- Gebruik scores voor internal security assessments
- Monitor trends over tijd voor security posture improvements

---

## 🔧 Geavanceerde Instellingen

### Automatische Monitoring
- **Minimum interval**: 5 minuten (voor testing)
- **Aanbevolen interval**: 60 minuten (dagelijkse monitoring)
- **Maximum interval**: 1440 minuten / 24 uur (wekelijkse checks)

### Logo Customization
Plaats eigen gemeente logo's in `assets/` directory:
1. Ondersteunde formaten: PNG, SVG, ICO
2. Aanbevolen grootte: 48x48px tot 256x256px
3. Bestandsnaam: `gemeente-naam.png` of `.svg`
4. Update configuratie in applicatie code indien nodig

---

## 📞 Hulp Nodig?

### Technische Ondersteuning
- **Documentatie**: Zie `DOCUMENTATIE.md` voor uitgebreide handleiding
- **Logs**: Check browser console (F12) voor error messages
- **Server logs**: Bekijk terminal output voor server errors

### Email Security Vragen
- **SPF Help**: [Microsoft SPF Guide](https://docs.microsoft.com/en-us/microsoft-365/security/office-365-security/set-up-spf-in-office-365-to-help-prevent-spoofing)
- **DMARC Help**: [DMARC.org Resources](https://dmarc.org/)
- **Best Practices**: Zie Bijlage C in volledige documentatie

---

## 🎯 Checklist voor Nieuwe Gebruikers

### Eerste Gebruik
- [ ] Node.js geïnstalleerd en werkend
- [ ] Applicatie gestart op localhost:3000
- [ ] Alle voorgedefinieerde domeinen zichtbaar
- [ ] Test "Controleer Alle" functionaliteit
- [ ] Bekijk detail weergave van minimaal 1 domein

### Dagelijks Gebruik
- [ ] Check overall status dashboard
- [ ] Onderzoek rode/oranje statussen
- [ ] Export data voor belangrijke wijzigingen
- [ ] Plan DNS configuratie verbeteringen

### Wekelijks Onderhoud
- [ ] Exporteer volledige dataset voor backup
- [ ] Voeg nieuwe gemeente domeinen toe indien nodig
- [ ] Controleer automatische monitoring instellingen
- [ ] Review trends en verbeteringen

---

**Versie**: 1.0.0 - Snelstart Gids  
**Voor volledige documentatie**: Zie `DOCUMENTATIE.md`