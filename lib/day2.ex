defmodule Day2 do
  def checksum(input) do
    {two, three} =
      input
      |> read_input()
      |> Enum.reduce({0, 0}, fn line, {appears_two_times, appears_three_times} ->
        {two_times, three_times, _} =
          line
          |> String.graphemes()
          |> Enum.group_by(& &1)
          |> get_checksum_values()

        {appears_two_times + two_times, appears_three_times + three_times}
      end)

    two * three
  end

  def differ(input) do
    lines = input |> read_input()

    # length(diff) == 4 # [eq: "_", del: "_", ins: "_", eq: "_"]
    for line1 <- lines,
        line2 <- lines,
        line1 != line2,
        diff = String.myers_difference(line1, line2),
        length(diff) == 4 do
      diff
      |> Keyword.get_values(:eq)
      |> Enum.join()
    end
    |> Enum.uniq()
  end

  defp read_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp get_checksum_values(groups) do
    Enum.reduce(groups, {0, 0, MapSet.new()}, fn {_key, chars},
                                                 {two_times, three_times, seen} = acc ->
      value = length(chars)

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
:aoc2018 |> :code.priv_dir() |> Path.join("day2.txt") |> Day2.differ()
