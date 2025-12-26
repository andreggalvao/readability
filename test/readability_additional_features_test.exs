defmodule ReadabilityAdditionalFeaturesTest do
  use ExUnit.Case, async: false

  test "calculates reading time" do
    text = String.duplicate("word ", 200) # 200 words
    assert Readability.ReadingTime.calculate(text) == 1

    text = String.duplicate("word ", 400) # 400 words
    assert Readability.ReadingTime.calculate(text) == 2

    text = ""
    assert Readability.ReadingTime.calculate(text) == 1 # Minimum 1 minute
  end

  test "detects text direction" do
    html = "<html dir='rtl'><body></body></html>"
    html_tree = Floki.parse_document!(html)
    assert Readability.DirFinder.find(html_tree) == "rtl"

    html = "<html><body dir='ltr'></body></html>"
    html_tree = Floki.parse_document!(html)
    assert Readability.DirFinder.find(html_tree) == "ltr"
  end

  test "resolves relative URLs" do
    html = """
    <html>
      <body>
        <img src="image.jpg">
        <a href="page.html">Link</a>
        <a href="/root.html">Root Link</a>
        <img src="http://other.com/image.jpg">
      </body>
    </html>
    """

    url = "http://example.com/subdir/"

    html_tree = Readability.Helper.normalize(html, url: url)

    # Check img
    [img1, _a1, _a2, img2] = Floki.find(html_tree, "img, a")

    assert Floki.attribute(img1, "src") == ["http://example.com/subdir/image.jpg"]
    assert Floki.attribute(img2, "src") == ["http://other.com/image.jpg"]

    # Check a (need to re-find or iterate carefully because find order depends on tree)
    [a1] = Floki.find(html_tree, "a[href='http://example.com/subdir/page.html']")
    assert Floki.attribute(a1, "href") == ["http://example.com/subdir/page.html"]

    [a2] = Floki.find(html_tree, "a[href='http://example.com/root.html']")
    assert Floki.attribute(a2, "href") == ["http://example.com/root.html"]
  end
end
