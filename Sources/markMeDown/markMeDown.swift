import SwiftUI

@main
@MainActor
struct markMeDownApp: App {
    @NSApplicationDelegateAdaptor(MenuBarAppDelegate.self) private var appDelegate
    @StateObject private var model = MarkdownDocumentModel()

    var body: some Scene {
        Window("markMeDown", id: "main") {
            NavigationStack {
                ContentView(model: model)
            }
            .frame(minWidth: 760, minHeight: 520)
            .onAppear {
                appDelegate.installMenuBar(for: model)
            }
            .onChange(of: model.fileURL) { _, _ in
                appDelegate.installMenuBar(for: model)
            }
        }
    }
}
