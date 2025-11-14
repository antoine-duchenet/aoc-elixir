defmodule Y2024.D07 do
  use Day, input: "2024/07", part1: ~c"l", part2: ~c"l"

  defp part1(input), do: partX(input, false)
  defp part2(input), do: partX(input, true)

  defp partX(input, concat?) do
    input
    |> Enum.map(&parse_line/1)
    |> Enum.filter(&works?(&1, concat?))
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  defp works?({r, [a, b | t]}, concat?) do
    works?({r, [a + b | t]}, concat?) or
      works?({r, [a * b | t]}, concat?) or
      (concat? and works?({r, [concat(a, b) | t]}, concat?))
  end

  defp works?({r, [r]}, _), do: true
  defp works?(_, _), do: false

  defp concat(a, b) do
    shift =
      b
      |> Integer.digits()
      |> Enum.count()

    a * 10 ** shift + b
  end

  defp parse_line(line) do
    [head | tail] = Utils.splitrim(line, " ")

    result =
      head
      |> String.replace(":", "")
      |> String.to_integer()

    components = Enum.map(tail, &String.to_integer/1)

    {result, components}
  end
end

Y2024.D07.bench2()
