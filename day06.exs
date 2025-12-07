file = "data/day06.txt"

parse_item = fn
  "*" -> &Enum.product/1
  "+" -> &Enum.sum/1
  x -> String.to_integer(x)
end

parse_a = fn ->
  data =
    file
    |> File.stream!()
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&parse_item.(&1))
    end)

  {lines, [operators]} = Enum.split(data, length(data) - 1)

  lookup = Map.new(0..(length(operators) - 1), fn i -> {i, []} end)

  dataset =
    Enum.reduce(lines, lookup, fn line, acc ->
      line
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {item, index}, acc ->
        Map.update!(acc, index, fn current -> [item | current] end)
      end)
    end)

  {dataset, operators}
end

parse_b = fn ->
  text = File.read!(file)

  raw_lines =
    text
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing(&1, "\r"))

  spaces_positions =
    Enum.map(raw_lines, fn line ->
      line |> :binary.matches(" ") |> Enum.map(&elem(&1, 0)) |> MapSet.new()
    end)
    |> Enum.reduce(fn pos, acc ->
      MapSet.intersection(pos, acc)
    end)
    |> Enum.sort()

  ranges =
    [-1 | spaces_positions]
    |> Enum.zip(spaces_positions ++ [byte_size(Enum.at(raw_lines, 0))])
    |> Enum.map(fn {x, y} -> Range.new(x + 1, y - 1) end)

  data =
    raw_lines
    |> Enum.map(fn line ->
      Enum.map(ranges, fn range -> String.slice(line, range) end)
    end)

  {lines, [operators]} = Enum.split(data, length(data) - 1)

  operators = Enum.map(operators, &parse_item.(String.trim(&1)))

  lookup = Map.new(0..(length(operators) - 1), fn i -> {i, []} end)

  dataset =
    Enum.reduce(lines, lookup, fn line, acc ->
      line
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {item, index}, acc ->
        splitted = item |> String.split("", trim: true) |> Enum.reverse()
        Map.update!(acc, index, fn current -> [splitted | current] end)
      end)
    end)

  dataset =
    dataset
    |> Map.new(fn {index, values} ->
      new_values =
        values
        |> Enum.reverse()
        |> Enum.zip()
        |> Enum.map(fn zipped ->
          zipped
          |> Tuple.to_list()
          |> Enum.join()
          |> String.trim()
          |> String.to_integer()
        end)

      {index, new_values}
    end)

  {dataset, operators}
end

calc = fn dataset, operators ->
  operators
  |> Enum.with_index()
  |> Enum.map(fn {op, index} ->
    op.(Map.fetch!(dataset, index))
  end)
  |> Enum.sum()
end

a = fn ->
  {dataset, operators} = parse_a.()

  calc.(dataset, operators)
end

b = fn ->
  {dataset, operators} = parse_b.()

  calc.(dataset, operators)
end

a.() |> IO.inspect()
b.() |> IO.inspect()
