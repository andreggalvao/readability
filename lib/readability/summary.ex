defmodule Readability.Summary do
  @moduledoc false
  defstruct title: nil,
            authors: [],
            article_html: nil,
            article_text: nil,
            published_at: nil,
            excerpt: nil,
            site_name: nil,
            lang: nil,
            dir: nil,
            reading_time_min: nil,
            lead_image_url: nil,
            article_markdown: nil
end
