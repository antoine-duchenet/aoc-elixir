import Input

defmodule Y2023.D12 do
  defp part1(input) do
    input
    |> Stream.map(&parse_line/1)
    |> Stream.map(&how_many?(elem(&1, 0), ".", elem(&1, 1)))
    |> Enum.sum()
  end

  defp part2(input, mult) do
    input
    |> Stream.map(&parse_line/1)
    |> Stream.map(
      &{
        elem(&1, 0) |> List.duplicate(mult) |> Enum.join("?"),
        elem(&1, 1) |> List.duplicate(mult) |> List.flatten()
      }
    )
    |> Stream.map(&how_many?(elem(&1, 0), ".", elem(&1, 1)))
    |> Enum.sum()
  end

  defp how_many?("", _, []), do: 1
  defp how_many?("", _, [0]), do: 1
  defp how_many?("", _, _), do: 0

  defp how_many?("#" <> _, _, []), do: 0
  defp how_many?("#" <> _, _, [0 | _]), do: 0
  defp how_many?("#" <> tail, _, [h | t]), do: how_many?(tail, "#", [h - 1 | t])

  defp how_many?("." <> tail, "#", [0 | t]), do: how_many?(tail, ".", t)
  defp how_many?("." <> _, "#", _), do: 0
  defp how_many?("." <> tail, _, counts), do: how_many?(tail, ".", counts)

  # defp how_many?("." <> tail, ".", counts) do
  #   if Enum.sum(counts) > String.length(tail) do
  #     0
  #   else
  #     how_many?(tail, ".", counts)
  #   end
  # end

  defp how_many?("?" <> tail, _, []), do: how_many?(tail, ".", [])
  defp how_many?("?" <> tail, _, [0 | t]), do: how_many?(tail, ".", t)
  defp how_many?("?" <> tail, "#", [h | t]), do: how_many?(tail, "#", [h - 1 | t])

  defp how_many?("?" <> tail, ".", [h | t]) do
    Performance.memoize({tail, [h | t]}, fn ->
      how_many?(tail, "#", [h - 1 | t]) + how_many?(tail, ".", [h | t])
    end)
  end

  defp parse_line(line) do
    [springs, counts_part] = Utils.splitrim(line, " ")

    counts =
      counts_part
      |> Utils.splitrim(",")
      |> Enum.map(&String.to_integer/1)

    {springs, counts}
  end

  def bench1() do
    Benchmark.mesure_milliseconds(fn -> part1(~i[2023/12]s) end)
  end

  def bench2(mult \\ 5) do
    Benchmark.mesure_milliseconds(fn -> part2(~i[2023/12]s, mult) end)
  end
end

Y2023.D12.bench2()
