defmodule Y2023.D16 do
  use Day, input: "2023/16", part1: ~c"l", part2: ~c"l"

  def part1(input) do
    {map, _} = parse_input(input)

    map
    |> walk({0, 0}, w())
    |> Enum.count()
  end

  def part2(input) do
    {map, {width, height}} = parse_input(input)

    north_boundary = {0..(width - 1), [0], n()}
    east_boundary = {[width - 1], 0..(height - 1), e()}
    south_boundary = {0..(width - 1), [height - 1], s()}
    west_boundary = {[0], 0..(height - 1), w()}

    [north_boundary, east_boundary, south_boundary, west_boundary]
    |> Enum.flat_map(&walk_boundary(map, &1))
    |> Enum.map(&Enum.count/1)
    |> Enum.max()
  end

  defp walk(map, {x, y} = xy, dirs, context \\ nil, energized \\ MapSet.new()) do
    Performance.once({xy, dirs, context}, energized, fn ->
      if(Map.has_key?(map, xy)) do
        energized = MapSet.put(energized, xy)

        {n, e, s, w} =
          map
          |> Map.get(xy)
          |> outputs?(dirs)

        energized = if n, do: walk(map, {x, y - 1}, s(), context, energized), else: energized
        energized = if e, do: walk(map, {x + 1, y}, w(), context, energized), else: energized
        energized = if s, do: walk(map, {x, y + 1}, n(), context, energized), else: energized
        energized = if w, do: walk(map, {x - 1, y}, e(), context, energized), else: energized

        energized
      else
        energized
      end
    end)
  end

  defp walk_boundary(map, {x_range, y_range, dir}) do
    for x <- x_range, y <- y_range, do: walk(map, {x, y}, dir, {x, y})
  end

  defp n(), do: {true, false, false, false}
  defp e(), do: {false, true, false, false}
  defp s(), do: {false, false, true, false}
  defp w(), do: {false, false, false, true}

  defp outputs?("\\", {n, e, s, w}), do: {e, n, w, s}
  defp outputs?("/", {n, e, s, w}), do: {w, s, e, n}
  defp outputs?(".", {n, e, s, w}), do: {s, w, n, e}
  defp outputs?("-", {n, e, s, w}), do: {false, n or s or w, false, n or e or s}
  defp outputs?("|", {n, e, s, w}), do: {e or s or w, false, n or e or w, false}

  defp parse_input(input) do
    matrix = Enum.map(input, &Utils.splitrim(&1, ""))
    width = matrix |> Enum.at(0) |> Enum.count()
    height = Enum.count(matrix)

    {Matrix.to_map(matrix), {width, height}}
  end
end

Y2023.D16.bench2()
