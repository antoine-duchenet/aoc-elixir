import Input

defmodule Y2023.D9 do
  def part1(input_stream) do
    partX(input_stream, &List.last/1, &Kernel.+/2)
  end

  def part2(input_stream) do
    partX(input_stream, &List.first/1, &Kernel.-/2)
  end

  defp partX(input_stream, choose, combine) do
    input_stream
    |> Stream.map(&parse_line/1)
    |> Stream.map(&extrapolate(&1, choose, combine))
    |> Enum.sum()
  end

  defp extrapolate(serie, choose, combine) do
    serie
    |> choose.()
    |> combine.(
      if Enum.all?(serie, &(&1 == 0)) do
        0
      else
        serie
        |> diffs()
        |> extrapolate(choose, combine)
      end
    )
  end

  defp diffs(serie) do
    serie
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end

  defp parse_line(line) do
    line
    |> Utils.splitrim(" ")
    |> Enum.map(&String.to_integer/1)
  end
end

~i[2023/09]s
|> Y2023.D9.part2()
|> dbg
