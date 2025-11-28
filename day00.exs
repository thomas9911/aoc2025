# day1 from 2024

file = "data/day00.txt"

parse_lines = fn ->
  file
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.split/1)
  |> Stream.map(fn [left, right] ->
    [left, right]
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end)
  |> Enum.unzip()
end

a = fn ->
  {left, right} = parse_lines.()

  left
  |> Enum.sort()
  |> Enum.zip(Enum.sort(right))
  |> Enum.map(fn {left, right} -> abs(left - right) end)
  |> Enum.sum()
end

b = fn ->
  {left, right} = parse_lines.()

  counts =
    right
    |> Enum.group_by(& &1)
    |> Map.new(fn {key, value} -> {key, Enum.count(value)} end)

  left
  |> Enum.map(&(&1 * Map.get(counts, &1, 0)))
  |> Enum.sum()
end

a.() |> IO.inspect()
b.() |> IO.inspect()
