import Input

defmodule Y2023.D10 do
  @start :start
  @ground []
  @ns [:n, :s]
  @ew [:e, :w]
  @ne [:e, :n]
  @nw [:n, :w]
  @se [:e, :s]
  @sw [:s, :w]

  def part1(input_list) do
    {full_map, start_xy} = infer_full_map(input_list)
    start_tile = Map.get(full_map, start_xy)

    full_map
    |> walk(start_xy, start_xy, List.first(start_tile))
    |> Enum.count()
    |> Kernel./(2)
    |> Float.ceil()
    |> round()
  end

  def part2(input_list) do
    {full_map, start_xy, {width, height}} = infer_full_map(input_list, :with_dimensions)
    start_tile = Map.get(full_map, start_xy)

    loop_tiles = walk(full_map, start_xy, start_xy, List.first(start_tile))

    ancestors_map =
      for y <- 1..(height - 1),
          x <- 1..(width - 1),
          reduce: for({xy, tile} <- full_map, into: %{}, do: {xy, {tile, [0, 0], [0, 0]}}) do
        map ->
          west_xy = neighboor_xy({x, y}, :w)
          north_xy = neighboor_xy({x, y}, :n)

          {west_tile, [west_n, west_s], _} = Map.get(map, west_xy)
          {north_tile, _, [north_e, north_w]} = Map.get(map, north_xy)

          ns =
            if west_xy in loop_tiles do
              [west_n + link(west_tile, :n), west_s + link(west_tile, :s)]
            else
              [west_n, west_s]
            end

          ew =
            if north_xy in loop_tiles do
              [north_e + link(north_tile, :e), north_w + link(north_tile, :w)]
            else
              [north_e, north_w]
            end

          Map.update(map, {x, y}, nil, fn {tile, _, _} -> {tile, ns, ew} end)
      end

    ancestors_map
    |> Enum.filter(&in_loop?(&1, loop_tiles))
    |> Enum.count()
  end

  defp infer_full_map(input_list, :with_dimensions) do
    height = Enum.count(input_list)

    width =
      input_list
      |> Enum.at(0)
      |> String.length()

    {full_map, start_xy} = infer_full_map(input_list)

    {full_map, start_xy, {width, height}}
  end

  defp infer_full_map(input_list) do
    map = parse_input(input_list)

    start_xy =
      map
      |> Enum.find(&(elem(&1, 1) == @start))
      |> elem(0)

    start_tile = infer_tile(map, start_xy)
    full_map = Map.replace(map, start_xy, start_tile)

    {full_map, start_xy}
  end

  defp infer_tile(map, xy) do
    [:e, :n, :s, :w]
    |> Enum.filter(fn direction ->
      map
      |> neighboor(xy, direction)
      |> linked_to?(opposite_of(direction))
    end)
  end

  defp walk(map, start_xy, xy, from, path \\ [])

  defp walk(_map, start_xy, start_xy, _from, path) when length(path) > 0, do: path

  defp walk(map, start_xy, xy, from, path) do
    current_tile = Map.get(map, xy)
    output_direction = output_of(current_tile, from)

    next_xy = neighboor_xy(xy, output_direction)
    next_from = opposite_of(output_direction)

    walk(map, start_xy, next_xy, next_from, [xy | path])
  end

  defp linked_to?(tile, direction) when is_list(tile), do: Enum.member?(tile, direction)
  defp linked_to?(_, _), do: false

  defp output_of(tile, direction) do
    tile
    |> Enum.reject(&(&1 == direction))
    |> List.first()
  end

  defp opposite_of(:n), do: :s
  defp opposite_of(:s), do: :n
  defp opposite_of(:e), do: :w
  defp opposite_of(:w), do: :e

  defp neighboor_xy({x, y}, :n), do: {x, y - 1}
  defp neighboor_xy({x, y}, :e), do: {x + 1, y}
  defp neighboor_xy({x, y}, :s), do: {x, y + 1}
  defp neighboor_xy({x, y}, :w), do: {x - 1, y}

  defp neighboor(map, xy, direction), do: Map.get(map, neighboor_xy(xy, direction))

  defp link(tile, direction), do: Enum.count(tile, &(&1 == direction))

  defp in_loop?({xy, {_, ns, ew}}, loop_tiles) do
    xy not in loop_tiles and
      ns |> Enum.min() |> rem(2) == 1 and
      ew |> Enum.min() |> rem(2) == 1
  end

  defp parse_input(input_list) do
    for {r, y} <- Enum.with_index(input_list),
        {c, x} <- Utils.splitrim(r, "", :with_index),
        into: %{} do
      {{x, y}, parse_tile(c)}
    end
  end

  defp parse_tile("|"), do: @ns
  defp parse_tile("-"), do: @ew
  defp parse_tile("L"), do: @ne
  defp parse_tile("J"), do: @nw
  defp parse_tile("7"), do: @sw
  defp parse_tile("F"), do: @se
  defp parse_tile("S"), do: @start
  defp parse_tile(_), do: @ground
end

~i[2023/10]l
|> Y2023.D10.part2()
|> dbg
