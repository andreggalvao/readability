# Readability

[![CI](https://github.com/keepcosmos/readability/actions/workflows/elixir.yml/badge.svg)](https://github.com/keepcosmos/readability/actions/workflows/elixir.yml)
[![Module Version](https://img.shields.io/hexpm/v/readability.svg)](https://hex.pm/packages/readability)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/readability/)
[![Total Download](https://img.shields.io/hexpm/dt/readability.svg)](https://hex.pm/packages/readability)
[![License](https://img.shields.io/hexpm/l/readability.svg)](https://github.com/keepcosmos/readability/blob/master/LICENSE.md)
[![Coverage Status](https://coveralls.io/repos/github/keepcosmos/readability/badge.svg?branch=master)](https://coveralls.io/github/keepcosmos/readability?branch=master)

Readability is a tool for extracting and curating the primary readable content of a webpage.

## Installation

The package can be installed as:

Add `:readability` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:readability, "~> 0.12"}
  ]
end
```

After that, run mix deps.get.

Note: Readability requires Elixir 1.10 or higher.

## Usage

### Examples

#### Just pass a url

```elixir
url = "https://medium.com/@kenmazaika/why-im-betting-on-elixir-7c8f847b58"
summary = Readability.summarize(url)

summary.title
#=> "Why I’m betting on Elixir"

summary.published_at
#=> ~U[2015-02-23 16:53:27.006Z]

summary.authors
#=> ["Ken Mazaika"]

summary.article_html
#=>
# <div><div><p id=\"3476\"><strong><em>Background: </em></strong><em>I’ve spent...
# ...
# ...button!</em></h3></div></div>

summary.article_text
#=>
# Background: I've spent the past 6 years building web applications in Ruby and.....
# ...
# ... value in this article, it would mean a lot to me if you hit the recommend button!

summary.article_markdown
#=> Markdown version of the cleaned article

summary.excerpt
#=> "Article description or short excerpt"

summary.site_name
#=> "Medium"

summary.lang
#=> "en"

summary.reading_time_min
#=> 5

summary.lead_image_url
#=> "https://example.com/image.jpg"
```

#### From raw html

```elixir
### Extract the title.
Readability.title(html)

### Extract the published at
Readability.published_at(html)

### Extract authors.
Readability.authors(html)

### Extract the primary content with transformed html.
html
|> Readability.article
|> Readability.readable_html

### Extract only text from the primary content.
html
|> Readability.article
|> Readability.readable_text

### you can extract the primary images with Floki
html
|> Readability.article
|> Floki.find("img")
|> Floki.attribute("src")
```

### Options

If the result is different from your expectations, you can add options to customize it.

#### Example with Blacklist (Remove Paywalls/Ads)

```elixir
url = "https://example.com/article"
opts = [
  blacklist: [".paywall", ".ad-banner"],  # CSS selectors
  text_blacklist: [~r/acessos por dia/i, ~r/assinante/i]  # Regex patterns for text content
]
summary = Readability.summarize(url, opts)
```

#### Example with Custom Regexes

```elixir
# Extend unlikely_candidate regex to include Portuguese terms
unlikely = Readability.regexes(:unlikely_candidate)
new_unlikely = Regex.compile!(unlikely.source <> "|assinante", "i")

opts = [regexes: [unlikely_candidate: new_unlikely]]
summary = Readability.summarize(url, opts)
```

#### Available Options

- `:min_text_length` \\\\ 25
- `:remove_unlikely_candidates` \\\\ true
- `:weight_classes` \\\\ true
- `:clean_conditionally` \\\\ true
- `:retry_length` \\\\ 250
- `:blacklist` \\\\ nil - List of CSS selectors to remove (e.g., `[".paywall"]`)
- `:text_blacklist` \\\\ nil - List of Regex patterns to remove nodes by text content
- `:disable_json_ld` \\\\ false - Skip JSON-LD metadata extraction

**You can find other algorithm and regex options in `readability.ex`**

### New Features

- **Markdown Support**: `summary.article_markdown` - Clean markdown version of the article
- **JSON-LD Metadata**: Automatic extraction from Schema.org structured data
- **Lead Image**: `summary.lead_image_url` - Extracted from og:image or JSON-LD
- **Reading Time**: `summary.reading_time_min` - Estimated reading time (200 wpm)
- **Text Direction**: `summary.dir` - Detects ltr/rtl
- **Site Name & Language**: `summary.site_name`, `summary.lang`
- **Blacklist Support**: Remove unwanted elements by CSS selector or text pattern

## Test

To run the test suite:

    $ mix test

## Todo

- [x] Extract authors
- [x] More configurable
- [x] Summarize function
- [x] Convert relative paths into absolute paths of `img#src` and `a#href`
- [x] Markdown conversion support
- [x] JSON-LD metadata extraction
- [x] Lead image extraction
- [x] Reading time calculation
- [x] Blacklist support (CSS selectors and text patterns)

## Contributions are welcome!

Check out [the main features milestone](https://github.com/keepcosmos/readability/milestones) and features of related projects below

**Contributing**

1. **Fork** the repo on GitHub
2. **Clone** the project to your own machine
3. **Commit** changes to your own branch
4. **Push** your work back up to your fork
5. Submit a **Pull request** so that we can review your changes

NOTE: Be sure to merge the latest from "upstream" before making a pull request!

## Related and Inspired Projects

- [readability.js](https://github.com/mozilla/readability) is a standalone version of the readability library used for Firefox Reader View.
- [newspaper](https://github.com/codelucas/newspaper) is an advanced news extraction, article extraction, and content curation library for Python.
- [ruby-readability](https://github.com/cantino/ruby-readability) is a tool for extracting the primary readable content of a webpage.

## Copyright and License

Copyright (c) 2016 Jaehyun Shin

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
