defmodule Y2024.D20 do
  use Day, input: "2024/20", part1: ~c"g", part2: ~c"g"

  @n {-1, 0}
  @e {0, +1}
  @s {+1, 0}
  @w {0, -1}

  defp partX(input, max_cheat_size, save) do
    raw_map = Matrix.to_rc_map(input)

    start_rc = find_key(raw_map, "S")
    end_rc = find_key(raw_map, "E")

    raw_map
    |> Map.replace(start_rc, ".")
    |> Map.replace(end_rc, ".")
    |> path(nil, start_rc, end_rc, [])
    |> count_cheats(max_cheat_size, save)
  end

  defp part1(input), do: partX(input, 2, 100)
  defp part2(input), do: partX(input, 20, 100)

  def count_cheats([], _, _), do: 0

  def count_cheats([from | tail], max_cheat_size, save) do
    tail
    |> Enum.drop(save)
    |> Enum.with_index()
    |> Enum.count(fn {to, index} ->
      cheat_size = distance(from, to)
      cheat_size <= max_cheat_size and index + 1 >= cheat_size
    end)
    |> Kernel.+(count_cheats(tail, max_cheat_size, save))
  end

  def path(_, _, target_rc, target_rc, wip), do: Enum.reverse([target_rc | wip])

  def path(map, previous_rc, current_rc, target_rc, wip) do
    [next_rc] =
      [@n, @e, @s, @w]
      |> Enum.map(&forward(current_rc, &1))
      |> Enum.reject(&(&1 == previous_rc))
      |> Enum.filter(&(Map.get(map, &1) == "."))

    path(map, current_rc, next_rc, target_rc, [current_rc | wip])
  end

  defp distance({r1, c1}, {r2, c2}), do: abs(r2 - r1) + abs(c2 - c1)
  defp forward({r, c}, {dr, dc}), do: {r + dr, c + dc}

  defp find_key(map, value) do
    map
    |> Enum.find(&(elem(&1, 1) == value))
    |> elem(0)
  end
end

Y2024.D20.bench2()
