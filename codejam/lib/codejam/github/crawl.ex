defmodule Codejam.Github.Crawl do
  def crawl(dir) do
    crawl(dir, nil)
  end

  defp crawl(dir, parent_id) do
    cur_id = Codejam.Github.Crawl.Idgen.create_id()
    cur_file = %Codejam.Github.Crawl.FileInfo{path: dir, is_file: false, is_dir: true}

    {dirs, files} =
      File.ls!(dir)
      |> Enum.split_with(&File.dir?(Path.join(dir, &1)))

    file_nodes =
      files
      |> Enum.map(
        &Codejam.Github.Crawl.FileTree.new(
          Codejam.Github.Crawl.Idgen.create_id(),
          %Codejam.Github.Crawl.FileInfo{path: Path.join(dir, &1), is_file: true, is_dir: false},
          cur_id,
          []
        )
      )

    # dir_nodes =
    #   dirs
    #   |> Enum.map(&Path.join(dir, &1))
    #   |> Enum.reduce(acc, &crawl(&1, cur_id, &2))

    dir_nodes =
      dirs
      |> Enum.map(&Path.join(dir, &1))
      |> Enum.map(&crawl(&1, cur_id))

    Codejam.Github.Crawl.FileTree.new(cur_id, cur_file, parent_id, file_nodes ++ dir_nodes)
  end
end
