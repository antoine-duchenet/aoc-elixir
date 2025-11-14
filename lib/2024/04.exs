defmodule Y2024.D04 do
  use Day, input: "2024/04", part1: ~c"g", part2: ~c"g"

  @patterns1 [
    [{0, 0}, {0, -1}, {0, -2}, {0, -3}],
    [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
    [{0, 0}, {-1, 0}, {-2, 0}, {-3, 0}],
    [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
    [{0, 0}, {1, -1}, {2, -2}, {3, -3}],
    [{0, 0}, {-1, 1}, {-2, 2}, {-3, 3}],
    [{0, 0}, {-1, -1}, {-2, -2}, {-3, -3}],
    [{0, 0}, {1, 1}, {2, 2}, {3, 3}]
  ]

  @patterns2 [
    [{-1, -1}, {-1, 1}, {0, 0}, {1, 1}, {1, -1}],
    [{-1, -1}, {1, -1}, {0, 0}, {1, 1}, {-1, 1}],
    [{1, 1}, {1, -1}, {0, 0}, {-1, -1}, {-1, 1}],
    [{1, 1}, {-1, 1}, {0, 0}, {-1, -1}, {1, -1}]
  ]

  defp part1(input) do
    partX(input, "X", @patterns1, &match1?/1)
  end

  defp part2(input) do
    partX(input, "A", @patterns2, &match2?/1)
  end

  defp partX(input, origin, patterns, match) do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      row
      |> Enum.with_index()
      |> Enum.filter(&(elem(&1, 0) == origin))
      |> Enum.flat_map(fn {_, c} ->
        Enum.map(patterns, &raycast(&1, input, {r, c}))
      end)
    end)
    |> Enum.count(match)
  end

  defp raycast(coords, grid, {r, c}) do
    Enum.map(coords, fn {dr, dc} ->
      cond do
        r + dr < 0 ->
          nil

        c + dc < 0 ->
          nil

        r + dr + 1 > Enum.count(grid) ->
          nil

        c + dc + 1 > grid |> Enum.at(0) |> Enum.count() ->
          nil

        true ->
          grid
          |> Enum.at(r + dr)
          |> Enum.at(c + dc)
      end
    end)
  end

  defp match1?(["X", "M", "A", "S"]), do: true
  defp match1?(_), do: false

  defp match2?(["M", "M", "A", "S", "S"]), do: true
  defp match2?(_), do: false
end

Y2024.D04.bench2()
