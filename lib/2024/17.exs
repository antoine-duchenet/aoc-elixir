defmodule Y2024.D17 do
  use Day, input: "2024/17", part1: ~c"c", part2: ~c"c"

  @bits 3
  @mod 2 ** @bits

  # Because of the static A = A / 2^3 (truncated)
  @iteration_factor 2 ** 3

  defp part1(input) do
    {registers, program} = parse_input(input)

    %{
      rest: program,
      whole: program,
      registers: registers,
      output: []
    }
    |> run()
    |> Map.get(:output)
    |> Enum.join(",")
  end

  defp part2(input) do
    {registers, program} = parse_input(input)

    program
    |> Enum.count()
    |> backtrack(registers, program)
    |> Enum.min()
  end

  defp run(%{rest: []} = state), do: state
  defp run(%{rest: [_]} = state), do: state

  defp run(%{rest: [op, operand | rest]} = state) do
    state
    |> Map.replace!(:rest, rest)
    |> opcode(op, operand)
    |> run()
  end

  defp backtrack(0, _, _), do: [0]

  defp backtrack(size, registers, program) do
    size
    |> Kernel.-(1)
    |> backtrack(registers, program)
    |> Enum.flat_map(&untrunc(&1, @iteration_factor))
    |> Enum.uniq()
    |> Enum.filter(fn a ->
      %{output: output} =
        run(%{
          rest: program,
          whole: program,
          registers: %{registers | a: a},
          output: []
        })

      output == Enum.take(program, -size)
    end)
  end

  defp untrunc(n, factor), do: Range.new(n * factor, (n + 1) * factor - 1)

  defp opcode(state, 0, operand), do: adv(state, operand)
  defp opcode(state, 1, operand), do: bxl(state, operand)
  defp opcode(state, 2, operand), do: bst(state, operand)
  defp opcode(state, 3, operand), do: jnz(state, operand)
  defp opcode(state, 4, operand), do: bxc(state, operand)
  defp opcode(state, 5, operand), do: out(state, operand)
  defp opcode(state, 6, operand), do: bdv(state, operand)
  defp opcode(state, 7, operand), do: cdv(state, operand)

  defp adv(state, operand) do
    Map.update!(
      state,
      :registers,
      fn %{a: a} = registers -> %{registers | a: trunc(a / 2 ** combo(operand, registers))} end
    )
  end

  defp bxl(state, operand) do
    Map.update!(
      state,
      :registers,
      fn %{b: b} = registers -> %{registers | b: Bitwise.bxor(b, literal(operand))} end
    )
  end

  defp bst(state, operand) do
    Map.update!(
      state,
      :registers,
      &Map.replace!(&1, :b, rem(combo(operand, &1), @mod))
    )
  end

  defp jnz(%{registers: %{a: 0}} = state, _), do: state

  defp jnz(%{whole: whole} = state, operand) do
    Map.replace!(
      state,
      :rest,
      Enum.drop(whole, literal(operand))
    )
  end

  defp bxc(state, _) do
    Map.update!(
      state,
      :registers,
      fn %{b: b, c: c} = registers -> %{registers | b: Bitwise.bxor(b, c)} end
    )
  end

  defp out(%{registers: registers} = state, operand) do
    Map.update!(
      state,
      :output,
      fn output -> output ++ [rem(combo(operand, registers), @mod)] end
    )
  end

  defp bdv(state, operand) do
    Map.update!(
      state,
      :registers,
      fn %{a: a} = registers -> %{registers | b: trunc(a / 2 ** combo(operand, registers))} end
    )
  end

  defp cdv(state, operand) do
    Map.update!(
      state,
      :registers,
      fn %{a: a} = registers -> %{registers | c: trunc(a / 2 ** combo(operand, registers))} end
    )
  end

  defp literal(n), do: n

  defp combo(4, %{a: a}), do: a
  defp combo(5, %{b: b}), do: b
  defp combo(6, %{c: c}), do: c
  defp combo(n, _), do: literal(n)

  defp parse_input([registers_chuck, program_chunk]) do
    {parse_registers(registers_chuck), parse_program(program_chunk)}
  end

  defp parse_registers(registers_chunk) do
    [a, b, c] = Enum.map(registers_chunk, &parse_register/1)

    %{a: a, b: b, c: c}
  end

  defp parse_program([program_line]) do
    program_line
    |> Utils.splitrim(":")
    |> Enum.at(1)
    |> Utils.splitrim(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_register(register_line) do
    register_line
    |> Utils.splitrim(":")
    |> Enum.at(1)
    |> String.to_integer()
  end
end

Y2024.D17.bench2()
