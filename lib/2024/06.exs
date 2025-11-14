defmodule Y2024.D06 do
  use Day, input: "2024/06", part1: ~c"g", part2: ~c"g"

  @n {-1, 0}
  @e {0, 1}
  @s {1, 0}
  @w {0, -1}

  defp part1(input) do
    map = to_map(input)

    {start_rc, _} = Enum.find(map, fn {_, v} -> v == "^" end)

    map
    |> walk1(start_rc, @n, MapSet.new())
    |> MapSet.size()
  end

  defp part2(input) do
    map = to_map(input)

    {start_rc, _} = Enum.find(map, fn {_, v} -> v == "^" end)

    pristine_path = walk1(map, start_rc, @n, MapSet.new())

    pristine_path
    |> MapSet.delete(start_rc)
    |> Enum.filter(&walk2(Map.replace(map, &1, "#"), start_rc, @n, MapSet.new()))
    |> Enum.count()
    |> dbg
  end

  defp walk1(map, rc, dir, path) do
    new_path = MapSet.put(path, rc)
    next_rc = move(rc, dir)

    case Map.get(map, next_rc) do
      nil ->
        new_path

      "#" ->
        walk1(map, rc, turn(dir), new_path)

      _ ->
        walk1(map, next_rc, dir, new_path)
    end
  end

  defp walk2(map, rc, dir, path) do
    with false <- MapSet.member?(path, {rc, dir}) do
      new_path = MapSet.put(path, {rc, dir})
      next_rc = move(rc, dir)

      case Map.get(map, next_rc) do
        nil ->
          false

        "#" ->
          walk2(map, rc, turn(dir), new_path)

        _ ->
          walk2(map, next_rc, dir, new_path)
      end
    end
  end

  defp move({r, c}, {dr, dc}), do: {r + dr, c + dc}

  defp turn(@n), do: @e
  defp turn(@e), do: @s
  defp turn(@s), do: @w
  defp turn(@w), do: @n

  defp to_map(input) do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, c} ->
        {{r, c}, cell}
      end)
    end)
    |> Enum.into(%{})
  end
end

Y2024.D06.bench2()
