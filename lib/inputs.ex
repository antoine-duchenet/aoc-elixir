defmodule Input do
  def stream(day) do
    "./inputs/#{day}.txt"
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  def list(day) do
    day
    |> stream()
    |> Enum.to_list()
  end

  def chunk(day) do
    day
    |> list()
    |> Enum.chunk_while(
      [],
      fn
        "", acc -> {:cont, acc, []}
        nonempty, acc -> {:cont, acc ++ [nonempty]}
      end,
      fn
        [] -> {:cont, []}
        acc -> {:cont, acc, []}
      end
    )
  end

  def whole(day) do
    day
    |> list()
    |> Enum.join("\n")
  end

  def grid(day) do
    day
    |> list()
    |> Enum.map(&Utils.splitrim(&1, ""))
  end

  def sigil_i(day, ~c"s"), do: stream(day)
  def sigil_i(day, ~c"l"), do: list(day)
  def sigil_i(day, ~c"w"), do: whole(day)
  def sigil_i(day, ~c"c"), do: chunk(day)
  def sigil_i(day, ~c"g"), do: grid(day)
end
