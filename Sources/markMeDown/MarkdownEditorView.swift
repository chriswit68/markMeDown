import AppKit
import SwiftUI

struct MarkdownEditorView: NSViewRepresentable {
    @ObservedObject var model: MarkdownDocumentModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true

        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        textView.isRichText = false
        textView.allowsUndo = true
        textView.usesFindBar = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.delegate = context.coordinator
        textView.string = model.text
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true

        scrollView.documentView = textView
        MarkdownSyntaxHighlighter.apply(to: textView)
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        context.coordinator.parent = self

        if textView.string != model.text {
            textView.string = model.text
            MarkdownSyntaxHighlighter.apply(to: textView)
        }

        if context.coordinator.lastSearchRequest != model.searchRequest {
            let searchesBackwards = model.searchRequest < context.coordinator.lastSearchRequest
            context.coordinator.lastSearchRequest = model.searchRequest
            context.coordinator.find(in: textView, backwards: searchesBackwards)
        }
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownEditorView
        var lastSearchRequest = 0

        init(_ parent: MarkdownEditorView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.model.updateText(textView.string)
            MarkdownSyntaxHighlighter.apply(to: textView)
        }

        func find(in textView: NSTextView, backwards: Bool) {
            guard !parent.model.searchTerm.isEmpty else {
                parent.model.searchStatus = "Suchbegriff eingeben."
                return
            }

            let source = textView.string as NSString
            let selected = textView.selectedRange()
            let start = backwards
                ? max(0, selected.location - 1)
                : min(source.length, NSMaxRange(selected))
            let searchRange: NSRange
            var searchOptions: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
            if backwards {
                searchOptions.insert(.backwards)
            }

            if backwards {
                searchRange = NSRange(location: 0, length: start)
            } else {
                searchRange = NSRange(location: start, length: source.length - start)
            }

            var result = source.range(
                of: parent.model.searchTerm,
                options: searchOptions,
                range: searchRange
            )

            if result.location == NSNotFound {
                let wrappedRange = backwards
                    ? NSRange(location: selected.location, length: source.length - selected.location)
                    : NSRange(location: 0, length: start)
                result = source.range(
                    of: parent.model.searchTerm,
                    options: searchOptions,
                    range: wrappedRange
                )
            }

            guard result.location != NSNotFound else {
                parent.model.searchStatus = "Kein Treffer."
                return
            }

            textView.setSelectedRange(result)
            textView.scrollRangeToVisible(result)
            parent.model.searchStatus = nil
        }
    }
}

@MainActor
enum MarkdownSyntaxHighlighter {
    private static let rules: [(pattern: String, color: NSColor, options: NSRegularExpression.Options)] = [
        ("(?m)^#{1,6}\\s+.*$", .systemPurple, []),
        ("(?s)^```[^\\n]*\\n.*?^```[ \\t]*$|(?m)^    .+$", .systemGreen, []),
        ("`[^`\\n]+`", .systemGreen, []),
        ("\\*\\*[^*\\n]+\\*\\*|__[^_\\n]+__", .systemBlue, []),
        ("(?<!\\*)\\*[^*\\n]+\\*(?!\\*)|(?<!_)_[^_\\n]+_(?!_)", .systemOrange, []),
        ("\\[[^\\]]+\\]\\([^)]+\\)", .systemTeal, []),
        ("(?m)^\\s*(?:>|[-+*]|\\d+\\.)\\s+", .secondaryLabelColor, []),
    ]

    static func apply(to textView: NSTextView) {
        guard let storage = textView.textStorage, storage.length > 0 else { return }
        let fullRange = NSRange(location: 0, length: storage.length)

        storage.beginEditing()
        storage.addAttribute(.foregroundColor, value: NSColor.textColor, range: fullRange)
        for rule in rules {
            guard let expression = try? NSRegularExpression(
                pattern: rule.pattern,
                options: rule.options
            ) else { continue }
            let matches = expression.matches(in: storage.string, range: fullRange)
            for match in matches {
                storage.addAttribute(.foregroundColor, value: rule.color, range: match.range)
            }
        }
        storage.endEditing()
    }
}
