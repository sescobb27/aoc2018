defmodule Day12 do
  # Based on JEG2 Stream https://www.twitch.tv/videos/348370632
  def part1(input) do
    input
    |> read_input()
    |> parse_input()
    |> pass_20_generations()
    |> count_plants()
  end

  # Based on JEG2 Stream https://www.twitch.tv/videos/348370632
  def part2(input) do
    input
    |> read_input()
    |> parse_input()
    |> find_stability()
  end

  defp read_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp parse_input(lines) do
    Enum.reduce(lines, {MapSet.new(), MapSet.new()}, fn line, {pots, notes} = acc ->
      case line do
        <<"initial state: ", rest::binary>> ->
          new_pots =
            rest
            |> String.graphemes()
            |> Enum.with_index()
            |> Enum.filter(&match?({"#", _index}, &1))
            |> Enum.reduce(pots, fn {"#", i}, new_pots -> MapSet.put(new_pots, i) end)

          {new_pots, notes}

        _ ->
          if String.match?(line, ~r|[\.#]{5}\s+=>\s+#|) do
            note = line |> String.slice(0..4) |> String.graphemes()
            {pots, MapSet.put(notes, note)}
          else
            acc
          end
      end
    end)
  end

  defp pass_generation({pots, notes}) do
    pots |> IO.inspect()
    {leftmost, rightmost} = Enum.min_max(pots)

    new_pots =
      (leftmost - 4)..(rightmost + 4)
      |> Enum.chunk_every(5, 1, :discard)
      |> Enum.filter(fn indices ->
        plants =
          Enum.map(indices, fn i ->
            if MapSet.member?(pots, i), do: "#", else: "."
          end)

        MapSet.member?(notes, plants)
      end)
      |> Enum.map(fn indices -> Enum.at(indices, 2) end)
      |> MapSet.new()

    {new_pots, notes}
  end

  defp pass_20_generations({_pots, _notes} = state) do
    Enum.reduce(1..20, state, fn _i, new_state -> pass_generation(new_state) end)
  end

  defp count_plants({pots, _notes}) do
    Enum.sum(pots)
  end

  defp find_stability(state) do
    1..50_000_000_000
    |> Enum.reduce_while({state, 0, []}, fn i, {new_state, prev_count, differences} ->
      next_generation = pass_generation(new_state)
      count = count_plants(next_generation)
      difference = count - prev_count
      new_differences = [difference | differences]

      if length(new_differences) < 10 do
        {:cont, {next_generation, count, new_differences}}
      else
        case Enum.uniq(new_differences) do
          [n] ->
            {:halt, (50_000_000_000 - i) * n + count}

          _not_stable ->
            {:cont, {next_generation, count, Enum.take(new_differences, 10)}}
        end
      end
    end)
  end
end

# r Day12; :aoc2018 |> :code.priv_dir() |> Path.join("day12.txt") |> Day12.part1()
# r Day12; :aoc2018 |> :code.priv_dir() |> Path.join("day12.txt") |> Day12.part2()
