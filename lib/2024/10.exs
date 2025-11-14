defmodule Y2024.D10 do
  use Day, input: "2024/10", part1: ~c"g", part2: ~c"g"

  @n {-1, 0}
  @e {0, 1}
  @s {1, 0}
  @w {0, -1}

  defp partX(input, score) do
    map =
      input
      |> parse_input()
      |> to_map()

    map
    |> Enum.filter(&(elem(&1, 1) == 0))
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&score.(&1, map))
    |> Enum.sum()
  end

  defp part1(input), do: partX(input, &score1/2)
  defp part2(input), do: partX(input, &score2/2)

  defp score1(start, map) do
    start
    |> walk1(map, -1, MapSet.new())
    |> Enum.count()
  end

  defp score2(start, map), do: walk2(start, map, -1)

  defp walk1(pos, map, 8, reached) do
    case Map.get(map, pos) do
      9 -> MapSet.put(reached, pos)
      _ -> reached
    end
  end

  defp walk1(pos, map, previous_height, reached) do
    target_height = previous_height + 1

    case Map.get(map, pos) do
      ^target_height ->
        reached
        |> then(&walk1(move(pos, @n), map, target_height, &1))
        |> then(&walk1(move(pos, @e), map, target_height, &1))
        |> then(&walk1(move(pos, @s), map, target_height, &1))
        |> then(&walk1(move(pos, @w), map, target_height, &1))

      _ ->
        reached
    end
  end

  defp walk2(pos, map, 8) do
    case Map.get(map, pos) do
      9 -> 1
      _ -> 0
    end
  end

  defp walk2(pos, map, previous_height) do
    target_height = previous_height + 1

    case Map.get(map, pos) do
      ^target_height ->
        (pos |> move(@n) |> walk2(map, target_height)) +
          (pos |> move(@e) |> walk2(map, target_height)) +
          (pos |> move(@s) |> walk2(map, target_height)) +
          (pos |> move(@w) |> walk2(map, target_height))

      _ ->
        0
    end
  end

  defp move({r, c}, {dr, dc}), do: {r + dr, c + dc}

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

  defp parse_input(input) do
    Enum.map(input, fn row -> Enum.map(row, &String.to_integer/1) end)
  end
end

Y2024.D10.bench2()
