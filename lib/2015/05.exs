defmodule Y2015.D05 do
  use Day, input: "2015/05", part1: ~c"l", part2: ~c"l"

  @vowels ~w(a e i o u)
  @forbidden ~w(ab cd pq xy)

  defp part1(input) do
    Enum.count(input, &is_nice1?/1)
  end

  defp part2(input) do
    Enum.count(input, &is_nice2?/1)
  end

  defp is_nice1?(str) do
    has_3_vowels? =
      str
      |> String.graphemes()
      |> Enum.count(&(&1 in @vowels))
      |> Kernel.>=(3)

    has_double? = String.match?(str, ~r/(.)\1/)
    has_forbidden? = Enum.any?(@forbidden, &String.contains?(str, &1))

    has_3_vowels? and has_double? and not has_forbidden?
  end

  defp is_nice2?(str) do
    has_pair? = String.match?(str, ~r/(..).*\1/)
    has_repeat? = String.match?(str, ~r/(.).\1/)

    has_pair? and has_repeat?
  end
end

Y2015.D05.bench1()
