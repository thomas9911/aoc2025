file = "data/day08.txt"

distance = fn {x1, y1, z1}, {x2, y2, z2} ->
  (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) + (z1 - z2) * (z1 - z2)
end

parse = fn ->
  file
  |> File.stream!()
  |> Stream.map(& &1 |> String.trim() |> String.split(","))
  |> Stream.map(fn list -> Enum.map(list, &String.to_integer/1) end)
  |> Stream.map(&List.to_tuple/1)
end

a = fn ->
  data = parse.() |> Enum.to_list()

  [first | rest] = 0..(length(data)-1) |> Enum.map(fn i -> Enum.drop(data, i) end)

  points = first
  |> Enum.with_index()
  |> Enum.flat_map(fn {item, index} ->
    rest
    |> Enum.at(index, [])
    |> Enum.map(fn x -> {item, x, distance.(item, x)} end)
  end)
  |> Enum.sort_by(fn {_, _, distance} -> distance end)


  [{point_a, point_b, _} | rest] = points

  sets = rest
  |> Enum.take(10)
  |> IO.inspect()
  |> Enum.reduce([MapSet.new([point_a, point_b])], fn {new_point_a, new_point_b, _}, acc ->
    # cry in non mutability
    new_list = Enum.map(acc, fn set ->
      cond do
        MapSet.member?(set, new_point_a) -> MapSet.put(set, new_point_b) |> MapSet.put(:new_point)
        MapSet.member?(set, new_point_b) -> MapSet.put(set, new_point_a) |> MapSet.put(:new_point)
        true -> set
      end
    end )

    case Enum.split_with(new_list, &MapSet.member?(&1, :new_point)) do
      {[], sets} -> [MapSet.new([new_point_a, new_point_b]) | sets]
      {[added_set], other_sets} -> [MapSet.delete(added_set, :new_point) | other_sets]
      {new_super_set, other_sets} -> [Enum.reduce(new_super_set, &MapSet.union/2) | other_sets]
    end
  end)

  sets
  |> Enum.map(&MapSet.size/1)
  |> IO.inspect()
  |> Enum.product()
end

a.() |> IO.inspect()