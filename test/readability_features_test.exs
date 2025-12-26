defmodule ReadabilityFeaturesTest do
  use ExUnit.Case, async: false

  test "extracts metadata from JSON-LD" do
    html = """
    <html>
      <head>
        <script type="application/ld+json">
        {
          "@context": "https://schema.org",
          "@type": "NewsArticle",
          "headline": "JSON-LD Title",
          "description": "This is an excerpt from JSON-LD.",
          "author": {
            "@type": "Person",
            "name": "Jane Doe"
          },
          "datePublished": "2023-10-27T10:00:00Z",
          "publisher": {
            "@type": "Organization",
            "name": "The Daily News"
          }
        }
        </script>
      </head>
      <body>
        <article>
          <p>Article content here.</p>
        </article>
      </body>
    </html>
    """

    # We mock HTTP request in summarize, but here we can test finders directly or use article/2 if we expose extraction
    # Summarize does extraction. We can't easily mock HTTPoison here without more setup (mock dependency is available).
    # Instead, let's test the helper functions we exposed/updated.

    html_tree = Floki.parse_document!(html)
    json_ld = Readability.Metadata.JSONLD.extract(html_tree)

    assert Readability.TitleFinder.title(html_tree, json_ld) == "JSON-LD Title"
    assert Readability.ExcerptFinder.find(html_tree, json_ld) == "This is an excerpt from JSON-LD."
    assert Readability.SiteNameFinder.find(html_tree, json_ld) == "The Daily News"
    assert Readability.AuthorFinder.find(html_tree, json_ld) == ["Jane Doe"]

    published_at = Readability.PublishedAtFinder.find(html_tree, json_ld)
    assert published_at == ~U[2023-10-27 10:00:00Z]
  end

  test "is_probably_readerable returns true for long content" do
    long_text = String.duplicate("This is a paragraph. ", 10)
    html = "<html><body><p>#{long_text}</p></body></html>"
    html_tree = Floki.parse_document!(html)

    assert Readability.is_probably_readerable(html_tree)
  end

  test "is_probably_readerable returns false for short content" do
    html = "<html><body><p>Short.</p></body></html>"
    html_tree = Floki.parse_document!(html)

    refute Readability.is_probably_readerable(html_tree)
  end
end
