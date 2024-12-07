defmodule Draw do
  defstruct green: 0, red: 0, blue: 0

  def from_string(draw_string) do
    draw_string
    |> Utils.splitrim(",")
    |> Enum.map(&Utils.splitrim(&1, " "))
    |> Map.new(fn [v, k] -> {String.to_existing_atom(k), String.to_integer(v)} end)
    |> from_map()
  end

  defp from_map(draw_map), do: struct(__MODULE__, draw_map)
end

defmodule Game do
  defstruct id: nil, draws: []

  def from_string(game_string) do
    ["Game " <> id_string, draws_part] = Utils.splitrim(game_string, ":")

    draws =
      draws_part
      |> Utils.splitrim(";")
      |> Enum.map(&Draw.from_string/1)

    %Game{
      id: String.to_integer(id_string),
      draws: draws
    }
  end

  def possible?(%Game{draws: draws}, %Draw{red: max_red, green: max_green, blue: max_blue}) do
    Enum.all?(draws, fn %Draw{green: green, red: red, blue: blue} ->
      green <= max_green and red <= max_red and blue <= max_blue
    end)
  end

  def power(%Game{draws: draws}) do
    greens = Enum.map(draws, & &1.green)
    reds = Enum.map(draws, & &1.red)
    blues = Enum.map(draws, & &1.blue)

    Enum.max(greens) * Enum.max(reds) * Enum.max(blues)
  end
end

defmodule Y2023.D02 do
  use Day, input: "2023/02", part1: ~c"s", part2: ~c"s"

  @max_draw %Draw{red: 12, green: 13, blue: 14}

  defp part1(input_stream) do
    input_stream
    |> Stream.map(&Game.from_string/1)
    |> Stream.filter(&Game.possible?(&1, @max_draw))
    |> Stream.map(& &1.id)
    |> Enum.sum()
  end

  defp part2(input_stream) do
    input_stream
    |> Stream.map(&Game.from_string/1)
    |> Stream.map(&Game.power/1)
    |> Enum.sum()
  end
end

Y2023.D02.bench2()
