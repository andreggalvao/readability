defmodule ReadabilityAdvancedFeaturesTest do
  use ExUnit.Case, async: false

  test "removes nodes by text blacklist" do
    # Add enough content to pass heuristics (min text length etc)
    content = String.duplicate("Actual content is important. ", 5)

    html = """
    <html>
      <body>
        <p>#{content}</p>
        <div class="warning">
          <p>Você tem 7 acessos por dia.</p>
        </div>
        <p>More #{content}</p>
      </body>
    </html>
    """

    opts = [
      text_blacklist: [~r/acessos por dia/i]
    ]

    article = Readability.article(html, opts)
    html_out = Readability.readable_html(article)

    refute html_out =~ "Você tem 7 acessos por dia"
    assert html_out =~ "Actual content"
  end

  test "finds lead image from og:image" do
    html = """
    <html>
      <head>
        <meta property="og:image" content="https://example.com/lead.jpg">
      </head>
      <body></body>
    </html>
    """

    html_tree = Floki.parse_document!(html)
    assert Readability.ImageFinder.find(html_tree) == "https://example.com/lead.jpg"
  end

  test "finds lead image from JSON-LD" do
    json_ld = [%{"image" => "https://example.com/jsonld.jpg"}]
    html_tree = [] # Empty tree

    assert Readability.ImageFinder.find(html_tree, json_ld) == "https://example.com/jsonld.jpg"
  end
end
