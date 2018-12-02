defmodule Day1 do
  def frequency(input) do
    input
    |> read_input()
    |> Enum.reduce(0, fn line, acc ->
      String.to_integer(line) + acc
    end)
  end

  def repeated_frequency(input) do
      input
      |> read_input()
      |> Stream.cycle()
      |> Enum.reduce_while({0, MapSet.new([0])}, fn line, {acc, seen} ->
        value = String.to_integer(line) + acc
        if MapSet.member?(seen, value) do
          {:halt, value}
        else
          {:cont, {value, MapSet.put(seen, value)}}
        end
      end)
  end

  defp read_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end

:aoc2018 |> :code.priv_dir() |> Path.join("day1.txt") |> Day1.frequency()
:aoc2018 |> :code.priv_dir() |> Path.join("day1.txt") |> Day1.repeated_frequency()
