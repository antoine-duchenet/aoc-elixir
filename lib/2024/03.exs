defmodule Y2024.D03 do
  use Day, input: "2024/03.aurelien", part1: ~c"w", part2: ~c"w"

  defp part1(input) do
    ~r/mul\((\d{1,3}),(\d{1,3})\)/
    |> Regex.scan(input)
    |> Enum.map(fn [_, a, b] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.sum()
  end

  defp part2(input) do
    dbg(input |> String.reverse())

    ~r/(do\(\))|(don't\(\))|mul\((\d{1,3}),(\d{1,3})\)/
    |> Regex.scan(input)
    |> Enum.reduce({0, true}, fn
      [_, "do()"], {sum, _} ->
        {sum, true}

      [_, _, "don't()"], {sum, _} ->
        {sum, false}

      [_, _, _, a, b], {sum, true} ->
        {String.to_integer(a) * String.to_integer(b) + sum, true}

      _, acc ->
        acc
    end)
    |> elem(0)
  end
end

Y2024.D03.bench2()
