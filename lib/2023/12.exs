defmodule Y2023.D12 do
  use Day, input: "2023/12", part1: ~c"s", part2: ~c"s"

  @mult 5

  defp partX(input, transform \\ & &1) do
    input
    |> Stream.map(&parse_line/1)
    |> Stream.map(transform)
    |> Stream.map(&how_many?(elem(&1, 0), ".", elem(&1, 1)))
    |> Enum.sum()
    |> dbg()
  end

  defp part1(input) do
    partX(input)
  end

  defp part2(input) do
    partX(
      input,
      &{
        elem(&1, 0) |> List.duplicate(@mult) |> Enum.join("?"),
        elem(&1, 1) |> List.duplicate(@mult) |> List.flatten()
      }
    )
  end

  # defp how_many?("", _, []), do: 1
  # defp how_many?("", _, [0]), do: 1
  # defp how_many?("", _, _), do: 0
  defp how_many?("", _, _), do: 1

  defp how_many?("#" <> _, _, []), do: 0
  defp how_many?("#" <> _, _, [0 | _]), do: 0
  defp how_many?("#" <> tail, _, [h | t]), do: how_many?(tail, "#", [h - 1 | t])

  defp how_many?("." <> tail, "#", [0 | t]), do: how_many?(tail, ".", t)
  defp how_many?("." <> _, "#", _), do: 0
  # defp how_many?("." <> tail, _, counts), do: how_many?(tail, ".", counts)
  defp how_many?("." <> tail, _, counts), do: ensure_dot_affordability(tail, counts)

  defp how_many?("?" <> tail, _, []), do: how_many?(tail, ".", [])
  defp how_many?("?" <> tail, _, [0 | t]), do: how_many?(tail, ".", t)
  defp how_many?("?" <> tail, "#", [h | t]), do: how_many?(tail, "#", [h - 1 | t])

  defp how_many?("?" <> tail, ".", [h | t] = counts) do
    Performance.memoize({tail, counts}, fn ->
      how_many?(tail, "#", [h - 1 | t]) + ensure_dot_affordability(tail, counts)
    end)
  end

  defp ensure_dot_affordability(tail, counts) do
    if can_afford_dot?(tail, counts), do: how_many?(tail, ".", counts), else: 0
  end

  defp can_afford_dot?(tail, counts) do
    counts
    |> Enum.intersperse(1)
    |> Enum.sum()
    |> Kernel.<=(String.length(tail))
  end

  defp parse_line(line) do
    [springs, counts_part] = Utils.splitrim(line, " ")

    counts =
      counts_part
      |> Utils.splitrim(",")
      |> Enum.map(&String.to_integer/1)

    {springs, counts}
  end
end

Y2023.D12.bench2()

# @mult 150
# 10477706755643845343893428170252765149121555033696250544526904974815478827018422860881670230594312966500548053926888088082011283403409150326525441489202186012862060376815657187183869192296658300644813921205656125220358107871986222001239761496202136108902627312242625702366259109812527002167400649685373980377380580124535417534556284000895426915818826676685728889288177846532864698623376616
# 3518953.184ms ~ 3519s = 58m19s
