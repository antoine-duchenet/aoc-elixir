defmodule Y2024.D19 do
  use Day, input: "2024/19", part1: ~c"c", part2: ~c"c"

  defp partX(input, transform) do
    {raw_towels, patterns} = parse_input(input)

    towels = Enum.map(raw_towels, &{&1, byte_size(&1)})

    prime_towels =
      towels
      |> Enum.sort_by(fn {_, size} -> size end, :asc)
      |> Enum.reduce([], &if(possible?(&1, &2), do: &2, else: [&1 | &2]))

    patterns
    |> Enum.filter(&possible?(&1, prime_towels))
    |> transform.(towels)
  end

  defp part1(input), do: partX(input, &Enum.count(&1))
  defp part2(input), do: partX(input, &ways/2)

  defp possible?("", _), do: true
  defp possible?({pattern, _}, towels), do: possible?(pattern, towels)

  defp possible?(pattern, towels) do
    Enum.any?(towels, fn {towel, size} ->
      case pattern do
        <<^towel::bytes-size(size), tail::binary>> -> possible?(tail, towels)
        _ -> false
      end
    end)
  end

  defp ways("", _), do: 1

  defp ways(patterns, towels) when is_list(patterns) do
    patterns
    |> Enum.map(&ways(&1, towels))
    |> Enum.sum()
  end

  defp ways(pattern, towels) do
    contained_towels = Enum.filter(towels, fn {towel, _} -> String.contains?(pattern, towel) end)

    Performance.memoize({pattern, towels}, fn ->
      contained_towels
      |> Enum.map(fn {towel, size} ->
        case pattern do
          <<^towel::bytes-size(size), tail::binary>> ->
            ways(tail, contained_towels)

          _ ->
            0
        end
      end)
      |> Enum.sum()
    end)
  end

  defp parse_input(input) do
    [towels_chunk, patterns_chunk] = input

    {parse_towels(towels_chunk), parse_patterns(patterns_chunk)}
  end

  defp parse_towels([towels_line]), do: Utils.splitrim(towels_line, ",")

  defp parse_patterns(patterns_chunk), do: patterns_chunk
end

Y2024.D19.bench2()
