defmodule Day do
  defmacro __using__(opts) do
    input = Keyword.fetch!(opts, :input)
    part1 = Keyword.get(opts, :part1, nil)
    part2 = Keyword.get(opts, :part2, nil)

    quote do
      if not is_nil(unquote(part1)) do
        def bench1() do
          source = unquote(input)
          flags = unquote(part1)
          Benchmark.mesure_milliseconds(fn -> part1(Input.sigil_i(source, flags)) end)
        end
      end

      if not is_nil(unquote(part2)) do
        def bench2() do
          source = unquote(input)
          flags = unquote(part2)
          Benchmark.mesure_milliseconds(fn -> part2(Input.sigil_i(source, flags)) end)
        end
      end
    end
  end
end
