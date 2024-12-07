defmodule Y2023.D05 do
  use Day, input: "2023/05", part1: ~c"l", part2: ~c"l"

  def part1(input_lines) do
    [[se], se2so, so2fe, fe2wa, wa2li, li2te, te2hu, hu2lo] = parse_input_lines(input_lines)

    se
    |> Enum.map(&find_in_map(&1, se2so))
    |> Enum.map(&find_in_map(&1, so2fe))
    |> Enum.map(&find_in_map(&1, fe2wa))
    |> Enum.map(&find_in_map(&1, wa2li))
    |> Enum.map(&find_in_map(&1, li2te))
    |> Enum.map(&find_in_map(&1, te2hu))
    |> Enum.map(&find_in_map(&1, hu2lo))
    |> Enum.min()
  end

  def part2(input_lines) do
    [[se], se2so, so2fe, fe2wa, wa2li, li2te, te2hu, hu2lo] = parse_input_lines(input_lines)

    se
    |> Enum.chunk_every(2)
    |> Enum.map(&to_boundaries/1)
    |> apply_map(se2so)
    |> apply_map(so2fe)
    |> apply_map(fe2wa)
    |> apply_map(wa2li)
    |> apply_map(li2te)
    |> apply_map(te2hu)
    |> apply_map(hu2lo)
    |> List.first()
    |> elem(0)
  end

  defp parse_input_lines(input_lines) do
    input_lines
    |> split_sections()
    |> then(fn [[se] | tail] -> [Utils.splitrim(se, "seeds: ") | tail] end)
    |> Enum.map(&parse_sections/1)
    |> then(fn [head | tail] ->
      [head | Enum.map(tail, fn segments -> Enum.map(segments, &to_boundaries/1) end)]
    end)
  end

  defp to_boundaries([s, l]), do: {s, s + l}
  defp to_boundaries([ds, os, l]), do: {os, os + l, ds - os}

  defp split_sections(input_lines) do
    Enum.chunk_while(
      input_lines,
      [],
      fn
        "", acc -> {:cont, acc, nil}
        _, nil -> {:cont, []}
        nonempty, acc -> {:cont, [nonempty | acc]}
      end,
      fn
        [] -> {:cont, []}
        acc -> {:cont, Enum.reverse(acc), []}
      end
    )
  end

  defp parse_sections(lines) do
    Enum.map(lines, &parse_section/1)
  end

  defp parse_section(line) do
    line
    |> Utils.splitrim(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp find_in_map(to_find, map) do
    found =
      Enum.find(
        map,
        fn {s, e, _} ->
          to_find >= s and to_find < e
        end
      )

    case found do
      {_, _, o} -> to_find + o
      _ -> to_find
    end
  end

  defp apply_map(segments, map) do
    segments
    |> Enum.flat_map(fn {s, e} ->
      map
      |> Enum.map(fn {ms, me, mo} ->
        cond do
          Range.disjoint?(s..(e - 1), ms..(me - 1)) -> nil
          ms <= s and me >= e -> {s, e, mo}
          ms >= s and me <= e -> {ms, me, mo}
          ms <= s and me <= e -> {s, me, mo}
          ms >= s and me >= e -> {ms, e, mo}
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.reduce({[], s}, fn
        {last_end, e, o}, {acc, last_end} ->
          {acc ++ [{last_end, e, o}], e}

        {s, e, o}, {acc, last_end} ->
          {acc ++ [{last_end, s, 0}, {s, e, o}], e}
      end)
      |> elem(0)
    end)
    |> Enum.map(fn {s, e, o} -> {s + o, e + o} end)
    |> Enum.sort_by(&elem(&1, 0))
  end
end

Y2023.D05.bench2()
