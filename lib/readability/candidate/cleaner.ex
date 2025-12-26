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

  @doc """
  Removes nodes whose text content matches any of the regex patterns in the blacklist.
  """
  @spec remove_text_blacklisted_nodes(html_tree, list(Regex.t())) :: html_tree
  def remove_text_blacklisted_nodes(html_tree, nil), do: html_tree
  def remove_text_blacklisted_nodes(html_tree, []), do: html_tree

  def remove_text_blacklisted_nodes(html_tree, blacklist) do
    # We cannot use Helper.remove_tag directly because it removes parent if parent matches.
    # Parent matches because it contains child text.
    # We need to traverse and only remove if:
    # 1. Text matches
    # 2. It doesn't contain children that *also* match?
    # Actually, if we use post-order traversal (bottom-up), we would remove child, then parent text would change?
    # Floki/Helper.remove_tag is usually recursive.

    # Let's write a custom traversal.
    traverse_remove_text(html_tree, blacklist)
  end

  defp traverse_remove_text(nodes, blacklist) when is_list(nodes) do
    nodes
    |> Enum.map(&traverse_remove_text(&1, blacklist))
    |> Enum.reject(&is_nil/1)
  end

  defp traverse_remove_text(text, _blacklist) when is_binary(text), do: text
  defp traverse_remove_text({:comment, _}, _), do: nil

  defp traverse_remove_text({tag, attrs, children}, blacklist) do
    # First recurse on children
    new_children = traverse_remove_text(children, blacklist)

    # Reconstruct tree to check text *after* children removal?
    # Or just check current node text (which includes children text)?
    # If we check current node text, and it matches, we remove it.
    # But if we already removed the "bad" child, maybe the parent no longer matches?
    # This suggests we should check text *after* cleaning children.

    # However, Floki.text takes the structure.
    new_tree = {tag, attrs, new_children}
    text = Floki.text(new_tree)

    match = Enum.any?(blacklist, fn regex -> Regex.match?(regex, text) end)

    if match && String.length(text) < 500 do
      # Remove this node
      nil
    else
      new_tree
    end
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
