defmodule Day5 do
  def part1(input) do
    input
    |> read_input()
    |> String.codepoints()
    |> reduce_polymer()
  end

  def part2(input) do
    chars =
      input
      |> read_input()
      |> String.codepoints()

    unit_types =
      chars
      |> Enum.map(&String.downcase/1)
      |> Enum.uniq()

    Enum.reduce(unit_types, 1_000_000, fn unit_type, min_size ->
      without_unit =
        Enum.reject(chars, fn char ->
          String.downcase(char) == unit_type
        end)

      min(min_size, reduce_polymer(without_unit))
    end)
  end

  defp read_input(input) do
    input
    |> File.read!()
    |> String.trim()
  end

  defp reduce_polymer(chars) do
    Enum.reduce(chars, [], fn
      char, [] ->
        [char]

      char, [last_seen | rest] = acc ->
        result =
          if char != last_seen &&
               (char == String.upcase(last_seen) || char == String.downcase(last_seen)) do
            rest
          else
            [char | acc]
          end

        result
    end)
    |> length()
  end
end

# :aoc2018 |> :code.priv_dir() |> Path.join("day5.txt") |> Day5.part1()
# :aoc2018 |> :code.priv_dir() |> Path.join("day5.txt") |> Day5.part2()

# input = "dabAcCaCBAcCcaDA"
# r Day5; Day5.part2(input)
