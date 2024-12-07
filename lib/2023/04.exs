defmodule Y2023.D04 do
  use Day, input: "2023/04", part1: ~c"s", part2: ~c"s"

  def part1(input_stream) do
    input_stream
    |> Stream.map(&count_winning/1)
    |> Stream.filter(&(&1 > 0))
    |> Stream.map(&(2 ** (&1 - 1)))
    |> Enum.sum()
  end

  def part2(input_stream) do
    input_stream
    |> Stream.map(&count_winning/1)
    |> Enum.reverse()
    |> Enum.reduce([], fn n, others -> [1 + (others |> Enum.take(n) |> Enum.sum()) | others] end)
    |> Enum.sum()
  end

  defp count_winning(line) do
    line
    |> Utils.splitrim(~r/[:|]/)
    |> then(fn [_, played_part, winning_part] ->
      for p <- Utils.splitrim(played_part, " "), p in Utils.splitrim(winning_part, " "), do: p
    end)
    |> Enum.count()
  end
end

Y2023.D04.bench2()
