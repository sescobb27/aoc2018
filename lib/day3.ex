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

  def part2(input) do
    map =
      input
      |> read_input()
      |> extract_grid()
      |> build_keyed_map()

    {id, _} =
      for {id1, coordinates1} <- map,
          {id2, coordinates2} <- map,
          id1 != id2 do
        overlaps = MapSet.intersection(coordinates1, coordinates2)

        if MapSet.size(overlaps) != 0 do
          {id1, id2}
        else
          {id1, nil}
        end
      end
      |> Enum.group_by(fn {key, _} -> key end, fn {_, value} -> value end)
      |> Enum.find(fn {_key, overlaps} ->
        Enum.all?(overlaps, &Kernel.==(&1, nil))
      end)

    id
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

  defp build_keyed_map(grid) do
    Enum.reduce(grid, %{}, fn [id, x, y, width, height], acc ->
      coordinates =
        for x <- x..(x + width - 1),
            y <- y..(y + height - 1) do
          {x, y}
        end

      Map.put_new(acc, id, MapSet.new(coordinates))
    end)
  end
end

# :aoc2018 |> :code.priv_dir() |> Path.join("day3.txt") |> Day3.part1()
# :aoc2018 |> :code.priv_dir() |> Path.join("day3.txt") |> Day3.part2()
