defmodule Y2024.D02 do
  use Day, input: "2024/02", part1: ~c"l", part2: ~c"l"

  defp part1(input) do
    input
    |> Enum.map(&parse_line/1)
    |> Enum.filter(&is_report_safe?/1)
    |> Enum.count()
    |> dbg()
  end

  defp part2(input) do
    input
    |> Enum.map(&parse_line/1)
    |> Enum.map(&compute_variants/1)
    |> Enum.filter(fn variants -> Enum.any?(variants, &is_report_safe?/1) end)
    |> Enum.count()
    |> dbg()
  end

  defp is_report_safe?(report) do
    report
    |> to_deltas()
    |> are_deltas_safe?()
  end

  defp compute_variants(report) do
    report
    |> Enum.with_index()
    |> Enum.map(fn {_, i} -> List.delete_at(report, i) end)
  end

  defp to_deltas(report) do
    report
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [from, to] -> to - from end)
  end

  defp are_deltas_safe?(deltas) do
    (Enum.all?(deltas, fn d -> d < 0 end) or
       Enum.all?(deltas, fn d -> d > 0 end)) and
      Enum.all?(deltas, fn d -> abs(d) >= 1 and abs(d) <= 3 end)
  end

  defp parse_line(line) do
    line
    |> Utils.splitrim(" ")
    |> Enum.map(&String.to_integer/1)
  end
end

Y2024.D02.bench2()
