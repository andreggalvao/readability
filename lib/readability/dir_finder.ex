defmodule Readability.DirFinder do
  @moduledoc """
  Detects text direction.
  """

  @doc """
  Finds text direction (`ltr` or `rtl`).
  Checks `dir` attribute on html or body tags.
  Defaults to nil (which implies usually ltr in browsers but we return nil to be explicit it wasn't found).
  """
  def find(html_tree) do
    # Check html tag
    dir =
      html_tree
      |> Floki.find("html")
      |> Floki.attribute("dir")
      |> List.first()

    if dir do
      dir
    else
      # Check body tag
      html_tree
      |> Floki.find("body")
      |> Floki.attribute("dir")
      |> List.first()
    end
  end
end
