file = "data/day04.txt"

parse = fn ->
  file
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&(&1 |> String.graphemes() |> Enum.with_index()))
  |> Stream.zip(Stream.from_index())
  |> Stream.flat_map(fn {data, y} ->
    Enum.flat_map(data, fn
      {".", _} -> []
      {item, x} -> [{{x, y}, item}]
    end)
  end)
  |> Map.new()
end

bool_to_int = fn
  false -> 0
  true -> 1
end

a = fn ->
  paper_locations = parse.() |> Map.keys() |> MapSet.new()

  Enum.filter(paper_locations, fn {x, y} ->
    adjacent =
      Enum.sum([
        bool_to_int.(MapSet.member?(paper_locations, {x - 1, y})),
        bool_to_int.(MapSet.member?(paper_locations, {x + 1, y})),
        bool_to_int.(MapSet.member?(paper_locations, {x, y - 1})),
        bool_to_int.(MapSet.member?(paper_locations, {x, y + 1})),
        bool_to_int.(MapSet.member?(paper_locations, {x - 1, y - 1})),
        bool_to_int.(MapSet.member?(paper_locations, {x + 1, y - 1})),
        bool_to_int.(MapSet.member?(paper_locations, {x - 1, y + 1})),
        bool_to_int.(MapSet.member?(paper_locations, {x + 1, y + 1}))
      ])

    adjacent < 4
  end)
  |> Enum.count()
end

b = fn ->
  paper_locations = parse.() |> Map.keys() |> MapSet.new()

  Enum.reduce_while(0..1000, {paper_locations, 0}, fn x, {paper_locations, deleted_total} ->
    to_be_removed =
      Enum.filter(paper_locations, fn {x, y} ->
        adjacent =
          Enum.sum([
            bool_to_int.(MapSet.member?(paper_locations, {x - 1, y})),
            bool_to_int.(MapSet.member?(paper_locations, {x + 1, y})),
            bool_to_int.(MapSet.member?(paper_locations, {x, y - 1})),
            bool_to_int.(MapSet.member?(paper_locations, {x, y + 1})),
            bool_to_int.(MapSet.member?(paper_locations, {x - 1, y - 1})),
            bool_to_int.(MapSet.member?(paper_locations, {x + 1, y - 1})),
            bool_to_int.(MapSet.member?(paper_locations, {x - 1, y + 1})),
            bool_to_int.(MapSet.member?(paper_locations, {x + 1, y + 1}))
          ])

        adjacent < 4
      end)
      |> MapSet.new()

    amount_to_be_removed = MapSet.size(to_be_removed)

    if amount_to_be_removed == 0 do
      {:halt, deleted_total}
    else
      new_locations = MapSet.difference(paper_locations, to_be_removed)
      {:cont, {new_locations, deleted_total + amount_to_be_removed}}
    end
  end)
end

a.() |> IO.inspect()
b.() |> IO.inspect()
