file = "data/day08.txt"

distance = fn {x1, y1, z1}, {x2, y2, z2} ->
  (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) + (z1 - z2) * (z1 - z2)
end

parse = fn ->
  file
  |> File.stream!()
  |> Stream.map(&(&1 |> String.trim() |> String.split(",")))
  |> Stream.map(fn list -> Enum.map(list, &String.to_integer/1) end)
  |> Stream.map(&List.to_tuple/1)
end

a = fn ->
  data = parse.() |> Enum.to_list()

  [first | rest] = 0..(length(data) - 1) |> Enum.map(fn i -> Enum.drop(data, i) end)

  points =
    first
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, index} ->
      rest
      |> Enum.at(index, [])
      |> Enum.map(fn x -> {item, x, distance.(item, x)} end)
    end)
    |> Enum.sort_by(fn {_, _, distance} -> distance end)

  sets =
    points
    |> Enum.take(1000)
    |> Enum.reduce([], fn {new_point_a, new_point_b, _}, acc ->
      # cry in non mutability
      new_list =
        Enum.map(acc, fn set ->
          cond do
            MapSet.member?(set, new_point_a) ->
              MapSet.put(set, new_point_b) |> MapSet.put(:new_point)

            MapSet.member?(set, new_point_b) ->
              MapSet.put(set, new_point_a) |> MapSet.put(:new_point)

            true ->
              set
          end
        end)

      case Enum.split_with(new_list, &MapSet.member?(&1, :new_point)) do
        {[], sets} ->
          [MapSet.new([new_point_a, new_point_b]) | sets]

        {[added_set], other_sets} ->
          [MapSet.delete(added_set, :new_point) | other_sets]

        {new_super_set, other_sets} ->
          [
            new_super_set
            |> Enum.map(&MapSet.delete(&1, :new_point))
            |> Enum.reduce(&MapSet.union/2)
            | other_sets
          ]
      end
    end)

  sets
  |> Enum.map(&MapSet.size/1)
  |> Enum.sort(:desc)
  |> Enum.take(3)
  |> Enum.product()
end

b = fn ->
  data = parse.() |> Enum.to_list()

  [first | rest] = 0..(length(data) - 1) |> Enum.map(fn i -> Enum.drop(data, i) end)

  points =
    first
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, index} ->
      rest
      |> Enum.at(index, [])
      |> Enum.map(fn x -> {item, x, distance.(item, x)} end)
    end)
    |> Enum.sort_by(fn {_, _, distance} -> distance end)

  # [{point_a, point_b, _} | rest] = points

  {sets, last_points} =
    points
    |> Enum.reduce_while({[], {{0, 0, 0}, {0, 0, 0}}}, fn {new_point_a, new_point_b, _},
                                                          {acc, last_points} ->
      case {acc, MapSet.size(Enum.at(acc, 0, MapSet.new()))} do
        {[_], size} when size == 1000 ->
          {:halt, {acc, last_points}}

        _ ->
          # cry in non mutability
          new_list =
            Enum.map(acc, fn set ->
              cond do
                MapSet.member?(set, new_point_a) ->
                  MapSet.put(set, new_point_b) |> MapSet.put(:new_point)

                MapSet.member?(set, new_point_b) ->
                  MapSet.put(set, new_point_a) |> MapSet.put(:new_point)

                true ->
                  set
              end
            end)

          {:cont,
           case Enum.split_with(new_list, &MapSet.member?(&1, :new_point)) do
             {[], sets} ->
               {[MapSet.new([new_point_a, new_point_b]) | sets], {new_point_a, new_point_b}}

             {[added_set], other_sets} ->
               {[MapSet.delete(added_set, :new_point) | other_sets], {new_point_a, new_point_b}}

             {new_super_set, other_sets} ->
               {[
                  new_super_set
                  |> Enum.map(&MapSet.delete(&1, :new_point))
                  |> Enum.reduce(&MapSet.union/2)
                  | other_sets
                ], {new_point_a, new_point_b}}
           end}
      end
    end)

  # just check if it is just one set left
  [_] = sets

  {{x, _, _}, {y, _, _}} = last_points
  x * y
end

a.() |> IO.inspect()
b.() |> IO.inspect()
