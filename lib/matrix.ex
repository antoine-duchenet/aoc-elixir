defmodule Matrix do
  def transpose(matrix) do
    height = Enum.count(matrix)
    width = matrix |> Enum.at(0) |> Enum.count()

    for x <- 0..(width - 1) do
      for y <- 0..(height - 1) do
        matrix
        |> Enum.at(y)
        |> Enum.at(x)
      end
    end
  end

  def to_xy_map(matrix) do
    height = Enum.count(matrix)
    width = matrix |> Enum.at(0) |> Enum.count()

    for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
      {{x, y},
       matrix
       |> Enum.at(y)
       |> Enum.at(x)}
    end
  end

  def to_rc_map(matrix) do
    matrix
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, c} -> {{r, c}, cell} end)
    end)
    |> Enum.into(%{})
  end
end
