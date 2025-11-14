defmodule Y2024.D24 do
  use Day, input: "2024/24", part1: ~c"c", part2: ~c"c"

  defp part1(input) do
    {raw_facts, gates} = parse_input(input)

    raw_facts
    |> sweep_facts(gates)
    |> resolve_zs(gates)
    |> read("z")
    |> Integer.undigits(2)
  end

  defp part2(input) do
    {raw_facts, gates} = parse_input(input)

    graphviz(raw_facts, gates)

    facts = sweep_facts(raw_facts, gates)

    initial_score =
      facts
      |> resolve_zs(gates)
      |> score()

    new_score =
      facts
      |> resolve_zs(
        gates
        |> swap("z05", "tst")
        |> swap("z11", "sps")
        |> swap("z23", "frt")
        |> swap("cgh", "pmd")
      )
      |> score()

    dbg({initial_score, new_score})

    # By looking at the graphviz :
    # cgh,frt,pmd,sps,tst,z05,z11,z23
  end

  defp graphviz(facts, gates) do
    gates
    |> Enum.flat_map(fn {out, {op, in1, in2}} ->
      [
        "#{in1} -> #{out}",
        "#{in2} -> #{out}",
        "#{out}[xlabel=\"#{in1} #{op} #{in2}\"]"
      ]
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  defp ancestors(wire, gates)
  defp ancestors(<<"x", _::binary>> = wire, _), do: [wire]
  defp ancestors(<<"y", _::binary>> = wire, _), do: [wire]

  defp ancestors(wire, gates) do
    {_, a, b} = Map.fetch!(gates, wire)
    [wire, a, b] ++ ancestors(a, gates) ++ ancestors(b, gates)
  end

  defp swap(gates, wire1, wire2) do
    gates
    |> Map.replace(wire1, Map.get(gates, wire2))
    |> Map.replace(wire2, Map.get(gates, wire1))
  end

  defp score(facts) do
    x = read(facts, "x")
    y = read(facts, "y")
    z = read(facts, "z")

    z
    |> wrong_bits(x, y)
    |> dbg
    |> Enum.count()
  end

  defp wrong_bits(z, x, y) do
    sum =
      x
      |> Integer.undigits(2)
      |> Kernel.+(Integer.undigits(y, 2))
      |> Integer.digits(2)

    max = length(sum) - 1

    0..max
    |> Enum.filter(fn n ->
      zn =
        z
        |> Enum.take(-(n + 1))
        |> Enum.drop(-n)
        |> Kernel.++(Enum.take(sum, -n))

      sum
      |> Enum.take(-(n + 1))
      |> Kernel.!=(zn)
    end)
  end

  defp resolve_zs(facts, gates) do
    if(done?(facts)) do
      facts
    else
      facts
      |> Enum.filter(&is_nil(elem(&1, 1)))
      |> Enum.reduce(facts, fn {out, nil}, acc ->
        {op, in1, in2} = Map.fetch!(gates, out)

        case Map.take(acc, [in1, in2]) do
          %{^in1 => nil} ->
            acc

          %{^in2 => nil} ->
            acc

          %{^in1 => a, ^in2 => b} ->
            op
            |> operation(a, b)
            |> then(&Map.replace(acc, out, &1))
        end
      end)
      |> resolve_zs(gates)
    end
  end

  defp read(facts, prefix) do
    facts
    |> Enum.filter(&match?({<<^prefix::bytes-size(1), _::binary>>, _}, &1))
    |> Enum.sort_by(&elem(&1, 0), :desc)
    |> Enum.map(&elem(&1, 1))
  end

  defp done?(facts) do
    Enum.all?(facts, fn
      {"z" <> _, nil} -> false
      _ -> true
    end)
  end

  defp operation(:and, a, b), do: Bitwise.band(a, b)
  defp operation(:xor, a, b), do: Bitwise.bxor(a, b)
  defp operation(:or, a, b), do: Bitwise.bor(a, b)

  defp sweep_facts(facts, gates) do
    gates
    |> Enum.flat_map(fn {out, {_, in1, in2}} -> [in1, in2, out] end)
    |> Enum.uniq()
    |> Enum.reduce(facts, &Map.put_new(&2, &1, nil))
  end

  defp quads(list) do
    for {a1, a2} = a <- list,
        {b1, b2} = b <- list,
        {c1, c2} = c <- list,
        {d1, d2} = d <- list,
        a1 != b1,
        a1 != b2,
        a1 != c1,
        a1 != c2,
        a1 != d1,
        a1 != d2,
        a2 != b1,
        a2 != b2,
        a2 != c1,
        a2 != c2,
        a2 != d1,
        a2 != d2,
        b1 != c1,
        b1 != c2,
        b1 != d1,
        b1 != d2,
        b2 != c1,
        b2 != c2,
        b2 != d1,
        b2 != d2,
        c1 != d1,
        c1 != d2,
        c2 != d1,
        c2 != d2 do
      {a, b, c, d}
    end
  end

  defp pairs([]), do: []
  defp pairs([h | tail]), do: for(t <- tail, do: {h, t}) ++ pairs(tail)

  defp parse_input([facts_chunk, gates_chunk]) do
    {parse_facts(facts_chunk), parse_gates(gates_chunk)}
  end

  defp parse_facts(facts_chunk) do
    facts_chunk
    |> Enum.map(&parse_fact/1)
    |> Map.new()
  end

  defp parse_gates(gates_chunk) do
    gates_chunk
    |> Enum.map(&parse_gate/1)
    |> Map.new()
  end

  defp parse_fact(<<wire::bytes-size(3), ": ", value::bitstring>>) do
    {wire, String.to_integer(value)}
  end

  defp parse_gate(<<in1::bytes-size(3), " AND ", in2::bytes-size(3), " -> ", out::bytes-size(3)>>) do
    {out, {:and, in1, in2}}
  end

  defp parse_gate(<<in1::bytes-size(3), " XOR ", in2::bytes-size(3), " -> ", out::bytes-size(3)>>) do
    {out, {:xor, in1, in2}}
  end

  defp parse_gate(<<in1::bytes-size(3), " OR ", in2::bytes-size(3), " -> ", out::bytes-size(3)>>) do
    {out, {:or, in1, in2}}
  end
end

Y2024.D24.bench2()
