file = "data/day03.txt"

parse = fn ->
  file
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&(&1 |> String.to_integer() |> Integer.digits()))
  |> Enum.to_list()
end

defmodule Day03 do
  def get_largest_numbers(_, 0, out) do
    out
    |> Enum.reverse()
    |> Integer.undigits()
  end

  def get_largest_numbers(list, n, out) do
    {max_item, max_pos} =
      list
      |> Enum.take(length(list) - n + 1)
      |> Enum.with_index()
      |> Enum.max_by(&elem(&1, 0))

    get_largest_numbers(Enum.drop(list, max_pos + 1), n - 1, [max_item | out])
  end
end

a = fn ->
  parse.()
  |> Stream.map(&Day03.get_largest_numbers(&1, 2, []))
  |> Enum.sum()
end

b = fn ->
  parse.()
  |> Stream.map(&Day03.get_largest_numbers(&1, 12, []))
  |> Enum.sum()
end

a.() |> IO.inspect()
b.() |> IO.inspect()
