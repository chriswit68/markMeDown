import Testing
@testable import markMeDown

@MainActor
@Test func markdownPreviewAndDocumentDirtyState() throws {
    let html = MarkdownHTMLRenderer.render("""
    # Überschrift

    **Fetter Text**

    | Name | Wert |
    | --- | --- |
    | Beispiel | 42 |

    - [x] Erledigt

    ~~Durchgestrichen~~
    """)

    #expect(html.contains("<h1>Überschrift</h1>"))
    #expect(html.contains("<strong>Fetter Text</strong>"))
    #expect(html.contains("<table>"))
    #expect(html.contains("type=\"checkbox\""))
    #expect(html.contains("<del>Durchgestrichen</del>"))
    #expect(html.contains("Content-Security-Policy"))
    #expect(html.contains("max-width: 980px"))
    #expect(html.contains("@media print"))
    #expect(html.contains("color: #1f2328 !important"))
    #expect(html.contains("background: #ffffff !important"))

    let codeHTML = MarkdownHTMLRenderer.render("```html\n<script>alert(1)</script>\n```")
    #expect(codeHTML.contains("&lt;script&gt;alert(1)&lt;/script&gt;"))
    #expect(!codeHTML.contains("class=\"language-html\" onload"))

    let model = MarkdownDocumentModel()
    model.updateText("Geändert")
    #expect(model.isDirty)

    model.updateText("")
    #expect(!model.isDirty)
}
