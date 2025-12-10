require Bitwise

file = "data/day10.txt"

parse_comma_separated = fn line ->
  line
  |> String.slice(1..(byte_size(line) - 2))
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)
end

parse_indicator = fn indicator ->
  indicator
  |> String.slice(1..(byte_size(indicator) - 2))
  |> String.graphemes()
  |> Enum.with_index()
  |> Map.new(fn
    {".", index} -> {index, false}
    {"#", index} -> {index, true}
  end)
end

parse = fn ->
  file
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.split(&1, " "))
  |> Enum.reduce({[], [], []}, fn data, acc ->
    [indicator | rest] = data
    {joltage, button_groups} = List.pop_at(rest, -1)

    {
      [parse_indicator.(indicator) | elem(acc, 0)],
      [Enum.map(button_groups, &parse_comma_separated.(&1)) | elem(acc, 1)],
      [parse_comma_separated.(joltage) | elem(acc, 2)]
    }
  end)
end

indicator_to_integer = fn indicator ->
  0..(map_size(indicator) - 1)
  |> Enum.reduce(0, fn x, acc ->
    if Map.fetch!(indicator, x) do
      acc + Bitwise.<<<(1, x)
    else
      acc
    end
  end)
end

button_group_to_integer = fn button_group ->
  button_group
  |> Enum.map(fn x -> Bitwise.<<<(1, x) end)
  |> Enum.sum()
end

defmodule Day10 do
  def solve_item({target, options}, acc, 0) do
    nil
  end

  def solve_item({target, options}, acc, tries) do
    if target in options do
      acc + 1
    else
      Enum.map(options, fn trying ->
        solve_item({Bitwise.bxor(target, trying), options -- [trying]}, acc + 1, tries - 1)
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.min(fn -> 99999 end)
    end
  end
end

a = fn ->
  {indicators, button_groups, _} = parse.()

  # xor numbers

  integer_indicators = Enum.map(indicators, &indicator_to_integer.(&1))

  integer_button_groups =
    button_groups |> Enum.map(fn x -> Enum.map(x, &button_group_to_integer.(&1)) end)

  integer_indicators
  |> Enum.zip(integer_button_groups)
  |> Enum.map(&Day10.solve_item(&1, 0, 8))
  |> Enum.sum()
end

# b = fn ->
#   {_, button_groups, joltage} = parse.()

# end
a.() |> IO.inspect()
