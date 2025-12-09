defmodule Y2025.D05 do
  use Day, input: "2025/05", part1: ~c"c", part2: ~c"c"

  defp part1(input) do
    {segments, ingredients} = parse_input(input)

    Enum.count(ingredients, &Enum.any?(segments, fn {s, e} -> &1 in s..e end))
  end

  defp part2(input) do
    {segments, _} = parse_input(input)

    segments
    |> merge()
    |> Enum.map(fn {s, e} -> Range.size(s..e) end)
    |> Enum.sum()
  end

  defp merge(segments) do
    Enum.reduce(segments, MapSet.new(), fn {s, e} = segment, past ->
      case Enum.filter(past, fn {ps, pe} -> not Range.disjoint?(s..e, ps..pe) end) do
        [] ->
          MapSet.put(past, segment)

        overlaps ->
          ms = Enum.min([s | for({os, _} <- overlaps, do: os)])
          me = Enum.max([e | for({_, oe} <- overlaps, do: oe)])

          overlaps
          |> Enum.reduce(past, &MapSet.delete(&2, &1))
          |> MapSet.put({ms, me})
      end
    end)
  end

  defp parse_input([segments, ingredients]) do
    {
      for(seg <- segments, do: parse_segment(seg)),
      for(ing <- ingredients, do: parse_ingredient(ing))
    }
  end

  defp parse_segment(line) do
    line
    |> Utils.splitrim("-")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp parse_ingredient(line), do: String.to_integer(line)
end

Y2025.D05.bench2()
