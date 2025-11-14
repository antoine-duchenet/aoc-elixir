defmodule Y2024.D23 do
  use Day, input: "2024/23", part1: ~c"l", part2: ~c"l"

  defp part1(input) do
    sorted_edges =
      input
      |> parse_input()
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.sort_by(&elem(&1, 0))

    sorted_edges
    |> Enum.chunk_by(&elem(&1, 0))
    |> Enum.flat_map(fn set ->
      set
      |> pairs()
      |> Enum.filter(&match?({{a1, _}, {a1, _}}, &1))
      |> Enum.filter(fn {{_, a2}, {_, b2}} -> Enum.member?(sorted_edges, {a2, b2}) end)
      |> Enum.map(fn {{a1, a2}, {a1, b2}} -> {a1, a2, b2} end)
    end)
    |> Enum.filter(fn
      {"t" <> _, _, _} -> true
      {_, "t" <> _, _} -> true
      {_, _, "t" <> _} -> true
      _ -> false
    end)
    |> Enum.count()
  end

  defp part2(input) do
    links =
      input
      |> parse_input()
      |> Enum.flat_map(fn {a, b} -> [{a, b}, {b, a}] end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    links
    |> Enum.reduce({[], 0}, fn {from, tos}, {_, size} = acc ->
      tos
      |> combinations()
      |> Enum.sort_by(&Enum.count/1, :desc)
      |> Enum.take_while(&(Enum.count(&1) >= size))
      |> Enum.find(&full_mesh?(&1, links))
      |> case do
        nil -> acc
        set -> {[from | set], Enum.count(set) + 1}
      end
    end)
    |> elem(0)
    |> Enum.sort()
    |> Enum.join(",")
  end

  defp full_mesh?([], _), do: true

  defp full_mesh?([h | tail], links) do
    connected = Map.get(links, h)

    tail
    |> Enum.all?(&Enum.member?(connected, &1))
    |> Kernel.and(full_mesh?(tail, links))
  end

  defp pairs([]), do: []
  defp pairs([h | tail]), do: for(t <- tail, do: {h, t}) ++ pairs(tail)

  defp combinations([]), do: [[]]

  defp combinations([h | tail]) do
    tails = combinations(tail)
    for(t <- tails, do: [h | t]) ++ tails
  end

  defp parse_input(input), do: Enum.map(input, &parse_line/1)

  defp parse_line(<<node1::bytes-size(2), "-", node2::bytes-size(2)>>) do
    [node1, node2]
    |> Enum.sort()
    |> List.to_tuple()
  end
end

Y2024.D23.bench2()
