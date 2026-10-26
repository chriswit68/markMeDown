# Bedienungsanleitung – markMeDown

**Status:** Bedienung des ersten implementierten MVP; Grenzen sind in Abschnitt 11 aufgeführt.  
**Zielgruppe:** Personen, die Markdown-Dateien auf macOS lesen oder bearbeiten möchten.

## 1. Überblick

markMeDown zeigt Markdown-Dateien in einer formatierten Vorschau an. Über die Toolbar lässt sich der Editor einblenden, um den Markdown-Quelltext zu ändern. Wenn beide Bereiche sichtbar sind, aktualisiert sich die Vorschau bei Änderungen unmittelbar.

Die App ist für die lokale Arbeit mit Dateien vorgesehen. Die Vorschau verwendet den GitHub-Flavored-Markdown-Parser cmark-gfm und orientiert sich visuell an GitHub, einschließlich Tabellen, Checklisten, Durchstreichungen und Codeblöcken.

## 2. Datei öffnen

1. Wähle **Ablage > Öffnen …**.
2. Wähle im macOS-Dateidialog eine Markdown-Datei.
3. Die Datei wird als formatiertes Dokument geöffnet.
4. Falls die Datei nicht gelesen werden kann, zeigt die App eine Fehlermeldung an; die betroffene Datei wird nicht als erfolgreich geöffnet dargestellt.

Dateien werden als UTF-8 gelesen und gespeichert. Der Öffnen-Dialog filtert übliche Markdown-Endungen. Relative Bilder neben einer geöffneten Datei können dargestellt werden; entfernte Bilder werden aus Datenschutzgründen nicht geladen. HTTP(S)- und E-Mail-Links werden an macOS übergeben; andere Link-Schemata werden nicht geöffnet.

## 3. Vorschau und Editor

- **Vorschau allein:** Blende den Editor über die entsprechende Ansichtsaktion bzw. Toolbar-Schaltfläche aus. Dieser Modus eignet sich zum Lesen.
- **Editor und Vorschau:** Aktiviere den Split-View. Der Editor zeigt den Markdown-Quelltext, die Vorschau dessen formatierte Darstellung.
- **Editor allein:** Falls angeboten, kann auch die Vorschau ausgeblendet werden, um mehr Platz für den Quelltext zu erhalten.
- **Split-Breite:** Passe die Trennlinie zwischen den Bereichen an, sofern das Fensterlayout dies zulässt.

Die Toolbar-Schaltfläche **Editor einblenden/Editor ausblenden** steuert den Split-View. Ein Modus mit Editor allein ist derzeit nicht vorhanden.

### Kontextmenü der Vorschau

Klicke mit der rechten Maustaste in die Vorschau, um das Kontextmenü zu öffnen. Es bietet **Markdown-Quelle kopieren**, **Editor einblenden**, **Suchen …** und **Drucken …**. Wenn der Editor bereits sichtbar ist, ist der Einblend-Befehl deaktiviert.

## 4. Markdown bearbeiten

Klicke in den Editor und bearbeite den Quelltext. Die Vorschau aktualisiert sich automatisch und wird mit WebKit als HTML dargestellt. Der GFM-Parser unterstützt unter anderem Tabellen, Checklisten und Durchstreichungen. Der Editor verwendet `NSTextView`; Syntaxfarben markieren unter anderem Überschriften, Hervorhebungen, Links, Listenmarker und Codeblöcke.

Die Syntaxhervorhebung dient der Orientierung und ändert weder den gespeicherten Text noch die Vorschau. Sie führt keine sprachspezifische Hervorhebung in Codeblöcken aus. Die formatierte Ausgabe basiert auf Swift Markdown/cmark-gfm und wird mit WebKit angezeigt. Die Darstellung ist an GitHub angelehnt, aber nicht pixelidentisch.

## 5. Speichern und Änderungen verwerfen

- **Sichern:** Speichert Änderungen in der geöffneten Datei.
- **Sichern unter …:** Öffnet den nativen Speichern-Dialog, um Speicherort und Dateiname festzulegen.
- Ein geändertes, noch nicht gespeichertes Dokument wird durch einen Dirty-Indikator kenntlich gemacht.
- Beim Öffnen oder Erstellen eines Dokuments mit Änderungen fragt die App, ob gesichert, verworfen oder abgebrochen werden soll.
- Schlägt das Speichern fehl, bleibt der aktuelle Text erhalten und das Dokument gilt weiterhin als geändert.

**Wichtig:** Beim Schließen des Fensters bzw. Beenden der App wird eine noch nicht gespeicherte Änderung derzeit nicht abgefangen.

## 6. Suchen und Ersetzen

Die Suche bezieht sich auf den Markdown-Quelltext im Editor. Über **Bearbeiten > Suchen …** oder die Toolbar lässt sich die Suchleiste einblenden. Sie bietet:

- Suchen im aktuellen Dokument
- Zum nächsten oder vorherigen Treffer springen
- Groß-/Kleinschreibung und diakritische Zeichen werden bei der Suche ignoriert

Die Suche blendet den Editor automatisch ein. Ersetzen ist noch nicht verfügbar. Der Formatierungstext der Vorschau ist nicht direkt editierbar.

## 7. Drucken

Wähle **Ablage > Drucken …** oder die Toolbar-Schaltfläche mit dem Druckersymbol, um die formatierte Vorschau über den nativen macOS-Druckdialog auszugeben. Gedruckt wird die angezeigte WebKit-Vorschau selbst. Für den Druck werden helle Seiten und dunkle Textfarben erzwungen, unabhängig davon, ob die App im Dunkelmodus läuft. Seitenumbrüche und Drucklayout sind noch nicht umfassend mit langen Dokumenten geprüft.

## 8. Tastatur und Menüs

Wenn markMeDown aktiv ist, installiert die App ihre macOS-Menüleiste mit den Menüs **markMeDown**, **Ablage**, **Bearbeiten**, **Darstellung**, **Fenster** und **Hilfe**. Unter **Ablage** findest du neues Dokument, Öffnen, Sichern, Sichern unter und Drucken; unter **Bearbeiten** Suche und Textaktionen; unter **Darstellung** Editor ein-/ausblenden und Vorschau drucken. Dazu gehören die üblichen Kurzbefehle, etwa ⌘N, ⌘O, ⌘S, ⇧⌘S, ⌘F und ⌘P. Undo, Ausschneiden, Kopieren und Einfügen verwenden die native Textbearbeitung.

Alle wesentlichen Aktionen sollen auch über Menüs erreichbar sein; wichtige Aktionen sollen per Tastatur bedienbar sein.

## 9. Darstellung und Bedienungshilfen

- Die Oberfläche folgt automatisch der systemweiten hellen oder dunklen Darstellung.
- Text und Bedienelemente sollen gut lesbar und mit ausreichendem Kontrast gestaltet sein.
- Split-View, Toolbar und Menüs sollen mit Tastatur und VoiceOver nutzbar sein.
- Symbole und Statusmeldungen dürfen Bedeutung nicht ausschließlich über Farbe vermitteln.

## 10. Fehlerbehebung

| Beobachtung | Vorgehen |
|---|---|
| Datei lässt sich nicht öffnen | Prüfe, ob die Datei verfügbar ist und Leseberechtigung besteht; versuche es erneut. |
| Speichern schlägt fehl | Prüfe Speicherort und Schreibberechtigung. Deine Änderungen bleiben im Fenster erhalten, bis du erneut speicherst oder sie bewusst verwirfst. |
| Vorschau aktualisiert sich nicht | Prüfe, ob der Editor tatsächlich Änderungen enthält. Bei einem Darstellungsfehler zeigt die Vorschau eine Meldung und weiterhin den Quelltext. |
| Markdown sieht anders aus als erwartet | Die Vorschau basiert auf cmark-gfm und nutzt GitHub-ähnliche, aber nicht pixelidentische Styles. |
| Drucken ist nicht möglich | Prüfe die macOS-Druckerauswahl und versuche erneut, den Druckdialog zu öffnen. |

Eine sehr große Datei kann die Vorschau während der synchronen Verarbeitung vorübergehend verlangsamen.

## 11. Geplanter Funktionsumfang und Grenzen

Das MVP enthält Öffnen/Speichern, Vorschau, optionalen Editor, Live-Update, grundlegende Syntaxfarben, Suchen und Drucken. Noch nicht implementiert sind unter anderem Suchen/Ersetzen, Tabs, Sitzung wiederherstellen, Drag-and-drop, Warnung beim Schließen mit Änderungen und Zeilennummern. Ein lokales `.app`-Bundle lässt sich mit `./build.sh` erzeugen und anschließend im Finder starten. Installer, Signierung und Notarisierung sind nicht eingerichtet. Git-Integration und Export in andere Formate sind nicht vorgesehen.

## 12. Lizenzen und Weitergabe

Die Anwendung verwendet die SwiftPM-Pakete swift-markdown und swift-cmark. Ihre Versionen, Lizenzarten und Hinweise für eine Weitergabe sind in der [Drittanbieter- und Lizenzübersicht](../THIRD_PARTY_NOTICES.md) beschrieben. Das Build-Skript kopiert die Originaltexte in das lokale App-Bundle. Für den eigenen markMeDown-Code ist derzeit keine Lizenz festgelegt; vor einer öffentlichen Weitergabe sind eine Projektlizenz sowie Signierung und Notarisierung zu klären.

Diese Hinweise dienen der technischen Dokumentation und sind keine Rechtsberatung.
