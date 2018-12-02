defmodule Day2 do
  def checksum(input) do
    {two, three} =
      input
      |> read_input()
      |> Enum.reduce({0, 0}, fn line, {appears_two_times, appears_three_times} ->
        {two_times, three_times, _} =
          line
          |> count_chars()
          |> get_checksum_values()

        {appears_two_times + two_times, appears_three_times + three_times}
      end)

    two * three
  end

  defp read_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp count_chars(line) do
    line
    |> String.graphemes()
    |> Enum.reduce(%{}, fn char, acc ->
      case acc do
        %{^char => value} ->
          Map.put(acc, char, value + 1)

        _ ->
          Map.put(acc, char, 1)
      end
    end)
  end

  defp get_checksum_values(chars) do
    Enum.reduce(chars, {0, 0, MapSet.new()}, fn {_key, value},
                                                {two_times, three_times, seen} = acc ->
      if MapSet.member?(seen, value) do
        acc
      else
        new_seen = MapSet.put(seen, value)

        case value do
          2 -> {two_times + 1, three_times, new_seen}
          3 -> {two_times, three_times + 1, new_seen}
          _ -> {two_times, three_times, new_seen}
        end
      end
    end)
  end
end

:aoc2018 |> :code.priv_dir() |> Path.join("day2.txt") |> Day2.checksum()
:aoc2018 |> :code.priv_dir() |> Path.join("day2.txt") |> Day2.checksum()
