defmodule Readability.ImageFinder do
  @moduledoc """
  Extracts lead image from the article.
  """

  @doc """
  Finds the lead image.
  Priority:
  1. JSON-LD 'image'
  2. meta og:image or twitter:image
  3. First large image in the parsed article content (optional, implemented if we pass article tree)
  """
  def find(html_tree, json_ld \\ []) do
    find_in_json_ld(json_ld) || find_in_meta(html_tree)
  end

  defp find_in_json_ld(json_ld) do
    Enum.find_value(json_ld, fn item ->
      case item["image"] do
        url when is_binary(url) -> url
        %{"url" => url} -> url
        list when is_list(list) -> List.first(list) # Could be list of strings or objects
        _ -> nil
      end
    end)
  end

  defp find_in_meta(html_tree) do
    selectors = [
      "meta[property='og:image']",
      "meta[name='twitter:image']",
      "link[rel='image_src']"
    ]

    Enum.find_value(selectors, fn selector ->
      html_tree
      |> Floki.attribute(selector, "content")
      |> List.first()
      # Fallback for link tag using href
      || (if String.contains?(selector, "link"), do: html_tree |> Floki.attribute(selector, "href") |> List.first(), else: nil)
    end)
  end
end
