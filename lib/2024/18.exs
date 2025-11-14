defmodule Y2024.D18 do
  use Day, input: "2024/18", part1: ~c"c", part2: ~c"c"

  @n {-1, 0}
  @e {0, +1}
  @s {+1, 0}
  @w {0, -1}

  defp part1(input) do
    {incoming, sample, start_rc, end_rc, empty_map} = bootstrap(input)

    map =
      incoming
      |> Enum.take(sample)
      |> Enum.reduce(empty_map, fn rc, acc -> Map.replace(acc, rc, "#") end)

    visited = walk(map, end_rc, [{start_rc, MapSet.new([start_rc])}])

    Enum.count(visited)
  end

  defp part2(input) do
    {incoming, sample, start_rc, end_rc, empty_map} = bootstrap(input)

    Stream.iterate(
      {0, sample, empty_map},
      fn
        {previous_sam, sam, previous_map} ->
          map =
            incoming
            |> Enum.drop(previous_sam)
            |> Enum.take(sam - previous_sam)
            |> Enum.reduce(previous_map, fn rc, wip_map -> Map.replace(wip_map, rc, "#") end)

          map
          |> walk(end_rc, [{start_rc, MapSet.new([start_rc])}])
          |> case do
            :blocked ->
              sam

            visited ->
              common_index =
                incoming
                |> Enum.with_index()
                |> Enum.drop(sam)
                |> Enum.find(fn {inc, _} -> MapSet.member?(visited, inc) end)
                |> elem(1)

              {sam, common_index + 1, map}
          end

        sam ->
          sam
      end
    )
    |> Stream.reject(&is_tuple/1)
    |> Enum.at(0)
    |> then(&Enum.at(incoming, &1 - 1))
    # beacuse {r, c} = {y, x}
    |> then(&"#{elem(&1, 1)},#{elem(&1, 0)}")
  end

  defp walk(_, "#", _), do: []
  defp walk(_, nil, _), do: []

  defp walk(current_rc, ".", visited) do
    [@n, @e, @s, @w]
    |> Enum.map(&forward(current_rc, &1))
    |> Enum.reject(&MapSet.member?(visited, &1))
    |> Enum.map(&{&1, MapSet.put(visited, current_rc)})
  end

  defp walk(_, _, []), do: :blocked

  defp walk(map, end_rc, states) do
    new_states =
      states
      |> Enum.flat_map(&walk(map, &1))
      |> Enum.uniq_by(&elem(&1, 0))

    new_states
    |> Enum.filter(fn {rc, _} -> rc == end_rc end)
    |> case do
      [] -> walk(map, end_rc, new_states)
      [{^end_rc, visited} | _] -> visited
    end
  end

  defp walk(map, {current_rc, visited}), do: walk(current_rc, Map.get(map, current_rc), visited)

  defp forward({r, c}, {dr, dc}), do: {r + dr, c + dc}

  defp bootstrap(input) do
    {{max_r, max_c}, sample, incoming} = parse_input(input)

    start_rc = {0, 0}
    end_rc = {max_r, max_c}

    empty_map = for r <- 0..max_r, c <- 0..max_c, do: {{r, c}, "."}, into: %{}

    {incoming, sample, start_rc, end_rc, empty_map}
  end

  defp parse_input([dimensions_chunk, sample_chunk, incoming_chunk]) do
    {
      parse_dimensions(dimensions_chunk),
      parse_sample(sample_chunk),
      parse_incoming(incoming_chunk)
    }
  end

  defp parse_dimensions([dimensions_line]), do: parse_position(dimensions_line)

  defp parse_sample([sample_line]), do: String.to_integer(sample_line)

  defp parse_incoming(incoming_chunk), do: Enum.map(incoming_chunk, &parse_position/1)

  defp parse_position(position_line) do
    [c, r] =
      position_line
      |> Utils.splitrim(",")
      |> Enum.map(&String.to_integer/1)

    {r, c}
  end
end

Y2024.D18.bench2()
