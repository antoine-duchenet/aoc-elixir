defmodule Y2023.D05 do
  use Day, input: "2023/05.sample", part1: ~c"l", part2: ~c"l"

  defmodule Span do
    defstruct start: 0, ending: 0, offset: 0

    def new(start, ending, offset \\ 0) do
      %Span{start: start, ending: ending, offset: offset}
    end

    def from_seeds_input([start, length]), do: new(start, start + length)

    def from_map_input([to_start, from_start, length]) do
      new(from_start, from_start + length, to_start - from_start)
    end

    def start(%Span{start: start}), do: start
    def ending(%Span{ending: ending}), do: ending
    def offset(%Span{offset: offset}), do: offset

    def matches_in?(%Span{} = span, value), do: value >= start(span) && value < ending(span)

    def transform(%Span{} = span) do
      new(start(span) + offset(span), ending(span) + offset(span), 0)
    end

    def transform(%Span{} = span, value), do: value + offset(span)

    def pipe(%Span{} = span1, %Span{} = span2) do
      cond do
        Range.disjoint?(
          (start(span1) + offset(span1))..(ending(span1) + offset(span1) - 1),
          start(span2)..(ending(span2) - 1)
        ) ->
          nil

        start(span1) + offset(span1) <= start(span2) and
            ending(span1) + offset(span1) >= ending(span2) ->
          new(
            start(span2) - offset(span1),
            ending(span2) - offset(span1),
            offset(span1) + offset(span2)
          )

        start(span1) + offset(span1) >= start(span2) and
            ending(span1) + offset(span1) <= ending(span2) ->
          new(start(span1), ending(span1), offset(span1) + offset(span2))

        start(span1) + offset(span1) <= start(span2) and
            ending(span1) + offset(span1) <= ending(span2) ->
          new(start(span2) - offset(span1), ending(span1), offset(span1) + offset(span2))

        start(span1) + offset(span1) >= start(span2) and
            ending(span1) + offset(span1) >= ending(span2) ->
          new(start(span1), ending(span2) - offset(span1), offset(span1) + offset(span2))
      end
    end
  end

  defmodule Layer do
    @min_u64 0
    @max_u64 18_446_744_073_709_551_615

    defstruct spans: []

    def new(spans), do: %Layer{spans: spans}

    def from_seeds_inputs(input) do
      input
      |> Enum.map(&Span.from_seeds_input/1)
      |> new()
    end

    def from_map_inputs(input) do
      input
      |> Enum.map(&Span.from_map_input/1)
      |> new()
      |> passthrough(@min_u64, @max_u64)
    end

    def compose(%Layer{spans: spans1}, %Layer{spans: spans2}) do
      spans1
      |> Enum.flat_map(fn span ->
        spans2
        |> Enum.map(&Span.pipe(span, &1))
        |> Enum.reject(&is_nil/1)
      end)
      |> new()
    end

    def transform(%Layer{spans: spans}) do
      spans
      |> Enum.map(&Span.transform/1)
      |> new()
    end

    def transform(%Layer{spans: spans}, value) do
      spans
      |> Enum.find(%Span{}, &Span.matches_in?(&1, value))
      |> Span.transform(value)
    end

    defp passthrough(%Layer{spans: spans}, in_min, in_max) do
      [Span.new(in_min, in_min), Span.new(in_max, in_max) | spans]
      |> Enum.sort_by(&Span.start/1)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.flat_map(fn [span1, span2] ->
        [span1, Span.new(Span.ending(span1), Span.start(span2), 0)]
      end)
      |> Enum.reject(fn span -> Span.start(span) == Span.ending(span) end)
      |> new()
    end

    def min(%Layer{spans: spans}) do
      spans
      |> Enum.min_by(&Span.start/1)
      |> Span.start()
    end
  end

  def part1(input_lines) do
    [[seeds] | maps] = parse_input_lines(input_lines)
    [map1, map2, map3, map4, map5, map6, map7] = Enum.map(maps, &Layer.from_map_inputs/1)

    # seeds
    # |> Enum.map(fn seed ->
    #   seed
    #   |> transform_via(map1)
    #   |> transform_via(map2)
    #   |> transform_via(map3)
    #   |> transform_via(map4)
    #   |> transform_via(map5)
    #   |> transform_via(map6)
    #   |> transform_via(map7)
    # end)
    # |> Enum.min()

    seeds
    |> Enum.map(&transform_via(&1, map1))
    |> Enum.map(&transform_via(&1, map2))
    |> Enum.map(&transform_via(&1, map3))
    |> Enum.map(&transform_via(&1, map4))
    |> Enum.map(&transform_via(&1, map5))
    |> Enum.map(&transform_via(&1, map6))
    |> Enum.map(&transform_via(&1, map7))
    |> Enum.min()
    |> dbg
  end

  def part2(input_lines) do
    [[seeds] | maps] = parse_input_lines(input_lines)
    [map1, map2, map3, map4, map5, map6, map7] = Enum.map(maps, &Layer.from_map_inputs/1)

    # seeds
    # |> Enum.chunk_every(2)
    # |> Layer.from_seeds_inputs()
    # |> transform_via(map1)
    # |> transform_via(map2)
    # |> transform_via(map3)
    # |> transform_via(map4)
    # |> transform_via(map5)
    # |> transform_via(map6)
    # |> transform_via(map7)
    # |> Layer.min()

    seeds
    |> Enum.chunk_every(2)
    |> Layer.from_seeds_inputs()
    |> Layer.compose(map1)
    |> Layer.compose(map2)
    |> Layer.compose(map3)
    |> Layer.compose(map4)
    |> Layer.compose(map5)
    |> Layer.compose(map6)
    |> Layer.compose(map7)
    |> Layer.transform()
    |> Layer.min()
  end

  defp transform_via(value, %Layer{} = map) when is_number(value) do
    Layer.transform(map, value)
  end

  defp transform_via(%Layer{} = spans, %Layer{} = map) do
    spans
    |> Layer.compose(map)
    |> Layer.transform()
  end

  defp parse_input_lines(input_lines) do
    input_lines
    |> chunk_sections()
    |> then(fn [["seeds: " <> seeds] | maps] -> [[seeds] | maps] end)
    |> parse_sections()
  end

  defp chunk_sections(input_lines) do
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

  defp parse_sections(sections), do: Enum.map(sections, &parse_section/1)

  defp parse_section(section), do: Enum.map(section, &parse_line/1)

  defp parse_line(line) do
    line
    |> Utils.splitrim(" ")
    |> Enum.map(&String.to_integer/1)
  end
end

Y2023.D05.bench2()
