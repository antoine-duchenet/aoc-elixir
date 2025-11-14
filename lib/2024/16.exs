defmodule Y2024.D16 do
  use Day, input: "2024/16", part1: ~c"l", part2: ~c"l"

  @n {-1, 0}
  @e {0, +1}
  @s {+1, 0}
  @w {0, -1}

  @choices [&__MODULE__.ccw/1, &__MODULE__.cw/1, &__MODULE__.straight/1]

  defp part1(input) do
    partX(input, fn lowest, end_rc ->
      lowest
      |> Enum.filter(fn {{rc, _}, _} -> rc == end_rc end)
      |> Enum.map(fn {{_, _}, score} -> score end)
      |> Enum.min()
    end)
  end

  defp part2(input) do
    partX(input, fn lowest, end_rc ->
      lowest_end =
        lowest
        |> Enum.filter(fn {{rc, _}, _} -> rc == end_rc end)
        |> Enum.min_by(fn {{_, _}, score} -> score end)

      MapSet.new([lowest_end])
      |> backtrack(lowest, lowest_end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.uniq_by(&elem(&1, 0))
      |> Enum.count()
    end)
  end

  defp partX(input, postprocess) do
    map =
      input
      |> parse_input()
      |> Matrix.to_rc_map()

    {start_rc, "S"} = Enum.find(map, &(elem(&1, 1) == "S"))
    {end_rc, "E"} = Enum.find(map, &(elem(&1, 1) == "E"))

    %{}
    |> walk(map, start_rc, @e, 0)
    |> postprocess.(end_rc)
  end

  defp walk(lowest, map, rc, dir, score) do
    previous_score = Map.get(lowest, {rc, dir})

    cond do
      previous_score == nil or score < previous_score ->
        lowest
        |> Map.put({rc, dir}, score)
        |> walk(map, rc, Map.get(map, rc), dir, score)

      true ->
        lowest
    end
  end

  defp walk(lowest, _, _, "#", _, _), do: lowest
  defp walk(lowest, _, _, "E", _, _), do: lowest

  defp walk(lowest, map, rc, _, dir, score) do
    Enum.reduce(@choices, lowest, fn choice, acc ->
      walk(acc, map, forward(rc, choice.(dir)), choice.(dir), choice.(score))
    end)
  end

  defp backtrack(best, lowest, {{to_rc, to_dir}, _} = to) do
    previous_rc = backward(to_rc, to_dir)

    matching_previous =
      lowest
      |> Enum.filter(fn {{rc, _}, _} -> rc == previous_rc end)
      |> Enum.filter(fn from -> Enum.any?(@choices, &match_choice?(to, from, &1)) end)
      |> MapSet.new()

    Enum.reduce(
      MapSet.difference(matching_previous, best),
      MapSet.union(best, matching_previous),
      &backtrack(&2, lowest, &1)
    )
  end

  defp match_choice?({{_, to_dir}, to_score}, {{_, from_dir}, from_score}, choice) do
    choice.(from_dir) == to_dir and choice.(from_score) == to_score
  end

  defp forward({r, c}, {dr, dc}), do: {r + dr, c + dc}
  defp backward({r, c}, {dr, dc}), do: {r - dr, c - dc}

  def straight(@n), do: @n
  def straight(@e), do: @e
  def straight(@s), do: @s
  def straight(@w), do: @w
  def straight(n), do: n + 1

  def cw(@n), do: @e
  def cw(@e), do: @s
  def cw(@s), do: @w
  def cw(@w), do: @n
  def cw(n), do: n + 1001

  def ccw(@n), do: @w
  def ccw(@w), do: @s
  def ccw(@s), do: @e
  def ccw(@e), do: @n
  def ccw(n), do: n + 1001

  defp parse_input(input), do: Enum.map(input, &Utils.splitrim/1)
end

Y2024.D16.bench1()
