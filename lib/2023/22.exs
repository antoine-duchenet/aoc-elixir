defmodule Y2023.D22 do
  use Day, input: "2023/22", part1: ~c"l", part2: ~c"l"

  def part1(input) do
    {graphs, ids} = bootstrap(input)

    ids
    |> Enum.filter(&is_overage(graphs, &1))
    |> Enum.count()
  end

  def part2(input) do
    {graphs, ids} = bootstrap(input)

    ids
    |> Enum.map(&chain_react(graphs, MapSet.new([&1])))
    |> Enum.sum()
  end

  defp chain_react(graphs, last_fallen, already_fallen \\ MapSet.new())
  defp chain_react(_, %MapSet{map: map}, _) when map_size(map) == 0, do: 0

  defp chain_react({under, over} = graphs, last_fallen, already_fallen) do
    all_fallen = MapSet.union(last_fallen, already_fallen)

    new_fallen =
      last_fallen
      |> Enum.flat_map(&Map.get(over, &1, MapSet.new()))
      |> Enum.filter(&will_fall?(under, all_fallen, &1))
      |> MapSet.new()

    Enum.count(new_fallen) + chain_react(graphs, new_fallen, all_fallen)
  end

  defp is_overage({under, over}, id) do
    over
    |> Map.get(id, MapSet.new())
    |> Enum.all?(&(not will_fall?(under, MapSet.new([id]), &1)))
  end

  defp will_fall?(under_graph, fallen, id) do
    under_graph
    |> Map.get(id)
    |> MapSet.difference(fallen)
    |> MapSet.size()
    |> Kernel.==(0)
  end

  defp build_graphs(stack) do
    Enum.reduce(stack, {Map.new(), Map.new()}, fn {z, layer}, accz ->
      Enum.reduce(layer, accz, fn {x, chunk}, accx ->
        Enum.reduce(chunk, accx, fn {y, under}, {u, o} = uo ->
          case stack_at(stack, {x, y, z + 1}) do
            nil ->
              uo

            ^under ->
              uo

            over ->
              pu = Map.get(u, over, MapSet.new())
              po = Map.get(o, under, MapSet.new())
              {Map.put(u, over, MapSet.put(pu, under)), Map.put(o, under, MapSet.put(po, over))}
          end
        end)
      end)
    end)
  end

  defp stack_at(_, {_, _, 0}), do: :g
  defp stack_at(stack, {x, y, z}), do: stack |> stack_at(z) |> layer_at({x, y})
  defp stack_at(stack, z), do: Map.get(stack, z, Map.new())

  defp stack_max(stack, {x, y}) do
    stack
    |> Enum.map(&{elem(&1, 0), stack_at(stack, {x, y, elem(&1, 0)})})
    |> Enum.reject(&is_nil(elem(&1, 1)))
    |> Enum.map(&elem(&1, 0))
    |> Enum.max(&>=/2, fn -> 0 end)
  end

  defp stack_add(stack, map, {id, {x, y, _}}) do
    {dx, dy, dz} = Map.fetch!(map, id)

    xys = for vx <- x..(x + dx), vy <- y..(y + dy), do: {vx, vy}

    minz =
      xys
      |> Enum.map(&stack_max(stack, &1))
      |> Enum.max()
      |> Kernel.+(1)

    Enum.reduce(xys, stack, fn {vx, vy}, stacc0 ->
      Enum.reduce(minz..(minz + dz), stacc0, fn vz, stacc1 ->
        stack_fill(stacc1, {vx, vy, vz}, id)
      end)
    end)
  end

  defp stack_fill(stack, {x, y, z}, id) do
    layer = Map.get(stack, z, Map.new())
    Map.put(stack, z, layer_fill(layer, {x, y}, id))
  end

  defp layer_at(layer, {x, y}), do: layer |> Map.get(x, Map.new()) |> Map.get(y, nil)

  defp layer_fill(layer, {x, y}, id) do
    chunk = Map.get(layer, x, Map.new())
    Map.put(layer, x, Map.put(chunk, y, id))
  end

  defp bootstrap(input) do
    {flow, map} = parse_input(input)

    stack = Enum.reduce(flow, Map.new(), &stack_add(&2, map, &1))

    {build_graphs(stack), Map.keys(map)}
  end

  defp parse_input(input) do
    raw =
      input
      |> Enum.map(&parse_line/1)
      |> Enum.sort_by(fn [{_, _, z}, _] -> z end)
      |> Enum.with_index()
      |> Enum.map(fn {[s, e], i} -> {"##{i}", s, e} end)

    flow = Enum.map(raw, &{elem(&1, 0), elem(&1, 1)})

    map =
      raw
      |> Enum.map(fn {i, {sx, sy, sz}, {ex, ey, ez}} -> {i, {ex - sx, ey - sy, ez - sz}} end)
      |> Map.new()

    {flow, map}
  end

  defp parse_line(line) do
    line
    |> Utils.splitrim("~")
    |> Enum.map(&parse_xyz/1)
  end

  defp parse_xyz(string) do
    string
    |> Utils.splitrim(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end

Y2023.D22.bench2()
