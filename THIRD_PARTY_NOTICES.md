# Drittanbieter- und Lizenzhinweise

Diese Übersicht bezieht sich auf die direkten und transitiven SwiftPM-Abhängigkeiten, die in `Package.resolved` gepinnt sind. Prüfe die Lizenzdateien der aufgelösten Revisionen erneut, sobald Abhängigkeiten aktualisiert oder für ein Release anders paketiert werden. Diese technische Übersicht ist keine Rechtsberatung und enthält nicht die vollständigen Lizenztexte.

## Laufzeitabhängigkeiten

| Paket | Version | Zweck | Lizenz / Hinweis |
|---|---:|---|---|
| [swift-markdown](https://github.com/swiftlang/swift-markdown) | 0.9.0 | GFM-Parser und HTML-Formatter | Apache License 2.0 mit Swift Runtime Library Exception; Copyright Apple Inc. und Swift-Projekt-Autoren. [LICENSE.txt](https://github.com/swiftlang/swift-markdown/blob/25cb61d3482054b09ae76ca4f281b1bfe7fe5a43/LICENSE.txt) und [NOTICE.txt](https://github.com/swiftlang/swift-markdown/blob/25cb61d3482054b09ae76ca4f281b1bfe7fe5a43/NOTICE.txt). |
| [swift-cmark](https://github.com/swiftlang/swift-cmark) | 0.9.0 | cmark-gfm Parser und Erweiterungen, von swift-markdown genutzt | BSD-2-Clause für cmark; [COPYING](https://github.com/swiftlang/swift-cmark/blob/08ddb528923cc1a6527e02b7a1aee9e516ca749a/COPYING) führt außerdem einzelne abgeleitete Komponenten und deren MIT-Lizenzhinweise auf. Copyright- und Disclaimer-Texte dieser Datei sind zu bewahren. |

Die konkret verwendeten Revisionen stehen in [`Package.resolved`](Package.resolved). Die obigen Lizenzangaben wurden mit den Dateien `LICENSE.txt`/`NOTICE.txt` von swift-markdown 0.9.0 und `COPYING` von swift-cmark 0.9.0 abgeglichen.

## Hinweise zur Weitergabe

- Bei einer Weitergabe müssen die vollständigen Lizenztexte und erforderlichen Copyright-, Attributions- und Disclaimer-Hinweise der enthaltenen Abhängigkeiten mitgeliefert werden.
- Für Apache-2.0-Komponenten ist insbesondere eine Kopie der Apache-2.0-Lizenz beizulegen; vorhandene NOTICE-Inhalte müssen, soweit anwendbar, erhalten bzw. weitergegeben werden. Geänderte Drittanbieterdateien müssen als geändert kenntlich gemacht werden. Derzeit wird kein Code dieser Pakete verändert oder vendort.
- Für BSD-2-Clause-Komponenten müssen Copyright-Hinweis, Bedingungen und Haftungsausschluss sowohl in Source- als auch in Binary-Distributionen erhalten bleiben.
- Das `COPYING` von swift-cmark enthält zusätzliche Lizenztexte für abgeleitete Komponenten. Die gesamte Datei ist bei einer Binary-Distribution als Drittanbieter-Lizenzmaterial zu berücksichtigen; nicht nur der einleitende BSD-2-Clause-Abschnitt.
- `build.sh` kopiert diese Originaltexte sowie diese Übersicht nach `Contents/Resources/ThirdPartyNotices/` im lokalen `.app`-Bundle. Vor einer Veröffentlichung muss geprüft werden, ob alle dann enthaltenen Abhängigkeiten und Ressourcen weiterhin vollständig abgedeckt sind.
- Auch zukünftige Abhängigkeiten sowie eingebettete Ressourcen (z. B. Schriftarten, Icons oder Syntaxdefinitionen) müssen vor Aufnahme auf Lizenz und Attributionspflichten geprüft werden.

## Lizenz des Projekts

Für den eigenen markMeDown-Code ist noch keine Lizenz ausgewählt. Die Drittanbieter-Lizenzen erteilen keine Lizenz an diesem Projektcode. Eine Projektlizenz sowie Signierung und Notarisierung sind vor einer öffentlichen oder kommerziellen Verteilung zu entscheiden.

## Apple-Plattformkomponenten

SwiftUI, AppKit, WebKit und macOS-Systemressourcen werden als Plattformbestandteile des Apple SDKs verwendet, nicht als in diesem Repository vendorte Drittanbieterpakete. Ihre Nutzung und Weitergabe richtet sich nach den jeweils geltenden Apple Developer- und SDK-Bedingungen.
