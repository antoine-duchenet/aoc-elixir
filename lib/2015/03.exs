defmodule Y2015.D03 do
  use Day, input: "2015/03", part1: ~c"w", part2: ~c"w"

  defp part1(input), do: walk1(input, {0, 0}, MapSet.new())
  defp part2(input), do: walk2(input, {0, 0}, {0, 0}, MapSet.new())

  defp walk1("", from, visited), do: visited |> MapSet.put(from) |> MapSet.size()

  defp walk1(<<dir, rest::binary>>, from, visited) do
    walk1(rest, to(from, dir), MapSet.put(visited, from))
  end

  defp walk2("", from_s, from_r, visited) do
    visited
    |> MapSet.put(from_s)
    |> MapSet.put(from_r)
    |> MapSet.size()
  end

  defp walk2(<<dir_s, dir_r, rest::binary>>, from_s, from_r, visited) do
    new_visited =
      visited
      |> MapSet.put(from_s)
      |> MapSet.put(from_r)

    walk2(rest, to(from_s, dir_s), to(from_r, dir_r), new_visited)
  end

  defp to({r, c}, ?^), do: {r - 1, c}
  defp to({r, c}, ?>), do: {r, c + 1}
  defp to({r, c}, ?v), do: {r + 1, c}
  defp to({r, c}, ?<), do: {r, c - 1}
end

Y2015.D03.bench2()
