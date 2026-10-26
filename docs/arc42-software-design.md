# Software Design Description – markMeDown (arc42)

**Dokumentstatus:** MVP implementiert; dieses Dokument beschreibt den Ist-Stand und offene Release-Arbeiten  
**Stand:** 2026-10-26  
**Produkt:** Native Markdown-Lese- und Bearbeitungs-App für macOS  
**Ist-Stand:** Native SwiftUI-/AppKit-Oberfläche, Dokumentgrundfunktionen, Vorschau, Split-Editor, Syntaxfarben, Suche und Druckaktion sind implementiert. `build.sh` erstellt ein lokales Finder-startbares Release-Bundle; Signierung und weitere Release-Qualitätsmerkmale fehlen noch.

## 1. Einführung und Ziele

### 1.1 Aufgabenstellung

markMeDown soll Markdown-Dateien nativ auf macOS öffnen, lesbar formatiert darstellen und optional in einem Editorfenster bearbeiten. Bei eingeblendetem Editor soll die Vorschau Änderungen fortlaufend anzeigen. Die Bedienung soll sich an Apples Human Interface Guidelines orientieren.

### 1.2 Qualitätsziele

| Priorität | Qualitätsziel | Konkretisierung |
|---|---|---|
| 1 | Korrektheit | Parser und Vorschau bewahren die Struktur und Reihenfolge des Dokuments. |
| 2 | Reaktionsfähigkeit | Vorschau und Syntaxfarben aktualisieren sich bei typischer Textbearbeitung ohne merkliche Verzögerung. |
| 3 | Native Bedienbarkeit | Menüs, Fenster, Toolbar, Tastatur, Undo und Dateidialoge verhalten sich wie auf macOS erwartet. |
| 4 | Zuverlässiger Dateischutz | Ungespeicherte Änderungen gehen nicht stillschweigend verloren; Speichern erfolgt robust. |
| 5 | Wartbarkeit | Parser, Darstellung, Editor und Dateizugriff sind klar getrennte Komponenten und testbar. |
| 6 | Zugänglichkeit | Inhalte sind mit Tastatur und VoiceOver bedienbar; Kontrast und Systemdarstellung werden respektiert. |

### 1.3 Stakeholder

| Rolle | Interesse |
|---|---|
| Schreibende und lesende Personen | Markdown lesen, ändern, prüfen und ausgeben |
| Produktverantwortliche | Begrenzter, klarer Funktionsumfang und konsistente Plattformbedienung |
| Entwicklung und Qualitätssicherung | Testbare Komponenten, definierte Parser-Unterstützung und zuverlässige Dateiverarbeitung |

## 2. Randbedingungen

### Technische Randbedingungen

- Implementierung in Swift als native macOS-Anwendung.
- SwiftUI ist für App-Oberfläche, Fenster und Layout vorgesehen.
- AppKit ist dort zulässig und erwünscht, wo es ausgereifte macOS-Editor- oder Druckfunktionen bereitstellt.
- Das Swift-Package stellt den macOS-App-Lifecycle bereit. Ein Xcode-App-Target gibt es nicht; das lokale App-Bundle wird durch `build.sh` aus dem SwiftPM-Release-Binary erstellt.
- Die Mindestversion macOS 14 ist im Package festgelegt.
- Das MVP arbeitet lokal mit Dateien; ein Cloud-Dienst oder eigener Server ist nicht vorgesehen.

### Produkt- und UX-Randbedingungen

- Die Vorschau darf HTML/WebKit verwenden; die Bearbeitung bleibt eine native AppKit-Textansicht und keine Web-Editorfläche.
- Standardverhalten der Plattform (Dateidialoge, Tastaturkurzbefehle, Undo, Drucken) hat Vorrang vor eigener, ungewohnter Interaktion.
- Der Editor ist optional. Ein reiner Vorschau-Modus muss ohne unnötige Editorfläche nutzbar sein.
- Syntaxhervorhebung ist rein visuell und darf Quelltext oder Parsergebnis nicht verändern.

## 3. Kontextabgrenzung

### 3.1 Fachlicher Kontext

```text
┌───────────────────┐     Markdown-Datei      ┌─────────────────────────┐
│ Person am Mac     │ ◄─────────────────────► │ markMeDown              │
│                   │   Öffnen / Bearbeiten   │ Vorschau / Editor /     │
│                   │   Speichern / Drucken   │ Suchen / Drucken        │
└───────────────────┘                         └────────────┬────────────┘
                                                          │
                                                Swift Markdown
                                                (cmark-gfm)
```

Die App liest und schreibt Dateien über die macOS-Dateiauswahl bzw. vom Betriebssystem übergebene URLs. Ein Dokument wird als Markdown-Quelltext verwaltet; die Vorschau ist eine daraus abgeleitete Darstellung.

### 3.2 Technischer Kontext

| Nachbar | Schnittstelle / Zweck |
|---|---|
| macOS-Dateisystem und Dateiauswahl | `NSOpenPanel`/`NSSavePanel` bzw. SwiftUI-Integration; Lesen und Schreiben lokaler Dateien |
| macOS-Drucksystem | Native Druckdialoge und Druckoperationen für die formatierte Vorschau |
| Swift Markdown | GFM-Parsing über cmark-gfm und HTML-Formatierung |
| WebKit | `WKWebView` rendert HTML und CSS in der Vorschau |
| AppKit-Textsystem | `NSTextView`, Textauswahl, Eingabe, Undo und Suchfunktionen |

## 4. Lösungsstrategie

1. **Eine Quelle der Wahrheit:** Das Dokumentmodell hält den aktuellen Markdown-Quelltext. Vorschau und Syntaxfarben sind davon abgeleitete Darstellungen.
2. **Formatierte Vorschau:** Swift Markdown (cmark-gfm) wandelt den Quelltext in HTML um. WebKit stellt dieses HTML mit GitHub-ähnlichen Styles dar. Der Editor basiert auf AppKit `NSTextView`, eingebettet in SwiftUI.
3. **Live-Aktualisierung im MVP:** Der beobachtete Quelltext aktualisiert die Vorschau unmittelbar. Das Parsing geschieht derzeit synchron während der SwiftUI-Auswertung; Debouncing, Revisionen und Hintergrundverarbeitung sind spätere Performance-Arbeiten.
4. **Dokumentzustand:** Ein beobachtbares Dokumentmodell hält Quelltext, URL, Dirty-State, Suchzustand und Fehler. Dateioperationen liegen derzeit im Modell statt in einem separaten Dienst.
5. **Expliziter Markdown-Umfang:** Das MVP nutzt Swift Markdown mit dem GFM-Parser cmark-gfm. Die CSS-Umsetzung ist GitHub-ähnlich, nicht pixelidentisch.
6. **Plattformkonventionen:** Menübefehle, Tastaturkürzel, Druckdialog, systemweite Darstellung, Fokusführung und Accessibility folgen den macOS-Konventionen.

## 5. Bausteinsicht

### 5.1 Ebene 1 – Komponentenübersicht

```text
┌────────────────────────────────────────────────────────────┐
│ markMeDownApp (SwiftUI App, Window)                          │
│  ├─ DocumentWindow                                          │
│  │   ├─ DocumentToolbar                                     │
│  │   ├─ SplitLayout                                         │
│  │   │   ├─ MarkdownEditor (SwiftUI ↔ NSTextView)           │
│  │   │   └─ MarkdownPreview (SwiftUI)                        │
│  │   └─ DocumentStatus / Fehlermeldungen                     │
│  └─ MenuBarAppDelegate / MenuBarController (NSApplication)  │
├────────────────────────────────────────────────────────────┤
│ MarkdownDocumentModel ─ MarkdownPreview                      │
│      ├─ MarkdownEditorView / MarkdownSyntaxHighlighter       │
│      └─ MarkdownPrintService                                 │
└────────────────────────────────────────────────────────────┘
```

### 5.2 Verantwortlichkeiten

| Baustein | Verantwortung |
|---|---|
| `MenuBarAppDelegate` / `MenuBarController` | Setzt die reguläre macOS-Aktivierungsrichtlinie, installiert `NSApplication.mainMenu` bei Fensteranzeige und App-Aktivierung; bindet Menüaktionen an das Dokumentmodell |
| `ContentView` | Toolbar, optionaler Split-View, Vorschau-Kontextmenü, Suchleiste und Fehleranzeige |
| `MarkdownDocumentModel` | Quelltext, URL, Dirty-State, Dateidialoge, Sichern und Suchzustand |
| `MarkdownEditorView` | `NSTextView`-Eingabe, Undo, Cursor/Selektion und Treffernavigation |
| `MarkdownSyntaxHighlighter` | Regex-basierte Markdown-Farbattribute; keine sprachspezifische Code-Hervorhebung |
| `MarkdownHTMLRenderer` | GFM-Quelltext in HTML umwandeln und mit GitHub-ähnlichem CSS sowie restriktiver Content-Security-Policy umgeben |
| `MarkdownPreview` | HTML über `WKWebView` rendern; JavaScript und Netzwerkressourcen sind deaktiviert |
| `MarkdownPrintService` | Vorschau an `NSPrintOperation` übergeben |
| `markMeDownApp` | SwiftUI-App-Lifecycle und Fenster; bindet den App-Delegate an |

Die genannten Bausteine sind in `Sources/markMeDown` implementiert. Ein separater Parser-Dienst, revisionsbasierte Verarbeitung und unabhängiger Dateiservice sind noch nicht umgesetzt.

## 6. Laufzeitsicht

### 6.1 Dokument öffnen

1. Person wählt „Öffnen …“.
2. `MarkdownDocumentModel` liest UTF-8-Text; bei nicht unterstützter Kodierung oder I/O-Fehler wird ein verständlicher Fehler angezeigt.
3. Das Modell übernimmt Quelltext und URL und setzt den Dirty-State zurück.
4. Die Vorschau wird im Fenster dargestellt. Der Editor wird je nach Ansichtseinstellung angezeigt.

### 6.2 Änderung und Live-Vorschau

1. `NSTextView` meldet eine Textänderung an `MarkdownDocumentModel`.
2. Das Modell aktualisiert den Quelltext und markiert das Dokument als geändert.
3. Swift Markdown parst den Quelltext als GFM und formatiert ihn als HTML.
4. Syntaxfarben werden im Editor auf den bestehenden Text angewendet; Textauswahl und Eingabe bleiben im `NSTextView`.

Die aktuelle synchrone Vorschauerstellung kann bei großen Dokumenten die Oberfläche belasten. Messung, Debouncing und Schutz vor veralteten Ergebnissen sind noch erforderlich.

### 6.3 Speichern und Schließen

1. Speichern schreibt den aktuellen Quelltext zur bestehenden URL; „Speichern unter …“ verwendet einen nativen Save Panel.
2. Das Schreiben erfolgt atomar, soweit die Dateisystem-API dies ermöglicht.
3. Erst nach erfolgreichem Schreiben wird der Dirty-State zurückgesetzt.
4. Bei Fehlern bleibt das Dokument geändert und die Person erhält eine konkrete Fehlermeldung.
5. Beim Öffnen oder Erstellen eines Dokuments mit Änderungen wird eine Entscheidung zum Speichern, Verwerfen oder Abbrechen angeboten. Das Schließen eines Fensters bzw. Beenden der App mit Änderungen wird noch nicht abgefangen.

Der Druckpfad verwendet die tatsächlich in der Vorschau angezeigte `WKWebView`. Wenn deren HTML noch nicht dem aktuellen Dokument entspricht, wartet die Druckanforderung auf den erfolgreichen Ladevorgang. Die AppKit-Druckoperation wird fenstergebunden als Dokument-Sheet gestartet und bis zum Abschluss gehalten. Ein separater Druck-WebView-/PDF-Konvertierungspfad wird vermieden, da er abweichendes Seitenlayout verursachte. Ein physischer Druckertest steht noch aus.

### 6.4 Suchen

Die native Suchleiste navigiert case- und diakritik-insensitiv zum nächsten oder vorherigen Treffer im Quelltext. Ersetzen ist noch nicht implementiert. Der Preview-Text selbst ist nicht editierbar.

## 7. Verteilungssicht

### MVP-Auslieferung

- Swift-Package-GUI-Executable; `build.sh` erstellt ein lokales Release-`.app`-Bundle unter `dist/markMeDown.app`.
- Keine Backend-Komponente und keine Netzwerkabhängigkeit zur Laufzeit.
- Das lokale Bundle kann per Finder bzw. `open dist/markMeDown.app` gestartet werden. Signierung, Notarisierung, Store-Verteilung und automatische Updates sind noch nicht eingerichtet.
- Die Vorschau nutzt Swift Markdown und WebKit. Netzwerkressourcen und JavaScript sind deaktiviert; relative lokale Bilder können geladen werden.
- `Package.resolved` pinnt swift-markdown und swift-cmark jeweils auf 0.9.0. Drittanbieter-Lizenzhinweise stehen in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md).
- `build.sh` legt die vollständigen Lizenztexte, Copyright- und NOTICE-Inhalte der gepinnten SwiftPM-Abhängigkeiten unter `Contents/Resources/ThirdPartyNotices` ab.
- Für den eigenen markMeDown-Code ist keine Projektlizenz festgelegt; eine Weitergabe erfordert eine separate Lizenzentscheidung.

### Dateizugriff

Bei aktivierter App Sandbox erfolgt der Zugriff auf vom Nutzer ausgewählte Dateien über Security-Scoped URLs und wird nur so lange gehalten, wie erforderlich. Falls ein Dokument nach Neustart wieder geöffnet werden soll, sind persistente Berechtigungen (z. B. Security-Scoped Bookmarks) gesondert zu entwerfen. Sandbox- und Bookmark-Verhalten ist vor der Implementierung zu entscheiden.

## 8. Querschnittliche Konzepte

### Dokumentzustand und Nebenläufigkeit

- Pro geöffnetem Dokument existiert ein klar abgegrenzter Zustand.
- UI-Zustand wird auf dem Main Actor verändert.
- Markdown-Parsing erfolgt aktuell synchron aus dem SwiftUI-View heraus; Nebenläufigkeit und Revisionsfilter sind noch nicht implementiert.
- Der letzte Quelltext bleibt auch bei Parsefehlern erhalten.

### Markdown und Rendering

- Parserausgabe wird in eine eigene UI-neutrale Struktur oder direkt in wohldefinierte Render-Inputs überführt.
- Der GFM-Formatter erzeugt HTML. WebKit-JavaScript ist deaktiviert; die Content-Security-Policy sperrt Netzwerkzugriffe, Frames, Objekte und Formulare. Eingebettete Datenbilder und relative lokale Bilder sind zugelassen, entfernte Bilder werden nicht geladen.
- HTTP(S)- und `mailto`-Links werden an macOS übergeben; andere Navigationsschemata werden abgebrochen.
- Die Druckdarstellung setzt per Print-CSS unabhängig vom App-Darstellungsmodus dunkle Textfarben auf hellem Hintergrund; umfassende Drucklayouttests für lange Dokumente stehen noch aus.
- Große Dokumente benötigen Messungen; inkrementelles Parsing bzw. Rendering wird nur bei nachgewiesenem Bedarf eingeführt.

### Syntax-Highlighting

- Textattribute werden deterministisch aus dem Quelltext abgeleitet.
- Farben berücksichtigen Light/Dark Mode und ausreichenden Kontrast.
- Hervorhebung ist keine Validierung und signalisiert keine Parserfehler durch alleinige Farbänderungen.

### Fehlerbehandlung

- I/O- und Parserfehler werden nicht verschluckt.
- Meldungen nennen Aktion und Ursache in verständlicher Sprache; der Dokumentinhalt bleibt nach Möglichkeit erhalten.
- Fehlgeschlagene Speicheraktionen ändern den Dirty-State nicht.

### Design und Accessibility

- Systemschrift, SF Symbols, native Toolbar- und Menüelemente verwenden.
- Fenstergröße, Split-View und Seitenleisten-/Toolbar-Verhalten folgen macOS-Konventionen.
- Keine ausschließlich farbbasierte Statusanzeige; sinnvolle Accessibility Labels, Rollen und Fokusreihenfolge.
- VoiceOver, Tastaturbedienung, dynamische Systemdarstellung und Reduce Motion berücksichtigen.

## 9. Architekturentscheidungen

| Entscheidung | Vorschlag | Begründung / offene Folge |
|---|---|---|
| App-UI | SwiftUI, punktuell AppKit | Native moderne Oberfläche, dabei Zugriff auf ausgereifte Editorfunktionen |
| Editor | `NSTextView` in SwiftUI-Wrapper | Textauswahl, Undo, Find und Eingabe sind im AppKit-Textsystem verfügbar |
| Vorschau | Swift Markdown HTML-Formatter und `WKWebView` mit lokalem CSS | GFM-Elemente wie Tabellen und Task Lists werden strukturiert gerendert; WebKit erhält eine restriktive Content-Security-Policy |
| Markdown-Parsing | Swift Markdown / cmark-gfm | GFM-Unterstützung für Tabellen, Task Lists und Strikethrough; Parserversion durch SwiftPM gelockt |
| Live-Update | Direktes SwiftUI-Update im MVP | Einfacher Start; bei großen Dateien auf Hintergrundverarbeitung und Zusammenfassung umstellen |
| Dokumentdaten | Markdown-Quelltext als maßgeblicher Zustand | Verhindert Abweichungen zwischen Editor und Vorschau |
| Mindestbetriebssystem | macOS 14 | Im Swift-Package-Manifest festgelegt; auf unterstützten Systemen noch zu testen |
| Projektform | Swift-Package-GUI-Executable mit lokalem Bundle-Skript | Finder-startbares Release-Bundle mit Lizenzdateien; Signierung/Notarisierung und Release-Bundle-Tests stehen noch aus |

## 10. Qualitätsanforderungen

### 10.1 Funktionale Akzeptanz

- Unterstützte Markdown-Konstrukte sind in README und Bedienungsanleitung dokumentiert.
- Die Vorschau kann allein oder gemeinsam mit dem Editor im Split-View genutzt werden; ein Editor-allein-Modus ist nicht implementiert.
- Speichern, Speichern unter, Öffnen, Suchen, Drucken und Undo sind über native UI erreichbar.
- Bearbeitete Dateien erhalten ihren Quelltext; die Vorschau verändert den Quelltext nicht.

### 10.2 Messbare Qualitätsziele (zu verifizieren)

- Bei einem Referenzdokument von 10.000 Zeilen soll die Vorschau nach Eingabeende in der Regel innerhalb von 300 ms aktualisiert werden. Messung auf festzulegender Referenzhardware; falls verfehlt, Profiling vor Optimierungsentscheidung.
- Keine Parse-Arbeit darf den Main Thread für einen spürbaren Zeitraum blockieren; UI-Responsiveness wird mit Instruments bzw. automatisierten UI-Tests geprüft.
- Fehlerhafte Speicheroperationen und abgebrochene Dialoge dürfen weder fälschlich Erfolg anzeigen noch ungespeicherte Daten verwerfen.
- Kernfunktionen müssen bei Light und Dark Mode sowie ausschließlich per Tastatur nutzbar sein.

### 10.3 Teststrategie

- Automatisierte Tests decken derzeit GFM-HTML-Ausgabe, Tabellen/Task-Listen/Strikethrough, Content-Security-Policy, Codeblock-Escaping und Dirty-State ab.
- Noch ausstehende Unit-Tests: Syntax-Highlighting-Ranges, Dateioperationen und etwaige Revisionsfilter.
- Snapshot-/Darstellungstests: repräsentative Markdown-Konstrukte und leere/ungültige Eingaben.
- Integrationstests: Öffnen → Editieren → Vorschau aktualisieren → Speichern und erneutes Öffnen.
- UI-Tests: Split-View umschalten, Suche, Druckdialog öffnen, Schließen mit ungespeicherten Änderungen.
- Accessibility- und Dark-Mode-Prüfungen auf unterstützten macOS-Versionen.

### 10.4 Vorgeschlagener Umsetzungsplan

| Phase | Ergebnis | Status |
|---|---|---|
| 1. Produktentscheidungen | Mindestversion, Markdown-Dialekt, Projekt-/Verteilungsform und MVP-Grenzen sind festgelegt. | macOS 14 und erste MVP-Grenzen festgelegt; Dialekt und Releaseweg noch offen. |
| 2. App-Grundgerüst | Native App-Lifecycle, Fenster und Menüstruktur. | Im Swift-Package implementiert; `build.sh` erzeugt ein lokales Finder-startbares `.app`-Bundle. |
| 3. Dokumentmodell und Dateien | Öffnen, Sichern, Save As, Dirty-State und Fehleranzeigen. | Grundfunktionen implementiert; Absicherung beim Fenster-/App-Schließen fehlt. |
| 4. Editor und Vorschau | `NSTextView`, native Vorschau und Live-Aktualisierung. | Einfacher Live-Flow implementiert; Hintergrund-/Revisionsverarbeitung fehlt. |
| 5. Bearbeitungsfunktionen | Syntax-Highlighting, Suche, Split-Ansicht und Druckpfad. | Grundlegende Funktionen implementiert; Ersetzen und ausgiebige Druckprüfung fehlen. |
| 6. Qualität und Release | Tests, Accessibility-, Dark-Mode-, Performance- und Verteilungsprüfungen. | Noch offen; bisher fokussierter Preview- und Dirty-State-Test. |

## 11. Risiken und offene Fragen

| Frage / Risiko | Auswirkung | Nächster Schritt |
|---|---|---|
| Welche macOS-Mindestversion soll gelten? | Beschränkt APIs und Zielgeräte | macOS 14 ist im Package eingestellt; Zielgeräte noch prüfen |
| Welcher Markdown-Dialekt ist verbindlich? | GFM-Features und raw HTML können je nach Parser bzw. Plattform abweichen | GFM ist Grundlage; gewünschte GitHub-spezifische Erweiterungen weiter prüfen |
| Soll die App sandboxed oder im Mac App Store verteilt werden? | Beeinflusst Datei-Bookmarks und Persistenz | Verteilungsweg festlegen und Dateizugriff darauf ausrichten |
| Soll der Editor Syntax-Highlighting oder auch Zeilennummern/Code-Folding bieten? | Beeinflusst Editorumfang und Umsetzung | MVP auf Syntax-Highlighting begrenzen; weitere Funktionen separat entscheiden |
| Wie sollen externe Links und Roh-HTML behandelt werden? | Sicherheits- und UX-Auswirkungen | Links kontrolliert öffnen; Roh-HTML im MVP nicht ausführen |
| Wie groß dürfen typische Dokumente sein? | Einfluss auf Parser, Rendering und Speicherbedarf | Referenzdokumente definieren und Performance messen |
| Soll die zuletzt geöffnete Sitzung wiederhergestellt werden? | Erfordert zusätzliche Persistenz und ggf. Bookmarks | Nicht Teil des MVP, bis ausdrücklich bestätigt |
| Welche Lizenz soll für den eigenen markMeDown-Code gelten? | Ohne Projektlizenz ist die Weitergabe des eigenen Codes nicht eindeutig lizenziert | Vor öffentlicher oder kommerzieller Verteilung festlegen; Drittanbieterpflichten siehe [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md) |
| Welche Bundle-ID und Signierung sollen für Release gelten? | Für verteilte Apps sind eindeutige Identität, Signierung und ggf. Notarisierung erforderlich | Build-Skript nutzt eine lokale Standard-ID; vor Release eigene eindeutige ID, Developer-ID-Signierung und Notarisierung einrichten |

## 12. Glossar

| Begriff | Bedeutung |
|---|---|
| AST | Abstract Syntax Tree; strukturierte Repräsentation des geparsten Markdown |
| Dirty-State | Kennzeichnung, dass Dokumentänderungen noch nicht gespeichert sind |
| Live-Vorschau | Aktualisierte formatierte Darstellung während der Bearbeitung |
| Markdown-Dialekt | Festgelegte Markdown-Syntax und optionale Erweiterungen |
| Split-View | Gleichzeitige Anzeige von Editor und Vorschau in einem geteilten Fenster |
| Security-Scoped URL | macOS-Datei-URL mit zeitlich begrenzter Berechtigung auf eine ausgewählte Datei |
