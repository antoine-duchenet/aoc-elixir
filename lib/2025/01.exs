defmodule Y2025.D01 do
  use Day, input: "2025/01", part1: ~c"l", part2: ~c"l"

  @start 50
  @size 100

  defp part1(input) do
    input
    |> parse_input()
    |> Enum.scan(@start, fn
      {"L", n}, acc -> mod(acc - n)
      {"R", n}, acc -> mod(acc + n)
    end)
    |> Enum.count(&(&1 == 0))
  end

  defp part2(input) do
    input
    |> parse_input()
    |> Enum.map_reduce(@start, fn
      {"L", n}, acc -> {div(n) + overflow(acc, -rem(n)), mod(acc - rem(n))}
      {"R", n}, acc -> {div(n) + overflow(acc, rem(n)), mod(acc + rem(n))}
    end)
    |> elem(0)
    |> Enum.sum()
  end

  defp overflow(acc, rest) when acc + rest <= 0 and acc != 0, do: 1
  defp overflow(acc, rest) when acc + rest >= @size, do: 1
  defp overflow(_, _), do: 0

  defp div(n), do: div(n, @size)
  defp rem(n), do: rem(n, @size)
  defp mod(n), do: Integer.mod(n, @size)

  defp parse_input(input), do: Enum.map(input, &parse_line/1)
  defp parse_line(<<dir::bytes-size(1), n::binary>>), do: {dir, String.to_integer(n)}
end

Y2025.D01.bench2()
