defmodule Y2024.D11 do
  use Day, input: "2024/11", part1: ~c"w", part2: ~c"w"

  defp part1(input), do: partX(input, 25)
  defp part2(input), do: partX(input, 1000)

  defp partX(input, steps) do
    input
    |> parse_input()
    |> blink(steps)
  end

  defp blink([_], 0), do: 1

  defp blink([0], steps), do: blink([1], steps - 1)

  defp blink([h], steps) do
    Performance.memoize({h, steps}, fn ->
      case should_split?(h) do
        {true, split_params} -> split_params |> split() |> blink(steps - 1)
        _ -> blink([h * 2024], steps - 1)
      end
    end)
  end

  defp blink([h | tail], steps) do
    blink([h], steps) + blink(tail, steps)
  end

  defp should_split?(n) do
    digits = Integer.digits(n)

    digits_number = Enum.count(digits)

    even =
      digits_number
      |> rem(2)
      |> Kernel.==(0)

    {even, {digits, digits_number}}
  end

  defp split({digits, digits_number}) do
    part_size = div(digits_number, 2)

    n1 =
      digits
      |> Enum.take(part_size)
      |> Integer.undigits()

    n2 =
      digits
      |> Enum.drop(part_size)
      |> Integer.undigits()

    [n1, n2]
  end

  defp parse_input(input) do
    input
    |> Utils.splitrim(" ")
    |> Enum.map(&String.to_integer/1)
  end
end

Y2024.D11.bench2()
