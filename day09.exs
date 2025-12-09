file = "data/day09.txt"

parse = fn ->
  file
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.split(&1, ","))
  |> Stream.map(fn [x, y] -> {String.to_integer(x), String.to_integer(y)} end)
  |> Enum.to_list()
end

area = fn {x1, y1}, {x2, y2} ->
  (abs(x1 - x2)+1) * (abs(y1 - y2)+1)
end

a = fn ->
  data = parse.()

  [first | rest] = 0..(length(data) - 1) |> Enum.map(fn i -> Enum.drop(data, i) end)

  first
  |> Enum.with_index()
  |> Enum.flat_map(fn {item, index} ->
    rest
    |> Enum.at(index, [])
    |> Enum.map(fn x -> {item, x, area.(item, x)} end)
  end)
  |> Enum.sort_by(fn {_, _, area} -> area end, :desc)
  |> Enum.at(0)
  |> elem(2)

end

a.() |> IO.inspect()