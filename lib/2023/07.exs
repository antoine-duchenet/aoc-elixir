import Input

defmodule Y2023.D7 do
  @kinds1 Utils.splitrim("23456789TJQKA", "")
  @kinds2 Utils.splitrim("J23456789TQKA", "")

  def part1(input_stream) do
    input_stream
    |> parse_hands()
    |> Stream.map(fn hand -> with_strength(hand, &classifier1/1, @kinds1) end)
    |> rank()
    |> score()
    |> dbg
  end

  def part2(input_stream) do
    input_stream
    |> parse_hands()
    |> Stream.map(fn hand -> with_strength(hand, &classifier2/1, @kinds2) end)
    |> rank()
    |> score()
    |> dbg
  end

  defp with_strength({hand, bid}, classifier, kinds) do
    base = Enum.count(kinds)

    type_strength =
      hand
      |> then(classifier)
      |> Kernel.*(base ** Enum.count(hand))

    cards_strength =
      hand
      |> Enum.map(fn card -> Enum.find_index(kinds, &(&1 == card)) end)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(&(elem(&1, 0) * base ** elem(&1, 1)))
      |> Enum.sum()

    {hand, bid, type_strength + cards_strength}
  end

  defp classifier1(hand) do
    hand
    |> Enum.group_by(& &1)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sort_by(&Enum.count(&1), :desc)
    |> case do
      [[_], [_], [_], [_], [_]] -> 0
      [[_, _], [_], [_], [_]] -> 1
      [[_, _], [_, _], [_]] -> 2
      [[_, _, _], [_], [_]] -> 3
      [[_, _, _], [_, _]] -> 4
      [[_, _, _, _], [_]] -> 5
      [[_, _, _, _, _]] -> 6
    end
  end

  defp classifier2(hand) do
    no_jokers = Enum.filter(hand, &(&1 != "J"))

    grouped =
      no_jokers
      |> Enum.group_by(& &1)
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort_by(&Enum.count(&1), :desc)

    jokers_count = Enum.count(hand) - Enum.count(no_jokers)

    type =
      case {grouped, jokers_count} do
        {[[_], [_], [_], [_], [_]], 0} -> 0
        {[[_, _], [_], [_], [_]], 0} -> 1
        {[[_, _], [_, _], [_]], 0} -> 2
        {[[_, _, _], [_], [_]], 0} -> 3
        {[[_, _, _], [_, _]], 0} -> 4
        {[[_, _, _, _], [_]], 0} -> 5
        {[[_, _, _, _, _]], 0} -> 6
        {[[_], [_], [_], [_]], 1} -> 1
        {[[_, _], [_], [_]], 1} -> 3
        {[[_, _], [_, _]], 1} -> 4
        {[[_, _, _], [_]], 1} -> 5
        {[[_, _, _, _]], 1} -> 6
        {[[_], [_], [_]], 2} -> 3
        {[[_, _], [_]], 2} -> 5
        {[[_, _, _]], 2} -> 6
        {[[_], [_]], 3} -> 5
        {[[_, _]], 3} -> 6
        {[[_]], 4} -> 6
        {[], 5} -> 6
      end
  end

  defp parse_hands(stream) do
    stream
    |> Stream.map(&Utils.splitrim(&1, " "))
    |> Stream.map(fn [hand, bid] -> {Utils.splitrim(hand, ""), String.to_integer(bid)} end)
  end

  defp rank(hands_with_strength) do
    hands_with_strength
    |> Enum.sort_by(&elem(&1, 2), :asc)
    |> Enum.with_index()
  end

  defp score(hands_with_rank) do
    hands_with_rank
    |> Enum.map(fn {{_, bid, _}, index} -> bid * (index + 1) end)
    |> Enum.sum()
  end
end

~i[2023/07]s
|> Y2023.D7.part2()
