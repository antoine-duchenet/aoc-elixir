defmodule Distance do
  def manhattan({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end
end
