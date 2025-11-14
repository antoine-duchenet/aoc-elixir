defmodule Y2024.D05 do
  use Day, input: "2024/05", part1: ~c"c", part2: ~c"c"

  defp part1(input) do
    {rules, updates} = parse_input(input)

    updates
    |> Enum.reject(&invalid?(&1, rules))
    |> Enum.map(&Enum.at(&1, div(Enum.count(&1), 2)))
    |> Enum.sum()
  end

  defp part2(input) do
    {rules, updates} = parse_input(input)

    updates
    |> Enum.map(&to_map/1)
    |> Enum.filter(&invalid?(&1, rules))
    |> Enum.map(&reorder(&1, rules))
    |> Enum.map(&to_list/1)
    |> Enum.map(&Enum.at(&1, div(Enum.count(&1), 2)))
    |> Enum.sum()
  end

  defp invalid?(update, rule_or_rules), do: not valid?(update, rule_or_rules)

  defp valid?(update, {f, s}) when is_list(update) do
    valid?({Enum.find_index(update, &(&1 == f)), Enum.find_index(update, &(&1 == s))})
  end

  defp valid?(update, {f, s}) when is_map(update) do
    valid?({Map.get(update, f), Map.get(update, s)})
  end

  defp valid?(update, rules), do: Enum.all?(rules, &valid?(update, &1))

  defp valid?({nil, _}), do: true
  defp valid?({_, nil}), do: true
  defp valid?({fi, si}), do: fi < si

  defp to_map(update) do
    update
    |> Enum.with_index()
    |> Enum.into(%{})
  end

  defp to_list(update) do
    update
    |> Map.to_list()
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
  end

  defp reorder(update, rules) when is_list(update) do
    {f, s} = Enum.find(rules, &invalid?(update, &1))
    {fi, si} = {Enum.find_index(update, &(&1 == f)), Enum.find_index(update, &(&1 == s))}

    modified =
      update
      |> List.replace_at(fi, s)
      |> List.replace_at(si, f)

    if valid?(modified, rules), do: modified, else: reorder(modified, rules)
  end

  defp reorder(update, rules) when is_map(update) do
    {f, s} = Enum.find(rules, &invalid?(update, &1))
    {fi, si} = {Map.get(update, f), Map.get(update, s)}

    modified =
      update
      |> Map.replace(s, fi)
      |> Map.replace(f, si)

    if valid?(modified, rules), do: modified, else: reorder(modified, rules)
  end

  defp parse_input(input) do
    [rules_chunk, updates_chunk] = input
    {parse_rules(rules_chunk), parse_updates(updates_chunk)}
  end

  defp parse_rules(rules), do: Enum.map(rules, &parse_rule/1)
  defp parse_updates(updates), do: Enum.map(updates, &parse_update/1)

  defp parse_rule(<<f::bytes-size(2), "|", s::bytes-size(2)>>), do: {parse_page(f), parse_page(s)}

  defp parse_update(update) do
    update
    |> Utils.splitrim(",")
    |> Enum.map(&parse_page/1)
  end

  defp parse_page(page), do: String.to_integer(page)
end

Y2024.D05.bench2()
