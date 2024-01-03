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

  def sigil_i(day, ~c"s") do
    stream(day)
  end

  def sigil_i(day, ~c"l") do
    list(day)
  end

  def sigil_i(day, ~c"w") do
    whole(day)
  end

  def sigil_i(day, ~c"c") do
    chunk(day)
  end
end
