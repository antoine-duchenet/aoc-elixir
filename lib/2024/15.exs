defmodule Y2024.D15.Guards do
  defguard is_vertical(step) when step == "^" or step == "v"
  defguard is_horizontal(step) when step == "<" or step == ">"
  defguard is_box(cell) when cell == "[" or cell == "]"
end

defmodule Y2024.D15 do
  use Day, input: "2024/15", part1: ~c"c", part2: ~c"c"

  import Y2024.D15.Guards

  defp partX(input, transform \\ & &1) do
    {grid, steps} = parse_input(input)

    map =
      grid
      |> transform.()
      |> to_map()

    {start_rc, "@"} = Enum.find(map, &(elem(&1, 1) == "@"))

    steps
    |> Enum.reduce({map, start_rc}, &try/2)
    |> elem(0)
    |> locate()
  end

  defp part1(input), do: partX(input)

  defp part2(input), do: partX(input, &widen/1)

  defp try(step, {map, rc}) do
    if can?(map, rc, step) do
      {act(map, rc, step), to(rc, step)}
    else
      {map, rc}
    end
  end

  defp can?(_, _, ".", _, _), do: true
  defp can?(_, _, "#", _, _), do: false

  defp can?(map, rc, "[", step, expand?) when is_vertical(step) do
    can?(map, to(rc, step), step) and (not expand? or can?(map, to(rc, ">"), step, false))
  end

  defp can?(map, rc, "]", step, expand?) when is_vertical(step) do
    can?(map, to(rc, step), step) and (not expand? or can?(map, to(rc, "<"), step, false))
  end

  defp can?(map, rc, _, step, _), do: can?(map, to(rc, step), step)

  defp can?(map, rc, step, expand? \\ true), do: can?(map, rc, Map.get(map, rc), step, expand?)

  defp act(map, _, ".", _, _), do: map

  defp act(map, rc, cell, step, expand?) when is_box(cell) and is_vertical(step) do
    map
    |> act(to(rc, step), step)
    |> Map.replace(to(rc, step), cell)
    |> Map.replace(rc, ".")
    |> then(fn m ->
      if expand? do
        act(m, rc |> to(expand_dir(cell)), step, false)
      else
        m
      end
    end)
  end

  defp act(map, rc, cell, step, _) do
    map
    |> act(to(rc, step), step)
    |> Map.replace(to(rc, step), cell)
    |> Map.replace(rc, ".")
  end

  defp act(map, rc, step, expand? \\ true), do: act(map, rc, Map.get(map, rc), step, expand?)

  defp locate({{r, c}, "O"}), do: r * 100 + c
  defp locate({{r, c}, "["}), do: r * 100 + c
  defp locate({_, _}), do: 0

  defp locate(map) do
    map
    |> Enum.map(&locate/1)
    |> Enum.sum()
  end

  defp widen(grid) do
    Enum.map(grid, fn row ->
      Enum.flat_map(row, fn
        "." -> [".", "."]
        "#" -> ["#", "#"]
        "O" -> ["[", "]"]
        "@" -> ["@", "."]
      end)
    end)
  end

  defp to({r, c}, {dr, dc}), do: {r + dr, c + dc}
  defp to(rc, step), do: to(rc, dir(step))

  defp expand_dir("]"), do: dir("<")
  defp expand_dir("["), do: dir(">")

  defp dir("^"), do: {-1, 0}
  defp dir("v"), do: {+1, 0}
  defp dir("<"), do: {0, -1}
  defp dir(">"), do: {0, +1}

  defp to_map(grid) do
    grid
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, c} -> {{r, c}, cell} end)
    end)
    |> Enum.into(%{})
  end

  defp parse_input(input) do
    [map_chunck, steps_chunk] = input

    {parse_grid(map_chunck), parse_steps(steps_chunk)}
  end

  defp parse_grid(grid_chunk), do: Enum.map(grid_chunk, &Utils.splitrim/1)

  defp parse_steps(steps_chunk) do
    steps_chunk
    |> Enum.join("")
    |> Utils.splitrim("")
  end
end

Y2024.D15.bench2()
