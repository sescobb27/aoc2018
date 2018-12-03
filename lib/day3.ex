defmodule Day3 do
  @grid_info ~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/

  def part1(input) do
    {overlaps, _} =
      input
      |> read_input()
      |> extract_grid()
      |> build_map()
      |> Enum.reduce({MapSet.new(), MapSet.new()}, fn {x, y, _id}, {overlap, no_overlap} ->
        if MapSet.member?(no_overlap, {x, y}) do
          {MapSet.put(overlap, {x, y}), no_overlap}
        else
          {overlap, MapSet.put(no_overlap, {x, y})}
        end
      end)

    MapSet.size(overlaps)
  end

  defp read_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp extract_grid(lines) do
    Enum.map(lines, fn line ->
      [id, x, y, width, height] = Regex.run(@grid_info, line, capture: :all_but_first)

      [
        id,
        String.to_integer(x),
        String.to_integer(y),
        String.to_integer(width),
        String.to_integer(height)
      ]
    end)
  end

  defp build_map(grid) do
    Enum.flat_map(grid, fn [id, x, y, width, height] ->
      for x <- x..(x + width - 1),
          y <- y..(y + height - 1) do
        {x, y, id}
      end
    end)
  end
end

# :aoc2018 |> :code.priv_dir() |> Path.join("day3.txt") |> Day3.part1()
# :aoc2018 |> :code.priv_dir() |> Path.join("day3.txt") |> Day3.part2()
