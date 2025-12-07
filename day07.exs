file = "data/day07.txt"

parse = fn ->
  file
  |> File.stream!()
  |> Stream.with_index()
  |> Stream.flat_map(fn {line, line_number} ->
    line
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, column_number} ->
      case item do
        "." -> []
        "S" -> [{{column_number, line_number}, :start}]
        "^" -> [{{column_number, line_number}, :splitter}]
      end
    end)
  end)
  |> Map.new()
end

print_schema = fn schema, schematic ->
  {max_width, max_height} =
    schematic
    |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} -> {max(max_x, x), max(max_y, y)} end)

  0..max_height
  |> Enum.each(fn y ->
    0..(max_width + 1)
    |> Enum.each(fn x ->
      if Map.has_key?(schema, {x, y}) do
        IO.write("|")
      else
        if MapSet.member?(schematic, {x, y}) do
          IO.write("^")
        else
          IO.write(".")
        end
      end
    end)

    IO.puts("")
  end)

  IO.puts("")
end

a = fn ->
  {starting, schematic_map} = parse.() |> Map.split_with(fn {_, value} -> value == :start end)

  [starting_point] = Map.keys(starting)
  schematic = schematic_map |> Map.keys() |> MapSet.new()

  {max_width, max_height} =
    Enum.reduce(schematic, {0, 0}, fn {x, y}, {max_x, max_y} -> {max(max_x, x), max(max_y, y)} end)

  path =
    0..max_height
    |> Enum.reduce(%{starting_point => true}, fn y, acc ->
      Enum.reduce(0..max_width, acc, fn x, acc ->
        hit_above? = Map.has_key?(acc, {x, y - 1})

        cond do
          MapSet.member?(schematic, {x, y}) and hit_above? ->
            # passed splitter
            acc
            |> Map.put({x + 1, y}, true)
            |> Map.put({x - 1, y}, true)
            |> Map.update(:split_point, [{x, y}], &[{x, y} | &1])

          hit_above? ->
            # just pass it down
            acc
            |> Map.put({x, y}, true)

          true ->
            acc
        end
      end)
    end)

  {split_point, path} = Map.pop(path, :split_point)

  _ = path
  # print_schema.(path)
  length(split_point)
end

_b_brute_force = fn ->
  {starting, schematic_map} = parse.() |> Map.split_with(fn {_, value} -> value == :start end)

  [starting_point] = Map.keys(starting)
  schematic = schematic_map |> Map.keys() |> MapSet.new()

  {max_width, max_height} =
    Enum.reduce(schematic, {0, 0}, fn {x, y}, {max_x, max_y} -> {max(max_x, x), max(max_y, y)} end)

  path =
    0..max_height
    |> Enum.reduce([%{starting_point => true}], fn y, acc ->
      Enum.reduce(0..max_width, acc, fn x, paths ->
        Enum.reduce(paths, [], fn current_path, acc ->
          hit_above? = Map.has_key?(current_path, {x, y - 1})

          cond do
            MapSet.member?(schematic, {x, y}) and hit_above? ->
              # passed splitter
              [
                Map.put(current_path, {x + 1, y}, true),
                Map.put(current_path, {x - 1, y}, true)
                | acc
              ]

            hit_above? ->
              # just pass it down
              [Map.put(current_path, {x, y}, true) | acc]

            true ->
              [current_path | acc]
          end
        end)
      end)
    end)

  # length(path)
  Enum.map(path, &print_schema.(&1, schematic))
end

b = fn ->
  # naive would be just to multiply by 2
  # but we overshoot, we shoud subtract the paths that are the same
  # or that arent hit :thinking:
  #
  # we know who are hit because of part 1
  #
  # still overshoot by two
  # looking at brute force we dont have the any same paths... (It always concats and no recombining/merging required)
  #
  # just times two is already to low, so wrong path

  # every splitter line it multiplies by two, so if every path splits always it should be the amount of 'splitterlines' in the example 7.
  # so 1 -> 2 -> 4 -> 8 -> 16 -> 32 -> 64 -> 128 (2**7)
  # but that is too much because some paths 'fall through' or dont split again after some point.
  # how to determine which paths fall though, without going through all the paths?
  #
  # if you start at the bottom and go up and check if a endpoint is valid?
  #
  # we can also do something with even/odd (parity)
  # a splitter always flips it to another parity
  # use hint from reddit
  #
  # try: https://i.redd.it/9lxea8kv9q5g1.gif

  {starting, schematic_map} = parse.() |> Map.split_with(fn {_, value} -> value == :start end)

  [starting_point] = Map.keys(starting)
  schematic = schematic_map |> Map.keys() |> MapSet.new()

  {max_width, max_height} =
    Enum.reduce(schematic, {0, 0}, fn {x, y}, {max_x, max_y} -> {max(max_x, x), max(max_y, y)} end)

  path =
    0..max_height
    |> Enum.reduce(%{starting_point => 1}, fn y, acc_root ->
      Enum.reduce(0..max_width, acc_root, fn x, acc ->
        hit_above_count = Map.get(acc, {x, y - 1}, 0)

        cond do
          MapSet.member?(schematic, {x, y}) and hit_above_count > 0 ->
            # passed splitter
            acc
            |> Map.update({x + 1, y}, hit_above_count, &(&1 + hit_above_count))
            |> Map.update({x - 1, y}, hit_above_count, &(&1 + hit_above_count))

          hit_above_count > 0 ->
            # just pass it down
            acc
            |> Map.update({x, y}, hit_above_count, &(&1 + hit_above_count))

          true ->
            acc
        end
      end)
    end)

  path
  |> Map.filter(fn {{_, y}, _} -> y == max_height end)
  |> Map.values()
  |> Enum.sum()
end

a.() |> IO.inspect()
b.() |> IO.inspect()
# b_brute_force.()
