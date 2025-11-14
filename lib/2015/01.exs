defmodule Y2015.D01 do
  use Day, input: "2015/01", part1: ~c"w", part2: ~c"w"

  defp part1(input) do
    chars = Utils.splitrim(input, "")
    plus = Enum.count(chars, &(&1 == "("))
    minus = Enum.count(chars, &(&1 == ")"))
    plus - minus
  end

  defp part2(input) do
    input
    |> Utils.splitrim("")
    |> walk()
  end

  defp walk(steps, floor \\ 0, position \\ 0)
  defp walk(_, -1, position), do: position
  defp walk(["(" | tail], floor, position), do: walk(tail, floor + 1, position + 1)
  defp walk([")" | tail], floor, position), do: walk(tail, floor - 1, position + 1)
end

Y2015.D01.bench2()
