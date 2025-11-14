defmodule Y2023.D11 do
  use Day, input: "2023/11", part1: ~c"l", part2: ~c"l"

  def part1(input_list) do
    partX(input_list, 2)
  end

  def part2(input_list) do
    partX(input_list, 1_000_000)
  end

  defp partX(input_list, expansion_factor) do
    list = parse_input(input_list)

    void_y = void_indices(list)
    void_x = list |> Matrix.transpose() |> void_indices()

    galaxies =
      list
      |> Matrix.to_xy_map()
      |> Enum.filter(&(elem(&1, 1) == :galaxy))
      |> Enum.map(&elem(&1, 0))
      |> Enum.with_index()

    distances =
      for {{x1, y1} = xy1, i1} <- galaxies, {{x2, y2} = xy2, i2} <- galaxies, i2 > i1 do
        x_expansion = interval_expansion(void_x, Enum.sort([x1, x2]), expansion_factor)
        y_expansion = interval_expansion(void_y, Enum.sort([y1, y2]), expansion_factor)

        Distance.manhattan(xy1, xy2) + x_expansion + y_expansion
      end

    Enum.sum(distances)
  end

  defp void_indices(list) do
    list
    |> Enum.with_index()
    |> Enum.filter(fn {line, _} -> Enum.all?(line, &(&1 == :void)) end)
    |> Enum.map(&elem(&1, 1))
  end

  defp interval_expansion(voids, [min, max], expansion_factor) do
    voids
    |> Enum.filter(&(&1 > min and &1 < max))
    |> Enum.count()
    |> Kernel.*(expansion_factor - 1)
  end

  defp parse_input(input_list) do
    for row <- input_list do
      for tile <- Utils.splitrim(row, "") do
        parse_tile(tile)
      end
    end
  end

  defp parse_tile("#"), do: :galaxy
  defp parse_tile("."), do: :void
end

Y2023.D11.bench2()
