defmodule Day4_1 do
  # 1518-11-01 00:00
  @log_info ~r/\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] (.*)/
  @guard_entry ~r/Guard #(\d+) begins shift/

  def part1(input) do
    {_, _, guards} =
      input
      |> read_input()
      |> extract_logs()

    {guard_id, _time_asleep} = most_asleep(guards)
    {minute, _size} = get_most_asleep_minutes(guards[guard_id])
    minute * String.to_integer(guard_id)
  end

  def part2(input) do
    {_, _, guards} =
      input
      |> read_input()
      |> extract_logs()

    {guard_id, minute, _size} = most_times_asleep(guards)
    minute * String.to_integer(guard_id)
  end

  defp read_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def extract_logs(lines) do
    lines
    |> Enum.sort()
    |> Enum.map(fn line ->
      [_year, _month, _day, _hour, minute, message] =
        Regex.run(@log_info, line, capture: :all_but_first)

      case message do
        "falls asleep" ->
          {:sleep, String.to_integer(minute)}

        "wakes up" ->
          {:wake, String.to_integer(minute)}

        _ ->
          [guard_id] = Regex.run(@guard_entry, message, capture: :all_but_first)
          {:guard, guard_id}
      end
    end)
    |> Enum.reduce({nil, nil, %{}}, fn log, {current_guard_id, last_minute, guards} ->
      case log do
        {:guard, guard_id} ->
          {guard_id, nil, Map.put_new(guards, guard_id, [])}

        {:sleep, minute} ->
          {current_guard_id, minute, guards}

        {:wake, minute} ->
          new_range = for min <- last_minute..(minute - 1), do: min
          {current_guard_id, nil, Map.update!(guards, current_guard_id, &(&1 ++ new_range))}
      end
    end)
  end

  defp most_asleep(guards) do
    Enum.reduce(guards, {nil, 0}, fn {guard_id, sleep_range}, {_, current_bigger_time} = acc ->
      time_asleep = length(sleep_range)

      if time_asleep > current_bigger_time do
        {guard_id, time_asleep}
      else
        acc
      end
    end)
  end

  defp most_times_asleep(guards) do
    Enum.reduce(guards, {nil, 0, 0}, fn {guard_id, asleep_range},
                                        {_current_guard, _minute, max_size} = acc ->
      {minute, size} = get_most_asleep_minutes(asleep_range)

      if size > max_size do
        {guard_id, minute, size}
      else
        acc
      end
    end)
  end

  defp get_minutes_of(guard_intervals) do
    {asleep_range, []} =
      guard_intervals
      |> Enum.reduce({[], []}, fn
        {datetime, _}, {range, []} ->
          {range, [datetime.minute]}

        {datetime, _}, {range, [asleep_time]} ->
          new_range = for min <- asleep_time..(datetime.minute - 1), do: min
          {[new_range | range], []}
      end)

    {minute, _size} = get_most_asleep_minutes(asleep_range)
    minute
  end

  defp get_most_asleep_minutes(asleep_range) do
    asleep_range
    |> Enum.group_by(& &1)
    |> Enum.reduce({nil, 0}, fn {minute, occurrences}, {_, times} = acc ->
      size = length(occurrences)

      if size > times do
        {minute, size}
      else
        acc
      end
    end)
  end
end

# :aoc2018 |> :code.priv_dir() |> Path.join("day4.txt") |> Day4_1.part1()
# :aoc2018 |> :code.priv_dir() |> Path.join("day4.txt") |> Day4_1.part2()
