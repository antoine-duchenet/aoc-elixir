defmodule Y2024.D12 do
  use Day, input: "2024/12", part1: ~c"g", part2: ~c"g"

  @n {-1, 0}
  @e {0, 1}
  @s {1, 0}
  @w {0, -1}

  defp part1(input) do
    filled_map =
      input
      |> to_regions_map()
      |> fill_regions()

    boundaries = count_boundaries(filled_map)

    filled_map
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
    |> Enum.map(fn {id, size} -> size * Map.get(boundaries, id) end)
    |> Enum.sum()
  end

  defp part2(input) do
    filled_map =
      input
      |> to_regions_map()
      |> fill_regions()

    sides = count_sides(filled_map)

    filled_map
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
    |> Enum.map(fn {id, size} -> size * Map.get(sides, id, 0) end)
    |> Enum.sum()
  end

  defp fill_regions(regions_map) do
    case Enum.find(regions_map, fn {_, {_, region}} -> region == nil end) do
      nil ->
        regions_map

      {rc, {type, nil}} = region_to_walk ->
        region_to_walk
        |> then(&walk(regions_map, &1, {type, rc}))
        |> fill_regions()
    end
  end

  defp walk(regions_map, {_, nil}, _), do: regions_map

  defp walk(regions_map, {rc, {type, nil}}, {type, _} = region_id) do
    regions_map
    |> Map.put(rc, region_id)
    |> walk_to(move(rc, @n), region_id)
    |> walk_to(move(rc, @e), region_id)
    |> walk_to(move(rc, @s), region_id)
    |> walk_to(move(rc, @w), region_id)
  end

  defp walk(regions_map, _, _), do: regions_map

  defp walk_to(regions_map, pos, region_id) do
    regions_map
    |> Map.get(pos)
    |> then(&walk(regions_map, {pos, &1}, region_id))
  end

  defp count_boundaries(filled_map) do
    filled_map
    |> to_boundaries(&Enum.count/1)
    |> Enum.map(fn {k, v} -> {k, Enum.sum(v)} end)
    |> Enum.into(%{})
  end

  defp count_sides(filled_map) do
    filled_map
    |> to_boundaries()
    |> Enum.map(fn {rid, boundaries} -> {rid, List.flatten(boundaries)} end)
    |> Enum.map(fn {rid, flatten_boundaries} -> {rid, to_boundaries_map(flatten_boundaries)} end)
    |> Enum.map(fn {rid, boundaries_map} -> {rid, to_sides(boundaries_map)} end)
    |> Enum.into(%{})
  end

  defp to_boundaries_map(flatten_boundaries) do
    flatten_boundaries
    |> Enum.map(fn {rc, dir, true} -> {{rc, dir}, false} end)
    |> Enum.into(%{})
  end

  defp to_sides(boundaries_map, sides \\ 0) do
    case Enum.find(boundaries_map, &(elem(&1, 1) == false)) do
      nil ->
        sides

      {side_start, false} ->
        boundaries_map
        |> follow_side(side_start)
        |> to_sides(sides + 1)
    end
  end

  defp follow_side(boundaries_map, {rc, dir} = from) do
    case Map.get(boundaries_map, from) do
      false ->
        boundaries_map
        |> Map.put(from, true)
        |> follow_side({move(rc, @n), dir})
        |> follow_side({move(rc, @e), dir})
        |> follow_side({move(rc, @s), dir})
        |> follow_side({move(rc, @w), dir})

      _ ->
        boundaries_map
    end
  end

  defp to_boundaries(filled_map, transform \\ & &1) do
    filled_map
    |> Enum.map(&to_boundaries(filled_map, &1, transform))
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  defp to_boundaries(filled_map, {rc, region_id}, transform) do
    boundaries =
      rc
      |> neighboors(filled_map, &(&1 != region_id))
      |> Enum.filter(&elem(&1, 2))
      |> transform.()

    {region_id, boundaries}
  end

  defp neighboors(rc, map, value_fn) do
    [@n, @e, @s, @w]
    |> Enum.map(fn dir ->
      neighboor =
        map
        |> Map.get(move(rc, dir))
        |> value_fn.()

      {rc, dir, neighboor}
    end)
  end

  defp move({r, c}, {dr, dc}), do: {r + dr, c + dc}

  defp to_regions_map(input) do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, c} ->
        {{r, c}, {cell, nil}}
      end)
    end)
    |> Enum.into(%{})
  end
end

Y2024.D12.bench2()
