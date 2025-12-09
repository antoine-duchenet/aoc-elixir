defmodule Y2025.D06 do
  use Day, input: "2025/06", part1: ~c"l", part2: ~c"g"

  defp part1(input), do: partX(input, :part1)
  defp part2(input), do: partX(input, :part2)

  defp partX(input, part) do
    {num_lines, [op_line]} = Enum.split(input, -1)

    ops = parse_ops(op_line, part)
    nums = parse_nums(num_lines, part)

    ops
    |> Enum.zip(nums)
    |> Enum.map(&op/1)
    |> Enum.sum()
  end

  defp op({"*", [a, b | tail]}), do: op({"*", [a * b | tail]})
  defp op({"+", [a, b | tail]}), do: op({"+", [a + b | tail]})
  defp op({_, [a]}), do: a

  defp parse_ops(op_line, :part1), do: Utils.splitrim(op_line, " ")
  defp parse_ops(op_line, :part2), do: Enum.reject(op_line, &(&1 == ""))

  defp parse_nums(num_lines, :part1) do
    num_lines
    |> Enum.map(fn line ->
      line
      |> Utils.splitrim(" ")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp parse_nums(num_lines, :part2) do
    num_lines
    |> Matrix.transpose()
    |> Enum.map(&Enum.join/1)
    |> EnumExt.chunk_on("")
    |> Enum.map(fn num_str -> Enum.map(num_str, &String.to_integer/1) end)
  end
end

Y2025.D06.bench2()
