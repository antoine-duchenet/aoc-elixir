defmodule Y2024.D21.Keypad do
  alias __MODULE__

  @n {-1, 0}
  @e {0, +1}
  @s {+1, 0}
  @w {0, -1}

  defstruct position: {0, 0}, grid: %{}

  def new(grid) do
    grid =
      grid
      |> Utils.splitrim("\n")
      |> Enum.map(&Utils.splitrim/1)
      |> Matrix.to_rc_map()

    position =
      grid
      |> Enum.find(&(elem(&1, 1) == "A"))
      |> elem(0)

    %Keypad{position: position, grid: grid}
  end

  def press(keypad = %Keypad{}, button) do
    to =
      keypad.grid
      |> Enum.find(&(elem(&1, 1) == button))
      |> elem(0)

    diff = sub(keypad.position, to)
    moves = do_press(diff, to, keypad.grid)

    steps =
      moves
      |> Enum.map(fn move -> Enum.map(move, &to_step/1) ++ ["A"] end)
      |> case do
        [step] -> step
        steps -> [{:alt, steps}]
      end

    {steps, %{keypad | position: to}}
  end

  defp do_press({0, 0}, _to, _grid), do: [[]]

  defp do_press(diff, to, grid) do
    [@n, @e, @s, @w]
    |> Enum.filter(fn dir ->
      new_diff = add(diff, dir)
      new_pos = add(to, new_diff)

      Map.has_key?(grid, new_pos) and
        distance(new_diff) < distance(diff) and
        Map.fetch!(grid, add(to, new_diff)) !== :panic
    end)
    |> Enum.flat_map(fn dir ->
      new_diff = add(diff, dir)

      do_press(new_diff, to, grid)
      |> Enum.map(fn path ->
        [dir | path]
      end)
    end)
  end

  defp distance({a, b}), do: abs(a) + abs(b)

  defp to_step(@n), do: "^"
  defp to_step(@e), do: ">"
  defp to_step(@s), do: "v"
  defp to_step(@w), do: "<"

  defp add({a, b}, {c, d}), do: {a + c, b + d}

  defp sub({a, b}, {c, d}), do: {a - c, b - d}
end

defmodule Y2024.D21.Keypad.Numeric do
  alias Y2024.D21.Keypad

  def new() do
    """
    789
    456
    123
    .0A
    """
    |> Keypad.new()
  end
end

defmodule Y2024.D21.Keypad.Directional do
  alias Y2024.D21.Keypad

  def new() do
    """
    .^A
    <v>
    """
    |> Keypad.new()
  end
end

defmodule Y2024.D21 do
  alias Y2024.D21.Keypad

  use Day, input: "2024/21", part1: ~c"l", part2: ~c"l"

  defp part1(input), do: partX(input, 2)
  defp part2(input), do: partX(input, 25)

  defp partX(input, n) do
    keypads = [Keypad.Numeric.new() | List.duplicate(Keypad.Directional.new(), n)]

    input
    |> parse_input()
    |> Enum.map(fn {num, code} ->
      code
      |> Utils.splitrim()
      |> press(keypads)
      |> then(&(num * &1))
    end)
    |> Enum.sum()
  end

  defp count(_, n \\ 0)
  defp count(c, n) when is_integer(c), do: n + c
  defp count(c, n) when is_bitstring(c), do: n + 1

  defp count({:alt, alts}, n) do
    alts
    |> Enum.map(&count(&1, 0))
    |> Enum.min()
    |> Kernel.+(n)
  end

  defp count([head | tail], n) do
    head
    |> count()
    |> then(&count(tail, n + &1))
  end

  defp count([], n), do: n

  defp press(buttons, keypads) do
    {result, _} = do_press(buttons, keypads)
    count(result)
  end

  defp do_press(buttons, keypads) do
    Enum.map_reduce(buttons, keypads, fn button, kps ->
      case kps do
        [] ->
          {count([button]), []}

        [kp | kps] ->
          cache_key = {button, kp.position, length(kps)}

          case Process.get(cache_key) do
            nil ->
              case button do
                {:alt, [alt | alts]} ->
                  {first, [kp | kps]} = do_press(alt, [kp | kps])

                  rest =
                    Enum.map(alts, fn alt ->
                      {buttons, _} = do_press(alt, [kp | kps])
                      buttons
                    end)

                  {count({:alt, [first | rest]}), [kp | kps]}

                _ when is_bitstring(button) ->
                  {buttons, kp} = Keypad.press(kp, button)
                  {buttons, kps} = do_press(buttons, kps)
                  {count(buttons), [kp | kps]}
              end
              |> then(fn {value, [kp | _] = kps} ->
                Process.put(cache_key, {value, kp})
                {value, kps}
              end)

            {value, kp} ->
              {value, [kp | kps]}
          end
      end
    end)
  end

  defp parse_input(input) do
    Enum.map(input, fn code ->
      num =
        code
        |> Integer.parse()
        |> elem(0)

      {num, code}
    end)
  end
end

Y2024.D21.bench2()
