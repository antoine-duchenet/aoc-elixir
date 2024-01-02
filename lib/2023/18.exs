import Input

defmodule Y2023.D18 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&without_color/1)
    |> area()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&from_color/1)
    |> Enum.map(&without_color/1)
    |> area()
  end

  defp area(steps) do
    inner =
      steps
      |> to_absolute_xys()
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [{x1, y1}, {x2, y2}] -> (x1 - x2) * (y1 + y2) end)
      |> Enum.sum()
      |> div(2)
      |> abs()
      |> round()

    trench =
      steps
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()
      |> div(2)
      |> Kernel.+(1)

    inner + trench
  end

  defp to_absolute_xys(steps) do
    Enum.reduce(steps, [{0, 0}], fn {raw_dir, length}, [{x, y} | _] = acc ->
      {dx, dy} = dir(raw_dir)
      [{x + dx * length, y + dy * length} | acc]
    end)
  end

  defp dir("U"), do: {0, -1}
  defp dir("D"), do: {0, 1}
  defp dir("L"), do: {-1, 0}
  defp dir("R"), do: {1, 0}
  defp dir(0), do: dir("R")
  defp dir(1), do: dir("D")
  defp dir(2), do: dir("L")
  defp dir(3), do: dir("U")

  defp from_color({_, _, color}) do
    <<length::20, dir::4>> =
      color
      |> String.upcase()
      |> Base.decode16!()

    {dir, length, color}
  end

  defp without_color({dir, length, _}), do: {dir, length}

  defp parse_input(input) do
    input
    |> Enum.map(&parse_line/1)
    |> Enum.to_list()
  end

  defp parse_line(line) do
    [dir, length, <<"(#", color::bytes-size(6), ")">>] = Utils.splitrim(line, " ")
    {dir, String.to_integer(length), color}
  end

  def run() do
    part2(~i[2023/18]l)
  end

  def bench() do
    Benchmark.mesure_milliseconds(&run/0)
  end
end

Y2023.D18.bench()
