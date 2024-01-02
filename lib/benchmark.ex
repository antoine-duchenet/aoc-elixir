defmodule Benchmark do
  def mesure_milliseconds(f, {display, return} \\ {true, false}) do
    f
    |> :timer.tc()
    |> then(&{elem(&1, 1), elem(&1, 0) / 1_000})
    |> then(fn {original, _} = with_milliseconds ->
      case {display, return} do
        {true, true} ->
          dbg(with_milliseconds)

        {true, false} ->
          dbg(with_milliseconds)
          original

        {false, true} ->
          with_milliseconds

        {false, false} ->
          original
      end
    end)
  end

  def mesure_seconds(f, {display, return} \\ {true, false}) do
    f
    |> :timer.tc()
    |> then(&{elem(&1, 1), elem(&1, 0) / 1_000_000})
    |> then(fn {original, _} = with_seconds ->
      case {display, return} do
        {true, true} ->
          dbg(with_seconds)

        {true, false} ->
          dbg(with_seconds)
          original

        {false, true} ->
          with_seconds

        {false, false} ->
          original
      end
    end)
  end
end
