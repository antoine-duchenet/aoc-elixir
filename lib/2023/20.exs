import Input

defmodule Y2023.D20 do
  def part1(input) do
    map = parse_input(input)

    {_, history} =
      1..1000
      |> Enum.reduce({map, []}, fn _, {m, h} ->
        dispatch(m, [{:button, "broadcaster", :lo}], h)
      end)

    history
    |> Enum.reduce({0, 0}, fn
      {_, _, :lo}, {lo, hi} -> {lo + 1, hi}
      {_, _, :hi}, {lo, hi} -> {lo, hi + 1}
    end)
    |> Tuple.product()
  end

  def part2(input) do
    map = parse_input(input)

    initil_counts = %{"js" => nil, "zb" => nil, "bs" => nil, "rr" => nil}

    1
    |> Stream.iterate(&(&1 + 1))
    |> Enum.reduce_while({map, initil_counts}, fn i, {m, counts} ->
      {map, history} = dispatch(m, [{:button, "broadcaster", :lo}], [])

      counts
      |> Enum.reduce(counts, fn
        {key, nil}, acc1 ->
          count =
            Enum.count(history, fn
              {^key, "hb", :hi} -> true
              {_, _, _} -> false
            end)

          if count > 0 do
            Map.replace(acc1, key, {count, i})
          else
            acc1
          end

        {_, _}, acc1 ->
          acc1
      end)
      |> then(fn c ->
        if Enum.any?(c, &is_nil(elem(&1, 1))) do
          {:cont, {map, c}}
        else
          {:halt, c}
        end
      end)
    end)
    |> Enum.reduce(1, fn {_, {_, v}}, acc -> acc * v end)
  end

  defp dispatch(map, [], history), do: {map, history}

  defp dispatch(map, signals, history) do
    {next_map, next_signals} =
      Enum.reduce(signals, {map, []}, fn {from, to, msg}, {m, s} ->
        target = Map.fetch!(m, to)

        {updated_target, new_signals} = handle(from, target, msg)

        {Map.replace(m, to, updated_target), s ++ new_signals}
      end)

    next_history = history ++ signals

    dispatch(next_map, next_signals, next_history)
  end

  defp handle(_, {name, :bc = type, state, links}, msg) do
    {{name, type, state, links}, Enum.map(links, &{name, &1, msg})}
  end

  defp handle(_, {name, :ff = type, :off, links}, :lo) do
    {{name, type, :on, links}, Enum.map(links, &{name, &1, :hi})}
  end

  defp handle(_, {name, :ff = type, :on, links}, :lo) do
    {{name, type, :off, links}, Enum.map(links, &{name, &1, :lo})}
  end

  defp handle(from, {name, :cj = type, memory, links}, msg) do
    new_memory = Map.put(memory, from, msg)

    new_msg =
      new_memory
      |> Enum.all?(&(elem(&1, 1) == :hi))
      |> case do
        true -> :lo
        _ -> :hi
      end

    {{name, type, new_memory, links}, Enum.map(links, &{name, &1, new_msg})}
  end

  defp handle(_, {_, :ff, _, _} = target, :hi), do: {target, []}

  defp parse_input(input) do
    input
    |> Enum.map(&parse_line/1)
    |> Map.new()
    |> fill_cjs()
  end

  defp fill_cjs(map) do
    Enum.reduce(map, map, fn {parent_name, {_, _, _, to}}, acc0 ->
      Enum.reduce(to, acc0, fn parent_link, acc1 ->
        case Map.fetch!(acc1, parent_link) do
          {_, :cj, _, _} ->
            Map.update!(acc1, parent_link, fn {name, type, memory, to} ->
              {name, type, Map.put(memory, parent_name, :lo), to}
            end)

          _ ->
            acc1
        end
      end)
    end)
  end

  defp parse_line(input) do
    input
    |> Utils.splitrim("->")
    |> then(fn [name_part, to_part] -> {name_part, Utils.splitrim(to_part, ",")} end)
    |> then(fn
      {"broadcaster" = name, to} ->
        {name, {name, :bc, nil, to}}

      {"%" <> name, to} ->
        {name, {name, :ff, :off, to}}

      {"&" <> name, to} ->
        {name, {name, :cj, %{}, to}}
    end)
  end

  def run() do
    part2(~i[2023/20]l)
  end

  def bench() do
    Benchmark.mesure_milliseconds(&run/0)
  end
end

Y2023.D20.bench()
