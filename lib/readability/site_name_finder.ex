defmodule Readability.SiteNameFinder do
  @moduledoc """
  Extracts site name.
  """

  @doc """
  Finds site name from JSON-LD or meta tags.
  """
  def find(html_tree, json_ld \\ []) do
    find_in_json_ld(json_ld) || find_in_meta(html_tree)
  end

  defp find_in_json_ld(json_ld) do
    Enum.find_value(json_ld, fn item ->
      publisher = item["publisher"]
      if is_map(publisher), do: publisher["name"], else: nil
    end)
  end

  defp find_in_meta(html_tree) do
    html_tree
    |> Floki.attribute("meta[property='og:site_name']", "content")
    |> List.first()
  end
end
