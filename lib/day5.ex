defmodule Day5 do
  def part1(input) do
    input
    |> read_input()
    |> String.codepoints()
    |> Enum.reduce([], fn
      char, [] ->
        [char]

      char, [last_seen | rest] = acc ->
        result = if (char != last_seen) && (char == String.upcase(last_seen) ||
             char == String.downcase(last_seen)) do
          rest
        else
          [char | acc]
        end
        result
    end)
    |> length()
  end

  def part2(input) do
    input
    |> read_input()
  end

  defp read_input(input) do
    input
    |> File.read!()
    |> String.trim()
  end
end

# :aoc2018 |> :code.priv_dir() |> Path.join("day5.txt") |> Day5.part1()
# :aoc2018 |> :code.priv_dir() |> Path.join("day5.txt") |> Day5.part2()

# input = "dabAcCaCBAcCcaDA"
# r Day5; Day5.part2(input)
