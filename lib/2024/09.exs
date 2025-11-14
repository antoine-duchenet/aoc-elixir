defmodule Y2024.D09 do
  use Day, input: "2024/09", part1: ~c"w", part2: ~c"w"

  defp part1(input) do
    input
    |> parse_input()
    |> to_indexed_blocks()
    |> Map.new(fn {block, block_index} -> {block_index, block} end)
    |> compact1()
    |> checksum()
  end

  defp part2(input) do
    chunks_list =
      input
      |> parse_input()
      |> to_indexed_blocks()
      |> Enum.chunk_by(&elem(&1, 0))
      |> Enum.map(fn [{b, fbi} | _] = c -> {b, fbi, Enum.count(c)} end)

    files_list =
      chunks_list
      |> Enum.map(&{elem(&1, 0), elem(&1, 1), elem(&1, 2)})
      |> Enum.reject(&(elem(&1, 0) == :free))
      |> Enum.sort_by(&elem(&1, 0), :desc)

    chunks_map = Map.new(chunks_list, &{elem(&1, 1), {elem(&1, 0), elem(&1, 2)}})

    files_list
    |> Enum.reduce(chunks_map, fn {file_id, first_file_block_index, file_blocks_count}, map ->
      map
      |> Enum.filter(fn {_, {b, c}} -> b == :free and c >= file_blocks_count end)
      |> Enum.sort_by(&elem(&1, 0))
      |> List.first()
      |> case do
        nil ->
          map

        {first_free_block_index, {_, _}} when first_free_block_index > first_file_block_index ->
          map

        {first_free_block_index, {_, free_blocks_count}} ->
          map
          |> Map.put(first_free_block_index, {file_id, file_blocks_count})
          |> Map.put_new(
            first_free_block_index + file_blocks_count,
            {:free, free_blocks_count - file_blocks_count}
          )
          |> Map.put(first_file_block_index, {:free, file_blocks_count})
      end
    end)
    |> Enum.flat_map(fn
      {first_block_index, {block_content, blocks_count}} ->
        for i <- 0..(blocks_count - 1) do
          {first_block_index + i, block_content}
        end
    end)
    |> checksum()
  end

  defp compact1(map) do
    %{true: frees, false: files} = Enum.group_by(map, &(elem(&1, 1) == :free))

    asc_frees = Enum.sort_by(frees, &elem(&1, 0), :asc)
    desc_files = Enum.sort_by(files, &elem(&1, 0), :desc)

    [asc_frees, desc_files]
    |> Enum.zip()
    |> Enum.reduce(map, fn
      {{free_block_index, :free}, {file_block_index, _}}, acc
      when free_block_index > file_block_index ->
        acc

      {{free_block_index, :free}, {file_block_index, file_id}}, acc ->
        acc
        |> Map.replace(file_block_index, :free)
        |> Map.replace(free_block_index, file_id)
    end)
  end

  defp checksum(blocks_list) do
    blocks_list
    |> Enum.map(fn
      {_, :free} -> 0
      {file_block_index, file_id} -> file_block_index * file_id
    end)
    |> Enum.sum()
  end

  defp to_indexed_blocks(disk) do
    disk
    |> Enum.chunk_every(2)
    |> Enum.with_index()
    |> Enum.reduce([], fn
      {[file_size, free_size], file_id}, acc ->
        Enum.concat([acc, List.duplicate(file_id, file_size), List.duplicate(:free, free_size)])

      {[file_size], file_id}, acc ->
        Enum.concat([acc, List.duplicate(file_id, file_size)])
    end)
    |> Enum.with_index()
  end

  defp parse_input(input) do
    input
    |> Utils.splitrim("")
    |> Enum.map(&String.to_integer/1)
  end
end

Y2024.D09.bench2()
