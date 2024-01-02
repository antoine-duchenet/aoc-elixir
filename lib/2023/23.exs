import Input

defmodule Y2023.D23 do
  defp part1(input) do
    {map, start, target} = parse_input(input)

    walk1(map, start, MapSet.new(), target)
  end

  defp part2(input) do
    {map, start, target} = parse_input(input)

    walk2(map, start, MapSet.new(), target)
  end

  defp walk1(_, target, trail, target), do: MapSet.size(trail)

  defp walk1(map, {x, y} = xy, trail, target) do
    map
    |> Map.get(xy)
    |> case do
      "." ->
        [
          {x - 1, y},
          {x + 1, y},
          {x, y - 1},
          {x, y + 1}
        ]

      ">" ->
        [{x + 1, y}]

      "<" ->
        [{x - 1, y}]

      "v" ->
        [{x, y + 1}]

      "^" ->
        [{x, y - 1}]
    end
    |> Enum.filter(fn candidate_xy ->
      candidate = Map.get(map, candidate_xy)

      candidate != nil and candidate != "#" and
        not MapSet.member?(trail, candidate_xy)
    end)
    |> case do
      [] ->
        -1

      [next_xy] ->
        walk1(map, next_xy, MapSet.put(trail, xy), target)

      next_xys ->
        next_xys
        |> Enum.map(&walk1(map, &1, MapSet.put(trail, xy), target))
        |> Enum.max()
    end
  end

  defp walk2(_, target, trail, target), do: MapSet.size(trail)

  defp walk2(map, {x, y} = xy, trail, target) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
    |> Enum.filter(fn candidate_xy ->
      candidate = Map.get(map, candidate_xy)

      candidate != nil and candidate != "#" and
        not MapSet.member?(trail, candidate_xy)
    end)
    |> case do
      [] ->
        -1

      [next_xy] ->
        walk2(map, next_xy, MapSet.put(trail, xy), target)

      next_xys ->
        next_xys
        |> Enum.map(&walk2(map, &1, MapSet.put(trail, xy), target))
        |> Enum.max()
    end
  end

  defp parse_input(input) do
    matrix = Enum.map(input, &Utils.splitrim(&1, ""))

    height = Enum.count(matrix)

    sy = 0
    sx = matrix |> Enum.at(sy) |> Enum.with_index() |> Enum.find(&(elem(&1, 0) == ".")) |> elem(1)

    ty = height - 1
    tx = matrix |> Enum.at(ty) |> Enum.with_index() |> Enum.find(&(elem(&1, 0) == ".")) |> elem(1)

    {Matrix.to_map(matrix), {sx, sy}, {tx, ty}}
  end

  def bench1() do
    Benchmark.mesure_milliseconds(fn -> part1(~i[2023/23]l) end)
  end

  def bench2() do
    Benchmark.mesure_milliseconds(fn -> part2(~i[2023/23]l) end)
  end
end

Y2023.D23.bench2()
