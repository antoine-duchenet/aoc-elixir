import Input

defmodule Vec3 do
  def x({x, _, _}), do: x
  def y({_, y, _}), do: y
  def z({_, _, z}), do: z

  def slope(vec3) do
    Vec3.y(vec3) / Vec3.x(vec3)
  end
end

defmodule Cong do
  def new(integer, modulo, normalize \\ true)
  def new(integer, modulo, true), do: integer |> new(modulo, false) |> Cong.normalize()
  def new(integer, modulo, false), do: {modulo, rem(integer, modulo)}

  def normalize({modulo, remainder}) when modulo < 0, do: {-modulo, remainder - modulo}
  def normalize(congruence), do: congruence

  def modulo({modulo, _}), do: modulo
  def remainder({_, remainder}), do: remainder

  def m(congruence), do: modulo(congruence)
  def r(congruence), do: remainder(congruence)
end

defmodule Snap do
  def new(position, velocity), do: {position, velocity}

  def map({position, velocity}, mapper), do: {mapper.(position), mapper.(velocity)}
  def map(list, mapper), do: Enum.map(list, &map(&1, mapper))

  def position({position, _}), do: position
  def velocity({_, velocity}), do: velocity
end

defmodule Y2023.D24 do
  @min_position 200_000_000_000_000
  @max_position 400_000_000_000_000
  @position_boundary 999_999_999_999_999
  @velocity_boundary 999

  defp part1(input) do
    hailstones = parse_input(input)

    count = Enum.count(hailstones)

    for i1 <- 0..(count - 1), i2 <- i1..(count - 1), i1 != i2 do
      {p1, v1} = Enum.at(hailstones, i1)
      {p2, v2} = Enum.at(hailstones, i2)

      slope1 = Vec3.slope(v1)
      slope2 = Vec3.slope(v2)

      with true <- slope1 != slope2 do
        interx =
          (slope2 * Vec3.x(p2) - slope1 * Vec3.x(p1) + Vec3.y(p1) - Vec3.y(p2)) /
            (slope2 - slope1)

        with true <- interx >= @min_position and interx <= @max_position do
          intery = slope1 * (interx - Vec3.x(p1)) + Vec3.y(p1)

          with true <- intery >= @min_position and intery <= @max_position do
            (interx - Vec3.x(p1)) / Vec3.x(v1) > 0 and (intery - Vec3.y(p1)) / Vec3.y(v1) > 0 and
              (interx - Vec3.x(p2)) / Vec3.x(v2) > 0 and (intery - Vec3.y(p2)) / Vec3.y(v2) > 0
          end
        end
      end
    end
    |> Enum.count(& &1)
  end

  defp part2(input) do
    hailstones = parse_input(input)

    x = hailstones |> Snap.map(&Vec3.x/1) |> axis_congruence()
    y = hailstones |> Snap.map(&Vec3.y/1) |> axis_congruence()
    z = hailstones |> Snap.map(&Vec3.z/1) |> axis_congruence()

    x + y + z
  end

  defp axis_congruence(axis_hailstones) do
    -@velocity_boundary..@velocity_boundary
    |> Stream.flat_map(fn rock_velocity ->
      axis_hailstones
      |> Enum.reject(&(Snap.velocity(&1) == rock_velocity))
      |> Enum.map(&(&1 |> Snap.position() |> Cong.new(Snap.velocity(&1) - rock_velocity)))
      |> Enum.reduce([], fn congruence, coprimes ->
        if Enum.all?(coprimes, &(&1 |> Cong.m() |> Integer.gcd(Cong.m(congruence)) == 1)) do
          [congruence | coprimes]
        else
          coprimes
        end
      end)
      |> :crt.chinese_remainder()
      |> case do
        :undefined ->
          []

        rock_position
        when rock_position < -@position_boundary or rock_position > @position_boundary ->
          []

        rock_position ->
          if Enum.all?(
               axis_hailstones,
               &will_collide?(&1, Snap.new(rock_position, rock_velocity))
             ) do
            [rock_position]
          else
            []
          end
      end
    end)
    |> Enum.at(0)
  end

  defp will_collide?(hailstone, rock) do
    maybe_null_delta_position = Snap.position(hailstone) - Snap.position(rock)
    maybe_null_delta_velocity = Snap.velocity(rock) - Snap.velocity(hailstone)

    case {maybe_null_delta_position, maybe_null_delta_velocity} do
      {0, 0} ->
        true

      {_, 0} ->
        false

      {delta_position, delta_velocity} ->
        time = delta_position / delta_velocity
        time > 0 and time == round(time)
    end
  end

  defp parse_input(input) do
    Enum.map(input, &parse_line/1)
  end

  defp parse_line(line) do
    line
    |> Utils.splitrim("@")
    |> Enum.map(&parse_vec3/1)
    |> List.to_tuple()
  end

  defp parse_vec3(string) do
    string
    |> Utils.splitrim(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def bench1() do
    Benchmark.mesure_milliseconds(fn -> part1(~i[2023/24]l) end)
  end

  def bench2() do
    Benchmark.mesure_milliseconds(fn -> part2(~i[2023/24]l) end)
  end
end

Y2023.D24.bench2()
