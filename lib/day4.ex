defmodule Day4 do
  # 1518-11-01 00:00
  @log_info ~r/\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] (.*)/
  @guard_entry ~r/Guard #(\d+) begins shift/

  def part1(input) do
    {_, guards} =
      input
      |> read_input()
      |> extract_logs()
      |> Enum.reduce({nil, %{}}, fn {_datetime, log_message} = log, {current_guard, guards} ->
        Regex.run(@guard_entry, log_message, capture: :all_but_first)
        |> case do
          nil ->
            {current_guard, Map.update!(guards, current_guard, &(&1 ++ [log]))}

          [guard_id] ->
            if Map.has_key?(guards, guard_id) do
              {guard_id, guards}
            else
              {guard_id, Map.put(guards, guard_id, [])}
            end
        end
      end)

    {guard_id, _time_asleep} = most_asleep(guards)
    minute = get_minutes_of(guards[guard_id])
    minute * String.to_integer(guard_id)
  end

  def part2(input) do
    {_, guards} =
      input
      |> read_input()
      |> extract_logs()
      |> Enum.reduce({nil, %{}}, fn {_datetime, log_message} = log, {current_guard, guards} ->
        Regex.run(@guard_entry, log_message, capture: :all_but_first)
        |> case do
          nil ->
            {current_guard, Map.update!(guards, current_guard, &(&1 ++ [log]))}

          [guard_id] ->
            if Map.has_key?(guards, guard_id) do
              {guard_id, guards}
            else
              {guard_id, Map.put(guards, guard_id, [])}
            end
        end
      end)

    {guard_id, minute, _size} = most_times_asleep(guards)
    minute * String.to_integer(guard_id)
  end

  defp read_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def extract_logs(lines) do
    Enum.map(lines, fn line ->
      [year, month, day, hour, minute, message] =
        Regex.run(@log_info, line, capture: :all_but_first)

      {:ok, datetime} =
        NaiveDateTime.new(
          String.to_integer(year),
          String.to_integer(month),
          String.to_integer(day),
          String.to_integer(hour),
          String.to_integer(minute),
          0
        )

      {datetime, message}
    end)
    |> Enum.sort_by(fn {datetime, _} -> datetime end, fn d1, d2 ->
      case NaiveDateTime.compare(d1, d2) do
        :lt -> true
        :gt -> false
      end
    end)
  end

  defp most_asleep(guards) do
    Enum.reduce(guards, {nil, 0}, fn {guard_id, logs}, {_, current_bigger_time} = acc ->
      {[], time_asleep} =
        Enum.reduce(logs, {[], 0}, fn {datetime, log}, {entries, total_time} = acc ->
          cond do
            log == "falls asleep" ->
              case entries do
                [] ->
                  {[datetime | entries], total_time}

                [prev_time] ->
                  # to minutes
                  time_asleep = abs(NaiveDateTime.diff(prev_time, datetime, :seconds) / 60)
                  {[datetime], total_time + time_asleep}
              end

            log == "wakes up" ->
              [prev_time] = entries
              # to minutes
              time_asleep = abs(NaiveDateTime.diff(prev_time, datetime, :seconds) / 60)
              {[], total_time + time_asleep}

            true ->
              acc
          end
        end)

      if time_asleep > current_bigger_time do
        {guard_id, time_asleep}
      else
        acc
      end
    end)
  end

  defp most_times_asleep(guards) do
    Enum.reduce(guards, {nil, 0, 0}, fn {guard_id, logs},
                                        {_current_guard, _minute, max_size} = acc ->
      {asleep_range, []} =
        Enum.reduce(logs, {[], []}, fn {datetime, log}, {range, entries} = acc ->
          cond do
            log == "falls asleep" ->
              {range, [datetime | entries]}

            log == "wakes up" ->
              [prev_time] = entries
              # to minutes
              new_range = for min <- prev_time.minute..(datetime.minute - 1), do: min
              {[new_range | range], []}

            true ->
              acc
          end
        end)

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
    |> List.flatten()
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

# :aoc2018 |> :code.priv_dir() |> Path.join("day4.txt") |> Day4.part1()
# :aoc2018 |> :code.priv_dir() |> Path.join("day4.txt") |> Day4.part2()

input = "[1518-11-01 00:00] Guard #10 begins shift
[1518-11-01 00:05] falls asleep
[1518-11-01 00:25] wakes up
[1518-11-01 00:30] falls asleep
[1518-11-01 00:55] wakes up
[1518-11-01 23:58] Guard #99 begins shift
[1518-11-02 00:40] falls asleep
[1518-11-02 00:50] wakes up
[1518-11-03 00:05] Guard #10 begins shift
[1518-11-03 00:24] falls asleep
[1518-11-03 00:29] wakes up
[1518-11-04 00:02] Guard #99 begins shift
[1518-11-04 00:36] falls asleep
[1518-11-04 00:46] wakes up
[1518-11-05 00:03] Guard #99 begins shift
[1518-11-05 00:45] falls asleep
[1518-11-05 00:55] wakes up"
# r Day4; Day4.part2(input)
