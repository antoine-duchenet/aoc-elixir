defmodule Y2024.D01 do
  use Day, input: "2024/01", part1: ~c"l", part2: ~c"l"

  defp part1(input) do
    input
    |> Enum.map(&parse_line/1)
    |> Enum.unzip()
    |> Tuple.to_list()
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip()
    |> Enum.map(&abs(elem(&1, 0) - elem(&1, 1)))
    |> Enum.sum()
  end

  defp part2(input) do
    {left, right} =
      input
      |> Enum.map(&parse_line/1)
      |> Enum.unzip()

    left
    |> Enum.map(&(&1 * Enum.count(right, fn r -> &1 == r end)))
    |> Enum.sum()
  end

  defp parse_line(<<left::bytes-size(5), "   ", right::bytes-size(5)>>) do
    {String.to_integer(left), String.to_integer(right)}
  end
end

Y2024.D01.bench2()
