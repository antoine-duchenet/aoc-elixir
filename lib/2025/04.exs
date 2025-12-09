defmodule Y2025.D04 do
  use Day, input: "2025/04", part1: ~c"g", part2: ~c"g"

  @roll "@"
  @empty "."

  defp part1(input) do
    input
    |> Matrix.to_rc_map()
    |> count_reachable()
  end

  defp part2(input) do
    input
    |> Matrix.to_rc_map()
    |> recursive_remove(0)
  end

  defp recursive_remove(map, count) do
removable_count = count_reachable(map)

    if count == 0 do
      count
    else
      next_map =
        map
        |> Enum.map(fn
          cell = {pos, @roll} -> if can_reach?(map, cell), do: {pos, @empty}, else: cell
          cell -> cell
        end)
        |> Map.new()

      recursive_remove(next_map, count + removable_count)
    end
  end

  defp count_reachable(map), do: Enum.count(map, &can_reach?(map, &1))

  defp can_reach?(map, {pos, @roll}) do
    pos
    |> adjacent_pos()
    |> Enum.count(&(Map.get(map, &1, @empty) == @roll))
    |> Kernel.<(4)
  end

  defp can_reach?(_, {_, _}), do: false

  defp adjacent_pos({r, c}) do
    for dr <- -1..1, dc <- -1..1, dr != 0 or dc != 0 do
      {r + dr, c + dc}
    end
  end
end

Y2025.D04.bench1()
