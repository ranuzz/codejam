defmodule Codejam.Git.Crawl.FileTree do
  import Ecto.Query, warn: false

  def new(id, data, parent, children) do
    %Codejam.Git.Crawl.FileTreeNode{id: id, data: data, parent: parent, children: children}
  end
end
