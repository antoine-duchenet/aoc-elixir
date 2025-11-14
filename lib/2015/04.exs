defmodule Y2015.D04 do
  use Day, input: "2015/04", part1: ~c"w", part2: ~c"w"

  defp part1(input), do: search(input, "00000", 0)
  defp part2(input), do: search(input, "000000", 0)

  defp search(salt, prefix, n) do
    "#{salt}#{n}"
    |> then(&:crypto.hash(:md5, &1))
    |> Base.encode16()
    |> String.starts_with?(prefix)
    |> case do
      true -> n
      false -> search(salt, prefix, n + 1)
    end
  end
end

Y2015.D04.bench2()
