defmodule ReadabilityImprovementsTest do
  use ExUnit.Case, async: false

  test "removes blacklisted elements" do
    # Content must be long enough (>25 chars) to be kept by default filters
    content = String.duplicate("Actual content is important. ", 5)

    html = """
    <html>
      <body>
        <div class="paywall">Subscribe to read more</div>
        <div class="content">#{content}</div>
      </body>
    </html>
    """

    opts = [blacklist: [".paywall"]]
    article = Readability.article(html, opts)
    html_out = Readability.readable_html(article)

    refute html_out =~ "Subscribe"
    assert html_out =~ "Actual content"
  end

  test "overrides regexes" do
    long_text = String.duplicate("text ", 50)

    html = """
    <html>
      <body>
        <div class="assinante">
          This is a paywall. #{long_text}
        </div>
        <div class="content">
          Actual content. #{long_text}
        </div>
      </body>
    </html>
    """

    # 1. Verify default behavior
    article_default = Readability.article(html)
    html_default = Readability.readable_html(article_default)
    assert html_default =~ "paywall"

    # 2. Verify override behavior
    unlikely = Readability.regexes(:unlikely_candidate)
    # Ensure we are compiling a valid regex
    source = unlikely.source
    new_unlikely = Regex.compile!(source <> "|assinante", "i")

    opts = [regexes: [unlikely_candidate: new_unlikely]]

    article_override = Readability.article(html, opts)
    html_override = Readability.readable_html(article_override)

    refute html_override =~ "paywall"
    assert html_override =~ "Actual content"
  end
end
