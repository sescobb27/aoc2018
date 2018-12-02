defmodule Day1 do
  def frequency(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn line, acc ->
      String.to_integer(line) + acc
    end)
  end
end
