defmodule Codejam.Explorer.FileReader do
  def read(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Stream.map(fn {line, index} -> IO.puts("#{index + 1} #{line}") end)
    |> Stream.run()
  end

  def read_file_with_index(filename) do
    File.stream!(filename)
    # trim whitespace from each line (optional)
    |> Stream.map(&String.trim/1)
    # add line index as second element
    |> Stream.with_index()
    # format line with index
    |> Stream.map(fn {line, index} -> "#{index + 1}: #{line}" end)
    # convert stream to list
    |> Enum.to_list()
  end

  def read_file_with_index_map(filename) do
    File.stream!(filename)
    # trim whitespace from each line (optional)
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Stream.map(fn {line, index} ->
      {Integer.to_string(index + 1), %{raw: line, notes: [], highlighted: ""}}
    end)
    |> Enum.to_list()
  end

  def add_line_numbers(lines) do
    Stream.map(lines, & &1)
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Stream.map(fn {line, index} ->
      {Integer.to_string(index + 1), %{raw: line, notes: [], highlighted: ""}}
    end)
    |> Enum.to_list()
  end
end
