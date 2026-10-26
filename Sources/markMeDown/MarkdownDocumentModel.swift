import AppKit
import Combine
import UniformTypeIdentifiers

@MainActor
final class MarkdownDocumentModel: ObservableObject {
    private var savedText = ""

    @Published var text = ""
    @Published var fileURL: URL?
    @Published var isEditorVisible = false
    @Published var isSearchVisible = false
    @Published var searchTerm = ""
    @Published var searchRequest = 0
    @Published var searchStatus: String?
    @Published var errorMessage: String?

    @Published var isDirty = false

    var windowTitle: String {
        let name = fileURL?.lastPathComponent ?? "Unbenannt"
        return isDirty ? "\(name) — geändert" : name
    }

    func open() {
        guard confirmHandlingUnsavedChanges() else { return }

        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = ["md", "markdown", "mdown", "mkd"].compactMap {
            UTType(filenameExtension: $0)
        }
        panel.title = "Markdown-Datei öffnen"
        panel.prompt = "Öffnen"

        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let loadedText = try String(contentsOf: url, encoding: .utf8)
            text = loadedText
            savedText = loadedText
            fileURL = url
            isDirty = false
        } catch {
            errorMessage = "Die Datei konnte nicht geöffnet werden: \(error.localizedDescription)"
        }
    }

    func newDocument() {
        guard confirmHandlingUnsavedChanges() else { return }
        text = ""
        savedText = ""
        fileURL = nil
        isDirty = false
    }

    func updateText(_ newText: String) {
        guard text != newText else { return }
        text = newText
        isDirty = text != savedText
    }

    @discardableResult
    func save() -> Bool {
        guard let fileURL else { return saveAs() }
        return write(to: fileURL)
    }

    @discardableResult
    func saveAs() -> Bool {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = fileURL?.lastPathComponent ?? "Unbenannt.md"
        panel.prompt = "Sichern"

        guard panel.runModal() == .OK, let url = panel.url else { return false }
        guard write(to: url) else { return false }
        fileURL = url
        return true
    }

    func showSearch() {
        isEditorVisible = true
        isSearchVisible = true
        searchStatus = nil
    }

    func findNext() {
        isEditorVisible = true
        isSearchVisible = true
        searchStatus = nil
        searchRequest += 1
    }

    func findPrevious() {
        isEditorVisible = true
        isSearchVisible = true
        searchStatus = nil
        searchRequest -= 1
    }

    func copySource() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func write(to url: URL) -> Bool {
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            savedText = text
            isDirty = false
            return true
        } catch {
            errorMessage = "Die Datei konnte nicht gespeichert werden: \(error.localizedDescription)"
            return false
        }
    }

    private func confirmHandlingUnsavedChanges() -> Bool {
        guard isDirty else { return true }

        let alert = NSAlert()
        alert.messageText = "Änderungen sichern?"
        alert.informativeText = "Dieses Dokument enthält ungesicherte Änderungen."
        alert.addButton(withTitle: "Sichern")
        alert.addButton(withTitle: "Verwerfen")
        alert.addButton(withTitle: "Abbrechen")

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            return save()
        case .alertSecondButtonReturn:
            return true
        default:
            return false
        }
    }
}
