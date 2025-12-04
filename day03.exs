file = "data/day03.txt"

parse = fn ->
  file
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&(&1 |> String.to_integer() |> Integer.digits()))
  |> Enum.to_list()
end

a = fn ->
  parse.()
  |> Enum.map(fn line ->
    line
    |> Enum.reduce({0, 0, line}, fn item, {first, second, [_ | tail]} ->
      if item > first and tail != [] do
        {item, Enum.max(tail), tail}
      else
        {first, second, tail}
      end
    end)
    |> then(fn {first, second, _} -> Integer.undigits([first, second]) end)
  end)
  |> Enum.sum()
end

# a.() |> IO.inspect(charlists: :as_lists)

# [8, 1, 4, 8, 3, 1, 5, 1, 8, 3, 2, 9, 1]

# starting_list = 818181911112111
# |> Integer.digits()

get_max_list_first_method = fn starting_list ->
  Enum.reduce_while(0..10000, {starting_list, 0}, fn item, {list, keep} ->
    # IO.inspect({item, {list, keep}})
    if item > 1000 do
      raise "Stuck in a loop!"
    end

    if keep > length(list) do
      raise "BIEM!"
    end

    if length(list) == 12 do
      {:halt, list |> Integer.undigits()}
    else
      # a = list |> Enum.drop(keep) |> Enum.drop(0) |> Enum.take(12 - keep) |> then(&Enum.concat(Enum.take(list, keep), &1)) |> Integer.undigits() |> IO.inspect()
      # b = list |> Enum.drop(keep) |> Enum.drop(1) |> Enum.take(12 - keep) |> then(&Enum.concat(Enum.take(list, keep), &1)) |> Integer.undigits() |> IO.inspect()
      b = list |> List.delete_at(keep)
      a = list |> Enum.take(length(b))
      # IO.inspect({Integer.undigits(a), Integer.undigits(b)})

      if a > b do
        # if the compared number is the same in both dont lock in the keep
        {:cont, {list, keep + 1}}
      else
        {:cont, {b, keep}}
      end
    end
  end)
end

make_mask = fn _ ->
  MapSet.new()
end

get_max_list_second_method = fn list ->
  mask = make_mask.(length(list))

  large_number_mask =
    Enum.reduce_while(9..0//-1, mask, fn item, mask ->
      pos_to_flip =
        list
        |> Enum.with_index()
        |> Enum.filter(fn {elem, _} -> elem == item end)
        |> Enum.map(&elem(&1, 1))

      mask =
        Enum.reduce(pos_to_flip, mask, fn pos, mask ->
          MapSet.put(mask, {pos, item})
        end)

      if MapSet.size(mask) > 12 do
        {:halt, mask}
      else
        {:cont, mask}
      end
    end)

  preprocessed =
    large_number_mask
    |> Enum.sort()
    |> Enum.map(fn {mask_pos, item} -> item end)

  # how many low numbers can be filtered
  # 54333353335
  # 55333533334
  to_be_removed = Enum.count(large_number_mask) - 12

  counter = large_number_mask |> Enum.frequencies_by(fn {_, item} -> item end)

  to_keep =
    counter
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.reduce({%{}, 0}, fn {score, amount}, {items_to_keep, counter} ->
      if counter == 12 do
        {items_to_keep, counter}
      else
        if counter + amount > 12 do
          to_keep = 12 - counter
          {Map.put(items_to_keep, score, to_keep) |> Map.put(:last, score), 12}
        else
          {Map.put(items_to_keep, score, amount), counter + amount}
        end
      end
    end)
    |> elem(0)

  # IO.inspect(to_keep)
  # IO.inspect(large_number_mask)
  rofl = Map.fetch!(to_keep, :last)
  rofl_amount = Map.fetch!(to_keep, rofl)

  # remove rofl element from mask to only keep rofl_amount
  to_delete =
    large_number_mask
    |> Enum.filter(fn {_, score} -> score == rofl end)
    |> Enum.sort()
    |> Enum.take(12 - rofl_amount)
    |> MapSet.new()

  large_number_mask
  |> MapSet.difference(to_delete)
  |> Enum.sort()
  |> Enum.map(&elem(&1, 1))
  |> Integer.undigits()
end

defmodule Day03 do
  def get_max_list(lists, 0), do: get_max_list(lists, 9)

  def get_max_list({list_front, []}, _) when length(list_front) >= 12 do
    starting_list = Enum.reverse(list_front)

    Enum.reduce_while(0..10000, {starting_list, 0}, fn item, {list, keep} ->
      if item > 1000 do
        raise "Stuck in a loop!"
      end

      cond do
        length(list) == 12 ->
          {:halt, list |> Integer.undigits()}

        keep > length(list) - 1 ->
          {:halt, list |> Enum.take(12) |> Integer.undigits()}

        true ->
          b = list |> List.delete_at(keep)
          a = list |> Enum.take(length(b))

          if a > b do
            {:cont, {list, keep + 1}}
          else
            {:cont, {b, keep}}
          end
      end
    end)
  end

  def get_max_list({list_front, list_back}, _) when length(list_front) + length(list_back) == 12,
    do: {list_front, list_back}

  def get_max_list({list_front, list_back}, score) do
    case Enum.find_index(list_back, &(&1 == score)) do
      nil ->
        get_max_list({list_front, list_back}, score - 1)

      found ->
        new_back_list = Enum.drop(list_back, found + 1)

        if length(new_back_list) < 12 - length(list_front) do
          get_max_list({list_front, list_back}, score - 1)
        else
          get_max_list({[score | list_front], new_back_list}, score)
        end
    end
  end

  # https://topaz.github.io/paste/#XQAAAQDbAgAAAAAAAAAjEkW1XgFn/E5D2tha5mUElmE4Qtzudc/PSz4FC9GlSAH6QUVmojbz+o+1P1d+/OFDNcxQ+TvD0VoJdMK4MfaTxY64WVbF06lJaru8jbyCxxD0YHVX8HZJqx0Ng1S190flsjELgWboC7ZVxZ1Mb0mGbC1HzZzDpXy/iZmg2o249hIp5BHnvsUEcWYEMBMGMbINT8xwMPVM1FnQAXhd7c+AQ06vsPslO1+bZJJaBZaJiXvtyy4x7XO6cwFR1IoY3wQNdxawRMWYj7DPqGB81D9y2/N3aIcIG4U4VaBXUMxAjluzmHbRUZiDk4jVLjeGyhpV+bMdi6XdSsYhgcq835vC5VjAaypv9RXXx+IS3KKKAmZeCj/4ENOT7XnH89XHM0sWFDpOVWQMk4+NyxUkWcOMYp48SG+dMsDHeyC63EiCebH+IK+HjqsZcQO5owZ1SBYBQualIO4PdvCqyhDSjMPIUoPyEmey3+1q4Tr/17EKIA==
  def get_max_list_python_port_solve(list, k) do
    # sorted_indices = list |> Enum.with_index() |> IO.inspect() |> Enum.sort(:desc) |> IO.inspect() |> Enum.map(&elem(&1, 1))
    sorted_indices = Range.new(0, length(list) - 1) |> Enum.sort_by(&Enum.at(list, &1), :desc)

    get_max_list_python_port_joltage(list, sorted_indices, k) |> Integer.undigits()
  end

  def get_max_list_python_port_joltage(_, _, 0), do: []

  def get_max_list_python_port_joltage(list, sorted_indices, k) do
    Enum.reduce_while(sorted_indices, [], fn i, acc ->
      rest_right = Enum.filter(sorted_indices, fn x -> x > i end)

      if length(rest_right) >= k - 1 do
        {:halt, [Enum.at(list, i) | get_max_list_python_port_joltage(list, rest_right, k - 1)]}
      else
        {:cont, acc}
      end
    end)
  end
end

get_max_list = fn list ->
  Day03.get_max_list_python_port_solve(list, 12)
end

b = fn ->
  parse.()
  |> Enum.map(&get_max_list.(&1))
  # |> IO.inspect(limit: 1_000_000)
  |> Enum.sum()
end

# a_list = mooi_lijst |> Enum.drop(0)
# b_list = mooi_lijst |> Enum.drop(1)

b.() |> IO.inspect()

# get_max_list.(
#   Integer.digits(
#     # 5_433_223_353_223_213_323_222_225_333_143_323_232_323_233_342_233_223_232_212_233_313_233_521_322_322_132_222_322_123_331_232_223_323
#     811_111_111_111_119
#   )
# )
# |> IO.inspect()

# manual = 555_533_333_333
# manuxl = 012_345_678_912

# 811_111_111_111_119
# 12_345_678_912
