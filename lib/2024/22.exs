defmodule Y2024.D22 do
  use Day, input: "2024/22", part1: ~c"l", part2: ~c"l"

  defp part1(input) do
    input
    |> parse_input()
    |> Enum.map(&generation(&1, 2000))
    |> Enum.sum()
  end

  defp part2(input) do
    buyers_roots = parse_input(input)
    buyers_numbers = Enum.map(buyers_roots, &buyer_numbers/1)
    buyers_prices = Enum.map(buyers_numbers, &buyer_prices/1)
    buyers_changes = Enum.map(buyers_prices, &buyer_changes/1)

    # [[-2, 1, -1, 3]]
    changes_sequences(buyers_changes)
    |> Task.async_stream(&bananas(&1, buyers_prices, buyers_changes))
    |> Enum.max()
    |> elem(1)
  end

  # defp changes_sequences() do
  #   range = -9..9

  #   for a <- range, b <- range, c <- range, d <- range, a + b + c + d > -9, a + b + c + d <= 9 do
  #     [a, b, c, d]
  #   end
  # end

  defp changes_sequences(buyers_changes) do
    buyers_changes
    |> Enum.flat_map(&Enum.chunk_every(&1, 4, 1, :discard))
    |> Enum.uniq()
    |> Enum.reject(&(Enum.sum(&1) <= 0))
  end

  defp bananas(changes_sequence, buyers_prices, buyers_changes) do
    pattern_indices = Enum.map(buyers_changes, &pattern_index(&1, changes_sequence))

    buyers_prices
    |> Enum.zip(pattern_indices)
    |> Enum.map(fn
      {_, nil} -> 0
      {prices, pattern_index} -> Enum.at(prices, pattern_index)
    end)
    |> Enum.sum()
  end

  defp pattern_index(list, pattern, index \\ 0)
  defp pattern_index([], [], _), do: 0
  defp pattern_index([], _, _), do: nil

  defp pattern_index([_ | tail] = list, pattern, index) do
    if List.starts_with?(list, pattern) do
      index + Enum.count(pattern)
    else
      pattern_index(tail, pattern, index + 1)
    end
  end

  defp buyer_changes(buyer_prices) do
    buyer_prices
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [from, to] -> to - from end)
  end

  defp buyer_prices(buyer_numbers) do
    Enum.map(buyer_numbers, fn number ->
      number
      |> Integer.digits()
      |> Enum.take(-1)
      |> Integer.undigits()
    end)
  end

  defp buyer_numbers(buyer_root) do
    [buyer_root | Enum.scan(1..2000, buyer_root, fn _, sn -> next_generation(sn) end)]
  end

  defp generation(secret_number, 0), do: secret_number

  defp generation(secret_number, gen) do
    secret_number
    |> generation(gen - 1)
    |> next_generation()
  end

  defp next_generation(secret_number) do
    secret_number =
      secret_number
      |> Kernel.*(64)
      |> mix(secret_number)
      |> prune()

    secret_number =
      secret_number
      |> Kernel.div(32)
      |> mix(secret_number)
      |> prune()

    secret_number
    |> Kernel.*(2048)
    |> mix(secret_number)
    |> prune()
  end

  defp mix(n, secret_number) do
    Bitwise.bxor(n, secret_number)
  end

  defp prune(n), do: rem(n, 16_777_216)

  defp parse_input(input), do: Enum.map(input, &String.to_integer/1)
end

Y2024.D22.bench2()
