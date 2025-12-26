defmodule ReadabilityMarkdownTest do
  use ExUnit.Case, async: false

  test "converts article to markdown" do
    html = """
    <html>
      <body>
        <h1>Article Title</h1>
        <p>This is a <strong>bold</strong> paragraph.</p>
        <p>This is a <a href="https://example.com">link</a>.</p>
        <ul>
          <li>Item 1</li>
          <li>Item 2</li>
        </ul>
      </body>
    </html>
    """

    article = Readability.article(html)
    markdown = Readability.readable_markdown(article)

    assert markdown =~ "**bold**"
    assert markdown =~ "[link](https://example.com)"
    assert markdown =~ "- Item 1"
    assert markdown =~ "- Item 2"
  end
end
