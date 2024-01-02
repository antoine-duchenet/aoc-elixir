defmodule Math do
  def lcm(a, b) do
    div(a * b, Integer.gcd(a, b))
  end

  def lcm(integers) do
    Enum.reduce(integers, 1, &lcm/2)
  end

  def permutations([]), do: [[]]

  def permutations(list) do
    for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])
  end
end
