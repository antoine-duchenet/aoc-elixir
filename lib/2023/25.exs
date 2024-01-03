defmodule Y2023.D25 do
  use Day, input: "2023/25", part1: ~c"l", part2: nil

  def part1(input) do
    input
    |> parse_input()
    |> search()
  end

  def search(map) do
    keys =
      map
      |> Map.keys()
      |> MapSet.new()

    keys
    |> Stream.map(&expand(map, MapSet.new([&1]), Map.get(map, &1, [])))
    |> Stream.reject(&is_nil(&1))
    |> Enum.at(0)
    |> then(&MapSet.size/1)
    |> then(&{&1, MapSet.size(keys) - &1})
    |> Tuple.product()
  end

  def expand(_, _, []), do: nil
  def expand(_, _, [_]), do: nil
  def expand(_, _, [_, _]), do: nil

  def expand(_, part, [_, _, _]), do: part

  def expand(map, part, exits) do
    exits
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Stream.map(&elem(&1, 0))
    |> Stream.map(&expand(map, MapSet.put(part, &1), update_exits(map, part, &1, exits)))
    |> Stream.reject(&is_nil(&1))
    |> Enum.at(0)
  end

  def update_exits(map, part, added, exits) do
    Enum.reject(exits, &(&1 == added)) ++
      (map
       |> Map.get(added, [])
       |> Enum.filter(&(not MapSet.member?(part, &1))))
  end

  defp parse_input(input) do
    input
    |> Enum.flat_map(&parse_line/1)
    |> Enum.flat_map(fn {from, to} -> [{from, to}, {to, from}] end)
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.map(fn {from, tos} -> {from, Enum.map(tos, &elem(&1, 1))} end)
    |> Map.new()
  end

  defp parse_line(line) do
    [from, tos] = Utils.splitrim(line, ":")

    for to <- Utils.splitrim(tos, " "), reduce: [], do: (acc -> [{from, to} | acc])
  end
end

Y2023.D25.bench1()
