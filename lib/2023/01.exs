defmodule Y2023.D01 do
  use Day, input: "2023/01", part1: ~c"l", part2: ~c"l"

  @pattern1 "^.*(?<dig>\\d).*$"
  @pattern2 "^.*(?<dig>\\d|one|two|three|four|five|six|seven|eight|nine).*$"

  defp part1(input) do
    input
    |> Enum.map(&find_endpoints(&1, [Regex.compile!(@pattern1, "U"), Regex.compile!(@pattern1)]))
    |> Enum.map(&to_digits1/1)
    |> Enum.map(&Integer.undigits/1)
    |> Enum.sum()
  end

  defp part2(input) do
    input
    |> Enum.map(&find_endpoints(&1, [Regex.compile!(@pattern2, "U"), Regex.compile!(@pattern2)]))
    |> Enum.map(&to_digits2/1)
    |> Enum.map(&Integer.undigits/1)
    |> Enum.sum()
  end

  defp find_endpoints(line, regexes) do
    regexes
    |> Enum.map(&Regex.named_captures(&1, line))
    |> Enum.map(&Map.get(&1, "dig", ""))
  end

  defp to_digits1(digits_like), do: Enum.map(digits_like, &String.to_integer/1)

  defp to_digits2(digits_like), do: Enum.map(digits_like, &to_digit2/1)

  defp to_digit2("zero"), do: 0
  defp to_digit2("one"), do: 1
  defp to_digit2("two"), do: 2
  defp to_digit2("three"), do: 3
  defp to_digit2("four"), do: 4
  defp to_digit2("five"), do: 5
  defp to_digit2("six"), do: 6
  defp to_digit2("seven"), do: 7
  defp to_digit2("eight"), do: 8
  defp to_digit2("nine"), do: 9
  defp to_digit2(other), do: String.to_integer(other)
end

Y2023.D01.bench1()
