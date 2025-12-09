defmodule Y2025.D07 do
  use Day, input: "2025/07", part1: ~c"g", part2: ~c"g"

  defp part1(input) do
    map = Matrix.to_rc_map(input)
    walk1(map, MapSet.new([start(map)]), 0)
  end

  defp part2(input) do
    map = Matrix.to_rc_map(input)
    walk2(map, Map.new([{start(map), 1}]))
  end

  defp walk1(map, beams, split_count) do
    if Enum.empty?(beams) do
      split_count
    else
      {next_beams, next_split_count} =
        Enum.reduce(beams, {MapSet.new(), split_count}, fn rc, {b, sc} ->
          south = s(rc)

          case Map.get(map, south) do
            "." -> {MapSet.put(b, south), sc}
            "^" -> {b |> MapSet.put(e(south)) |> MapSet.put(w(south)), sc + 1}
            _ -> {b, sc}
          end
        end)

      walk1(map, next_beams, next_split_count)
    end
  end

  defp walk2(map, beams) do
    new_beams =
      Enum.reduce(beams, Map.new(), fn {rc, quantity}, b ->
        south = s(rc)

        case Map.get(map, south) do
          "." ->
            Map.update(b, south, quantity, &(&1 + quantity))

          "^" ->
            b
            |> Map.update(e(south), quantity, &(&1 + quantity))
            |> Map.update(w(south), quantity, &(&1 + quantity))

          _ ->
            Map.update(b, rc, quantity, & &1)
        end
      end)

    case new_beams do
      ^beams -> beams |> Map.values() |> Enum.sum()
      next_beams -> walk2(map, next_beams)
    end
  end

  defp start(map), do: Enum.find(map, fn {_, v} -> v == "S" end) |> elem(0)
  defp e({r, c}), do: {r, c + 1}
  defp s({r, c}), do: {r + 1, c}
  defp w({r, c}), do: {r, c - 1}
end

Y2025.D07.bench2()
