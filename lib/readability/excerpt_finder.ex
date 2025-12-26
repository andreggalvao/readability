defmodule Readability.ExcerptFinder do
  @moduledoc """
  Extracts article excerpt/description.
  """

  @doc """
  Finds excerpt from JSON-LD, meta tags, or first paragraph.
  """
  def find(html_tree, json_ld \\ []) do
    find_in_json_ld(json_ld) || find_in_meta(html_tree)
  end

  defp find_in_json_ld(json_ld) do
    Enum.find_value(json_ld, fn item ->
      item["description"]
    end)
  end

  defp find_in_meta(html_tree) do
    selectors = [
      "meta[name='description']",
      "meta[property='og:description']",
      "meta[name='twitter:description']"
    ]

    Enum.find_value(selectors, fn selector ->
      html_tree
      |> Floki.attribute(selector, "content")
      |> List.first()
    end)
  end
end
