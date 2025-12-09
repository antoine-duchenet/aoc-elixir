defmodule Y2025.D03 do
  use Day, input: "2025/03", part1: ~c"l", part2: ~c"l"

  defp part1(input), do: partX(input, 2)

  defp part2(input), do: partX(input, 12)

  defp partX(input, n) do
    input
    |> parse_input()
    |> Enum.map(&joltage(&1, n))
    |> Enum.sum()
  end

  defp joltage(bank, n, head \\ "")

  defp joltage(_, 0, head), do: String.to_integer(head)

  defp joltage(bank, n, head) do
    biggest =
      bank
      |> Enum.drop(-(n - 1))
      |> Enum.max()

    next_bank =
      bank
      |> Enum.drop_while(&(&1 != biggest))
      |> Enum.drop(1)

    joltage(next_bank, n - 1, "#{head}#{biggest}")
  end

  defp parse_input(input), do: Enum.map(input, &parse_line/1)

  defp parse_line(line) do
    line
    |> Utils.splitrim("")
    |> Enum.map(&String.to_integer/1)
  end
end

Y2025.D03.bench2()
