import Input

defmodule Y2023.D4 do
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

~i[2023/04]s
|> Y2023.D4.part2()
|> dbg
