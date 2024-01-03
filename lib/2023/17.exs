defmodule Y2023.D17 do
  use Day, input: "2023/17", part1: ~c"l", part2: ~c"l"

  def part1(input) do
    {map, {w, h}} = parse_input(input)

    start = {0, 0}
    target = {w - 1, h - 1}

    djikstra1(map, MapSet.new([{start, 0, [start]}]), MapSet.new(), target)
  end

  def part2(input) do
    {map, {w, h}} = parse_input(input)

    start = {0, 0}
    target = {w - 1, h - 1}

    djikstra2(map, MapSet.new([{start, 0, []}]), MapSet.new(), target)
  end

  defp djikstra1(map, candidates, done, target) do
    closers =
      candidates
      |> Enum.sort_by(&elem(&1, 1), :asc)
      |> Enum.chunk_by(&elem(&1, 1))
      |> Enum.at(0)
      |> MapSet.new()

    if closers |> Enum.map(&elem(&1, 0)) |> MapSet.new() |> Enum.member?(target) do
      Enum.find(closers, &(elem(&1, 0) == target))
    else
      cn =
        closers
        |> Enum.flat_map(fn {cxy, cdist, chistory} ->
          cxy
          |> neighboor_xys1(chistory)
          |> Enum.filter(fn xy -> Map.has_key?(map, xy) end)
          |> Enum.map(fn xy -> {xy, cdist + Map.get(map, xy), [cxy | Enum.take(chistory, 2)]} end)
          |> Enum.reject(fn cand -> MapSet.member?(done, to_done(cand)) end)
        end)
        |> MapSet.new()

      new_candidates =
        candidates
        |> MapSet.difference(closers)
        |> MapSet.union(cn)

      new_done = MapSet.union(done, closers |> Enum.map(&to_done/1) |> MapSet.new())

      djikstra1(map, new_candidates, new_done, target)
    end
  end

  defp djikstra2(map, candidates, done, target) do
    closers =
      candidates
      |> Enum.sort_by(&elem(&1, 1), :asc)
      |> Enum.chunk_by(&elem(&1, 1))
      |> Enum.at(0)
      |> MapSet.new()

    if closers |> Enum.map(&elem(&1, 0)) |> MapSet.new() |> Enum.member?(target) do
      Enum.find(closers, &(elem(&1, 0) == target))
    else
      cn =
        closers
        |> Enum.flat_map(fn {cxy, cdist, chistory} ->
          cxy
          |> neighboor_xys2(chistory)
          |> Enum.filter(fn xy -> Map.has_key?(map, xy) end)
          |> Enum.map(fn xy -> {xy, cdist + Map.get(map, xy), [cxy | Enum.take(chistory, 9)]} end)
          |> Enum.reject(fn cand -> MapSet.member?(done, to_done(cand)) end)
        end)
        |> MapSet.new()

      new_candidates =
        candidates
        |> MapSet.difference(closers)
        |> MapSet.union(cn)

      new_done = MapSet.union(done, closers |> Enum.map(&to_done/1) |> MapSet.new())

      djikstra2(map, new_candidates, new_done, target)
    end
  end

  defp neighboor_xys1(xy, []), do: [to(xy, :n), to(xy, :e), to(xy, :s), to(xy, :w)]

  defp neighboor_xys1({x, y} = xy, [{xn, yn}]) do
    ndir =
      case {x - xn, y - yn} do
        {1, 0} -> :w
        {-1, 0} -> :e
        {0, 1} -> :n
        {0, -1} -> :s
        _ -> nil
      end

    neighboor_xys1(xy, []) -- [to(xy, ndir)]
  end

  defp neighboor_xys1(xy, [newer, _]) do
    neighboor_xys1(xy, [newer])
  end

  defp neighboor_xys1({x, y} = xy, [newer, _, {xo, yo}]) do
    odir =
      case {x - xo, y - yo} do
        {3, 0} -> :e
        {-3, 0} -> :w
        {0, 3} -> :s
        {0, -3} -> :n
        _ -> nil
      end

    neighboor_xys1(xy, [newer]) -- [to(xy, odir)]
  end

  defp neighboor_xys2(xy0, []), do: [to(xy0, :n), to(xy0, :e), to(xy0, :s), to(xy0, :w)]

  defp neighboor_xys2({x0, y0} = xy0, [{x1, y1} | _] = history) when length(history) < 4 do
    dir =
      case {x0 - x1, y0 - y1} do
        {1, 0} -> :e
        {-1, 0} -> :w
        {0, 1} -> :s
        {0, -1} -> :n
      end

    [to(xy0, dir)]
  end

  defp neighboor_xys2({x0, y0} = xy0, [xy1, _, _, {x4, y4} | _] = history)
       when length(history) < 10 do
    case {x0 - x4, y0 - y4} do
      {4, 0} ->
        neighboor_xys2(xy0, [xy1]) ++ [to(xy0, :n), to(xy0, :s)]

      {-4, 0} ->
        neighboor_xys2(xy0, [xy1]) ++ [to(xy0, :n), to(xy0, :s)]

      {0, 4} ->
        neighboor_xys2(xy0, [xy1]) ++ [to(xy0, :e), to(xy0, :w)]

      {0, -4} ->
        neighboor_xys2(xy0, [xy1]) ++ [to(xy0, :e), to(xy0, :w)]

      _ ->
        neighboor_xys2(xy0, [xy1])
    end
  end

  defp neighboor_xys2({x0, y0} = xy0, [xy1, _, _, {x4, y4}, _, _, _, _, _, {x10, y10}] = history) do
    h9 = Enum.take(history, 9)

    case {x0 - x4, y0 - y4} do
      {4, 0} ->
        case {x0 - x10, y0 - y10} do
          {10, 0} -> neighboor_xys2(xy0, h9) -- [to(xy0, :e)]
          _ -> neighboor_xys2(xy0, h9)
        end

      {-4, 0} ->
        case {x0 - x10, y0 - y10} do
          {-10, 0} -> neighboor_xys2(xy0, h9) -- [to(xy0, :w)]
          _ -> neighboor_xys2(xy0, h9)
        end

      {0, 4} ->
        case {x0 - x10, y0 - y10} do
          {0, 10} -> neighboor_xys2(xy0, h9) -- [to(xy0, :s)]
          _ -> neighboor_xys2(xy0, h9)
        end

      {0, -4} ->
        case {x0 - x10, y0 - y10} do
          {0, -10} -> neighboor_xys2(xy0, h9) -- [to(xy0, :n)]
          _ -> neighboor_xys2(xy0, h9)
        end

      _ ->
        neighboor_xys2(xy0, [xy1])
    end
  end

  defp to_done({xy, _, history}), do: {xy, history}

  defp to({x, y}, :n), do: {x, y - 1}
  defp to({x, y}, :e), do: {x + 1, y}
  defp to({x, y}, :s), do: {x, y + 1}
  defp to({x, y}, :w), do: {x - 1, y}
  defp to(_, nil), do: nil

  defp parse_input(input) do
    matrix = Enum.map(input, &parse_line/1)

    width = matrix |> Enum.at(0) |> Enum.count()
    height = Enum.count(matrix)

    {Matrix.to_map(matrix), {width, height}}
  end

  defp parse_line(line) do
    line
    |> Utils.splitrim("")
    |> Enum.map(&String.to_integer(&1))
  end
end

Y2023.D17.bench2()
