file = "data/day02.txt"

parse = fn ->
  file
  |> File.read!()
  |> String.trim()
  |> String.split(",")
  |> Enum.map(fn item_range ->
    String.split(item_range, "-")
    |> Enum.map(&String.to_integer/1)
    |> then(fn [x, y] -> Range.new(x, y) end)
  end)
end

require Integer

a = fn ->
  invalid_pattern? = fn item ->
    digits = Integer.digits(item)

    if Integer.is_even(length(digits)) do
      to_check_length = Integer.floor_div(length(digits), 2)
      match?({a, a}, Enum.split(digits, to_check_length))
    else
      false
    end
  end

  parse.()
  |> Enum.map(fn range -> range |> Enum.filter(&invalid_pattern?.(&1)) |> Enum.sum() end)
  |> Enum.sum()
end

divisible_by = fn a, b -> rem(a, b) == 0 end

b = fn ->
  invalid_pattern? = fn item ->
    digits = Integer.digits(item)
    until_check_length = Integer.floor_div(length(digits), 2)
    digits_length = length(digits)

    1..until_check_length//1
    |> Enum.filter(&divisible_by.(digits_length, &1))
    |> Enum.reduce_while(false, fn size, _ ->
      {[first], rest} = digits |> Enum.chunk_every(size) |> Enum.split(1)

      if not Enum.empty?(rest) and Enum.all?(rest, &match?(^first, &1)) do
        {:halt, true}
      else
        {:cont, false}
      end
    end)
  end

  parse.()
  |> Enum.map(fn range -> range |> Stream.filter(&invalid_pattern?.(&1)) |> Enum.sum() end)
  |> Enum.sum()
end

a.() |> IO.inspect()
b.() |> IO.inspect()
