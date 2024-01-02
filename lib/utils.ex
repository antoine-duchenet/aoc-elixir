defmodule Utils do
  def splitrim(to_split, separator) do
    to_split
    |> String.split(separator, trim: true)
    |> Enum.map(&String.trim/1)
  end

  def splitrim(to_split, separator, :with_index) do
    to_split
    |> splitrim(separator)
    |> Enum.with_index()
  end
end
