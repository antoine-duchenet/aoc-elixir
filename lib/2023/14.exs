defmodule Y2023.D14 do
  use Day, input: "2023/14", part1: ~c"l", part2: ~c"l"

  def part1(input) do
    input
    |> parse_input()
    |> tilt()
    |> roll()
    |> Enum.map(fn col ->
      length = Enum.count(col)

      col
      |> Enum.with_index()
      |> Enum.map(fn
        {"O", i} -> length - i
        {_, _} -> 0
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    platform =
      parse_input(input)

    {w, h} = {Enum.count(platform), platform |> Enum.at(0) |> Enum.count()}

    1..(w * h)
    |> Enum.reduce(platform, fn _, p ->
      Performance.memoize({:cycle, p}, fn ->
        # east
        p
        |> tilt()
        |> roll()
        # north
        |> tilt()
        |> roll()
        # west
        |> tilt()
        |> roll()
        # south
        |> tilt()
        |> roll()

        # east again
      end)
    end)
    |> tilt()
    |> Enum.map(fn col ->
      length = Enum.count(col)

      col
      |> Enum.with_index()
      |> Enum.map(fn
        {"O", i} -> length - i
        {_, _} -> 0
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  defp tilt(platform) do
    Performance.memoize({:tilt, platform}, fn ->
      platform
      |> Matrix.transpose()
      |> Enum.map(&Enum.reverse/1)
      |> Matrix.transpose()
      |> Enum.map(&Enum.reverse/1)
      |> Matrix.transpose()
      |> Enum.map(&Enum.reverse/1)
    end)
  end

  defp roll(platform) do
    platform
    |> Enum.map(fn col ->
      Performance.memoize({:roll, col}, fn ->
        col
        |> then(&(&1 |> Enum.join("") |> String.split("#", trim: false)))
        |> then(fn sections -> Enum.map(sections, &sort_string(&1, :desc)) end)
        |> then(&(&1 |> Enum.join("#") |> Utils.splitrim("")))
      end)
    end)
  end

  defp sort_string(string, order) do
    Performance.memoize({:sort, string, order}, fn ->
      string
      |> Utils.splitrim("")
      |> Enum.sort(order)
      |> Enum.join("")
    end)
  end

  defp parse_input(input) do
    input
    |> Enum.map(&Utils.splitrim(&1, ""))
    |> Enum.map(&Enum.reverse/1)

    # oriented east
  end
end

Y2023.D14.bench2()
