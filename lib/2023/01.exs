import Input

defmodule Y2023.D1 do
  @pattern "^.*(?<dig>\\d|one|two|three|four|five|six|seven|eight|nine).*$"
  @first_regex Regex.compile!(@pattern, "U")
  @last_regex Regex.compile!(@pattern)

  defp part2(input) do
    input
    |> Enum.map(&find_endpoints/1)
    |> Enum.map(&to_digits/1)
    |> Enum.map(&Integer.undigits/1)
    |> Enum.sum()
    |> dbg
  end

  defp find_endpoints(line) do
    [@first_regex, @last_regex]
    |> Enum.map(&Regex.named_captures(&1, line))
    |> Enum.map(&Map.get(&1, "dig", ""))
  end

  defp to_digits(maybe_digits), do: Enum.map(maybe_digits, &to_digit/1)

  defp to_digit("zero"), do: 0
  defp to_digit("one"), do: 1
  defp to_digit("two"), do: 2
  defp to_digit("three"), do: 3
  defp to_digit("four"), do: 4
  defp to_digit("five"), do: 5
  defp to_digit("six"), do: 6
  defp to_digit("seven"), do: 7
  defp to_digit("eight"), do: 8
  defp to_digit("nine"), do: 9
  defp to_digit(other), do: String.to_integer(other)

  def bench2() do
    Benchmark.mesure_milliseconds(fn -> part2(~i[2023/01]l) end)
  end
end

Y2023.D1.bench2()
