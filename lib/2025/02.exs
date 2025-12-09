defmodule Y2025.D02 do
  use Day, input: "2025/02", part1: ~c"w", part2: ~c"w"

  defp part1(input) do
    ranges = parse_input(input)

    ranges
    |> Enum.flat_map(&for n <- &1, is_twice?(n), do: n)
    |> Enum.sum()
  end

  defp part2(input) do
    ranges = parse_input(input)

    ranges
    |> Enum.flat_map(&for n <- &1, is_at_least_twice?(n), do: n)
    |> Enum.sum()
  end

  defp is_twice?(n) do
    n
    |> Integer.to_string()
    |> String.match?(~r/^(\d+)\1$/)

    # halfs = String.split_at(str, div(String.length(str), 2))
    # elem(halfs, 0) == elem(halfs, 1)
  end

  defp is_at_least_twice?(n) do
    n
    |> Integer.to_string()
    |> String.match?(~r/^(\d+)\1+$/)
  end

  defp parse_input(input) do
    input
    |> Utils.splitrim(",")
    |> Enum.map(&parse_range/1)
  end

  defp parse_range(range) do
    [from, to] = String.split(range, "-")
    String.to_integer(from)..String.to_integer(to)
  end
end

Y2025.D02.bench2()
