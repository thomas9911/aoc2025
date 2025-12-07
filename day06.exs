file = "data/day06.txt"

parse_item = fn
  "*" -> &Enum.product/1
  "+" -> &Enum.sum/1
  # "" -> nil
  # x -> String.to_integer(x)
  x -> x
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

  dataset = Enum.reduce(lines, lookup, fn line, acc ->
    line
    |> Enum.with_index()
    |> Enum.reduce(acc, fn {item, index}, acc ->
      Map.update!(acc, index, fn current -> [item | current] end)
    end)
  end)

  # might need to reverse the order in the list

  {dataset, operators}
end

parse_b = fn ->
    data =
    file
    |> File.stream!()
    |> Enum.map(fn line ->
      line
      |> String.trim_trailing("\n")

      |> Enum.map(&parse_item.(&1))
    end)

  {lines, [operators]} = Enum.split(data, length(data) - 1)

  lookup = Map.new(0..(length(operators) - 1), fn i -> {i, []} end)

  dataset = Enum.reduce(lines, lookup, fn line, acc ->
    line
    |> Enum.with_index()
    |> Enum.reduce(acc, fn {item, index}, acc ->
      IO.inspect(item)
      splitted = item |> String.split("") |> Enum.reverse()
      Map.update!(acc, index, fn current -> [splitted | current] end)
    end)
  end)

  dataset
  |> Map.new(fn {index, values} ->
    max_length = Enum.max(Enum.map(values, &length/1))
    new_values = Enum.reverse(values)

    0..(max_length-1)
    |> Enum.map(fn index ->
      new_values
    |> IO.inspect(charlists: :as_lists)

       |> Enum.flat_map(fn value ->
        case Enum.at(value, index) do
          nil -> []
          something -> [something]
        end
      end)
      |> Integer.undigits()
    end)
    |> IO.inspect()

    {index, values}
  end)

  # {dataset, operators}
end

a = fn ->
  {dataset, operators} = parse_a.()

  operators
  |> Enum.with_index()
  |> Enum.map(fn {op, index} ->
      op.(Map.fetch!(dataset, index))
  end)
  |> Enum.sum()
end

b = fn ->
  parse_b.()
end

a.() |> IO.inspect()
# b.() |> IO.inspect()
