defmodule Readability.Metadata.JSONLD do
  @moduledoc """
  Extracts metadata from JSON-LD script tags.
  """

  @doc """
  Finds and parses JSON-LD data from the HTML tree.
  Returns the first valid JSON-LD object or a list of objects if multiple valid ones are found and merged/handled?
  For simplicity, we return the first one that looks like a NewsArticle, Article, or WebPage, or just all of them as a list to be processed.
  """
  def extract(html_tree) do
    html_tree
    |> Floki.find("script[type='application/ld+json']")
    |> Enum.map(&parse_json_content/1)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  defp parse_json_content(script_tag) do
    script_tag
    |> Floki.children()
    |> List.first()
    |> decode_json()
  end

  defp decode_json(json_string) when is_binary(json_string) do
    case Jason.decode(json_string) do
      {:ok, data} -> process_graph(data)
      _ -> nil
    end
  end

  defp decode_json(_), do: nil

  defp process_graph(%{"@graph" => graph}) when is_list(graph), do: graph
  defp process_graph(data) when is_map(data), do: [data]
  defp process_graph(data) when is_list(data), do: data
  defp process_graph(_), do: nil
end
