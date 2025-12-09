defmodule EnumExt do
  def chunk_on(enum, delimiter) do
    Enum.chunk_while(
      enum,
      [],
      fn
        ^delimiter, acc -> {:cont, acc, []}
        nonempty, acc -> {:cont, acc ++ [nonempty]}
      end,
      fn
        [] -> {:cont, []}
        acc -> {:cont, acc, []}
      end
    )
  end
end
