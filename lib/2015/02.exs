defmodule Y2015.D02 do
  use Day, input: "2015/02", part1: ~c"l", part2: ~c"l"

  defp part1(input), do: partX(input, &to_paper_surface/1)
  defp part2(input), do: partX(input, &to_ribbon_length/1)

  defp partX(input, mapper) do
    input
    |> Enum.map(&parse_dims/1)
    |> Enum.map(mapper)
    |> Enum.sum()
  end

  defp to_paper_surface([a, b, c]) do
    faces = [a * b, a * c, b * c]
    smallest = Enum.min(faces)

    Enum.sum(faces) * 2 + smallest
  end

  defp to_ribbon_length(dims) do
    wrap =
      dims
      |> Enum.sort()
      |> Enum.take(2)
      |> Enum.sum()
      |> Kernel.*(2)

    bow = Enum.product(dims)

    wrap + bow
  end

  defp parse_dims(line) do
    line
    |> Utils.splitrim("x")
    |> Enum.map(&String.to_integer/1)
  end
end

Y2015.D02.bench2()
