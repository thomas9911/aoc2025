file = "data/day11.txt"

parse = fn ->
  file
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.split(&1, ": "))
  |> Stream.map(fn [key, value] -> {key, String.split(value, " ")} end)
  |> Map.new()
end

defmodule Day11 do
  def flip_it(original_data, current_key, prev) do
    geinig =
      original_data
      |> Enum.reduce(prev, fn {input, output}, acc ->
        if current_key in output do
          Map.update(acc, current_key, [input], &[input | &1])
        else
          acc
        end
      end)

    geinig
    |> Map.get(current_key, [])
    |> Enum.reject(&Map.has_key?(geinig, &1))
    |> Enum.reduce(geinig, fn x, acc ->
      flip_it(original_data, x, acc)
    end)
  end

  def find_min_steps(output_to_input, step, lookup, same?) do
    if same? do
      lookup
    else
      new_lookup =
        output_to_input
        |> Enum.reject(fn {output, _} -> Map.has_key?(lookup, output) end)
        |> Enum.flat_map(fn {output, inputs} ->
          inputs
          |> Enum.flat_map(fn input ->
            if input in Map.keys(lookup) do
              [{output, Map.fetch!(lookup, input) + 1}]
            else
              []
            end
          end)
        end)
        |> Map.new()
        |> Map.merge(lookup)

      find_min_steps(output_to_input, step + 1, new_lookup, new_lookup == lookup)
    end
  end

  def find_paths_to_you(_, _, "you"), do: [:ok]

  def find_paths_to_you(output_to_input, pid, current_key) do
    case {Agent.get(pid, fn state -> Map.fetch(state, current_key) end),
          Map.fetch(output_to_input, current_key)} do
      {{:ok, cached}, _} ->
        cached

      {_, {:ok, keys}} ->
        result =
          keys
          |> Enum.filter(&Map.has_key?(output_to_input, &1))
          |> Enum.flat_map(fn key -> find_paths_to_you(output_to_input, pid, key) end)

        :ok = Agent.update(pid, fn state -> Map.put(state, current_key, result) end)

        result

      _ ->
        []
    end
  end

  def find_paths_to_svr(_, _, "svr"), do: []

  def find_paths_to_svr(output_to_input, pid, current_key) do
    case {Agent.get(pid, fn state -> Map.fetch(state, current_key) end),
          Map.fetch(output_to_input, current_key)} do
      {{:ok, cached}, _} ->
        cached

      {_, {:ok, keys}} ->
        result =
          keys
          |> Enum.map(fn key -> [key | find_paths_to_svr(output_to_input, pid, key)] end)

        :ok = Agent.update(pid, fn state -> Map.put(state, current_key, result) end)

        result

      _ ->
        []
    end
  end
end

a = fn ->
  data = parse.()

  output_to_input = Day11.flip_it(data, "out", %{})

  {:ok, pid} = Agent.start_link(fn -> %{} end)

  Day11.find_paths_to_you(output_to_input, pid, "out") |> length()
  # steps_to_you = Day11.find_min_steps(output_to_input, 1, %{"you" => 0}, false)["out"]
end

b = fn ->
  data = parse.()
  output_to_input = Day11.flip_it(data, "out", %{}) |> IO.inspect()

  {:ok, pid} = Agent.start_link(fn -> %{} end)

  steps_to_you = Day11.find_min_steps(output_to_input, 1, %{"svr" => 0}, false)["out"]

  # Day11.find_paths_to_svr(output_to_input, pid, "fft")
  # Day11.find_paths_to_svr(output_to_input, pid, "dac")

  # Agent.get(pid, fn state -> state end) |> IO.inspect

  # Day11.find_paths_to_svr(output_to_input, pid, "out")
end

a.() |> IO.inspect()
# b.() |> IO.inspect()
