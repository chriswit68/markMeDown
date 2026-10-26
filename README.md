# markMeDown

markMeDown ist eine native macOS-App zum Lesen und Bearbeiten von Markdown-Dateien. Die erste Implementierungsstufe bietet eine formatierte Vorschau und einen optionalen Split-View-Editor mit Live-Aktualisierung.

## Implementierter Funktionsumfang

- Markdown-Dateien als UTF-8 öffnen, bearbeiten, speichern und „Sichern unter …“
- Ungespeicherte Änderungen beim Öffnen oder Erstellen eines Dokuments sichern, verwerfen oder den Vorgang abbrechen
- Vorschau und Editor separat bzw. gemeinsam anzeigen
- Markdown-Syntax im `NSTextView` farblich hervorheben
- Im Quelltext suchen und vorwärts/rückwärts durch Treffer navigieren
- Formatierte Vorschau über den nativen macOS-Druckdialog drucken
- Explizit installiertes macOS-Hauptmenü (Ablage, Bearbeiten, Darstellung, Fenster und Hilfe) sowie Vorschau-Kontextmenü
- Native macOS-Menüs, Toolbar, Systemfarben und AppKit-Textbearbeitung

Die Vorschau verwendet Swift Markdown, dessen Parser auf GitHub-Flavored Markdown (cmark-gfm) basiert. Das HTML wird mit GitHub-ähnlichem CSS in WebKit dargestellt; JavaScript und Netzwerkressourcen sind per Content-Security-Policy deaktiviert. Eingebettete Datenbilder und relative lokale Bilder sind erlaubt; entfernte Bilder werden nicht geladen. Links zu HTTP(S) und E-Mail werden an macOS übergeben, andere Link-Schemata nicht geöffnet. Der Editor hebt grundlegende Markdown-Strukturen farblich hervor; sprachspezifisches Highlighting innerhalb von Codeblöcken ist nicht enthalten.

## Noch nicht umgesetzt

- Warnung bzw. Sicherungsabfrage beim Schließen eines Fensters oder Beenden der App
- Ersetzen, Tabs/Mehrdokumentbetrieb, Sitzung wiederherstellen und Drag-and-drop
- Hintergrund-/inkrementelles Parsing für sehr große Dokumente
- Releasefähiges `.app`-Bundle, Signierung, Notarisierung und Sandbox-Konfiguration
- Umfassende VoiceOver-, UI-, Performance- und Drucklayout-Tests

## Dokumentation

- [Software Design Description (arc42)](docs/arc42-software-design.md) – Zielarchitektur, Ist-Stand, Qualitätsziele und nächste Umsetzungsschritte
- [Bedienungsanleitung](docs/bedienungsanleitung.md) – verfügbare Bedienung und bekannte Grenzen
- [Drittanbieter- und Lizenzhinweise](THIRD_PARTY_NOTICES.md) – verwendete Pakete, Versionen und Lizenzpflichten

## Technologie

- Swift und SwiftUI für App-Lifecycle, Fenster, Toolbar und Oberflächenlayout
- AppKit `NSTextView` für Bearbeitung, Undo und Textsuche
- Swift Markdown (`cmark-gfm`) für GitHub-Flavored Markdown und HTML-Formatierung
- WebKit (`WKWebView`) für das GitHub-ähnliche Rendering
- Swift Package Manager für die fixierten direkten und transitiven Abhängigkeiten (`Package.resolved`)
- macOS 14 oder neuer
- Kein Server und keine Netzwerkabhängigkeit

## Bauen, testen und starten

Voraussetzung ist eine macOS-Entwicklungsumgebung mit Swift 6.4 oder kompatibler Version.

Erstelle das Release-App-Bundle im Projektverzeichnis mit:

```sh
./build.sh
```

Das Skript verwendet die bekannte Xcode-Installation auf dem externen Laufwerk, sofern vorhanden, andernfalls die mit `xcode-select` ausgewählte Toolchain. Eine andere Toolchain kann über `DEVELOPER_DIR` vorgegeben werden. Das Ergebnis ist `dist/markMeDown.app`; öffne es per Doppelklick im Finder oder über `open dist/markMeDown.app`. Die vollständigen Lizenztexte der SwiftPM-Abhängigkeiten werden im App-Bundle unter `Contents/Resources/ThirdPartyNotices` mitgeliefert.

Tests können weiterhin direkt über SwiftPM ausgeführt werden:

```sh
swift test
```

Das Bundle ist für lokale Entwicklung und Ausführung vorgesehen. Es wird derzeit nicht signiert oder notariell beglaubigt und enthält keine automatische Update- oder Installationsroutine. Für öffentliche Verteilung sind insbesondere eine eigene, eindeutige Bundle-ID, Signierung, Notarisierung und die Projektlizenz festzulegen.

## Lizenz

Für den eigenen markMeDown-Code ist im Repository derzeit keine Lizenz festgelegt. Die verwendeten Drittanbieterpakete unterliegen den in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) aufgeführten Lizenzen. Das Build-Skript nimmt die dort genannten Lizenztexte und Copyright-Hinweise in das lokale App-Bundle auf. Vor einer Weitergabe oder Veröffentlichung müssen die Lizenz für den eigenen Code festgelegt und alle enthaltenen Materialien erneut geprüft werden. Die Übersicht ist kein Ersatz für rechtliche Prüfung.
