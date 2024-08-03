defmodule SyntaxHighlighter do
  @moduledoc """
  module to generate syntax highlighted HTML file
  given a raw code file, using Pyhton Pygments
  """

  def highlight(path, output_file) do
    System.cmd("pygmentize", ["-f", "html", "-g", "-o", output_file, path])
  end
end
