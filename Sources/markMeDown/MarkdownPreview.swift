import AppKit
import Markdown
import SwiftUI
import WebKit

struct MarkdownPreview: View {
    let source: String
    var baseURL: URL?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        MarkdownWebView(source: source, baseURL: baseURL, colorScheme: colorScheme)
            .accessibilityLabel("Markdown-Vorschau")
    }
}

enum MarkdownHTMLRenderer {
    static func render(_ source: String) -> String {
        var rewriter = SafeCodeBlockRewriter()
        let document = Document(parsing: source)
        let safeDocument = rewriter.visit(document) ?? document
        let body = HTMLFormatter.format(safeDocument)
        return """
        <!doctype html>
        <html lang="de">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <meta http-equiv="Content-Security-Policy" content="default-src 'none'; base-uri 'none'; connect-src 'none'; form-action 'none'; frame-src 'none'; object-src 'none'; img-src data: file:; style-src 'unsafe-inline'; font-src data:;">
          <style>
        \(styles)
          </style>
        </head>
        <body>
          <article class="markdown-body">
        \(body)
          </article>
        </body>
        </html>
        """
    }

    private static let styles = """
    :root {
      color-scheme: light dark;
      --canvas: #ffffff;
      --foreground: #1f2328;
      --muted: #656d76;
      --border: #d1d9e0;
      --surface: #f6f8fa;
      --accent: #0969da;
      --quote: #59636e;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --canvas: #0d1117;
        --foreground: #e6edf3;
        --muted: #9198a1;
        --border: #30363d;
        --surface: #151b23;
        --accent: #4493f8;
        --quote: #9198a1;
      }
    }
    * { box-sizing: border-box; }
    html { background: var(--canvas); }
    body {
      margin: 0;
      padding: 32px;
      color: var(--foreground);
      background: var(--canvas);
      font: 16px/1.5 -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
      overflow-wrap: break-word;
    }
    .markdown-body { max-width: 980px; margin: 0 auto; }
    h1, h2, h3, h4, h5, h6 {
      margin: 24px 0 16px;
      font-weight: 600;
      line-height: 1.25;
    }
    h1 { padding-bottom: .3em; font-size: 2em; border-bottom: 1px solid var(--border); }
    h2 { padding-bottom: .3em; font-size: 1.5em; border-bottom: 1px solid var(--border); }
    h3 { font-size: 1.25em; }
    h4 { font-size: 1em; }
    p, blockquote, ul, ol, dl, table, pre { margin: 0 0 16px; }
    a { color: var(--accent); text-decoration: none; }
    a:hover { text-decoration: underline; }
    strong { font-weight: 600; }
    blockquote {
      padding: 0 1em;
      color: var(--quote);
      border-left: .25em solid var(--border);
    }
    ul, ol { padding-left: 2em; }
    li + li { margin-top: .25em; }
    li > p { margin-top: 16px; }
    input[type="checkbox"] { margin: 0 .35em .2em -1.45em; vertical-align: middle; }
    code, tt {
      padding: .2em .4em;
      font: 85% ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, monospace;
      background: var(--surface);
      border-radius: 6px;
    }
    pre {
      padding: 16px;
      overflow: auto;
      font: 85%/1.45 ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, monospace;
      background: var(--surface);
      border-radius: 6px;
    }
    pre code { padding: 0; background: transparent; border-radius: 0; }
    table { display: block; width: max-content; max-width: 100%; overflow: auto; border-spacing: 0; border-collapse: collapse; }
    th, td { padding: 6px 13px; border: 1px solid var(--border); }
    th { font-weight: 600; }
    tr:nth-child(2n) { background: var(--surface); }
    img { max-width: 100%; height: auto; }
    hr { height: .25em; margin: 24px 0; background: var(--border); border: 0; }
    @media (max-width: 600px) { body { padding: 20px 16px; } }
    @media print {
      :root {
        color-scheme: light;
        --canvas: #ffffff;
        --foreground: #1f2328;
        --muted: #656d76;
        --border: #d1d9e0;
        --surface: #f6f8fa;
        --accent: #0969da;
        --quote: #59636e;
      }
      html, body {
        color: #1f2328 !important;
        background: #ffffff !important;
      }
      body { padding: 0; }
      a { color: #0969da; }
    }
    """
}

private struct SafeCodeBlockRewriter: MarkupRewriter {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Markup? {
        var safeCodeBlock = codeBlock
        safeCodeBlock.code = codeBlock.code
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        safeCodeBlock.language = codeBlock.language?
            .replacingOccurrences(of: "[^A-Za-z0-9_+-]", with: "", options: .regularExpression)
        return safeCodeBlock
    }
}

private struct MarkdownWebView: NSViewRepresentable {
    static let printRequest = Notification.Name("markMeDownPrintPreview")

    let source: String
    let baseURL: URL?
    let colorScheme: ColorScheme

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.underPageBackgroundColor = .clear
        context.coordinator.attach(webView)
        context.coordinator.load(source, baseURL: baseURL, colorScheme: colorScheme, in: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.load(source, baseURL: baseURL, colorScheme: colorScheme, in: webView)
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        private var loadedHTML: String?
        private var loadedBaseURL: URL?
        private weak var webView: WKWebView?
        private var printWhenLoaded = false
        private var activePrintOperation: NSPrintOperation?

        override init() {
            super.init()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handlePrintRequest(_:)),
                name: MarkdownWebView.printRequest,
                object: nil
            )
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        func attach(_ webView: WKWebView) {
            self.webView = webView
        }

        func load(
            _ source: String,
            baseURL: URL?,
            colorScheme: ColorScheme,
            in webView: WKWebView
        ) {
            webView.appearance = NSAppearance(named: colorScheme == .dark ? .darkAqua : .aqua)
            let html = MarkdownHTMLRenderer.render(source)
            guard loadedHTML != html || loadedBaseURL != baseURL else { return }
            loadHTML(html, baseURL: baseURL, in: webView)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            guard navigationAction.navigationType == .linkActivated,
                  let url = navigationAction.request.url else {
                return .allow
            }

            switch url.scheme?.lowercased() {
            case "http", "https", "mailto":
                NSWorkspace.shared.open(url)
                return .cancel
            default:
                return .cancel
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard printWhenLoaded else { return }
            printWhenLoaded = false
            print(webView)
        }

        @objc private func handlePrintRequest(_ notification: Notification) {
            guard let webView,
                  let html = notification.userInfo?["html"] as? String else { return }
            let baseURL = notification.userInfo?["baseURL"] as? URL

            if loadedHTML == html, loadedBaseURL == baseURL, !webView.isLoading {
                print(webView)
            } else {
                printWhenLoaded = true
                loadHTML(html, baseURL: baseURL, in: webView)
            }
        }

        @objc private func printOperationDidRun(
            _ printOperation: NSPrintOperation,
            success: Bool,
            contextInfo: UnsafeMutableRawPointer?
        ) {
            guard activePrintOperation === printOperation else { return }
            activePrintOperation = nil
        }

        private func print(_ webView: WKWebView) {
            guard activePrintOperation == nil else { return }
            guard let window = webView.window else {
                let alert = NSAlert()
                alert.messageText = "Drucken nicht möglich"
                alert.informativeText = "Die Vorschau ist nicht mit einem Fenster verbunden."
                alert.alertStyle = .warning
                alert.runModal()
                return
            }

            let operation = webView.printOperation(with: NSPrintInfo.shared)
            operation.showsPrintPanel = true
            operation.showsProgressPanel = true
            activePrintOperation = operation
            operation.runModal(
                for: window,
                delegate: self,
                didRun: #selector(printOperationDidRun(_:success:contextInfo:)),
                contextInfo: nil
            )
        }

        private func loadHTML(_ html: String, baseURL: URL?, in webView: WKWebView) {
            loadedHTML = html
            loadedBaseURL = baseURL
            webView.loadHTMLString(html, baseURL: baseURL)
        }
    }
}

enum MarkdownPrintService {
    @MainActor
    static func print(source: String, baseURL: URL? = nil) {
        var userInfo: [String: Any] = [
            "html": MarkdownHTMLRenderer.render(source)
        ]
        if let baseURL {
            userInfo["baseURL"] = baseURL
        }
        NotificationCenter.default.post(
            name: MarkdownWebView.printRequest,
            object: nil,
            userInfo: userInfo
        )
    }
}
