defmodule Y2024.D14 do
  use Day, input: "2024/14", part1: ~c"l", part2: ~c"l"

  @r_count 103
  @c_count 101

  @max_r @r_count - 1
  @max_c @c_count - 1
  @mid_r div(@max_r, 2)
  @mid_c div(@max_c, 2)

  defp part1(input) do
    input
    |> parse_input()
    |> Enum.map(&move(&1, 100))
    |> Enum.group_by(&quadrants/1)
    |> Enum.filter(fn {{qr1, qr2, qc1, qc2}, _} -> (qr1 or qr2) and (qc1 or qc2) end)
    |> Enum.map(fn {_, robots} -> Enum.count(robots) end)
    |> Enum.product()
  end

  defp part2(input) do
    input
    |> parse_input()
    |> animate()
  end

  # First pattern appears at 19s and every 103s
  # Second pattern appears at 74s and every 101s
  # x E 19 mod 103, x E 74 mod 101
  # CRT => x E 8053 mod 10403
  defp animate(robots, elapsed \\ 8053) do
    sprites =
      robots
      |> Enum.map(&move(&1, elapsed))
      |> Enum.reduce(%{}, fn {{r, c}, _}, bg ->
        Map.put(bg, {r, c}, "X")
      end)

    IO.puts("START ELAPSED #{elapsed}s")
    draw(sprites)
    IO.puts("END ELAPSED #{elapsed}s\n")

    Process.sleep(250)
    animate(robots, elapsed + 1)
  end

  defp draw(sprites) do
    for r <- 0..@max_r do
      row = for c <- 0..@max_c, do: Map.get(sprites, {r, c}, " ")
      Enum.join(row, "")
    end
    |> Enum.join("\n")
    |> IO.puts()
  end

  defp move({{r, c}, {dr, dc}}, sec) do
    {
      {move(r, dr, @r_count, sec), move(c, dc, @c_count, sec)},
      {dr, dc}
    }
  end

  defp move(v, dv, m, sec), do: mod(v + sec * dv, m)

  defp quadrants({{r, c}, _}) do
    {
      r < @mid_r,
      r > @mid_r,
      c < @mid_c,
      c > @mid_c
    }
  end

  defp mod(n, m) do
    case rem(n, m) do
      remainder when remainder < 0 -> remainder + m
      remainder -> remainder
    end
  end

  defp parse_input(input), do: Enum.map(input, &parse_line/1)

  defp parse_line(line) do
    [r, c, dr, dc] =
      line
      |> Utils.splitrim(~r/p=|v=/)
      |> Enum.flat_map(&Utils.splitrim(&1, ","))
      |> Enum.map(&String.to_integer/1)

    {{c, r}, {dc, dr}}
  end
end

Y2024.D14.bench2()
