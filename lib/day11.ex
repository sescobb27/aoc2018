defmodule Day11 do
  def part1(input) do
    input
    |> read_input()
    |> compute_power_levels()
    |> max_cell()
  end

  def part2(input) do
    input
    |> read_input()
    |> compute_power_levels()
    |> max_cell_dynamic_size()
  end

  defp read_input(input) do
    input
    |> File.read!()
  end

  defp compute_power_levels(input) do
    serial_number = String.to_integer(input)

    for x <- 1..300, y <- 1..300 do
      rack_id = x + 10
      power_level = (rack_id * y + serial_number) * rack_id

      power_level =
        if power_level > 100 do
          power_level
          |> to_string()
          |> String.at(-3)
          |> String.to_integer()
        else
          0
        end

      power_level = power_level - 5
      {{x, y}, power_level}
    end
    |> Enum.into(%{})
  end

  defp max_cell(grid) do
    for size <- 0..2 do
      for x <- 1..(300 - size), y <- 1..(300 - size) do
        power_level =
          for xs <- 0..size, ys <- 0..size do
            Map.get(grid, {x + xs, y + ys}) || 0
          end
          |> Enum.sum()

        {power_level, {x, y}}
      end
    end
    |> List.flatten()
    |> Enum.max_by(fn {power_level, _} -> power_level end)
  end

  defp max_cell_dynamic_size(grid) do
    acc = {{0, 0, 0}, 0}

    Enum.reduce(1..299, acc, fn x, acc ->
      Enum.reduce(1..299, acc, fn y, acc ->
        find_largest(x, y, grid, acc)
      end)
    end)
  end

  defp find_largest(x, y, grid, acc) do
    max_square_size = min(301 - x, 301 - y)
    level = grid[{x, y}]

    {best, _} =
      Enum.reduce(2..max_square_size, {acc, level}, fn square_size,
                                                       {{_coord, prev_level} = prev, level} ->
        level = sum_square(x, y, square_size, grid, level)

        if level > prev_level do
          {{{x, y, square_size}, level}, level}
        else
          {prev, level}
        end
      end)

    best
  end

  defp sum_square(x0, y0, square_size, grid, acc) do
    y = y0 + square_size - 1

    acc =
      Enum.reduce(x0..(x0 + square_size - 2), acc, fn x, acc ->
        acc + grid[{x, y}]
      end)

    x = x0 + square_size - 1

    acc =
      Enum.reduce(y0..(y0 + square_size - 1), acc, fn y, acc ->
        acc + grid[{x, y}]
      end)

    acc
  end
end

# r Day11; :aoc2018 |> :code.priv_dir() |> Path.join("day11.txt") |> Day11.part1()
# :aoc2018 |> :code.priv_dir() |> Path.join("day11.txt") |> Day11.part2()
