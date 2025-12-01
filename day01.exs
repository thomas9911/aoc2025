file = "data/day01.txt"
start = 50
dial_ticks = 100

parse = fn ->
  file
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn <<a, rest::binary>> ->
    [if(a == ?L, do: :l, else: :r), String.to_integer(rest)]
  end)
end

eucidian_rem = fn a, b ->
  cond do
    a > 0 -> rem(a, b)
    a == 0 -> 0
    a < 0 -> rem(a + b, b)
  end
end

assert = fn
  true -> raise "Will never happen"
  false -> :ok
end

a = fn ->
  rotate_dial = fn
    dial, amount, :l ->
      eucidian_rem.(dial - amount, dial_ticks)

    dial, amount, :r ->
      eucidian_rem.(dial + amount, dial_ticks)
  end

  parse.()
  |> Enum.reduce({start, 0}, fn
    [direction, amount], {dial, zero_count} ->
      new_dial = rotate_dial.(dial, amount, direction)

      zero_count =
        if new_dial == 0 do
          zero_count + 1
        else
          zero_count
        end

      {new_dial, zero_count}
  end)
  |> elem(1)
end

b = fn ->
  rotate_dial = fn
    dial, amount, :l ->
      before_rem = dial - amount
      assert.(before_rem < -(dial_ticks - 1))

      {
        eucidian_rem.(before_rem, dial_ticks),
        if(before_rem <= 0 and dial != 0, do: 1, else: 0)
      }

    dial, amount, :r ->
      before_rem = dial + amount
      assert.(before_rem > 2 * dial_ticks - 1)

      {
        eucidian_rem.(before_rem, dial_ticks),
        if(before_rem >= dial_ticks and dial != 0, do: 1, else: 0)
      }
  end

  parse.()
  |> Enum.reduce({start, 0}, fn
    [direction, amount], {dial, zero_count} ->
      extra_zeroes = Integer.floor_div(amount, dial_ticks)
      removed_extra_rotation = amount - extra_zeroes * dial_ticks
      assert.(removed_extra_rotation > dial_ticks)

      {new_dial, rolled_over} = rotate_dial.(dial, removed_extra_rotation, direction)
      {new_dial, zero_count + extra_zeroes + rolled_over}
  end)
  |> elem(1)
end

a.() |> IO.inspect()
b.() |> IO.inspect()
