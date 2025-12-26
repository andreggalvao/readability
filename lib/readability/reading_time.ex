defmodule Readability.ReadingTime do
  @moduledoc """
  Calculates reading time.
  """

  @wpm 200

  @doc """
  Calculates reading time in minutes based on text content.
  """
  def calculate(text) when is_binary(text) do
    word_count =
      text
      |> String.split(~r/\s+/, trim: true)
      |> Enum.count()

    max(1, ceil(word_count / @wpm))
  end

  def calculate(_), do: nil
end
