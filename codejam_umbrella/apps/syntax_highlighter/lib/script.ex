defmodule SyntaxHighlighter.Script do
  require Logger

  def main(args) do
    Logger.info("running syntax_highlighter script")

    {parsed, _, _} =
      OptionParser.parse(args, strict: [method: :string, path: :string, output: :string])

    {_, method} = Enum.find(parsed, fn {key, _} -> key == :method end)
    {_, path} = Enum.find(parsed, fn {key, _} -> key == :path end)
    {_, output} = Enum.find(parsed, fn {key, _} -> key == :output end)

    case method do
      "highlight" -> SyntaxHighlighter.highlight(path, output)
      _ -> IO.puts("not a valid method")
    end
  end
end
