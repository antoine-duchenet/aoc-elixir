import Input

defmodule Y2023.D19 do
  def part1(input) do
    {map, parts} = parse_input(input)

    parts
    |> Enum.map(&walk(map, "in", &1))
    |> Enum.zip(parts)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  defp walk(map, wf_name, part) do
    conds = Map.fetch!(map, wf_name)

    conds
    |> Enum.find(fn
      {field, ">", thresh, _} ->
        part
        |> Map.fetch!(field)
        |> Kernel.>(thresh)

      {field, "<", thresh, _} ->
        part
        |> Map.fetch!(field)
        |> Kernel.<(thresh)

      _ ->
        true
    end)
    |> then(fn
      {_, _, _, res} -> res
      default -> default
    end)
    |> case do
      "A" -> "A"
      "R" -> "R"
      new_wf_name -> walk(map, new_wf_name, part)
    end
  end

  defp score({"R", _}), do: 0
  defp score({"A", %{"x" => x, "m" => m, "a" => a, "s" => s}}), do: x + m + a + s

  def part2(input) do
    {map, _} = parse_input(input)

    combs(map, Map.fetch!(map, "in"), %{
      "x" => {1, 4001},
      "m" => {1, 4001},
      "a" => {1, 4001},
      "s" => {1, 4001}
    })
  end

  defp combs(map, [{field, op, thresh, res} | tail], threshs) do
    {new_thresh, rev_thresh} = split_treshs(threshs, field, op, thresh)
    combs(map, res, new_thresh) + combs(map, tail, rev_thresh)
  end

  defp combs(map, [key], threshs), do: combs(map, key, threshs)

  defp combs(_, "A", threshs) do
    threshs
    |> Enum.map(fn {_, {min, max}} -> max - min end)
    |> Enum.map(&max(&1, 0))
    |> Enum.reduce(1, &(&1 * &2))
  end

  defp combs(_, "R", _), do: 0
  defp combs(map, key, threshs), do: combs(map, Map.fetch!(map, key), threshs)

  defp split_treshs(threshs, field, "<", thresh) do
    new_threshs =
      Map.update!(threshs, field, fn {min, max} ->
        {min, min(max, thresh)}
      end)

    rev_threshs =
      Map.update!(threshs, field, fn {min, max} ->
        {max(min, thresh), max}
      end)

    {new_threshs, rev_threshs}
  end

  defp split_treshs(threshs, field, ">", thresh) do
    new_threshs =
      Map.update!(threshs, field, fn {min, max} ->
        {max(min, thresh + 1), max}
      end)

    rev_threshs =
      Map.update!(threshs, field, fn {min, max} ->
        {min, min(max, thresh + 1)}
      end)

    {new_threshs, rev_threshs}
  end

  defp parse_input([workflows, parts]) do
    {
      workflows |> Enum.map(&parse_workflow/1) |> Map.new(),
      Enum.map(parts, &parse_part/1)
    }
  end

  defp parse_workflow(input) do
    input
    |> Utils.splitrim(~r/[{},]/)
    |> Enum.map(&Utils.splitrim(&1, ":"))
    |> Enum.map(fn
      [solo] ->
        solo

      [<<field::bytes-size(1), op::bytes-size(1), thresh::binary>>, res] ->
        {field, op, String.to_integer(thresh), res}
    end)
    |> then(fn [name | conds] -> {name, conds} end)
  end

  defp parse_part(input) do
    input
    |> Utils.splitrim(~r/[{},]/)
    |> Enum.map(&Utils.splitrim(&1, "="))
    |> Enum.map(fn [field, value] -> {field, String.to_integer(value)} end)
    |> Map.new()
  end

  def run() do
    part2(~i[2023/19]c)
  end

  def bench() do
    Benchmark.mesure_milliseconds(&run/0)
  end
end

Y2023.D19.bench()
