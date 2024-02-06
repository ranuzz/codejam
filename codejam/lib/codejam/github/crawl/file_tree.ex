defmodule Codejam.Github.Crawl.FileTree do
  import Ecto.Query, warn: false

  def new(id, data, parent, children) do
    %Codejam.Github.Crawl.FileTreeNode{id: id, data: data, parent: parent, children: children}
  end

  def create_inodes(tree_node, parent_id, snapshot_id, organization_id) do
    {_, inode} =
      Codejam.Canvas.create_from_tree_node(
        tree_node,
        parent_id,
        snapshot_id,
        organization_id
      )

    Enum.each(tree_node.children, &create_inodes(&1, inode.id, snapshot_id, organization_id))
  end
end
