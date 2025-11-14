defmodule Y2024.D25 do
  use Day, input: "2024/25", part1: ~c"c", part2: ~c"c"

  @height 7
  @width 5

  defp part1(input) do
    %{key: keys, lock: locks} =
      input
      |> Enum.map(&parse_chunk/1)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    for k <- keys, l <- locks do
      0..(@width - 1)
      |> Enum.all?(fn i -> Enum.at(k, i) + Enum.at(l, i) <= @height end)
      |> if do
        1
      else
        0
      end
    end
    |> Enum.sum()
  end

  defp part2(input) do
    input
  end

  defp parse_chunk(chunk) do
    chunk
    |> Enum.map(&Utils.splitrim/1)
    |> Matrix.to_rc_map()
    |> parse_lock_or_key()
  end

  defp parse_lock_or_key(lock_or_key) do
    type =
      case Map.get(lock_or_key, {0, 0}) do
        "." -> :key
        "#" -> :lock
      end

    repr =
      0..(@width - 1)
      |> Enum.map(fn c ->
        0..(@height - 1)
        |> Enum.map(fn r ->
          case Map.get(lock_or_key, {r, c}) do
            "#" -> 1
            "." -> 0
          end
        end)
        |> Enum.sum()
      end)

    {type, repr}
  end
end

Y2024.D25.bench1()
