defmodule Readability.LangFinder do
  @moduledoc """
  Extracts content language.
  """

  @doc """
  Finds language from html tag or meta tags.
  """
  def find(html_tree) do
    find_in_html_attr(html_tree) || find_in_meta(html_tree)
  end

  defp find_in_html_attr(html_tree) do
    # html_tree root might be <html> tag or list of tags including doctype
    html_tree
    |> Floki.find("html")
    |> Floki.attribute("lang")
    |> List.first()
  end

  defp find_in_meta(html_tree) do
    html_tree
    |> Floki.attribute("meta[name='lang'], meta[http-equiv='content-language']", "content")
    |> List.first()
  end
end
