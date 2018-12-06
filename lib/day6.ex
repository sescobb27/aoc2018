defmodule Day6 do
  def part1(input) do
    {_infinites, finites} =
      input
      |> read_input()
      |> create_grid()
      |> group_by_infinites()


    {_coordinates, layout} =
      finites
      |> Enum.group_by(fn {x, y, _dist} -> {x, y} end)
      |> Enum.max_by(fn {_, v} -> length(v) end)

    length(layout)
  end

  defp read_input(input) do
    {max_x, max_y, coordinates} =
      input
      |> File.read!()
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.reduce({-1, -1, []}, fn line, {max_x, max_y, coordinates} ->
        [x, y] = String.split(line, ", ")
        x = String.to_integer(x)
        y = String.to_integer(y)
        coordinate = {x, y}
        max_x = if x > max_x, do: x, else: max_x
        max_y = if y > max_y, do: y, else: max_y
        {max_x, max_y, [coordinate | coordinates]}
      end)

    {max_x, max_y, Enum.reverse(coordinates)}
  end

  defp create_grid({max_x, max_y, coordinates}) do
    for x <- 0..max_x,
        y <- 0..max_y do
      [{px, py, dist1}, {_, _, dist2} | _] =
        Enum.map(coordinates, fn {point_x, point_y} ->
          distance = abs(x - point_x) + abs(y - point_y)
          {point_x, point_y, distance}
        end)
        |> Enum.sort_by(fn {_, _, distance} -> distance end)

      if dist1 == dist2 do
        nil
      else
        cond do
          x == 0 ->
            {:infinite, px, py}

          x == max_x ->
            {:infinite, px, py}

          y == 0 ->
            {:infinite, px, py}

          y == max_y ->
            {:infinite, px, py}

          true ->
            {px, py, dist1}
        end
      end
    end
  end

  defp group_by_infinites(grid) do
    Enum.reduce(grid, {MapSet.new(), []}, fn
      nil, acc ->
        acc

      {:infinite, px, py}, {infinites, finites} ->
        {MapSet.put(infinites, {px, py}), finites}

      {px, py, dist}, {infinites, finites} ->
        if MapSet.member?(infinites, {px, py}) do
          {infinites, finites}
        else
          {infinites, [{px, py, dist} | finites]}
        end
    end)
  end
end

# r Day6; :aoc2018 |> :code.priv_dir() |> Path.join("day6.txt") |> Day6.part1()
# r Day6; :aoc2018 |> :code.priv_dir() |> Path.join("day6.txt") |> Day6.part2()

# input = "1, 1
# 1, 6
# 8, 3
# 3, 4
# 5, 5
# 8, 9"
# r Day6; Day6.part1(input)
