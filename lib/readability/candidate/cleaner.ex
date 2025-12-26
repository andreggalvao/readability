defmodule Readability.Candidate.Cleaner do
  @moduledoc """
  Clean HTML tree for prepare candidates.

  It transforms misused tags and removes unlikely candidates.
  """

  alias Readability.Helper

  @type html_tree :: tuple | list

  @doc """
  Transforms misused divs <div>s that do not contain other block elements into <p>s.
  """
  @spec transform_misused_div_to_p(html_tree, list) :: html_tree
  def transform_misused_div_to_p(content, opts \\ [])
  def transform_misused_div_to_p(content, _opts) when is_binary(content), do: content
  def transform_misused_div_to_p([], _opts), do: []

  def transform_misused_div_to_p([h | t], opts) do
    [transform_misused_div_to_p(h, opts) | transform_misused_div_to_p(t, opts)]
  end

  def transform_misused_div_to_p({tag, attrs, inner_tree}, opts) do
    tag = if misused_divs?(tag, inner_tree, opts), do: "p", else: tag
    {tag, attrs, transform_misused_div_to_p(inner_tree, opts)}
  end

  @doc """
  Removes unlikely HTML tree.
  """
  @spec remove_unlikely_tree(html_tree, list) :: html_tree
  def remove_unlikely_tree(html_tree, opts \\ []) do
    Helper.remove_tag(html_tree, &unlikely_tree?(&1, opts))
  end

  @doc """
  Removes nodes that match the blacklist selectors.
  """
  @spec remove_blacklisted_nodes(html_tree, list(String.t())) :: html_tree
  def remove_blacklisted_nodes(html_tree, nil), do: html_tree
  def remove_blacklisted_nodes(html_tree, []), do: html_tree

  def remove_blacklisted_nodes(html_tree, blacklist) do
    Enum.reduce(blacklist, html_tree, fn selector, acc ->
      Floki.filter_out(acc, selector)
    end)
  end

  defp misused_divs?("div", inner_tree, opts) do
    !(Floki.raw_html(inner_tree) =~ Readability.regexes(:div_to_p_elements, opts))
  end

  defp misused_divs?(_, _, _), do: false

  defp unlikely_tree?({tag, attrs, _}, opts) do
    idclass_str =
      attrs
      |> Enum.filter(&(elem(&1, 0) =~ ~r/id|class/i))
      |> Enum.map(&elem(&1, 1))
      |> Enum.join("")

    str = tag <> idclass_str

    str =~ Readability.regexes(:unlikely_candidate, opts) &&
      !(str =~ Readability.regexes(:ok_maybe_its_a_candidate, opts)) && tag != "html"
  end
end
