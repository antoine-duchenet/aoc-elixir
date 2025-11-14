defmodule Y2024.D21 do
  use Day, input: "2024/21", part1: ~c"l", part2: ~c"l"

  defp part1(input) do
    input
    |> Enum.map(&complexity(&1, [:numeric | List.duplicate(:directional, 2)]))
    |> Enum.sum()
  end

  defp part2(input) do
    input
  end

  defp complexity(code, modes) do
    [code]
    |> seq(modes)
    |> Enum.map(&String.length/1)
    |> Enum.min()
    |> Kernel.*(num(code))
  end

  defp seq(strings, []), do: strings

  defp seq(strings, [mode | next_modes]) do
    strings
    |> Enum.flat_map(&keypad(&1, "A", mode))
    |> seq(next_modes)
  end

  defp num(code) do
    code
    |> Integer.parse()
    |> elem(0)
  end

  defp keypad("", _, _), do: [""]

  defp keypad(<<to::bytes-size(1)>>, from, mode) do
    Performance.memoize({to, from, mode}, fn ->
      to
      |> k(from, mode)
      |> comb()
      |> Enum.map(&(&1 <> "A"))
    end)
  end

  defp keypad(<<to::bytes-size(1), tail::binary>>, from, mode) do
    Performance.memoize({to, tail, from, mode}, fn ->
      to
      |> keypad(from, mode)
      |> Enum.flat_map(fn h ->
        tail
        |> keypad(to, mode)
        |> Enum.map(fn t -> h <> t end)
      end)
    end)
  end

  def comb({steps, forbidden}) do
    Performance.memoize({steps, forbidden}, fn ->
      steps
      |> comb()
      |> Kernel.--([forbidden])
    end)
  end

  def comb(steps) when is_bitstring(steps) do
    Performance.memoize(steps, fn ->
      steps
      |> Utils.splitrim()
      |> comb()
      |> Enum.map(&Enum.join/1)
    end)
  end

  def comb([]), do: [[]]

  def comb(steps) when is_list(steps) do
    Performance.memoize(steps, fn ->
      for(h <- steps, t <- comb(steps -- [h]), do: [h | t])
      |> Enum.uniq()
    end)
  end

  # From A (numeric)
  defp k("A", "A", :numeric), do: ""
  defp k("0", "A", :numeric), do: "<"
  defp k("1", "A", :numeric), do: {"^<<", "<<^"}
  defp k("2", "A", :numeric), do: "^<"
  defp k("3", "A", :numeric), do: "^"
  defp k("4", "A", :numeric), do: {"^^<<", "<<^^"}
  defp k("5", "A", :numeric), do: "^^<"
  defp k("6", "A", :numeric), do: "^^"
  defp k("7", "A", :numeric), do: {"^^^<<", "<<^^^"}
  defp k("8", "A", :numeric), do: "^^^<"
  defp k("9", "A", :numeric), do: "^^^"

  # From 0
  defp k("A", "0", :numeric), do: ">"
  defp k("0", "0", :numeric), do: ""
  defp k("1", "0", :numeric), do: {"^<", "<^"}
  defp k("2", "0", :numeric), do: "^"
  defp k("3", "0", :numeric), do: "^>"
  defp k("4", "0", :numeric), do: {"^^<", "<^^"}
  defp k("5", "0", :numeric), do: "^^"
  defp k("6", "0", :numeric), do: "^^>"
  defp k("7", "0", :numeric), do: {"^^^<", "<^^^"}
  defp k("8", "0", :numeric), do: "^^^"
  defp k("9", "0", :numeric), do: "^^^>"

  # From 1
  defp k("A", "1", :numeric), do: {">>v", "v>>"}
  defp k("0", "1", :numeric), do: {">v", "v>"}
  defp k("1", "1", :numeric), do: ""
  defp k("2", "1", :numeric), do: ">"
  defp k("3", "1", :numeric), do: ">>"
  defp k("4", "1", :numeric), do: "^"
  defp k("5", "1", :numeric), do: "^>"
  defp k("6", "1", :numeric), do: "^>>"
  defp k("7", "1", :numeric), do: "^^"
  defp k("8", "1", :numeric), do: "^^>"
  defp k("9", "1", :numeric), do: "^^>>"

  # From 2
  defp k("A", "2", :numeric), do: ">v"
  defp k("0", "2", :numeric), do: "v"
  defp k("1", "2", :numeric), do: "<"
  defp k("2", "2", :numeric), do: ""
  defp k("3", "2", :numeric), do: ">"
  defp k("4", "2", :numeric), do: "^<"
  defp k("5", "2", :numeric), do: "^"
  defp k("6", "2", :numeric), do: "^>"
  defp k("7", "2", :numeric), do: "^^<"
  defp k("8", "2", :numeric), do: "^^"
  defp k("9", "2", :numeric), do: "^^>"

  # From 3
  defp k("A", "3", :numeric), do: "v"
  defp k("0", "3", :numeric), do: "v<"
  defp k("1", "3", :numeric), do: "<<"
  defp k("2", "3", :numeric), do: "<"
  defp k("3", "3", :numeric), do: ""
  defp k("4", "3", :numeric), do: "^<<"
  defp k("5", "3", :numeric), do: "^<"
  defp k("6", "3", :numeric), do: "^"
  defp k("7", "3", :numeric), do: "^^<<"
  defp k("8", "3", :numeric), do: "^^<"
  defp k("9", "3", :numeric), do: "^^"

  # From 4
  defp k("A", "4", :numeric), do: {">>vv", "vv>>"}
  defp k("0", "4", :numeric), do: {">vv", "vv>"}
  defp k("1", "4", :numeric), do: "v"
  defp k("2", "4", :numeric), do: ">v"
  defp k("3", "4", :numeric), do: ">>v"
  defp k("4", "4", :numeric), do: ""
  defp k("5", "4", :numeric), do: ">"
  defp k("6", "4", :numeric), do: ">>"
  defp k("7", "4", :numeric), do: "^"
  defp k("8", "4", :numeric), do: "^>"
  defp k("9", "4", :numeric), do: "^>>"

  # From 5
  defp k("A", "5", :numeric), do: ">vv"
  defp k("0", "5", :numeric), do: "vv"
  defp k("1", "5", :numeric), do: "v<"
  defp k("2", "5", :numeric), do: "v"
  defp k("3", "5", :numeric), do: ">v"
  defp k("4", "5", :numeric), do: "<"
  defp k("5", "5", :numeric), do: ""
  defp k("6", "5", :numeric), do: ">"
  defp k("7", "5", :numeric), do: "^<"
  defp k("8", "5", :numeric), do: "^"
  defp k("9", "5", :numeric), do: "^>"

  # From 6
  defp k("A", "6", :numeric), do: "vv"
  defp k("0", "6", :numeric), do: "vv<"
  defp k("1", "6", :numeric), do: "v<<"
  defp k("2", "6", :numeric), do: "v<"
  defp k("3", "6", :numeric), do: "v"
  defp k("4", "6", :numeric), do: "<<"
  defp k("5", "6", :numeric), do: "<"
  defp k("6", "6", :numeric), do: ""
  defp k("7", "6", :numeric), do: "^<<"
  defp k("8", "6", :numeric), do: "^<"
  defp k("9", "6", :numeric), do: "^"

  # From 7
  defp k("A", "7", :numeric), do: {">>vvv", "vvv>>"}
  defp k("0", "7", :numeric), do: {">vvv", "vvv>"}
  defp k("1", "7", :numeric), do: "vv"
  defp k("2", "7", :numeric), do: ">vv"
  defp k("3", "7", :numeric), do: ">>vv"
  defp k("4", "7", :numeric), do: "v"
  defp k("5", "7", :numeric), do: ">v"
  defp k("6", "7", :numeric), do: ">>v"
  defp k("7", "7", :numeric), do: ""
  defp k("8", "7", :numeric), do: ">"
  defp k("9", "7", :numeric), do: ">>"

  # From 8
  defp k("A", "8", :numeric), do: ">vvv"
  defp k("0", "8", :numeric), do: "vvv"
  defp k("1", "8", :numeric), do: "vv<"
  defp k("2", "8", :numeric), do: "vv"
  defp k("3", "8", :numeric), do: ">vv"
  defp k("4", "8", :numeric), do: "v<"
  defp k("5", "8", :numeric), do: "v"
  defp k("6", "8", :numeric), do: ">v"
  defp k("7", "8", :numeric), do: "<"
  defp k("8", "8", :numeric), do: ""
  defp k("9", "8", :numeric), do: ">"

  # From 9
  defp k("A", "9", :numeric), do: "vvv"
  defp k("0", "9", :numeric), do: "vvv<"
  defp k("1", "9", :numeric), do: "vv<<"
  defp k("2", "9", :numeric), do: "vv<"
  defp k("3", "9", :numeric), do: "vv"
  defp k("4", "9", :numeric), do: "v<<"
  defp k("5", "9", :numeric), do: "v<"
  defp k("6", "9", :numeric), do: "v"
  defp k("7", "9", :numeric), do: "<<"
  defp k("8", "9", :numeric), do: "<"
  defp k("9", "9", :numeric), do: ""

  # From A (directional)
  defp k("A", "A", :directional), do: ""
  defp k("^", "A", :directional), do: "<"
  defp k("<", "A", :directional), do: {"v<<", "<<v"}
  defp k("v", "A", :directional), do: "v<"
  defp k(">", "A", :directional), do: "v"

  # From ^
  defp k("A", "^", :directional), do: ">"
  defp k("^", "^", :directional), do: ""
  defp k("<", "^", :directional), do: {"v<", "<v"}
  defp k("v", "^", :directional), do: "v"
  defp k(">", "^", :directional), do: ">v"

  # From <
  defp k("A", "<", :directional), do: {">>^", "^>>"}
  defp k("^", "<", :directional), do: {">^", "^>"}
  defp k("<", "<", :directional), do: ""
  defp k("v", "<", :directional), do: ">"
  defp k(">", "<", :directional), do: ">>"

  # From <
  defp k("A", "v", :directional), do: "^>"
  defp k("^", "v", :directional), do: "^"
  defp k("<", "v", :directional), do: "<"
  defp k("v", "v", :directional), do: ""
  defp k(">", "v", :directional), do: ">"

  # From >
  defp k("A", ">", :directional), do: "^"
  defp k("^", ">", :directional), do: "^<"
  defp k("<", ">", :directional), do: "<<"
  defp k("v", ">", :directional), do: "<"
  defp k(">", ">", :directional), do: ""
end

Y2024.D21.bench1()
