defmodule Performance do
  def memoize(key, f) do
    with nil <- Process.get(key), do: tap(f.(), &Process.put(key, &1))
  end

  def once(key, otherwise, f) do
    with nil <- Process.get(key) do
      Process.put(key, true)
      f.()
    else
      _ -> otherwise
    end
  end
end
