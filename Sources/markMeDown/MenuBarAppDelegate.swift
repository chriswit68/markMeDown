import AppKit

@MainActor
final class MenuBarAppDelegate: NSObject, NSApplicationDelegate {
    private var menuController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        menuController?.install()
    }

    func installMenuBar(for model: MarkdownDocumentModel) {
        if let menuController {
            menuController.model = model
        } else {
            menuController = MenuBarController(model: model)
        }
        menuController?.install()
    }
}

@MainActor
private final class MenuBarController: NSObject {
    var model: MarkdownDocumentModel
    private var mainMenu: NSMenu?

    init(model: MarkdownDocumentModel) {
        self.model = model
    }

    func install() {
        if let mainMenu {
            if NSApp.mainMenu !== mainMenu {
                NSApp.mainMenu = mainMenu
            }
            return
        }

        let mainMenu = NSMenu()
        mainMenu.addItem(makeApplicationMenu())
        mainMenu.addItem(makeFileMenu())
        mainMenu.addItem(makeEditMenu())
        mainMenu.addItem(makeViewMenu())
        mainMenu.addItem(makeWindowMenu())
        mainMenu.addItem(makeHelpMenu())
        self.mainMenu = mainMenu
        NSApp.mainMenu = mainMenu
    }

    private func makeApplicationMenu() -> NSMenuItem {
        let applicationName = NSRunningApplication.current.localizedName ?? "markMeDown"
        let root = NSMenuItem(title: applicationName, action: nil, keyEquivalent: "")
        let menu = NSMenu()
        menu.addItem(applicationItem("Über markMeDown", #selector(NSApplication.orderFrontStandardAboutPanel(_:))))
        menu.addItem(.separator())
        menu.addItem(applicationItem("markMeDown ausblenden", #selector(NSApplication.hide(_:)), key: "h"))
        menu.addItem(applicationItem("Andere ausblenden", #selector(NSApplication.hideOtherApplications(_:)), key: "h", modifiers: [.command, .option]))
        menu.addItem(applicationItem("Alle einblenden", #selector(NSApplication.unhideAllApplications(_:))))
        menu.addItem(.separator())
        menu.addItem(applicationItem("markMeDown beenden", #selector(NSApplication.terminate(_:)), key: "q"))
        root.submenu = menu
        return root
    }

    private func makeFileMenu() -> NSMenuItem {
        let root = NSMenuItem(title: "Ablage", action: nil, keyEquivalent: "")
        let menu = NSMenu(title: "Ablage")
        menu.addItem(item("Neues Dokument", #selector(newDocument(_:)), key: "n"))
        menu.addItem(item("Öffnen …", #selector(openDocument(_:)), key: "o"))
        menu.addItem(.separator())
        menu.addItem(item("Sichern", #selector(saveDocument(_:)), key: "s"))
        menu.addItem(item("Sichern unter …", #selector(saveDocumentAs(_:)), key: "s", modifiers: [.command, .shift]))
        menu.addItem(.separator())
        menu.addItem(item("Drucken …", #selector(printDocument(_:)), key: "p"))
        menu.addItem(.separator())
        menu.addItem(responderItem("Fenster schließen", action: #selector(NSWindow.performClose(_:)), key: "w"))
        root.submenu = menu
        return root
    }

    private func makeEditMenu() -> NSMenuItem {
        let root = NSMenuItem(title: "Bearbeiten", action: nil, keyEquivalent: "")
        let menu = NSMenu(title: "Bearbeiten")
        menu.addItem(item("Widerrufen", #selector(undoEdit(_:)), key: "z"))
        menu.addItem(item("Wiederholen", #selector(redoEdit(_:)), key: "z", modifiers: [.command, .shift]))
        menu.addItem(.separator())
        menu.addItem(responderItem("Ausschneiden", action: #selector(NSText.cut(_:)), key: "x"))
        menu.addItem(responderItem("Kopieren", action: #selector(NSText.copy(_:)), key: "c"))
        menu.addItem(responderItem("Einsetzen", action: #selector(NSText.paste(_:)), key: "v"))
        menu.addItem(responderItem("Alles auswählen", action: #selector(NSText.selectAll(_:)), key: "a"))
        menu.addItem(.separator())
        menu.addItem(item("Suchen …", #selector(showSearch(_:)), key: "f"))
        root.submenu = menu
        return root
    }

    private func makeViewMenu() -> NSMenuItem {
        let root = NSMenuItem(title: "Darstellung", action: nil, keyEquivalent: "")
        let menu = NSMenu(title: "Darstellung")
        menu.addItem(item("Editor ein-/ausblenden", #selector(toggleEditor(_:)), key: "e", modifiers: [.command, .option]))
        menu.addItem(item("Vorschau drucken …", #selector(printDocument(_:)), key: ""))
        root.submenu = menu
        return root
    }

    private func makeWindowMenu() -> NSMenuItem {
        let root = NSMenuItem(title: "Fenster", action: nil, keyEquivalent: "")
        let menu = NSMenu(title: "Fenster")
        menu.addItem(responderItem("Im Dock ablegen", action: #selector(NSWindow.performMiniaturize(_:)), key: "m"))
        menu.addItem(responderItem("Zoomen", action: #selector(NSWindow.performZoom(_:)), key: ""))
        menu.addItem(.separator())
        menu.addItem(applicationItem("Alle nach vorne bringen", #selector(NSApplication.arrangeInFront(_:))))
        root.submenu = menu
        NSApp.windowsMenu = menu
        return root
    }

    private func makeHelpMenu() -> NSMenuItem {
        let root = NSMenuItem(title: "Hilfe", action: nil, keyEquivalent: "")
        root.submenu = NSMenu(title: "Hilfe")
        NSApp.helpMenu = root.submenu
        return root
    }

    private func item(
        _ title: String,
        _ action: Selector,
        key: String = "",
        modifiers: NSEvent.ModifierFlags = [.command]
    ) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        menuItem.target = self
        menuItem.keyEquivalentModifierMask = modifiers
        return menuItem
    }

    private func applicationItem(
        _ title: String,
        _ action: Selector,
        key: String = "",
        modifiers: NSEvent.ModifierFlags = [.command]
    ) -> NSMenuItem {
        let menuItem = item(title, action, key: key, modifiers: modifiers)
        menuItem.target = NSApp
        return menuItem
    }

    private func responderItem(
        _ title: String,
        action: Selector,
        key: String,
        modifiers: NSEvent.ModifierFlags = [.command]
    ) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        menuItem.keyEquivalentModifierMask = modifiers
        return menuItem
    }

    @objc private func newDocument(_ sender: Any?) {
        model.newDocument()
        restoreMenuAfterDocumentAction()
    }

    @objc private func openDocument(_ sender: Any?) {
        model.open()
        restoreMenuAfterDocumentAction()
    }

    @objc private func saveDocument(_ sender: Any?) {
        model.save()
    }

    @objc private func saveDocumentAs(_ sender: Any?) {
        model.saveAs()
    }

    @objc private func showSearch(_ sender: Any?) {
        model.showSearch()
    }

    @objc private func toggleEditor(_ sender: Any?) {
        model.isEditorVisible.toggle()
    }

    @objc private func printDocument(_ sender: Any?) {
        MarkdownPrintService.print(
            source: model.text,
            baseURL: model.fileURL?.deletingLastPathComponent()
        )
    }

    @objc private func undoEdit(_ sender: Any?) {
        NSApp.keyWindow?.undoManager?.undo()
    }

    @objc private func redoEdit(_ sender: Any?) {
        NSApp.keyWindow?.undoManager?.redo()
    }

    private func restoreMenuAfterDocumentAction() {
        DispatchQueue.main.async { [weak self] in
            self?.install()
        }
    }
}
