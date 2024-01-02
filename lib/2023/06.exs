import Input

defmodule Y2023.D6 do
  def part1(input_lines) do
    input_lines
    |> Enum.map(&Utils.splitrim(&1, ":"))
    |> Enum.flat_map(fn [_ | tail] -> Enum.map(tail, &split_integers/1) end)
    |> Enum.zip()
    |> Enum.map(fn {t, d} -> for p <- 0..t, p * (t - p) > d, do: {p, t - p} end)
    |> Enum.map(&Enum.count/1)
    |> Enum.reduce(1, fn item, acc -> acc * item end)
    |> dbg
  end

  def part2(input_lines) do
    input_lines
    |> Enum.map(&Utils.splitrim(&1, ":"))
    |> Enum.map(fn [_ | tail] -> Enum.map(tail, &merge_integer/1) end)
    |> Enum.zip()
    |> Enum.at(0)
    |> then(fn {t, d} -> for p <- 0..t, p * (t - p) > d, do: {p, t - p} end)
    |> Stream.transform(
      fn -> 0 end,
      fn _, acc -> {[], acc + 1} end,
      fn acc -> {[acc], :done} end,
      fn _ -> :ok end
    )
    |> Enum.at(0)
    |> dbg
  end

  defp split_integers(string) do
    string
    |> Utils.splitrim(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp merge_integer(string) do
    string
    |> Utils.splitrim(" ")
    |> Enum.join("")
    |> String.to_integer()
  end
end

~i[2023/06]l
|> Y2023.D6.part2()
|> dbg
