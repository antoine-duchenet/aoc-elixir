defmodule Y2023.D03 do
  use Day, input: "2023/03", part1: ~c"l", part2: ~c"l"

  @symbol_regex ~r/[^\d\.]/
  @number_regex ~r/\d+/

  defp part1(input_list) do
    {numbers, symbols} = locate_numbers_and_symbols(input_list)

    numbers
    |> Enum.filter(fn number ->
      number
      |> neighbors()
      |> Enum.any?(&is_symbol_location?(&1, symbols))
    end)
    |> Enum.reduce(0, fn {_, _, _, value}, sum -> sum + value end)
  end

  defp part2(input_list) do
    {numbers, symbols} = locate_numbers_and_symbols(input_list)

    symbols
    |> Enum.filter(fn {_, _, _, value} -> value == "*" end)
    |> Enum.map(fn star ->
      numbers
      |> Enum.filter(fn number ->
        number
        |> neighbors()
        |> Enum.any?(&is_symbol_location?(&1, [star]))
      end)
    end)
    |> Enum.filter(fn numbers -> Enum.count(numbers) == 2 end)
    |> Enum.map(fn [{_, _, _, a}, {_, _, _, b}] -> a * b end)
    |> Enum.sum()
  end

  defp locate_numbers_and_symbols(input_list) do
    symbols = locate(input_list, @symbol_regex)

    numbers =
      input_list
      |> locate(@number_regex)
      |> Enum.map(fn {x, y, length, value} -> {x, y, length, String.to_integer(value)} end)

    {numbers, symbols}
  end

  defp locate(rows, regex) do
    rows
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      case Regex.scan(regex, line, return: :index) do
        [] ->
          []

        matches ->
          matches
          |> Enum.flat_map(fn positions ->
            Enum.map(positions, fn {x, length} ->
              value = String.slice(line, x, length)
              {x, y, length, value}
            end)
          end)
      end
    end)
  end

  defp neighbors({x, y, length, _}) do
    for x_offset <- -1..length,
        y_offset <- -1..1,
        x_offset != 0 or y_offset != 0,
        do: {x + x_offset, y + y_offset}
  end

  defp is_symbol_location?({x, y}, symbols) do
    Enum.any?(symbols, fn {x_symbol, y_symbol, _, _} -> x == x_symbol and y == y_symbol end)
  end
end

Y2023.D03.bench2()
