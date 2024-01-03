defmodule Y2023.D15 do
  use Day, input: "2023/15", part1: ~c"w", part2: ~c"w"

  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&hash(0, &1))
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&Regex.run(~r/(\w+)([=-])(\d*)/, &1, capture: :all_but_first))
    |> Enum.reduce(List.duplicate([], 256), fn
      [label, "=", focal], boxes ->
        box_index = hash(0, label)

        List.update_at(boxes, box_index, fn slots ->
          key = String.to_atom(label)
          value = String.to_integer(focal)

          index =
            Enum.find_index(slots, fn
              {^key, _} -> true
              _ -> false
            end)

          if index != nil do
            List.replace_at(slots, index, {key, value})
          else
            slots ++ [{key, value}]
          end
        end)

      [label, "-", _], boxes ->
        box_index = hash(0, label)

        List.update_at(boxes, box_index, fn slots ->
          key = String.to_atom(label)

          Enum.filter(slots, fn
            {^key, _} -> false
            _ -> true
          end)
        end)
    end)
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {box, box_index} ->
      box
      |> Enum.with_index(1)
      |> Enum.map(fn {{_, focal}, slot_index} ->
        box_index * slot_index * focal
      end)
    end)
    |> Enum.sum()
  end

  defp hash(current, ""), do: current

  defp hash(current, <<head::utf8, tail::binary>>) do
    (current + head)
    |> Kernel.*(17)
    |> Kernel.rem(256)
    |> hash(tail)
  end

  defp parse_input(input) do
    Utils.splitrim(input, ",")
  end
end

Y2023.D15.bench2()
