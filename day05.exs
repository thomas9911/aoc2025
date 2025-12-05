file = "data/day05.txt"

parse_range = fn range_text ->
  range_text
  |> String.split("-")
  |> Enum.map(&String.to_integer/1)
  |> then(fn [from, to] -> Range.new(from, to) end)
end

parse = fn ->
  all = File.read!(file) |> String.trim()

  [ranges_text, indexes_text] = String.split(all, ~r/(\r\n|\n){2}/)

  ranges =
    ranges_text
    |> String.split(~r/(\r\n|\n)/)
    |> Enum.map(&parse_range.(&1))

  indices =
    indexes_text
    |> String.split(~r/(\r\n|\n)/)
    |> Enum.map(&String.to_integer/1)

  {ranges, indices}
end

a = fn ->
  {ranges, indices} = parse.()

  Enum.reduce(indices, 0, fn item, count ->
    if Enum.any?(ranges, fn range -> Enum.member?(range, item) end) do
      count + 1
    else
      count
    end
  end)
end

defmodule Day05 do
  @doc "recursively combines the ranges until there are no changes"
  def recursively_reduce(list_of_ranges) do
    Enum.reduce(list_of_ranges, {[], 0}, fn range, {range_list, updates} ->
      {new_list, updated} = Day05.reduce_ranges([range | range_list])
      {new_list, updates + updated}
    end)
    |> case do
      {new_list, 0} -> new_list
      {new_list, _} -> recursively_reduce(new_list)
    end
  end

  def reduce_ranges([first | range_list]) do
    Enum.find_value(range_list |> Enum.with_index(), :not_found, fn {inner_range, pos} ->
      if not Range.disjoint?(first, inner_range) do
        {pos, inner_range}
      else
        false
      end
    end)
    |> case do
      :not_found ->
        {[first | range_list], 0}

      {pos, found_range} ->
        merged = merge_ranges(first, found_range)
        {List.replace_at(range_list, pos, merged), 1}
    end
  end

  defp merge_ranges(a, b) do
    # assumes the a and b an not disjoint (as in they overlap)
    a_start..a_end//1 = a
    b_start..b_end//1 = b

    Range.new(min(a_start, b_start), max(a_end, b_end))
  end
end

b = fn ->
  {ranges, _} = parse.()

  # # memory exploding method, used 24GB at the max :')
  # Enum.reduce(ranges, MapSet.new(), fn range, acc ->
  #   MapSet.union(acc, MapSet.new(range))
  # end)
  # |> MapSet.size()

  ranges
  |> Day05.recursively_reduce()
  |> Enum.map(&Range.size/1)
  |> Enum.sum()
end

a.() |> IO.inspect()
b.() |> IO.inspect()
