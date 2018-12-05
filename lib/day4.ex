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
    input
    |> read_input()
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

    {minute, _} =
      asleep_range
      |> Enum.reverse()
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

    minute
  end
end

# :aoc2018 |> :code.priv_dir() |> Path.join("day4.txt") |> Day4.part1()
# :aoc2018 |> :code.priv_dir() |> Path.join("day4.txt") |> Day4.part2()
