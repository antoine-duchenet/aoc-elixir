defmodule Y2024.D08 do
  use Day, input: "2024/08", part1: ~c"g", part2: ~c"g"

  defp part1(input), do: partX(input, &to_antinodes1/1)
  defp part2(input), do: partX(input, &to_antinodes2(&1, grid_size(input)))

  defp partX(input, to_antinodes) do
    map = to_map(input)

    map
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Map.delete(".")
    |> Map.values()
    |> Enum.map(to_antinodes)
    |> Enum.reduce(&MapSet.union/2)
    |> Enum.filter(&Map.has_key?(map, &1))
    |> Enum.count()
  end

  defp to_antinodes1(freq_group) do
    for {ra, ca} = a <- freq_group, {rb, cb} = b <- freq_group, a != b do
      {2 * rb - ra, 2 * cb - ca}
    end
    |> MapSet.new()
  end

  defp to_antinodes2(freq_group, size) do
    for {ra, ca} = a <- freq_group, {rb, cb} = b <- freq_group, a != b do
      dr = rb - ra
      dc = cb - ca

      r_step = trunc(dr / Integer.gcd(dr, dc))
      c_step = trunc(dc / Integer.gcd(dr, dc))

      {{ra, ca}, {r_step, c_step}}
    end
    |> Enum.flat_map(fn {origin, step} ->
      Enum.concat([
        explore(origin, step, size, &Kernel.+/2),
        explore(origin, step, size, &Kernel.-/2)
      ])
    end)
    |> MapSet.new()
  end

  defp explore({origin_r, origin_c}, {r_step, c_step}, {r_size, c_size}, dir_op) do
    Stream.unfold(0, fn n ->
      new_r = origin_r + n * r_step
      new_c = origin_c + n * c_step

      if new_r >= 0 and new_r < r_size and new_c >= 0 and new_c < c_size do
        {{new_r, new_c}, dir_op.(n, 1)}
      else
        nil
      end
    end)
    |> Enum.to_list()
  end

  defp grid_size(grid) do
    {
      Enum.count(grid),
      Enum.count(Enum.at(grid, 0))
    }
  end

  defp to_map(input) do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, c} ->
        {{r, c}, cell}
      end)
    end)
    |> Enum.into(%{})
  end
end

Y2024.D08.bench2()
