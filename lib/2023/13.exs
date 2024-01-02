import Input

defmodule Y2023.D13 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&m_line/1)
    |> Enum.reduce({0, 0}, fn
      {nil, v}, {ah, av} -> {ah, av + v}
      {h, _}, {ah, av} -> {ah + h, av}
    end)
    |> then(&(elem(&1, 0) * 100 + elem(&1, 1)))
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&s_line/1)
    |> Enum.reduce({0, 0}, fn
      {nil, v}, {ah, av} -> {ah, av + v}
      {h, _}, {ah, av} -> {ah + h, av}
    end)
    |> then(&(elem(&1, 0) * 100 + elem(&1, 1)))
  end

  defp m_line({as_rows, as_cols}) do
    case m_line(as_rows) do
      nil -> {nil, m_line(as_cols)}
      l -> {l, nil}
    end
  end

  defp m_line(items) do
    length = Enum.count(items)
    first_index = 1
    last_index = length - 1

    first_index..last_index
    |> Enum.find(fn line ->
      range = min(line, length - line)
      remaining = Enum.drop(items, line - range)

      a = Enum.take(remaining, range)
      b = remaining |> Enum.drop(range) |> Enum.take(range) |> Enum.reverse()

      a == b
    end)
  end

  defp s_line({as_rows, as_cols}) do
    {mh, mv} = m_line({as_rows, as_cols})

    case s_line(as_rows, mh) do
      nil -> {nil, s_line(as_cols, mv)}
      l -> {l, nil}
    end
  end

  defp s_line(items, m) do
    length = Enum.count(items)
    first_index = 1
    last_index = length - 1

    first_index..last_index
    |> Enum.find(fn line ->
      if line == m do
        false
      else
        range = min(line, length - line)
        remaining = Enum.drop(items, line - range)

        a = Enum.take(remaining, range)
        b = remaining |> Enum.drop(range) |> Enum.take(range) |> Enum.reverse()

        diffs(a, b) == 1
      end
    end)
  end

  defp diffs(ass, bss) do
    ass
    |> Enum.zip(bss)
    |> Enum.flat_map(fn {as, bs} ->
      as
      |> String.split("")
      |> Enum.zip(String.split(bs, ""))
    end)
    |> Enum.count(fn {a, b} -> a != b end)
  end

  defp parse_input(input) do
    as_rows =
      Enum.chunk_while(
        input,
        [],
        fn
          "", acc -> {:cont, acc, []}
          nonempty, acc -> {:cont, acc ++ [nonempty]}
        end,
        fn
          [] -> {:cont, []}
          acc -> {:cont, acc, []}
        end
      )

    as_cols =
      as_rows
      |> Enum.map(fn rows -> Enum.map(rows, &Utils.splitrim(&1, "")) end)
      |> Enum.map(&Matrix.transpose/1)
      |> Enum.map(fn cols -> Enum.map(cols, &Enum.join(&1, "")) end)

    Enum.zip(as_rows, as_cols)
  end

  def run() do
    part2(~i[2023/13]s)
  end

  def bench() do
    Benchmark.mesure_milliseconds(&run/0)
  end
end

Y2023.D13.bench()
