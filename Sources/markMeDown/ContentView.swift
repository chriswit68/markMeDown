import SwiftUI

struct ContentView: View {
    @ObservedObject var model: MarkdownDocumentModel

    var body: some View {
        VStack(spacing: 0) {
            if model.isSearchVisible {
                searchBar
                Divider()
            }

            if model.isEditorVisible {
                HSplitView {
                    editor
                        .frame(minWidth: 260)
                    MarkdownPreview(source: model.text, baseURL: model.fileURL?.deletingLastPathComponent())
                        .frame(minWidth: 260)
                        .contextMenu {
                            previewContextMenu
                        }
                }
            } else {
                MarkdownPreview(source: model.text, baseURL: model.fileURL?.deletingLastPathComponent())
                    .contextMenu {
                        previewContextMenu
                    }
            }
        }
        .navigationTitle(model.windowTitle)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    model.isEditorVisible.toggle()
                } label: {
                    Label(
                        model.isEditorVisible ? "Editor ausblenden" : "Editor einblenden",
                        systemImage: "rectangle.split.2x1"
                    )
                }
                .help(model.isEditorVisible ? "Editor ausblenden" : "Editor einblenden")

                Button {
                    model.showSearch()
                } label: {
                    Label("Suchen", systemImage: "magnifyingglass")
                }

                Button {
                    MarkdownPrintService.print(
                        source: model.text,
                        baseURL: model.fileURL?.deletingLastPathComponent()
                    )
                } label: {
                    Label("Drucken", systemImage: "printer")
                }
            }
        }
        .alert(
            "Fehler",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
    }

    private var editor: some View {
        MarkdownEditorView(model: model)
            .accessibilityLabel("Markdown-Editor")
    }

    @ViewBuilder
    private var previewContextMenu: some View {
        Button {
            model.copySource()
        } label: {
            Label("Markdown-Quelle kopieren", systemImage: "doc.on.doc")
        }

        Button {
            model.isEditorVisible = true
        } label: {
            Label("Editor einblenden", systemImage: "rectangle.split.2x1")
        }
        .disabled(model.isEditorVisible)

        Button {
            model.showSearch()
        } label: {
            Label("Suchen …", systemImage: "magnifyingglass")
        }

        Divider()

        Button {
            MarkdownPrintService.print(
                source: model.text,
                baseURL: model.fileURL?.deletingLastPathComponent()
            )
        } label: {
            Label("Drucken …", systemImage: "printer")
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            TextField(
                "Im Dokument suchen",
                text: Binding(
                    get: { model.searchTerm },
                    set: { model.searchTerm = $0 }
                )
            )
                .textFieldStyle(.roundedBorder)
                .onSubmit(model.findNext)
                .frame(maxWidth: 280)

            Button("Zurück") {
                model.findPrevious()
            }
            .help("Vorherigen Treffer suchen")

            Button("Weiter") {
                model.findNext()
            }
            .help("Nächsten Treffer suchen")

            if let searchStatus = model.searchStatus {
                Text(searchStatus)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                model.isSearchVisible = false
            } label: {
                Label("Suche schließen", systemImage: "xmark")
                    .labelStyle(.iconOnly)
            }
            .help("Suche schließen")
        }
        .padding(10)
    }
}
