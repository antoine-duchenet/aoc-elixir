defmodule Y2025.D08 do
  use Day, input: "2025/08", part1: ~c"l", part2: ~c"l"

  @n_pairs 1000

  defp part1(input) do
    boxes = parse_input(input)
    circuits = Map.new(boxes, &{&1, nil})

    boxes
    |> dists()
    |> Enum.reduce_while({circuits, @n_pairs}, &connect_n/2)
    |> Enum.reject(fn {_, circuit} -> circuit == nil end)
    |> Enum.group_by(fn {_, circuit} -> circuit end)
    |> Map.values()
    |> Enum.map(&Enum.count/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(&Kernel.*/2)
  end

  defp part2(input) do
    boxes = parse_input(input)
    circuits = Map.new(boxes, &{&1, nil})

    boxes
    |> dists()
    |> Enum.reduce_while({circuits, nil}, &connect_all/2)
    |> then(fn {{x1, _, _}, {x2, _, _}} -> x1 * x2 end)
  end

  defp dists(boxes) do
    for(
      i1 <- 0..(Enum.count(boxes) - 1),
      i2 <- 0..(Enum.count(boxes) - 1),
      i1 < i2,
      do: {Enum.at(boxes, i1), Enum.at(boxes, i2)}
    )
    |> Enum.sort_by(fn {box1, box2} -> dist(box1, box2) end)
  end

  defp dist({x1, y1, z1}, {x2, y2, z2}) do
    (x2 - x1)
    |> Math.pow(2)
    |> Kernel.+(Math.pow(y2 - y1, 2))
    |> Kernel.+(Math.pow(z2 - z1, 2))
    |> Math.sqrt()
  end

  defp connect_n(_, {circuits, 0}), do: halt(circuits)

  defp connect_n({box1, box2}, {circuits, n}) do
    {Map.get(circuits, box1), Map.get(circuits, box2)}
    |> case do
      {nil, nil} -> circuits |> Map.put(box1, box1) |> Map.put(box2, box1)
      {circuit1, nil} -> Map.put(circuits, box2, circuit1)
      {nil, circuit2} -> Map.put(circuits, box1, circuit2)
      {circuit1, circuit1} -> circuits
      {circuit1, circuit2} -> merge(circuits, circuit1, circuit2)
    end
    |> cont(n - 1)
  end

  defp connect_all({box1, box2} = pair, {circuits, last}) do
    [cid | tail] = circuits |> Map.values() |> Enum.uniq()

    if cid != nil and tail == [] do
      halt(last)
    else
      {Map.get(circuits, box1), Map.get(circuits, box2)}
      |> case do
        {nil, nil} -> circuits |> Map.put(box1, box1) |> Map.put(box2, box1)
        {circuit1, nil} -> Map.put(circuits, box2, circuit1)
        {nil, circuit2} -> Map.put(circuits, box1, circuit2)
        {circuit1, circuit1} -> circuits
        {circuit1, circuit2} -> merge(circuits, circuit1, circuit2)
      end
      |> cont(pair)
    end
  end

  defp cont(circuits, other), do: {:cont, {circuits, other}}
  defp halt(result), do: {:halt, result}

  defp merge(circuits, circuit1, circuit2) do
    circuits
    |> Enum.map(fn
      {box, ^circuit2} -> {box, circuit1}
      other -> other
    end)
    |> Map.new()
  end

  def parse_input(input) do
    input
    |> Enum.map(&Utils.splitrim(&1, ","))
    |> Enum.map(&Enum.map(&1, fn coord -> String.to_integer(coord) end))
    |> Enum.map(&List.to_tuple/1)
  end
end

Y2025.D08.bench2()
