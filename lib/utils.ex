defmodule Utils do
  def splitrim(to_split, separator \\ "") do
    to_split
    |> String.split(separator, trim: true)
    |> Enum.map(&String.trim/1)
  end

  def splitrim(to_split, separator, :with_index) do
    to_split
    |> splitrim(separator)
    |> Enum.with_index()
  end

  def unordered_pairs(list) do
    ilist = Enum.with_index(list)
    for({v1, i1} <- ilist, {v2, i2} <- ilist, i1 < i2, do: {v1, v2})
  end
end
