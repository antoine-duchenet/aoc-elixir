defmodule Y2023.D8 do
  use Day, input: "2023/08", part1: ~c"l", part2: ~c"l"

  def part1(input_list) do
    {steps, map} = parse_input(input_list)

    done? = &(&1 === "ZZZ")

    walk(steps, steps, map, 0, "AAA", done?)
  end

  def part2(input_list) do
    {steps, map} = parse_input(input_list)

    is_start? = &String.ends_with?(&1, "A")
    done? = &String.ends_with?(&1, "Z")

    map
    |> Map.keys()
    |> Enum.filter(is_start?)
    |> Enum.map(&walk(steps, steps, map, 0, &1, done?))
    |> Math.lcm()
  end

  defp walk([], steps, map, count, location, done?) do
    walk(steps, steps, map, count, location, done?)
  end

  defp walk([next | rest], steps, map, count, location, done?) do
    if done?.(location) do
      count
    else
      map
      |> Map.get(location)
      |> elem(next)
      |> then(&walk(rest, steps, map, count + 1, &1, done?))
    end
  end

  defp parse_input(input_list) do
    [raw_steps | raw_map] = input_list

    steps = parse_steps(raw_steps)
    map = parse_map(raw_map)

    {steps, map}
  end

  defp parse_steps(raw_steps) do
    raw_steps
    |> Utils.splitrim("")
    |> Enum.map(&to_index/1)
  end

  defp parse_map(raw_map) do
    raw_map
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&parse_node/1)
    |> Enum.into(%{})
  end

  defp parse_node(<<f::binary-size(3), " = (", l::binary-size(3), ", ", r::binary-size(3), ")">>) do
    {f, {l, r}}
  end

  defp to_index("L"), do: 0
  defp to_index("R"), do: 1
end

Y2023.D8.bench2()
