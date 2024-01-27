defmodule Codejam.Canvas do
  @moduledoc """
  The Canvas context.
  """

  import Ecto.Query, warn: false
  # Imports only from/2 of Ecto.Query
  import Ecto.Query, only: [from: 2]
  alias Codejam.Canvas
  alias Codejam.Repo

  alias Codejam.Canvas.{Snapshot, Inode, Note}

  @doc """
  add snapshot
  """
  def add_snapshot(branch, commit_hash, storage_path, project_id, organization_id) do
    Repo.insert(%Snapshot{
      branch: branch,
      commit_hash: commit_hash,
      storage_path: storage_path,
      project_id: project_id,
      organization_id: organization_id
    })
  end

  def create_from_tree_node(tree_node, parent_inode_id, snapshot_id, organization_id) do
    Repo.insert(%Inode{
      path: tree_node.data.path,
      name: tree_node.data.path,
      is_file: tree_node.data.is_file,
      is_dir: tree_node.data.is_dir,
      parent_inode_id: parent_inode_id,
      snapshot_id: snapshot_id,
      organization_id: organization_id
    })
  end

  def create_note(content, lines, inode_id, discussion_id, membership_id, organization_id) do
    Repo.insert(%Note{
      content: content,
      lines: lines,
      inode_id: inode_id,
      discussion_id: discussion_id,
      membership_id: membership_id,
      organization_id: organization_id
    })
  end

  def list_notes do
    [%Note{}]
  end

  def get_note(_id) do
    %Note{}
  end

  def get_file_tree(snapshot_id) do
    Repo.all(
      from ir in Canvas.Inode,
        where: ir.snapshot_id == ^snapshot_id
    )
  end

  def get_file_tree_by_parent(discussion_id, parent_id, organization_id) do
    discussion = Repo.get(Codejam.Canvas.Discussion, discussion_id)

    if is_nil(parent_id) do
      Repo.all(
        from ir in Canvas.Inode,
          where:
            ir.snapshot_id == ^discussion.snapshot_id and is_nil(ir.parent_inode_id) and
              ir.organization_id == ^organization_id
      )
    else
      Repo.all(
        from ir in Canvas.Inode,
          where:
            ir.snapshot_id == ^discussion.snapshot_id and ir.parent_inode_id == ^parent_id and
              ir.organization_id == ^organization_id
      )
    end
  end

  def get_inode(inode_id) do
    Repo.get(Codejam.Canvas.Inode, inode_id)
  end

  def get_inode_notes(inode_id) do
    Repo.all(from note in Canvas.Note, where: note.inode_id == ^inode_id)
  end

  def get_discussion_notes(discussion_id) do
    Repo.all(from note in Canvas.Note, where: note.discussion_id == ^discussion_id)
  end
end
