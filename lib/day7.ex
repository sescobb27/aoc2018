defmodule Day7 do
  @instruction_info ~r/Step (\w+) must be finished before step (\w+) can begin/
  def part1(input) do
    input
    |> read_input()
    |> parse_input()
    |> discover_dependencies([])
  end

  defp read_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp parse_input(lines) do
    Enum.reduce(lines, %{}, fn line, acc ->
      [step, dependency] = Regex.run(@instruction_info, line, capture: :all_but_first)

      acc
      |> Map.put_new(step, [])
      |> Map.update(dependency, [step], fn dependencies ->
        Enum.sort([step | dependencies])
      end)
    end)
    |> Enum.to_list()
  end

  defp discover_dependencies(deps_tree, acc) when map_size(deps_tree) == 0do
    acc |> Enum.reverse() |> Enum.join()
  end

  defp discover_dependencies(deps_tree, acc) do
    {step, []} = Enum.find(deps_tree, fn {_, deps} -> Enum.empty?(deps) end)

    new_dependencies =
      Enum.reduce(deps_tree, %{}, fn
        {^step, _}, acc -> Map.delete(acc, step)
        {other_step, deps}, acc -> Map.put_new(acc, other_step, List.delete(deps, step))
      end)

    discover_dependencies(new_dependencies, [step | acc])
  end
end

# r Day7; :aoc2018 |> :code.priv_dir() |> Path.join("day7.txt") |> Day7.part1()
# :aoc2018 |> :code.priv_dir() |> Path.join("day7.txt") |> Day7.part2()

input = "Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
Step C must be finished before step A can begin.
Step B must be finished before step E can begin.
Step A must be finished before step D can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin."

# r Day7; Day7.part1(input)
