defmodule Y2024.D13 do
  use Day, input: "2024/13", part1: ~c"c", part2: ~c"c"

  defp part1(input), do: partX(input, 0)
  defp part2(input), do: partX(input, 10_000_000_000_000)

  defp partX(input, supp) do
    input
    |> parse_input()
    |> Enum.map(&solve(&1, supp))
    |> Enum.sum()
  end

  defp solve({{ax, ay}, {bx, by}, {px, py}}, supp) do
    px = px + supp
    py = py + supp

    [{{ax, bx, px}, {ay, by, py}}, {{ay, by, py}, {ax, bx, px}}]
    |> Enum.map(&solve/1)
    |> Enum.map(fn {a, b} -> a * 3 + b * 1 end)
    |> Enum.min()
  end

  defp solve({{ax, bx, px} = eqx, {ay, _, _} = eqy}) do
    x_factor = div(ax, Integer.gcd(ax, ay))
    y_factor = div(ay, Integer.gcd(ax, ay))

    a_nullifier = mlt(eqx, y_factor / x_factor)

    {0, db, dp} =
      eqy
      |> sub(a_nullifier)
      |> mlt(x_factor)
      |> rnd()

    b = div(dp, db)
    rest = px - b * bx
    a = div(rest, ax)

    if rem(rest, a) == 0 do
      {a, b}
    else
      {0, 0}
    end
  end

  defp mlt({a, b, p}, c), do: {a * c, b * c, p * c}
  defp sub({a1, b1, p1}, {a2, b2, p2}), do: {a1 - a2, b1 - b2, p1 - p2}
  defp rnd({a, b, p}), do: {round(a), round(b), round(p)}

  defp parse_input(input), do: Enum.map(input, &parse_chunk/1)

  defp parse_chunk([a_line, b_line, prize_line]) do
    {
      parse_button(a_line),
      parse_button(b_line),
      parse_prize(prize_line)
    }
  end

  defp parse_button(<<"Button ", _, ": X+", x::bytes-size(2), ", Y+", y::bytes-size(2)>>) do
    {String.to_integer(x), String.to_integer(y)}
  end

  defp parse_prize(prize_line) do
    prize_line
    |> Utils.splitrim("X=")
    |> Enum.at(1)
    |> Utils.splitrim(", Y=")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  # defp _fewest_tokens({{ax, ay}, {bx, by}, {px, py}} = params) do
  #   max_b = 100 |> min(div(px, bx)) |> min(div(py, by))

  #   {a, b} = _search(params, max_b)

  #   a * 3 + b * 1
  # end

  # defp _search(_, 0), do: {0, 0}

  # defp _search({{ax, ay}, {bx, by}, {px, py}} = params, current_b) do
  #   rest_x = px - current_b * bx
  #   rest_y = py - current_b * by

  #   case {div(rest_x, ax), div(rest_y, ay), rem(rest_x, ax), rem(rest_y, ay)} do
  #     {current_a, current_a, 0, 0} -> {current_a, current_b}
  #     _ -> _search(params, current_b - 1)
  #   end
  # end
end

Y2024.D13.bench2()
