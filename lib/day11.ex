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
    # |> File.read!()
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
    for size <- 0..300, x <- 1..(300 - size), y <- 1..(300 - size) do
      power_level =
        for xs <- 0..size, ys <- 0..size do
          Map.get(grid, {x + xs, y + ys}) || 0
        end
        |> Enum.sum()

      {power_level, {x, y}, size}
    end
    |> List.flatten()
    |> Enum.max_by(fn {power_level, _, _} -> power_level end)
  end
end

# r Day11; :aoc2018 |> :code.priv_dir() |> Path.join("day11.txt") |> Day11.part1()
# :aoc2018 |> :code.priv_dir() |> Path.join("day11.txt") |> Day11.part2()
