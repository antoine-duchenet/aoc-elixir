import Input

defmodule Y2023.D21 do
  def part1(input) do
    {raw_map, _} = parse_input(input)

    {start_xy, _} = Enum.find(raw_map, &(elem(&1, 1) == "S"))
    map = Map.replace(raw_map, start_xy, ".")

    walk(map, [start_xy], 64)
  end

  def manual(input) do
    # Before Google's math help, tweaking parameters to get inputs for manual calculation
    # Not self sufficient, but at the end it gaves me the solution !
    {raw_map, size} = parse_input(input)

    {start_xy, _} = Enum.find(raw_map, &(elem(&1, 1) == "S"))
    map = Map.replace(raw_map, start_xy, ".")

    odd = walk(map, [start_xy], 2 * size)
    even = walk(map, [start_xy], 2 * size + 1)

    pink = walk(map, [start_xy], 65, size)
    green = (walk(map, [start_xy], 65 + size, size) - 5 * pink) / 4

    n = (26_501_365 - 65) / size

    res =
      1..round(n + 1)
      |> Enum.map(fn x ->
        4 * x *
          if rem(x, 2) == 0 do
            odd
          else
            even
          end
      end)
      |> Enum.sum()

    dbg({odd, even, pink, green, res})
  end

  def part2(input) do
    # After Google's math help
    # Self sufficient
    {raw_map, size} = parse_input(input)

    {start_xy, _} = Enum.find(raw_map, &(elem(&1, 1) == "S"))
    map = Map.replace(raw_map, start_xy, ".")

    abc = {
      walk(map, [start_xy], 65, size),
      walk(map, [start_xy], 65 + size, size),
      walk(map, [start_xy], 65 + size * 2, size)
    }

    {aa, bb, cc} = lagrange(abc)

    n = (26_501_365 - 65) / size

    aaa = aa * n ** 2
    bbb = bb * n
    ccc = cc

    aaa + bbb + ccc
  end

  def lagrange({a, b, c}) do
    {
      0.5 * a - b + 0.5 * c,
      -1.5 * a + 2 * b - 0.5 * c,
      a
    }
  end

  defp walk(_, from, 0, _), do: Enum.count(from)

  defp walk(map, from, n, size) do
    from
    |> Enum.flat_map(fn {x, y} ->
      [
        {x - 1, y},
        {x + 1, y},
        {x, y - 1},
        {x, y + 1}
      ]
    end)
    |> Enum.uniq()
    |> Enum.filter(fn {x, y} ->
      Map.get(
        map,
        {x |> rem(size) |> Kernel.+(size) |> rem(size),
         y |> rem(size) |> Kernel.+(size) |> rem(size)}
      ) == "."
    end)
    |> then(&walk(map, &1, n - 1, size))
  end

  defp walk(_, from, 0), do: Enum.count(from)

  defp walk(map, from, n) do
    from
    |> Enum.flat_map(fn {x, y} ->
      [
        {x - 1, y},
        {x + 1, y},
        {x, y - 1},
        {x, y + 1}
      ]
    end)
    |> Enum.uniq()
    |> Enum.filter(&(Map.get(map, &1) == "."))
    |> then(&walk(map, &1, n - 1))
  end

  defp parse_input(input) do
    matrix = Enum.map(input, &Utils.splitrim(&1, ""))

    size = matrix |> Enum.at(0) |> Enum.count()

    {Matrix.to_map(matrix), size}
  end

  def run() do
    part2(~i[2023/21]l)
  end

  def bench() do
    Benchmark.mesure_milliseconds(&run/0)
  end
end

Y2023.D21.bench()
