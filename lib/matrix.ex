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

  def to_map(matrix) do
    height = Enum.count(matrix)
    width = matrix |> Enum.at(0) |> Enum.count()

    for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
      {{x, y},
       matrix
       |> Enum.at(y)
       |> Enum.at(x)}
    end
  end
end
